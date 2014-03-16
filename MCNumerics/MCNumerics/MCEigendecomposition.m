//
//  EigenvalueDecomposition.m
//  MCNumerics
//
//  Created by andrew mcknight on 1/4/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <Accelerate/Accelerate.h>

#import "MCEigendecomposition.h"
#import "MCMatrix.h"
#import "MCVector.h"
#import "MCTribool.h"

@implementation MCEigendecomposition

- (instancetype)initWithMatrix:(MCMatrix *)matrix
{
    self = [super init];
    if (self) {
        if (matrix.isSymmetric.isYes) {
            int n = matrix.rows;
            int lda = n;
            double *w = malloc(n * sizeof(double));
            double *a = [matrix triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                        inStorageFormat:MCMatrixLeadingDimensionColumn
                                                      withPackingFormat:MCMatrixValuePackingFormatConventional];
            double wkopt;
            int lwork = -1;
            int iwkopt;
            int liwork = -1;
            int info;
            dsyevd_("V", "L", &n, a, &lda, w, &wkopt, &lwork, &iwkopt, &liwork, &info);
            
            lwork = (int)wkopt;
            double *work = malloc(lwork * sizeof(double));
            liwork = iwkopt;
            int *iwork = malloc(liwork * sizeof(int));
            dsyevd_("V", "L", &n, a, &lda, w, work, &lwork, iwork, &liwork, &info);
            
            if (info == 0) {
                _eigenvalues = [MCVector vectorWithValues:w length:n];
                _eigenvectors = [MCMatrix matrixWithValues:a rows:n columns:n];
            }
        } else {
            int n = matrix.rows;
            double *a = [matrix valuesInStorageFormat:MCMatrixLeadingDimensionColumn];
            int lda = n;
            double *wr= malloc(n * sizeof(double));
            double *wi= malloc(n * sizeof(double));
            double *vl= malloc(n * sizeof(double));
            int ldvl = n;
            double *vr= malloc(n * sizeof(double));
            int ldvr = n;
            int lwork = -1;
            double wkopt;
            int info;
            dgeev_("V", "V", &n, a, &lda, wr, wi, vl, &ldvl, vr, &ldvr, &wkopt, &lwork, &info);
            
            lwork = (int)wkopt;
            double *work = malloc(lwork * sizeof(double));
            dgeev_("V", "V", &n, a, &lda, wr, wi, vl, &ldvl, vr, &ldvr, work, &lwork, &info);
            
            if (info == 0) {
                _eigenvalues = [MCVector vectorWithValues:wr length:n];
                _eigenvectors = [MCMatrix matrixWithValues:vr rows:n columns:n];
            }
        }
    }
    return self;
}

+ (instancetype)eigendecompositionOfMatrix:(MCMatrix *)matrix
{
    return [[MCEigendecomposition alloc] initWithMatrix:matrix];
}

@end

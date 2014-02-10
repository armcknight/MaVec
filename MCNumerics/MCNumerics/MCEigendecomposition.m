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
            long n = matrix.rows;
            long lda = n;
            double *w = malloc(n * sizeof(double));
            double *a = [matrix triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                        inStorageFormat:MCMatrixValueStorageFormatColumnMajor
                                                      withPackingFormat:MCMatrixValuePackingFormatUnpacked];
            double wkopt;
            long lwork = -1;
            long iwkopt;
            long liwork = -1;
            long info;
            dsyevd_("V", "L", &n, a, &lda, w, &wkopt, &lwork, &iwkopt, &liwork, &info);
            
            lwork = (long)wkopt;
            double *work = malloc(lwork * sizeof(double));
            liwork = iwkopt;
            long *iwork = malloc(liwork * sizeof(long));
            dsyevd_("V", "L", &n, a, &lda, w, work, &lwork, iwork, &liwork, &info);
            
            if (info == 0) {
                _eigenvalues = [MCVector vectorWithValues:w length:n];
                _eigenvectors = [MCMatrix matrixWithValues:a rows:n columns:n];
            }
        } else {
            long n = matrix.rows;
            double *a = [matrix valuesInStorageFormat:MCMatrixValueStorageFormatColumnMajor];
            long lda = n;
            double *wr= malloc(n * sizeof(double));
            double *wi= malloc(n * sizeof(double));
            double *vl= malloc(n * sizeof(double));
            long ldvl = n;
            double *vr= malloc(n * sizeof(double));
            long ldvr = n;
            long lwork = -1;
            double wkopt;
            long info;
            dgeev_("V", "V", &n, a, &lda, wr, wi, vl, &ldvl, vr, &ldvr, &wkopt, &lwork, &info);
            
            lwork = (long)wkopt;
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

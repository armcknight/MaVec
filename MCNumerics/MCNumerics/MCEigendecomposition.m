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
            // TODO: implement non-symmetric version
//            dgeev_('V', <#char *jobvr#>, <#__CLPK_integer *n#>, <#__CLPK_doublereal *a#>, <#__CLPK_integer *lda#>, <#__CLPK_doublereal *wr#>, <#__CLPK_doublereal *wi#>, <#__CLPK_doublereal *vl#>, <#__CLPK_integer *ldvl#>, <#__CLPK_doublereal *vr#>, <#__CLPK_integer *ldvr#>, <#__CLPK_doublereal *work#>, <#__CLPK_integer *lwork#>, <#__CLPK_integer *info#>)
        }
    }
    return self;
}

+ (instancetype)eigendecompositionOfMatrix:(MCMatrix *)matrix
{
    return [[MCEigendecomposition alloc] initWithMatrix:matrix];
}

@end

//
//  MAVEigenvalueDecomposition.m
//  MaVec
//
//  Created by andrew mcknight on 1/4/14.
//
//  Copyright (c) 2014 Andrew Robert McKnight
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <Accelerate/Accelerate.h>

#import "MAVEigendecomposition.h"
#import "MAVMatrix.h"
#import "MAVVector.h"
#import "MCKTribool.h"
#import "MCKNumberFormats.h"

@implementation MAVEigendecomposition

- (instancetype)initWithMatrix:(MAVMatrix *)matrix
{
    self = [super init];
    if (self) {
        if (matrix.isSymmetric.isYes) {
            int n = matrix.rows;
            int lda = n;
            int lwork = -1;
            int iwkopt;
            int liwork = -1;
            int info;
            NSData *a = [matrix valuesFromTriangularComponent:MAVMatrixTriangularComponentLower
                                             leadingDimension:MAVMatrixLeadingDimensionColumn
                                                packingMethod:MAVMatrixValuePackingMethodConventional];
            
            if (matrix.precision == MCKValuePrecisionDouble) {
                size_t size = n * sizeof(double);
                double *w = malloc(size);
                double wkopt;
                dsyevd_("V", "L", &n, (double*)a.bytes, &lda, w, &wkopt, &lwork, &iwkopt, &liwork, &info);
                
                lwork = (int)wkopt;
                double *work = malloc(lwork * sizeof(double));
                liwork = iwkopt;
                int *iwork = malloc(liwork * sizeof(int));
                dsyevd_("V", "L", &n, (double *)a.bytes, &lda, w, work, &lwork, iwork, &liwork, &info);
                
                free(work);
                free(iwork);
                
                if (info == 0) {
                    _eigenvalues = [MAVVector vectorWithValues:[NSData dataWithBytesNoCopy:w length:size] length:n];
                    _eigenvectors = [MAVMatrix matrixWithValues:a rows:n columns:n];
                } else {
                    free(w);
                }
            } else {
                size_t size = n * sizeof(float);
                float *w = malloc(size);
                float wkopt;
                ssyevd_("V", "L", &n, (float*)a.bytes, &lda, w, &wkopt, &lwork, &iwkopt, &liwork, &info);
                
                lwork = (int)wkopt;
                float *work = malloc(lwork * sizeof(float));
                liwork = iwkopt;
                int *iwork = malloc(liwork * sizeof(int));
                ssyevd_("V", "L", &n, (float *)a.bytes, &lda, w, work, &lwork, iwork, &liwork, &info);
                
                free(work);
                free(iwork);
                
                if (info == 0) {
                    _eigenvalues = [MAVVector vectorWithValues:[NSData dataWithBytesNoCopy:w length:size] length:n];
                    _eigenvectors = [MAVMatrix matrixWithValues:a rows:n columns:n];
                } else {
                    free(w);
                }
            }
        } else {
            int n = matrix.rows;
            int lda = n;
            int ldvl = n;
            int ldvr = n;
            int lwork = -1;
            int info;
            
            NSData *a = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
            
            if (matrix.precision == MCKValuePrecisionDouble) {
                size_t size = n * sizeof(double);
                double *wr= malloc(size);
                double *wi= malloc(size);
                double *vl= malloc(n * size);
                double *vr= malloc(n * size);
                double wkopt;
                dgeev_("V", "V", &n, (double *)a.bytes, &lda, wr, wi, vl, &ldvl, vr, &ldvr, &wkopt, &lwork, &info);
                
                lwork = (int)wkopt;
                double *work = malloc(lwork * sizeof(double));
                dgeev_("V", "V", &n, (double *)a.bytes, &lda, wr, wi, vl, &ldvl, vr, &ldvr, work, &lwork, &info);
                
                free(wi);
                free(vl);
                free(work);
                
                if (info == 0) {
                    _eigenvalues = [MAVVector vectorWithValues:[NSData dataWithBytesNoCopy:wr length:size] length:n];
                    _eigenvectors = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:vr length:n * size] rows:n columns:n];
                } else {
                    free(wr);
                    free(vr);
                }
            } else {
                size_t size = n * sizeof(float);
                float *wr= malloc(size);
                float *wi= malloc(size);
                float *vl= malloc(n * size);
                float *vr= malloc(n * size);
                float wkopt;
                sgeev_("V", "V", &n, (float *)a.bytes, &lda, wr, wi, vl, &ldvl, vr, &ldvr, &wkopt, &lwork, &info);
                
                lwork = (int)wkopt;
                float *work = malloc(lwork * sizeof(float));
                sgeev_("V", "V", &n, (float *)a.bytes, &lda, wr, wi, vl, &ldvl, vr, &ldvr, work, &lwork, &info);
                
                free(wi);
                free(vl);
                free(work);
                
                if (info == 0) {
                    _eigenvalues = [MAVVector vectorWithValues:[NSData dataWithBytesNoCopy:wr length:size] length:n];
                    _eigenvectors = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:vr length:n * size] rows:n columns:n];
                } else {
                    free(wr);
                    free(vr);
                }
            }
            
        }
    }
    return self;
}

+ (instancetype)eigendecompositionOfMatrix:(MAVMatrix *)matrix
{
    return [[MAVEigendecomposition alloc] initWithMatrix:matrix];
}

@end

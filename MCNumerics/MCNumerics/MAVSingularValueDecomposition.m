//
//  MAVSingularValueDecomposition.m
//  MAVNumerics
//
//  Created by andrew mcknight on 12/15/13.
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

#import "MAVSingularValueDecomposition.h"
#import "MAVMatrix.h"
#import "MCKNumberFormats.h"

@implementation MAVSingularValueDecomposition

- (instancetype)initWithMatrix:(MAVMatrix *)matrix
{
    self = [super init];
    if (self) {
        int lwork = -1;
        int m = matrix.rows;
        int n = matrix.columns;
        int numSingularValues = MIN(m, n);
        int *iwork = malloc(8 * numSingularValues);
        int info = 0;
        
        if (matrix.precision == MCKValuePrecisionDouble) {
            double workSize;
            double *work = &workSize;
            double *singularValues = malloc(numSingularValues * sizeof(double));
            double *values = malloc(m * n * sizeof(double));
            for (int i = 0; i < m * n; i++) {
                values[i] = ((double *)matrix.values.bytes)[i];
            }
            
            size_t uSize = m * m * sizeof(double);
            size_t vTSize = n * n * sizeof(double);
            size_t sSize = m * n * sizeof(double);
            double *uValues = malloc(uSize);
            double *vTValues = malloc(vTSize);
            double *sValues = malloc(sSize);
            
            // call first with lwork = -1 to determine optimal size of working array
            dgesvd_("A", "A", &m, &n, values, &m, singularValues, uValues, &m, vTValues, &n, work, &lwork, &info);
            
            lwork = workSize;
            work = malloc(lwork * sizeof(double));
            
            // now run the actual decomposition
            dgesvd_("A", "A", &m, &n, values, &m, singularValues, uValues, &m, vTValues, &n, work, &lwork, &info);
            
            free(work);
            free(iwork);
            free(values);
            
            // build the sigma matrix
            int idx = 0;
            for (int i = 0; i < n; i++) {
                for (int j = 0; j < m; j++) {
                    if (i == j) {
                        sValues[idx] = singularValues[i];
                    } else {
                        sValues[idx] = 0.0;
                    }
                    idx++;
                }
            }
            free(singularValues);
            
            if (info == 0) {
                _u = [MAVMatrix matrixWithValues:[NSData dataWithBytes:uValues length:uSize] rows:m columns:m];
                _vT = [MAVMatrix matrixWithValues:[NSData dataWithBytes:vTValues length:vTSize] rows:n columns:n];
                _s = [MAVMatrix matrixWithValues:[NSData dataWithBytes:sValues length:sSize] rows:m columns:n];
            }
        } else {
            float workSize;
            float *work = &workSize;
            float *singularValues = malloc(numSingularValues * sizeof(float));
            float *values = malloc(m * n * sizeof(float));
            for (int i = 0; i < m * n; i++) {
                values[i] = ((float *)matrix.values.bytes)[i];
            }
            
            size_t uSize = m * m * sizeof(float);
            size_t vTSize = n * n * sizeof(float);
            size_t sSize = m * n * sizeof(float);
            float *uValues = malloc(uSize);
            float *vTValues = malloc(vTSize);
            float *sValues = malloc(sSize);
            
            // call first with lwork = -1 to determine optimal size of working array
            sgesvd_("A", "A", &m, &n, values, &m, singularValues, uValues, &m, vTValues, &n, work, &lwork, &info);
            
            lwork = workSize;
            work = malloc(lwork * sizeof(float));
            
            // now run the actual decomposition
            sgesvd_("A", "A", &m, &n, values, &m, singularValues, uValues, &m, vTValues, &n, work, &lwork, &info);
            
            free(work);
            free(iwork);
            free(values);
            
            // build the sigma matrix
            int idx = 0;
            for (int i = 0; i < n; i++) {
                for (int j = 0; j < m; j++) {
                    if (i == j) {
                        sValues[idx] = singularValues[i];
                    } else {
                        sValues[idx] = 0.0f;
                    }
                    idx++;
                }
            }
            free(singularValues);
            
            if (info == 0) {
                _u = [MAVMatrix matrixWithValues:[NSData dataWithBytes:uValues length:uSize] rows:m columns:m];
                _vT = [MAVMatrix matrixWithValues:[NSData dataWithBytes:vTValues length:vTSize] rows:n columns:n];
                _s = [MAVMatrix matrixWithValues:[NSData dataWithBytes:sValues length:sSize] rows:m columns:n];
            }
        }
    }
    return self;
}

+ (instancetype)singularValueDecompositionWithMatrix:(MAVMatrix *)matrix
{
    return [[MAVSingularValueDecomposition alloc] initWithMatrix:matrix];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MAVSingularValueDecomposition *svdCopy = [[self class] allocWithZone:zone];
    
    svdCopy->_s = _s.copy;
    svdCopy->_u = _u.copy;
    svdCopy->_vT = _vT.copy;
    
    return svdCopy;
}

@end

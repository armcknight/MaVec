//
//  MAVQRFactorization.m
//  MaVec
//
//  Created by andrew mcknight on 1/14/14.
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

#import "MAVQRFactorization.h"
#import "MAVMatrix.h"
#import "MAVMutableMatrix.h"
#import "NSNumber+MCKPrecision.h"

@interface MAVQRFactorization ()

@property (assign, nonatomic) __CLPK_integer rows;
@property (assign, nonatomic) __CLPK_integer columns;

@end

@implementation MAVQRFactorization

#pragma mark - Init

- (instancetype)initWithMatrix:(MAVMatrix *)matrix
{
    // usage can be found at http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.essl.v5r2.essl100.doc%2Fam5gr_hdgeqrf.htm
    self = [super init];
    if (self) {
        __CLPK_integer m = matrix.rows;
        __CLPK_integer n = matrix.columns;
        _rows = m;
        _columns = n;
        __CLPK_integer lwork = -1;
        __CLPK_integer info;
        NSData *values = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
        
        NSData *data;
        
        if (matrix.precision == MCKPrecisionDouble) {
            size_t size = m * m * sizeof(double);
            double *a = malloc(size);
            for (__CLPK_integer i = 0; i < m * n; i += 1) {
                a[i] = ((double *)values.bytes)[i];
            }
            __CLPK_integer lda = m;
            double *tau = malloc(MIN(m, n) * sizeof(double));
            double wkopt;
            
            // query the optimal workspace size
            dgeqrf_(&m, &n, a, &lda, tau, &wkopt, &lwork, &info);
            
            lwork = (__CLPK_integer)wkopt;
            double *work = malloc(lwork * sizeof(double));
            
            // perform the factorization
            dgeqrf_(&m, &n, a, &lda, tau, work, &lwork, &info);
            
            // extract the q matrix using dorgqr funtion - see http://www.nag.com/numeric/fl/nagdoc_fl22/xhtml/F08/f08aff.xml and http://www.netlib.org/lapack/explore-html/d9/d1d/dorgqr_8f.html
            
            // query the optimal workspace size
            lwork = -1;
            dorgqr_(&m, &m, &n, a, &lda, tau, &wkopt, &lwork, &info);
            
            // extract the matrix
            lwork = (__CLPK_integer)wkopt;
            free(work);
            work = malloc(lwork * sizeof(double));
            dorgqr_(&m, &m, &n, a, &lda, tau, work, &lwork, &info);
            
            free(tau);
            free(work);
            
            data = [NSData dataWithBytesNoCopy:a length:size];
        } else {
            size_t size = m * m * sizeof(float);
            float *a = malloc(size);
            for (__CLPK_integer i = 0; i < m * n; i += 1) {
                a[i] = ((float *)values.bytes)[i];
            }
            __CLPK_integer lda = m;
            float *tau = malloc(MIN(m, n) * sizeof(float));
            float wkopt;
            
            // query the optimal workspace size
            sgeqrf_(&m, &n, a, &lda, tau, &wkopt, &lwork, &info);
            
            lwork = (__CLPK_integer)wkopt;
            float *work = malloc(lwork * sizeof(float));
            
            // perform the factorization
            sgeqrf_(&m, &n, a, &lda, tau, work, &lwork, &info);
            
            // extract the q matrix
            
            // query the optimal workspace size
            lwork = -1;
            sorgqr_(&m, &m, &n, a, &lda, tau, &wkopt, &lwork, &info);
            
            // extract the matrix
            lwork = (__CLPK_integer)wkopt;
            free(work);
            work = malloc(lwork * sizeof(float));
            sorgqr_(&m, &m, &n, a, &lda, tau, work, &lwork, &info);
            
            free(tau);
            free(work);
            
            data = [NSData dataWithBytesNoCopy:a length:size];
        }
        
        // use output from dorgqr to build the q mcmatrix object
        _q = [MAVMatrix matrixWithValues:data rows:m columns:m leadingDimension:MAVMatrixLeadingDimensionColumn];
        
        // compute r by multiplying the transpose of q by the input matrix
        _r = [[_q.transpose mutableCopy] multiplyByMatrix:matrix];
    }
    return self;
}

+ (instancetype)qrFactorizationOfMatrix:(MAVMatrix *)matrix
{
    return [[MAVQRFactorization alloc] initWithMatrix:matrix];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Q:%@\nR:%@", self.q.description, self.r.description];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MAVQRFactorization *qrCopy = [[self class] allocWithZone:zone];
    
    qrCopy->_q = _q;
    qrCopy->_r = _r;
    qrCopy->_columns = _columns;
    qrCopy->_rows = _rows;
    
    return qrCopy;
}

#pragma mark - Operations

- (MAVQRFactorization *)thinFactorization
{
    MAVQRFactorization *thin = [self copy];
    NSMutableArray *qColumnVectors = [NSMutableArray array];
    NSMutableArray *rRowVectors = [NSMutableArray array];
    for (__CLPK_integer i = 0; i < self.columns; i += 1) {
        [qColumnVectors addObject:[self.q columnVectorForColumn:i]];
        [rRowVectors addObject:[self.r rowVectorForRow:i]];
    }
    
    thin->_q = [MAVMatrix matrixWithColumnVectors:qColumnVectors];
    thin->_r = [MAVMatrix matrixWithRowVectors:rRowVectors];
    
    return thin;
}

@end

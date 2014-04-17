//
//  MCQRFactorization.m
//  MCNumerics
//
//  Created by andrew mcknight on 1/14/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <Accelerate/Accelerate.h>

#import "MCQRFactorization.h"
#import "MCMatrix.h"
#import "MCNumberFormats.h"

@interface MCQRFactorization ()

@property (assign, nonatomic) int rows;
@property (assign, nonatomic) int columns;

@end

@implementation MCQRFactorization

#pragma mark - Init

- (instancetype)initWithMatrix:(MCMatrix *)matrix
{
    // usage can be found at http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.essl.v5r2.essl100.doc%2Fam5gr_hdgeqrf.htm
    self = [super init];
    if (self) {
        int m = matrix.rows;
        int n = matrix.columns;
        _rows = m;
        _columns = n;
        int lwork = -1;
        int info;
        NSData *values = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
        
        NSData *data;
        
        if (matrix.precision == MCValuePrecisionDouble) {
            size_t size = m * m * sizeof(double);
            double *a = malloc(size);
            for (int i = 0; i < m * n; i += 1) {
                a[i] = ((double *)values.bytes)[i];
            }
            int lda = m;
            double *tau = malloc(MIN(m, n) * sizeof(double));
            double wkopt;
            
            // query the optimal workspace size
            dgeqrf_(&m, &n, a, &lda, tau, &wkopt, &lwork, &info);
            
            lwork = wkopt;
            double *work = malloc(lwork * sizeof(double));
            
            // perform the factorization
            dgeqrf_(&m, &n, a, &lda, tau, work, &lwork, &info);
            
            // extract the q matrix using dorgqr funtion - see http://www.nag.com/numeric/fl/nagdoc_fl22/xhtml/F08/f08aff.xml and http://www.netlib.org/lapack/explore-html/d9/d1d/dorgqr_8f.html
            
            // query the optimal workspace size
            lwork = -1;
            dorgqr_(&m, &m, &n, a, &lda, tau, &wkopt, &lwork, &info);
            
            // extract the matrix
            lwork = wkopt;
            free(work);
            work = malloc(lwork * sizeof(double));
            dorgqr_(&m, &m, &n, a, &lda, tau, work, &lwork, &info);
            
            free(tau);
            free(work);
            
            data = [NSData dataWithBytes:a length:size];
        } else {
            size_t size = m * m * sizeof(float);
            float *a = malloc(size);
            for (int i = 0; i < m * n; i += 1) {
                a[i] = ((float *)values.bytes)[i];
            }
            int lda = m;
            float *tau = malloc(MIN(m, n) * sizeof(float));
            float wkopt;
            
            // query the optimal workspace size
            sgeqrf_(&m, &n, a, &lda, tau, &wkopt, &lwork, &info);
            
            lwork = wkopt;
            float *work = malloc(lwork * sizeof(float));
            
            // perform the factorization
            sgeqrf_(&m, &n, a, &lda, tau, work, &lwork, &info);
            
            // extract the q matrix
            
            // query the optimal workspace size
            lwork = -1;
            sorgqr_(&m, &m, &n, a, &lda, tau, &wkopt, &lwork, &info);
            
            // extract the matrix
            lwork = wkopt;
            free(work);
            work = malloc(lwork * sizeof(float));
            sorgqr_(&m, &m, &n, a, &lda, tau, work, &lwork, &info);
            
            free(tau);
            free(work);
            
            data = [NSData dataWithBytes:a length:size];
        }
        
        // use output from dorgqr to build the q mcmatrix object
        _q = [MCMatrix matrixWithValues:data rows:m columns:m leadingDimension:MCMatrixLeadingDimensionColumn];
        
        // compute r by multiplying the transpose of q by the input matrix
        _r = [MCMatrix productOfMatrixA:_q.transpose andMatrixB:matrix];
    }
    return self;
}

+ (instancetype)qrFactorizationOfMatrix:(MCMatrix *)matrix
{
    return [[MCQRFactorization alloc] initWithMatrix:matrix];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MCQRFactorization *qrCopy = [[self class] allocWithZone:zone];
    
    qrCopy->_q = _q;
    qrCopy->_r = _r;
    qrCopy->_columns = _columns;
    qrCopy->_rows = _rows;
    
    return qrCopy;
}

#pragma mark - Operations

- (MCQRFactorization *)thinFactorization
{
    MCQRFactorization *thin = [self copy];
    NSMutableArray *qColumnVectors = [NSMutableArray array];
    NSMutableArray *rRowVectors = [NSMutableArray array];
    for (int i = 0; i < self.columns; i += 1) {
        [qColumnVectors addObject:[self.q columnVectorForColumn:i]];
        [rRowVectors addObject:[self.r rowVectorForRow:i]];
    }
    
    thin->_q = [MCMatrix matrixWithColumnVectors:qColumnVectors];
    thin->_r = [MCMatrix matrixWithRowVectors:rRowVectors];
    
    return thin;
}

@end

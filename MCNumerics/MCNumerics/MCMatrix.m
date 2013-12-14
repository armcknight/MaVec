//
//  Matrix.m
//  AccelerometerPlot
//
//  Created by andrew mcknight on 11/30/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import "MCMatrix.h"
#import <Accelerate/Accelerate.h>

@implementation MCMatrix

#pragma mark - Constructors

- (id)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    self = [super init];
    
    if (self) {
        self.rows = rows;
        self.columns = columns;
        self.values = malloc(rows * columns * sizeof(double));
    }
    
    return self;
}

- (id)initWithValues:(double *)values
                rows:(NSUInteger)rows
             columns:(NSUInteger)columns
{
    self = [super init];
    
    if (self) {
        self.rows = rows;
        self.columns = columns;
        self.values = values;
    }
    
    return self;
}

+ (id)matrixWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    return [[MCMatrix alloc] initWithRows:rows columns:columns];
}

+ (id)matrixWithValues:(double *)values
                  rows:(NSUInteger)rows
               columns:(NSUInteger)columns
{
    return [[MCMatrix alloc] initWithValues:values
                                     rows:rows
                                  columns:columns];
}

- (void)dealloc
{
    free(self.values);
}

#pragma mark - Matrix operations

- (MCMatrix *)transpose
{
    double *tVals = malloc(self.rows * self.columns * sizeof(double));
    
    int i = 0;
    for (int j = 0; j < self.rows; j++) {
        for (int k = 0; k < self.columns; k++) {
            int idx = ((i * self.rows) % (self.columns * self.rows)) + j;
            
            tVals[i] = self.values[idx];
            
            i++;
        }
    }
    
    return [MCMatrix matrixWithValues:tVals rows:self.columns columns:self.rows];
}

- (MCMatrix *)rowMajor
{
    double *tVals = malloc(self.rows * self.columns * sizeof(double));
    
    int i = 0;
    for (int j = 0; j < self.rows; j++) {
        for (int k = 0; k < self.columns; k++) {
            int idx = ((i * self.rows) % (self.columns * self.rows)) + j;
            
            tVals[i] = self.values[idx];
            
            i++;
        }
    }
    
    return [MCMatrix matrixWithValues:tVals rows:self.rows columns:self.columns];
}

- (MCMatrix *)columnMajor
{
    double *tVals = malloc(self.rows * self.columns * sizeof(double));
    
    int i = 0;
    for (int j = 0; j < self.columns; j++) {
        for (int k = 0; k < self.rows; k++) {
            int idx = ((i * self.columns) % (self.rows * self.columns)) + j;
            
            tVals[i] = self.values[idx];
            
            i++;
        }
    }
    
    return [MCMatrix matrixWithValues:tVals rows:self.rows columns:self.columns];
}

- (MCMatrix *)minorByRemovingRow:(NSUInteger)row column:(NSUInteger)column
{
    // page 269 of Bretscher
    MCMatrix *minor = [MCMatrix matrixWithRows:self.rows - 1 columns:self.columns - 1];
    
    // TODO: implement
    @throw [NSException exceptionWithName:@"Unimplemented method" reason:@"Method not yet implemented" userInfo:nil];
    
    return minor;
}

- (double)determinant
{
    double determinant = 0.0;
    
    // TODO: implement
    @throw [NSException exceptionWithName:@"Unimplemented method" reason:@"Method not yet implemented" userInfo:nil];
    
    return determinant;
}

- (MCSingularValueDecomposition *)singularValueDecomposition
{
    /*
     examples of dgesdd_(...) usage found at
     http://software.intel.com/sites/products/documentation/doclib/mkl_sa/11/mkl_lapack_examples/lapacke_dgesdd_row.c.htm 
     and
     http://stackoverflow.com/questions/5047503/lapack-svd-singular-value-decomposition
     
     good documentation here: http://www.nag.com/numeric/FL/nagdoc_fl22/xhtml/F08/f08kdf.xml
     */
    
    double workSize;
    double *work = &workSize;
    int lwork = -1;
    int numSingularValues = (int)MIN(self.rows, self.columns);
    double *singularValues = malloc(numSingularValues * sizeof(double));
    int *iwork = malloc(8 * numSingularValues);
    int info = 0;
    int m = (int)self.rows;
    int n = (int)self.columns;
    
    MCSingularValueDecomposition *svd = [MCSingularValueDecomposition SingularValueDecompositionWithM:self.rows n:self.columns numberOfSingularValues:numSingularValues];
    
    double *values = malloc(m * n * sizeof(double));
    for (int i = 0; i < m * n; i++) {
        values[i] = self.values[i];
    }
    
    dgesdd_("A", &m, &n, values, &m, singularValues, svd.u.values, &m, svd.vT.values, &n, work, &lwork, iwork, &info);
    
    lwork = workSize;
    work = malloc(lwork * sizeof(double));
    
    dgesdd_("A", &m, &n, values, &m, singularValues, svd.u.values, &m, svd.vT.values, &n, work, &lwork, iwork, &info);
    
    free(work);
    free(iwork);
    
    // build the sigma matrix
    int idx = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            if (i == j) {
                svd.s.values[idx] = singularValues[i];
            } else {
                svd.s.values[idx] = 0.0;
            }
            idx++;
        }
    }
    
    return info == 0 ? svd : nil;
}

#pragma mark - Inspection

- (NSString *)description
{
    NSMutableString *description = [@"\n" mutableCopy];
    
    int i = 0;
    for (int j = 0; j < self.rows; j++) {
        NSMutableString *line = [NSMutableString string];
        for (int k = 0; k < self.columns; k++) {
            int idx = ((i * self.rows) % (self.columns * self.rows)) + j;
            
            NSString *string = [NSString stringWithFormat:@"%.1f", self.values[idx]];
            [line appendString:[string stringByPaddingToLength:25 withString:@" " startingAtIndex:0]];
            
            i++;
        }
        [description appendFormat:@"%@\n", line];
    }
    return description;
}

#pragma mark - Class-level matrix operations

+ (MCMatrix *)productOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB
{
    MCMatrix *product = [MCMatrix matrixWithRows:matrixA.rows columns:matrixB.columns];
    
    double *aVals = matrixA.rowMajor.values;
    double *bVals = matrixB.rowMajor.values;
    
    for (int i = 0; i < matrixA.rows; i++) {
        for (int j = 0; j < matrixB.columns; j++) {
            double val = 0.0;
            for (int k = 0; k < matrixA.columns; k++) {
                val += aVals[i * matrixA.columns + k] * bVals[k * matrixB.columns + j];
            }
            product.values[i * matrixB.columns + j] = val;
        }
    }
    
    return product.columnMajor;
}

+ (MCMatrix *)solveLinearSystemWithMatrixA:(MCMatrix *)A
                                 valuesB:(MCMatrix*)B
{
    if (A.rows == A.columns) {
        // solve for square matrix A
        
        /*
         documentation: http://www.netlib.org/lapack/double/dgesv.f
         example: http://software.intel.com/sites/products/documentation/doclib/mkl_sa/11/mkl_lapack_examples/dgesv_ex.c.htm
         */
        
        int n = A.rows;
        int nrhs = 1;
        int lda = n;
        int ldb = n;
        int info;
        int *ipiv = malloc(n * sizeof(int));
        double *a = malloc(n * n * sizeof(double));
        for (int i = 0; i < n * n; i++) {
            a[i] = A.values[i];
        }
        int nb = B.rows;
        double *b = malloc(nb * sizeof(double));
        for (int i = 0; i < nb; i++) {
            b[i] = B.values[i];
        }
        
        dgesv_(&n, &nrhs, a, &lda, ipiv, b, &ldb, &info);
        
        if (info != 0) {
            return nil;
        } else {
            MCMatrix *solution = [MCMatrix matrixWithRows:n columns:1];
            solution.values = malloc(n * sizeof(double));
            for (int i = 0; i < n; i++) {
                solution.values[i] = b[i];
            }
            return solution;
        }
    } else {
        // solve for general m x n rectangular matrix A
        
        /*
         documentation: http://www.netlib.org/lapack/double/dgels.f
         example: http://software.intel.com/sites/products/documentation/doclib/mkl_sa/11/mkl_lapack_examples/dgels_ex.c.htm
         */
        
        int m = A.rows;
        int n = A.columns;
        int nrhs = 1;
        int lda = A.rows;
        int ldb = A.rows;
        int info;
        int lwork = -1;
        double wkopt;
        double* work;
        double *a = malloc(m * n * sizeof(double));
        for (int i = 0; i < m * n; i++) {
            a[i] = A.values[i];
        }
        int nb = B.rows;
        double *b = malloc(nb * sizeof(double));
        for (int i = 0; i < nb; i++) {
            b[i] = B.values[i];
        }
        // get the optimal workspace
        dgels_("No transpose", &m, &n, &nrhs, a, &lda, b, &ldb, &wkopt, &lwork, &info);
        
        lwork = (int)wkopt;
        work = (double*)malloc(lwork * sizeof(double));
        
        // solve the system of equations
        dgels_("No transpose", &m, &n, &nrhs, a, &lda, b, &ldb, work, &lwork, &info);
        
        /*
         if  m >= n, rows 1 to n of b contain the least
            squares solution vectors; the residual sum of squares for the
            solution in each column is given by the sum of squares of
            elements N+1 to M in that column;
         if  m < n, rows 1 to n of b contain the
            minimum norm solution vectors;
         */
        if (info != 0) {
            return nil;
        } else {
            MCMatrix *solution = [MCMatrix matrixWithRows:n columns:1];
            solution.values = malloc(n * sizeof(double));
            for (int i = 0; i < n; i++) {
                solution.values[i] = b[i];
            }
            return solution;
        }
    }
}

@end

@implementation MCSingularValueDecomposition

- (id)initWithM:(NSUInteger)m n:(NSUInteger)n numberOfSingularValues:(NSUInteger)s
{
    self = [super init];
    if (self) {
        self.u = [MCMatrix matrixWithRows:m columns:m];
        self.vT = [MCMatrix matrixWithRows:n columns:n];
        self.s = [MCMatrix matrixWithRows:m columns:n];
    }
    return self;
}

+ (id)SingularValueDecompositionWithM:(NSUInteger)m n:(NSUInteger)n numberOfSingularValues:(NSUInteger)s
{
    return [[MCSingularValueDecomposition alloc] initWithM:m n:n numberOfSingularValues:s];
}

@end

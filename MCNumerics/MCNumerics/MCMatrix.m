//
//  Matrix.m
//  AccelerometerPlot
//
//  Created by andrew mcknight on 11/30/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import "MCMatrix.h"
#import "MCVector.h"
#import "MCSingularValueDecomposition.h"
#import "MCLUFactorization.h"
#import "MCEigendecomposition.h"
#import "MCQRFactorization.h"
#import "MCTribool.h"

@interface MCMatrix ()

@end

@implementation MCMatrix

@synthesize transpose = _transpose;
@synthesize qrFactorization = _qrFactorization;
@synthesize luFactorization = _luFactorization;
@synthesize singularValueDecomposition = _singularValueDecomposition;
@synthesize eigendecomposition = _eigendecomposition;
@synthesize inverse = _inverse;
@synthesize determinant = _determinant;
@synthesize conditionNumber = _conditionNumber;
@synthesize isPositiveDefinite = _isPositiveDefinite;
@synthesize isSymmetric = _isSymmetric;

#pragma mark - Constructors

- (void)commonInit
{
    _isSymmetric = [MCTribool triboolWithValue:MCTriboolIndeterminate];
    _isPositiveDefinite = [MCTribool triboolWithValue:MCTriboolIndeterminate];
    _qrFactorization = nil;
    _luFactorization = nil;
    _singularValueDecomposition = nil;
    _eigendecomposition = nil;
    _inverse = nil;
    _transpose = nil;
    _conditionNumber = nil;
    _determinant = nil;
}

- (instancetype)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    self = [super init];
    
    if (self) {
        _rows = rows;
        _columns = columns;
        _values = malloc(rows * columns * sizeof(double));
        _valueStorageFormat = MCMatrixValueStorageFormatColumnMajor;
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithRows:(NSUInteger)rows
                     columns:(NSUInteger)columns
          valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    self = [super init];
    
    if (self) {
        _rows = rows;
        _columns = columns;
        _values = malloc(rows * columns * sizeof(double));
        _valueStorageFormat = valueStorageFormat;
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithValues:(double *)values
                          rows:(NSUInteger)rows
                       columns:(NSUInteger)columns
{
    self = [super init];
    
    if (self) {
        _rows = rows;
        _columns = columns;
        _values = values;
        _valueStorageFormat = MCMatrixValueStorageFormatColumnMajor;
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithValues:(double *)values
                          rows:(NSUInteger)rows
                       columns:(NSUInteger)columns
            valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    self = [super init];
    
    if (self) {
        _rows = rows;
        _columns = columns;
        _values = values;
        _valueStorageFormat = valueStorageFormat;
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithColumnVectors:(NSArray *)columnVectors
{
    self = [super init];
    if (self) {
        _columns = columnVectors.count;
        _rows = ((MCVector *)columnVectors.firstObject).length;
        _valueStorageFormat = MCMatrixValueStorageFormatColumnMajor;
        
        _values = malloc(self.rows * self.columns * sizeof(double));
        [columnVectors enumerateObjectsUsingBlock:^(MCVector *columnVector, NSUInteger column, BOOL *stop) {
            for(int i = 0; i < self.rows; i++) {
                _values[column * self.rows + i] = [columnVector valueAtIndex:i];
            }
        }];
        
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithRowVectors:(NSArray *)rowVectors
{
    self = [super init];
    if (self) {
        _rows = rowVectors.count;
        _columns = ((MCVector *)rowVectors.firstObject).length;
        _valueStorageFormat = MCMatrixValueStorageFormatRowMajor;
        
        _values = malloc(self.rows * self.columns * sizeof(double));
        [rowVectors enumerateObjectsUsingBlock:^(MCVector *rowVector, NSUInteger row, BOOL *stop) {
            for(int i = 0; i < self.rows; i++) {
                _values[row * self.columns + i] = [rowVector valueAtIndex:i];
            }
        }];
        
        [self commonInit];
    }
    return self;
}

+ (instancetype)matrixWithColumnVectors:(NSArray *)columnVectors
{
    return [[MCMatrix alloc] initWithColumnVectors:columnVectors];
}

+ (instancetype)matrixWithRowVectors:(NSArray *)rowVectors
{
    return [[MCMatrix alloc] initWithRowVectors:rowVectors];
}

+ (instancetype)matrixWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    return [[MCMatrix alloc] initWithRows:rows columns:columns];
}

+ (instancetype)matrixWithRows:(NSUInteger)rows
                       columns:(NSUInteger)columns
            valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    return [[MCMatrix alloc] initWithRows:rows
                                  columns:columns
                       valueStorageFormat:valueStorageFormat];
}

+ (instancetype)matrixWithValues:(double *)values
                            rows:(NSUInteger)rows
                         columns:(NSUInteger)columns
{
    return [[MCMatrix alloc] initWithValues:values
                                     rows:rows
                                  columns:columns];
}

+ (instancetype)matrixWithValues:(double *)values
                            rows:(NSUInteger)rows
                         columns:(NSUInteger)columns
              valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    return [[MCMatrix alloc] initWithValues:values
                                       rows:rows
                                    columns:columns
                         valueStorageFormat:valueStorageFormat];
}

+ (instancetype)identityMatrixWithSize:(NSUInteger)size
{
    double *values = malloc(size * size * sizeof(double));
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            values[i * size + j] = i == j ? 1.0 : 0.0;
        }
    }
    return [MCMatrix matrixWithValues:values
                                 rows:size
                              columns:size];
}

+ (instancetype)diagonalMatrixWithValues:(double *)values size:(NSUInteger)size
{
    double *allValues = malloc(size * size * sizeof(double));
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            allValues[i * size + j] = i == j ? values[i] : 0.0;
        }
    }
    return [MCMatrix matrixWithValues:allValues
                                 rows:size
                              columns:size];
}

//- (void)dealloc
//{
//    if (self.values) {
//        free(self.values);
//    }
//}

#pragma mark - Lazy-loaded properties

- (MCMatrix *)transpose
{
    if (!_transpose) {
        double *aVals = self.values;
        double *tVals = malloc(self.rows * self.columns * sizeof(double));
        
        vDSP_mtransD(aVals, 1, tVals, 1, self.columns, self.rows);
        
        _transpose = [MCMatrix matrixWithValues:tVals rows:self.columns columns:self.rows];
    }
    
    return _transpose;
}

- (NSNumber *)determinant
{
    if (!_determinant) {
        _determinant = @(0.0);
        
        // TODO: implement
        @throw kMCUnimplementedMethodException;
    }
    
    return _determinant;
}

- (MCMatrix *)inverse
{
    if (!_inverse) {
        _inverse = nil;
        
        // TODO: implement
        @throw kMCUnimplementedMethodException;
    }
    
    return _inverse;
}

- (NSNumber *)conditionNumber
{
    if (!_conditionNumber) {
        _conditionNumber = @(0.0);
        
        // TODO: implement
        @throw kMCUnimplementedMethodException;
    }
    
    return _conditionNumber;
}

- (MCQRFactorization *)qrFactorization
{
    if (!_qrFactorization) {
        _qrFactorization = [MCQRFactorization qrFactorizationOfMatrix:self];
    }
    
    return _qrFactorization;
}

- (MCLUFactorization *)luFactorization
{
    if (!_luFactorization) {
        _luFactorization = [MCLUFactorization luFactorizationOfMatrix:self];
    }
    
    return _luFactorization;
}

- (MCSingularValueDecomposition *)singularValueDecomposition
{
    if (!_singularValueDecomposition) {
        _singularValueDecomposition = [MCSingularValueDecomposition singularValueDecompositionWithMatrix:self];
    }
    
    return _singularValueDecomposition;
}

- (MCEigendecomposition *)eigendecomposition
{
    if (self.rows != self.columns) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Matrix must be square to derive eigendecomposition." userInfo:nil];
    }
    
    // TODO: implement
    @throw kMCUnimplementedMethodException;
    
    if (!_eigendecomposition) {
        if (self.isSymmetric) {
            
        } else {
            
        }
    }
    
    return _eigendecomposition;
}

- (MCTribool *)isSymmetric
{
    if (_isSymmetric.triboolValue == MCTriboolIndeterminate) {
        if (self.rows != self.columns) {
            _isSymmetric = [MCTribool triboolWithValue:MCTriboolNo];
        }
        
        for (int i = 0; i < self.rows; i++) {
            for (int j = i + 1; j < self.columns; j++) {
                if ([self valueAtRow:i column:j] != [self valueAtRow:j column:i]) {
                    _isSymmetric = [MCTribool triboolWithValue:MCTriboolNo];
                }
            }
        }
        
        _isSymmetric = [MCTribool triboolWithValue:MCTriboolYes];
    }
    
    
    return _isSymmetric;
}

- (MCTribool *)isPositiveDefinite
{
    if (_isPositiveDefinite.triboolValue == MCTriboolIndeterminate) {
        
        // TODO: implement
        @throw kMCUnimplementedMethodException;
    }
    
    return _isPositiveDefinite;
}

#pragma mark - Property overrides

- (void)setValueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    if (self.valueStorageFormat != valueStorageFormat) {
        _values = [self valuesInStorageFormat:valueStorageFormat];
        _valueStorageFormat = valueStorageFormat;
    }
}

#pragma mark - Matrix operations

- (MCMatrix *)minorByRemovingRow:(NSUInteger)row column:(NSUInteger)column
{
    if (row >= self.rows) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Specified row is outside the range of possible rows." userInfo:nil];
    } else if (column >= self.columns) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Specified column is outside the range of possible columns." userInfo:nil];
    }
    
    MCMatrix *minor = [MCMatrix matrixWithRows:self.rows - 1 columns:self.columns - 1 valueStorageFormat:self.valueStorageFormat];
    
    for (int i = 0; i < self.rows; i++) {
        for (int j = 0; j < self.rows; j++) {
            if (i != row && j != column) {
                [minor setEntryAtRow:i > row ? i - 1 : i  column:j > column ? j - 1 : j toValue:[self valueAtRow:i column:j]];
            }
        }
    }
    
    return minor;
}

- (void)swapRowA:(NSUInteger)rowA withRowB:(NSUInteger)rowB
{
    if (rowA >= self.rows) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"rowA is outside the range of possible rows." userInfo:nil];
    } else if (rowB >= self.rows) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"rowB is outside the range of possible rows." userInfo:nil];
    }
    
    // TODO: implement using cblas_dswap
    
    for (int i = 0; i < self.columns; i++) {
        double temp = [self valueAtRow:rowA
                                column:i];
        [self setEntryAtRow:rowA
                     column:i
                    toValue:[self valueAtRow:rowB
                                      column:i]];
        [self setEntryAtRow:rowB
                     column:i
                    toValue:temp];
    }
}

- (void)swapColumnA:(NSUInteger)columnA withColumnB:(NSUInteger)columnB
{
    if (columnA >= self.columns) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"columnA is outside the range of possible columns." userInfo:nil];
    } else if (columnB >= self.columns) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"columnB is outside the range of possible columns." userInfo:nil];
    }
    
    // TODO: implement using cblas_dswap
    
    for (int i = 0; i < self.rows; i++) {
        double temp = [self valueAtRow:i column:columnA];
        [self setEntryAtRow:i column:columnA toValue:[self valueAtRow:i column:columnB]];
        [self setEntryAtRow:i column:columnB toValue:temp];
    }
}

#pragma mark - NSObject overrides

- (BOOL)isEqualToMatrix:(MCMatrix *)otherMatrix
{
    if (!([otherMatrix isKindOfClass:[MCMatrix class]] && self.rows == otherMatrix.rows && self.columns == otherMatrix.columns)) {
        return NO;
    } else {
        for (int row = 0; row < self.rows; row += 1) {
            for (int col = 0; col < self.columns; col += 1) {
                if ([self valueAtRow:row column:col] != [otherMatrix valueAtRow:row column:col]) {
                    return NO;
                }
            }
        }
        return YES;
    }
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    } else if (![object isKindOfClass:[MCMatrix class]]) {
        return NO;
    } else {
        return [self isEqualToMatrix:(MCMatrix *)object];
    }
}

- (NSString *)description
{
    double max = DBL_MIN;
    for (int i = 0; i < self.rows * self.columns; i++) {
        max = MAX(max, self.values[i]);
    }
    int padding = floor(log10(max)) + 5;
    
    NSMutableString *description = [@"\n" mutableCopy];
    
    int i = 0;
    for (int j = 0; j < self.rows; j++) {
        NSMutableString *line = [NSMutableString string];
        for (int k = 0; k < self.columns; k++) {
            int idx;
            
            if (self.valueStorageFormat == MCMatrixValueStorageFormatRowMajor) {
                idx = j * self.rows + k;
            } else {
                idx = ((i++ * self.rows) % (self.columns * self.rows)) + j;
            }
            
            NSString *string = [NSString stringWithFormat:@"%.1f", self.values[idx]];
            [line appendString:[string stringByPaddingToLength:padding withString:@" " startingAtIndex:0]];
        }
        [description appendFormat:@"%@\n", line];
    }
    
    return description;
}

#pragma mark - Inspection

- (double *)valuesInStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    double *copiedValues = malloc(self.rows * self.columns * sizeof(double));
    
    if (self.valueStorageFormat == valueStorageFormat) {
        for (int i = 0; i < self.rows * self.columns; i += 1) {
            copiedValues[i] = self.values[i];
        }
        return copiedValues;
    }
    
    double *tVals = malloc(self.rows * self.columns * sizeof(double));
    
    int i = 0;
    for (int j = 0; j < (valueStorageFormat == MCMatrixValueStorageFormatRowMajor ? self.rows : self.columns); j++) {
        for (int k = 0; k < (valueStorageFormat == MCMatrixValueStorageFormatRowMajor ? self.columns : self.rows); k++) {
            int idx = ((i * (valueStorageFormat == MCMatrixValueStorageFormatRowMajor ? self.rows : self.columns)) % (self.columns * self.rows)) + j;
            tVals[i] = self.values[idx];
            i++;
        }
    }
    
    return tVals;
}

- (double)valueAtRow:(NSUInteger)row column:(NSUInteger)column
{
    if (row >= self.rows) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Specified row is outside the range of possible rows." userInfo:nil];
    } else if (column >= self.columns) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Specified column is outside the range of possible columns." userInfo:nil];
    }
    
    if (self.valueStorageFormat == MCMatrixValueStorageFormatRowMajor) {
        return self.values[row * self.columns + column];
    } else {
        return self.values[column * self.rows + row];
    }
}

- (MCVector *)rowVectorForRow:(NSUInteger)row
{
    MCVector *rowVector = nil;
    
    // TODO: implement
    @throw kMCUnimplementedMethodException;
    
    return rowVector;
}

- (MCVector *)columnVectorForColumn:(NSUInteger)column
{
    MCVector *columnVector = nil;
    
    // TODO: implement
    @throw kMCUnimplementedMethodException;
    
    return columnVector;
}

#pragma mark - Mutation

- (void)setEntryAtRow:(NSUInteger)row column:(NSUInteger)column toValue:(double)value
{
    if (row >= self.rows) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Specified row is outside the range of possible rows." userInfo:nil];
    } else if (column >= self.columns) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Specified column is outside the range of possible columns." userInfo:nil];
    }
    
    if (self.valueStorageFormat == MCMatrixValueStorageFormatRowMajor) {
        self.values[row * self.columns + column] = value;
    } else {
        self.values[column * self.rows + row] = value;
    }
}

#pragma mark - Class-level matrix operations

+ (MCMatrix *)productOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB
{
    if (matrixA.columns != matrixB.rows) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"matrixA does not have an equal amount of columns as rows in matrixB" userInfo:nil];
    }
    
    double *aVals = [matrixA valuesInStorageFormat:MCMatrixValueStorageFormatRowMajor];
    double *bVals = [matrixB valuesInStorageFormat:MCMatrixValueStorageFormatRowMajor];
    double *cVals = malloc(matrixA.rows * matrixB.columns * sizeof(double));
    
    vDSP_mmulD(aVals, 1, bVals, 1, cVals, 1, matrixA.rows, matrixB.columns, matrixA.columns);
    
    return [MCMatrix matrixWithValues:cVals rows:matrixA.rows columns:matrixB.columns valueStorageFormat:MCMatrixValueStorageFormatRowMajor];
}

+ (MCMatrix *)sumOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB
{
    if (matrixA.rows != matrixB.rows) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Matrices have mismatched amounts of rows." userInfo:nil];
    } else if (matrixA.columns != matrixB.columns) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Matrices have mismatched amounts of columns." userInfo:nil];
    }
    
    MCMatrix *sum = [MCMatrix matrixWithRows:matrixA.rows columns:matrixA.columns];
    for (int i = 0; i < matrixA.rows; i++) {
        for (int j = 0; j < matrixA.columns; j++) {
            [sum setEntryAtRow:i column:j toValue:[matrixA valueAtRow:i column:j] + [matrixB valueAtRow:i column:j]];
        }
    }
    
    return sum;
}

+ (MCMatrix *)differenceOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB
{
    if (matrixA.rows != matrixB.rows) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Matrices have mismatched amounts of rows." userInfo:nil];
    } else if (matrixA.columns != matrixB.columns) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Matrices have mismatched amounts of columns." userInfo:nil];
    }
    
    MCMatrix *sum = [MCMatrix matrixWithRows:matrixA.rows columns:matrixA.columns];
    for (int i = 0; i < matrixA.rows; i++) {
        for (int j = 0; j < matrixA.columns; j++) {
            [sum setEntryAtRow:i column:j toValue:[matrixA valueAtRow:i column:j] - [matrixB valueAtRow:i column:j]];
        }
    }
    
    return sum;
}

+ (MCMatrix *)solveLinearSystemWithMatrixA:(MCMatrix *)A
                                 valuesB:(MCMatrix*)B
{
    double *aVals = [A valuesInStorageFormat:MCMatrixValueStorageFormatColumnMajor];
    
    if (A.rows == A.columns) {
        // solve for square matrix A
        
        long n = A.rows;
        long nrhs = 1;
        long lda = n;
        long ldb = n;
        long info;
        long *ipiv = malloc(n * sizeof(long));
        double *a = malloc(n * n * sizeof(double));
        for (int i = 0; i < n * n; i++) {
            a[i] = aVals[i];
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
            double *solutionValues = malloc(n * sizeof(double));
            for (int i = 0; i < n; i++) {
                solutionValues[i] = b[i];
            }
            return [MCMatrix matrixWithValues:solutionValues
                                         rows:n
                                      columns:1];
        }
    } else {
        // solve for general m x n rectangular matrix A
        
        long m = A.rows;
        long n = A.columns;
        long nrhs = 1;
        long lda = A.rows;
        long ldb = A.rows;
        long info;
        long lwork = -1;
        double wkopt;
        double* work;
        double *a = malloc(m * n * sizeof(double));
        for (int i = 0; i < m * n; i++) {
            a[i] = aVals[i];
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
            double *solutionValues = malloc(n * sizeof(double));
            for (int i = 0; i < n; i++) {
                solutionValues[i] = b[i];
            }
            return [MCMatrix matrixWithValues:solutionValues rows:n columns:1];
        }
    }
}

@end

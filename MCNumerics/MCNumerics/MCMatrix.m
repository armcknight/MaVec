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
#import "MCQuadratic.h"
#import "MCPair.h"

#import "NSNumber+MCMath.h"

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
@synthesize definiteness = _definiteness;
@synthesize isSymmetric = _isSymmetric;
@synthesize diagonalValues = _diagonalValues;
@synthesize trace = _trace;

#pragma mark - Constructors

- (void)commonInit
{
    _isSymmetric = [MCTribool triboolWithValue:MCTriboolIndeterminate];
    _definiteness = MCMatrixDefinitenessUnknown;
    _qrFactorization = nil;
    _luFactorization = nil;
    _singularValueDecomposition = nil;
    _eigendecomposition = nil;
    _inverse = nil;
    _transpose = nil;
    _conditionNumber = nil;
    _determinant = NAN;
    _diagonalValues = nil;
    _trace = NAN;
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

- (instancetype)initWithValuesInArray:(NSArray *)valuesArray
                                 rows:(NSUInteger)rows
                              columns:(NSUInteger)columns
{
    return [self initWithValuesInArray:valuesArray
                                  rows:rows
                               columns:columns
                    valueStorageFormat:MCMatrixValueStorageFormatColumnMajor];
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

- (instancetype)initWithValuesInArray:(NSArray *)valuesArray
                                 rows:(NSUInteger)rows
                              columns:(NSUInteger)columns
                   valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    double *values = malloc(valuesArray.count * sizeof(double));
    for(long idx = 0; idx < valuesArray.count; idx += 1) {
        values[idx] = [valuesArray[idx] doubleValue];
    }
    return [self initWithValues:values
                           rows:rows
                        columns:columns
             valueStorageFormat:valueStorageFormat];
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

- (instancetype)initTriangularMatrixWithValues:(double *)values
                         ofTriangularComponent:(MCMatrixTriangularComponent)triangularComponent
                               inPackingFormat:(MCMatrixValuePackingFormat)packingFormat
                          inValueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
                                       ofOrder:(NSUInteger)order
{
    if (packingFormat == MCMatrixValuePackingFormatUnpacked) {
        self = [self initWithValues:values rows:order columns:order valueStorageFormat:valueStorageFormat];
    } else {
        self = [super init];
        if (self) {
            _rows = order;
            _columns = order;
            _values = malloc(order * order * sizeof(double));
            _valueStorageFormat = valueStorageFormat;
            long k = 0; // current index in parameter array
            long z = 0; // current index in ivar array
            for (int i = 0; i < order; i += 1) {
                for (int j = 0; j < order; j += 1) {
                    BOOL shouldTakeValue = triangularComponent == MCMatrixTriangularComponentUpper ? (valueStorageFormat == MCMatrixValueStorageFormatColumnMajor ? j <= i : i <= j) : (valueStorageFormat == MCMatrixValueStorageFormatColumnMajor ? i <= j : j <= i);
                    if (shouldTakeValue) {
                        _values[z++] = values[k++];
                    } else {
                        _values[z++] = 0.0;
                    }
                }
            }
        }
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initTriangularMatrixWithValuesInArray:(NSArray *)values
                                ofTriangularComponent:(MCMatrixTriangularComponent)triangularComponent
                                      inPackingFormat:(MCMatrixValuePackingFormat)packingFormat
                                 inValueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    NSUInteger length = values.count;
    MCPair *orderCandidates = [MCQuadratic quadraticWithA:@1 b:@1 c:@(length)].roots;
    NSUInteger order = [orderCandidates.first isPositive] ? orderCandidates.first.integerValue : orderCandidates.second.integerValue;
    double *valuesCArray = malloc(length * sizeof(double));
    for (int i = 0; i < length; i += 1) {
        valuesCArray[i] = [[values objectAtIndex:i] doubleValue];
    }
    return [self initTriangularMatrixWithValues:valuesCArray
                          ofTriangularComponent:triangularComponent
                                inPackingFormat:packingFormat
                           inValueStorageFormat:valueStorageFormat
                                        ofOrder:order];
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

+ (instancetype)matrixWithValuesInArray:(NSArray *)valuesArray
                                   rows:(NSUInteger)rows
                                columns:(NSUInteger)columns
{
    return [[MCMatrix alloc] initWithValuesInArray:valuesArray
                                              rows:rows
                                           columns:columns];
}

+ (instancetype)matrixWithValuesInArray:(NSArray *)valuesArray
                                   rows:(NSUInteger)rows
                                columns:(NSUInteger)columns
                     valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    return [[MCMatrix alloc] initWithValuesInArray:valuesArray
                                              rows:rows
                                           columns:columns
                                valueStorageFormat:valueStorageFormat];
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

+ (instancetype)triangularMatrixWithValues:(double *)values
                     ofTriangularComponent:(MCMatrixTriangularComponent)triangularComponent
                           inPackingFormat:(MCMatrixValuePackingFormat)packingFormat
                      inValueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
                                   ofOrder:(NSUInteger)order
{
    return [[MCMatrix alloc] initTriangularMatrixWithValues:values
                                      ofTriangularComponent:triangularComponent
                                            inPackingFormat:packingFormat
                                       inValueStorageFormat:valueStorageFormat
                                                    ofOrder:order];
}

+ (instancetype)triangularMatrixWithValuesInArray:(NSArray *)values
                            ofTriangularComponent:(MCMatrixTriangularComponent)triangularComponent
                                  inPackingFormat:(MCMatrixValuePackingFormat)packingFormat
                             inValueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    return [[MCMatrix alloc] initTriangularMatrixWithValuesInArray:values
                                             ofTriangularComponent:triangularComponent
                                                   inPackingFormat:packingFormat
                                              inValueStorageFormat:valueStorageFormat];
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

- (double)determinant
{
    if (isnan(_determinant)) {
        if (_rows == 2 && _columns == 2) {
            double a = self[0][0].doubleValue;
            double b = self[0][1].doubleValue;
            double c = self[1][0].doubleValue;
            double d = self[1][1].doubleValue;
            
            _determinant = a * d - b * c;
        } else if (_rows == 3 && _columns == 3) {
            double a = self[0][0].doubleValue;
            double b = self[0][1].doubleValue;
            double c = self[0][2].doubleValue;
            double d = self[1][0].doubleValue;
            double e = self[1][1].doubleValue;
            double f = self[1][2].doubleValue;
            double g = self[2][0].doubleValue;
            double h = self[2][1].doubleValue;
            double i = self[2][2].doubleValue;
            
            _determinant = a * e * i + b * f * g + c * d * h - g * e * c - h * f * a - i * d * b;
        } else {
            _determinant = self.luFactorization.upperTriangularMatrix.diagonalValues.productOfValues * pow(-1.0, self.luFactorization.numberOfPermutations);
        }
    }
    
    return _determinant;
}

- (MCMatrix *)inverse
{
    if (!_inverse) {
        if (_rows == _columns) {
            double *a = [self valuesInStorageFormat:MCMatrixValueStorageFormatColumnMajor];
            
            long m = _rows;
            long n = _columns;
            
            long lda = m;
            
            long *ipiv = malloc(MIN(m, n) * sizeof(long));
            
            long info = 0;
            
            // compute factorization
            dgetrf_(&m, &n, a, &lda, ipiv, &info);
        
            double wkopt;
            long lwork = -1;
            
            // query optimal workspace size
            dgetri_(&m, a, &lda, ipiv, &wkopt, &lwork, &info);
            
            lwork = wkopt;
            double *work = malloc(lwork * sizeof(double));
            
            // calculate the inverse
            dgetri_(&m, a, &lda, ipiv, work, &lwork, &info);
            
            _inverse = [MCMatrix matrixWithValues:a
                                             rows:_rows
                                          columns:_columns
                               valueStorageFormat:MCMatrixValueStorageFormatColumnMajor];
        }
    }
    
    return _inverse;
}

- (MCMatrix *)adjugate
{
    if (!_adjugate) {
        
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
    
    if (!_eigendecomposition) {
        _eigendecomposition = [MCEigendecomposition eigendecompositionOfMatrix:self];
    }
    
    return _eigendecomposition;
}

- (MCTribool *)isSymmetric
{
    if (_isSymmetric.triboolValue == MCTriboolIndeterminate) {
        if (self.rows != self.columns) {
            _isSymmetric = [MCTribool triboolWithValue:MCTriboolNo];
            return _isSymmetric;
        } else {
            _isSymmetric = [MCTribool triboolWithValue:MCTriboolYes];
        }
        
        for (int i = 0; i < self.rows; i++) {
            for (int j = i + 1; j < self.columns; j++) {
                if ([self valueAtRow:i column:j] != [self valueAtRow:j column:i]) {
                    _isSymmetric = [MCTribool triboolWithValue:MCTriboolNo];
                    return _isSymmetric;
                }
            }
        }
    }
    
    return _isSymmetric;
}

- (MCMatrixDefiniteness)definiteness
{
    if (_definiteness == MCMatrixDefinitenessUnknown) {
        @throw kMCUnimplementedMethodException;
        // TODO: implement
    }
    return _definiteness;
}

- (MCVector *)diagonalValues
{
    if (!_diagonalValues) {
        long length = MIN(self.rows, self.columns);
        double *values = malloc(length * sizeof(double));
        for (int i = 0; i < length; i += 1) {
            values[i] = [self valueAtRow:i column:i];
        }
        _diagonalValues = [MCVector vectorWithValues:values length:length inVectorFormat:MCVectorFormatRowVector];
    }
    return _diagonalValues;
}

- (double)trace
{
    if (isnan(_trace)) {
        _trace = self.diagonalValues.sumOfValues;
    }
    return _trace;
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
        max = MAX(max, fabs(self.values[i]));
    }
    int padding = floor(log10(max)) + 5;
    
    NSMutableString *description = [@"\n" mutableCopy];
    
    for (int j = 0; j < self.rows; j++) {
        NSMutableString *line = [NSMutableString string];
        for (int k = 0; k < self.columns; k++) {
            double value = [self valueAtRow:j column:k];
            NSString *string = [NSString stringWithFormat:@"%.1f", value];
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

- (double *)triangularValuesFromTriangularComponent:(MCMatrixTriangularComponent)triangularComponent
                                    inStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
                                  withPackingFormat:(MCMatrixValuePackingFormat)packingFormat
{
    if (self.rows != self.columns) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot extract triangular components from non-square matrices" userInfo:nil];
    }
    
    int numberOfValues = packingFormat == MCMatrixValuePackingFormatPacked ? ((self.rows * (self.rows + 1)) / 2) : self.rows * self.rows;
    double *values = malloc(numberOfValues * sizeof(double));
    
    int i = 0;
    int outerLimit = self.valueStorageFormat == MCMatrixValueStorageFormatRowMajor ? self.rows : self.columns;
    int innerLimit = self.valueStorageFormat == MCMatrixValueStorageFormatRowMajor ? self.columns : self.rows;
    
    for (int j = 0; j < outerLimit; j++) {
        for (int k = 0; k < innerLimit; k++) {
            int row = valueStorageFormat == MCMatrixValueStorageFormatRowMajor ? j : k;
            int col = valueStorageFormat == MCMatrixValueStorageFormatRowMajor ? k : j;
            
            BOOL shouldStoreValueForLowerTriangle = triangularComponent == MCMatrixTriangularComponentLower && col <= row;
            BOOL shouldStoreValueForUpperTriangle = triangularComponent == MCMatrixTriangularComponentUpper && row <= col;
            
            if (shouldStoreValueForLowerTriangle || shouldStoreValueForUpperTriangle) {
                double value = [self valueAtRow:row column:col];
                values[i++] = value;
            } else if (packingFormat == MCMatrixValuePackingFormatUnpacked) {
                values[i++] = 0.0;
            }
        }
    }
    
    return values;
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
    double *values = malloc(self.columns * sizeof(double));
    for (int col = 0; col < self.columns; col += 1) {
        values[col] = [self valueAtRow:row column:col];
    }
    
    return [MCVector vectorWithValues:values length:self.columns inVectorFormat:MCVectorFormatRowVector];
}

- (MCVector *)columnVectorForColumn:(NSUInteger)column
{
    double *values = malloc(self.rows * sizeof(double));
    for (int row = 0; row < self.rows; row += 1) {
        values[row] = [self valueAtRow:row column:column];
    }
    
    return [MCVector vectorWithValues:values length:self.rows inVectorFormat:MCVectorFormatColumnVector];
}

#pragma mark - Subscripting

- (MCVector *)objectAtIndexedSubscript:(NSUInteger)idx
{
    return [self rowVectorForRow:idx];
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

+ (MCVector *)productOfMatrix:(MCMatrix *)matrix andVector:(MCVector *)vector
{
    short order = matrix.valueStorageFormat == MCMatrixValueStorageFormatColumnMajor ? CblasColMajor : CblasRowMajor;
    short transpose = CblasNoTrans;
    int rows = matrix.rows;
    int cols = matrix.columns;
    double *result = malloc(vector.length * sizeof(double));
    for (int i = 0; i < vector.length; i += 1) {
        result[i] = 0.0;
    }
    cblas_dgemv(order, transpose, rows, cols, 1.0, matrix.values, rows, vector.values, 1, 1.0, result, 1);
    return [MCVector vectorWithValues:result length:vector.length];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MCMatrix *matrixCopy = [[self class] allocWithZone:zone];
    
    matrixCopy->_columns = self.columns;
    matrixCopy->_rows = self.rows;
    matrixCopy->_valueStorageFormat = self.valueStorageFormat;
    
    matrixCopy->_values = malloc(self.rows * self.columns * sizeof(double));
    for (int i = 0; i < self.rows * self.columns; i += 1) {
        matrixCopy->_values[i] = self.values[i];
    }
    
    if (_transpose) {
        matrixCopy->_transpose = _transpose.copy;
    }
    
    matrixCopy->_determinant = _determinant;
    
    if (_inverse) {
        matrixCopy->_inverse = _inverse.copy;
    }
    
    if (_conditionNumber) {
        matrixCopy->_conditionNumber = _conditionNumber.copy;
    }
    
    if (_qrFactorization) {
        matrixCopy->_qrFactorization = _qrFactorization.copy;
    }
    
    if (_luFactorization) {
        matrixCopy->_luFactorization = _luFactorization.copy;
    }
    
    if (_singularValueDecomposition) {
        matrixCopy->_singularValueDecomposition = _singularValueDecomposition.copy;
    }
    
    if (_eigendecomposition) {
        matrixCopy->_eigendecomposition = _eigendecomposition.copy;
    }
    
    if (_diagonalValues) {
        matrixCopy->_diagonalValues = _diagonalValues.copy;
    }
    
    matrixCopy->_isSymmetric = _isSymmetric.copy;
    matrixCopy->_definiteness = _definiteness;
    matrixCopy->_trace = _trace;
    
    return matrixCopy;
}

@end

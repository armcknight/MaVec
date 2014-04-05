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

typedef enum : UInt8 {
    /**
     The maximum absolute column sum of the matrix.
     */
    MCMatrixNormL1,
    
    /**
     The maximum absolute row sum of the matrix.
     */
    MCMatrixNormInfinity,
    
    /**
     The maximum value of all entries in the matrix.
     */
    MCMatrixNormMax,
    
    /**
     Square root of the sum of the squared values in the matrix.
     */
    MCMatrixNormFroebenius
}
/**
 Constants describing types of matrix norms.
 */
MCMatrixNorm;

@interface MCMatrix ()

// public readonly properties redeclared as readwrite
@property (strong, readwrite, nonatomic) MCMatrix *transpose;
@property (strong, readwrite, nonatomic) MCQRFactorization *qrFactorization;
@property (strong, readwrite, nonatomic) MCLUFactorization *luFactorization;
@property (strong, readwrite, nonatomic) MCSingularValueDecomposition *singularValueDecomposition;
@property (strong, readwrite, nonatomic) MCEigendecomposition *eigendecomposition;
@property (strong, readwrite, nonatomic) MCMatrix *inverse;
@property (assign, readwrite, nonatomic) double determinant;
@property (assign, readwrite, nonatomic) double conditionNumber;
@property (assign, readwrite, nonatomic) MCMatrixDefiniteness definiteness;
@property (strong, readwrite, nonatomic) MCTribool *isSymmetric;
@property (strong, readwrite, nonatomic) MCVector *diagonalValues;
@property (assign, readwrite, nonatomic) double trace;
@property (strong, readwrite, nonatomic) MCMatrix *adjugate;
@property (strong, readwrite, nonatomic) MCMatrix *minorMatrix;
@property (strong, readwrite, nonatomic) MCMatrix *cofactorMatrix;
@property (assign, readwrite, nonatomic) double normL1;
@property (assign, readwrite, nonatomic) double normInfinity;
@property (assign, readwrite, nonatomic) double normFroebenius;
@property (assign, readwrite, nonatomic) double normMax;
@property (assign, readwrite, nonatomic) MCMatrixTriangularComponent triangularComponent;

// private properties for band matrices
@property (assign, nonatomic) int bandwidth;
@property (assign, nonatomic) int numberOfBandValues;
@property (assign, nonatomic) BOOL evenAmountOfCodiagonals;

/**
 @brief Generates specified number of floating-point values.
 @param size Amount of random values to generate.
 @return C array point containing specified number of random values.
 */
+ (double *)randomArrayOfSize:(int)size;

/**
 @brief Sets all properties to default states.
 @return A new instance of MCMatrix in a default state with no values or row/column counts.
 */
- (instancetype)init;

/**
 @description Documentation on usage and other details can be found at http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.essl.v5r2.essl100.doc%2Fam5gr_llange.htm. More information about different matrix norms can be found at http://en.wikipedia.org/wiki/Matrix_norm.
 @brief Compute the desired norm of this matrix.
 @param normType The type of norm to compute.
 @return The calculated norm of desired type of this matrix as a floating-point value.
 */
- (double)normOfType:(MCMatrixNorm)normType;

/**
 @return The array representation of this band matrix in conventional packing format (all values including out-of-band zeroes). (Currently only returns column-major format.)
 */
// TODO: accept a parameter for leading dimension
- (double *)unpackedValuesFromBandValues;

/**
 @brief Get the array representation of this triangular or symmetric matrix in conventional packing format (all values including opposite triangular component's zeroes).
 @param leadingDimension The leading dimension the returned array should be flattened with.
 */
- (double *)unpackedArrayFromPackedArrayWithLeadingDimension:(MCMatrixLeadingDimension)leadingDimension;

@end

@implementation MCMatrix

#pragma mark - Constructors

- (instancetype)initWithValues:(double *)values
                          rows:(int)rows
                       columns:(int)columns
              leadingDimension:(MCMatrixLeadingDimension)leadingDimension
                 packingMethod:(MCMatrixValuePackingMethod)packingMethod
           triangularComponent:(MCMatrixTriangularComponent)triangularComponent
{
    self = [self init];
    if (self) {
        _leadingDimension = leadingDimension;
        _packingMethod = packingMethod;
        _triangularComponent = triangularComponent;
        _values = values;
        _rows = rows;
        _columns = columns;
    }
    return self;
}

#pragma mark - Class constructors

+ (instancetype)matrixWithColumnVectors:(NSArray *)columnVectors
{
    int columns = (int)columnVectors.count;
    int rows = ((MCVector *)columnVectors.firstObject).length;
    double *values = malloc(rows * columns * sizeof(double));
    [columnVectors enumerateObjectsUsingBlock:^(MCVector *columnVector, NSUInteger column, BOOL *stop) {
        for(int i = 0; i < rows; i++) {
            values[column * rows + i] = [columnVector valueAtIndex:i];
        }
    }];
    return [[MCMatrix alloc] initWithValues:values
                                       rows:rows
                                    columns:columns
                           leadingDimension:MCMatrixLeadingDimensionColumn
                              packingMethod:MCMatrixValuePackingMethodConventional
                        triangularComponent:MCMatrixTriangularComponentBoth];
}

+ (instancetype)matrixWithRowVectors:(NSArray *)rowVectors
{
    int rows = (int)rowVectors.count;
    int columns = ((MCVector *)rowVectors.firstObject).length;
    double *values = malloc(rows * columns * sizeof(double));
    [rowVectors enumerateObjectsUsingBlock:^(MCVector *rowVector, NSUInteger row, BOOL *stop) {
        for(int i = 0; i < columns; i++) {
            values[row * columns + i] = [rowVector valueAtIndex:i];
        }
    }];
    return [[MCMatrix alloc] initWithValues:values
                                       rows:rows
                                    columns:columns
                           leadingDimension:MCMatrixLeadingDimensionRow
                              packingMethod:MCMatrixValuePackingMethodConventional
                        triangularComponent:MCMatrixTriangularComponentBoth];
}

+ (instancetype)matrixWithRows:(int)rows
                       columns:(int)columns
{
    return [[MCMatrix alloc] initWithValues:malloc(rows * columns * sizeof(double))
                                       rows:rows
                                    columns:columns
                           leadingDimension:MCMatrixLeadingDimensionColumn
                              packingMethod:MCMatrixValuePackingMethodConventional
                        triangularComponent:MCMatrixTriangularComponentBoth];
}

+ (instancetype)matrixWithRows:(int)rows
                       columns:(int)columns
              leadingDimension:(MCMatrixLeadingDimension)leadingDimension
{
    return [[MCMatrix alloc] initWithValues:malloc(rows * columns * sizeof(double))
                                       rows:rows
                                    columns:columns
                           leadingDimension:leadingDimension
                              packingMethod:MCMatrixValuePackingMethodConventional
                        triangularComponent:MCMatrixTriangularComponentBoth];
}

+ (instancetype)matrixWithValues:(double *)values
                            rows:(int)rows
                         columns:(int)columns
{
    return [[MCMatrix alloc] initWithValues:values
                                       rows:rows
                                    columns:columns
                           leadingDimension:MCMatrixLeadingDimensionColumn
                              packingMethod:MCMatrixValuePackingMethodConventional
                        triangularComponent:MCMatrixTriangularComponentBoth];
}

+ (instancetype)matrixWithValues:(double *)values
                            rows:(int)rows
                         columns:(int)columns
                leadingDimension:(MCMatrixLeadingDimension)leadingDimension
{
    return [[MCMatrix alloc] initWithValues:values
                                       rows:rows
                                    columns:columns
                           leadingDimension:leadingDimension
                              packingMethod:MCMatrixValuePackingMethodConventional
                        triangularComponent:MCMatrixTriangularComponentBoth];
}

+ (instancetype)identityMatrixWithSize:(int)size
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

+ (instancetype)diagonalMatrixWithValues:(double *)values
                                    size:(int)size
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

+ (instancetype)triangularMatrixWithPackedValues:(double *)values
                           ofTriangularComponent:(MCMatrixTriangularComponent)triangularComponent
                                leadingDimension:(MCMatrixLeadingDimension)leadingDimension
                                           order:(int)order
{
    MCMatrix *matrix = [[MCMatrix alloc] initWithValues:values
                                                   rows:order
                                                columns:order
                                       leadingDimension:leadingDimension
                                          packingMethod:MCMatrixValuePackingMethodPacked
                                    triangularComponent:triangularComponent];
    matrix.isSymmetric = [MCTribool triboolWithValue:MCTriboolValueNo];
    return matrix;
}

+ (instancetype)symmetricMatrixWithPackedValues:(double *)values
                            triangularComponent:(MCMatrixTriangularComponent)triangularComponent
                               leadingDimension:(MCMatrixLeadingDimension)leadingDimension
                                          order:(int)order
{
    MCMatrix *matrix = [[MCMatrix alloc] initWithValues:values
                                                   rows:order
                                                columns:order
                                       leadingDimension:leadingDimension
                                          packingMethod:MCMatrixValuePackingMethodPacked
                                    triangularComponent:triangularComponent];
    matrix.isSymmetric = [MCTribool triboolWithValue:MCTriboolValueYes];
    return matrix;
}

+ (instancetype)bandMatrixWithValues:(double *)values
                               order:(int)order
                           bandwidth:(int)bandwidth
                 oddDiagonalLocation:(MCMatrixTriangularComponent)oddDiagonalLocation
{
    MCMatrix *matrix = [[MCMatrix alloc] initWithValues:values
                                                   rows:order
                                                columns:order
                                       leadingDimension:MCMatrixLeadingDimensionColumn
                                          packingMethod:MCMatrixValuePackingMethodBand
                                    triangularComponent:oddDiagonalLocation];
    
    BOOL evenAmountOfCodiagonals = (bandwidth / 2.0) == round(bandwidth / 2.0);
    
    int numberOfBandValues = order;
    int numberOfBalancedUpperCodiagonals = ( bandwidth - 1 - (evenAmountOfCodiagonals ? 1 : 0) ) / 2;
    for (int i = 0; i < numberOfBalancedUpperCodiagonals; i += 1) {
        numberOfBandValues += 2 * (order - (i + 1));
    }
    if (evenAmountOfCodiagonals) {
        numberOfBandValues += order - floor(bandwidth / 2.0) - 1;
    }
    
    matrix.bandwidth = bandwidth;
    matrix.numberOfBandValues = numberOfBandValues;
    matrix.evenAmountOfCodiagonals = evenAmountOfCodiagonals;
    return matrix;
}

+ (instancetype)randomMatrixWithRows:(int)rows
                             columns:(int)columns
{
    double *values = [self randomArrayOfSize:rows * columns];
    return [MCMatrix matrixWithValues:values
                                 rows:rows
                              columns:columns];
}

+ (instancetype)randomSymmetricMatrixOfOrder:(int)order
{
    double *values = [self randomArrayOfSize:(order * (order + 1))/2];
    return [MCMatrix symmetricMatrixWithPackedValues:values
                                 triangularComponent:MCMatrixTriangularComponentUpper
                                    leadingDimension:MCMatrixLeadingDimensionColumn
                                               order:order];
}

+ (instancetype)randomDiagonalMatrixOfOrder:(int)order
{
    double *values = [self randomArrayOfSize:order];
    return [MCMatrix diagonalMatrixWithValues:values size:order];
}

+ (instancetype)randomTriangularMatrixOfOrder:(int)order
                          triangularComponent:(MCMatrixTriangularComponent)triangularComponent
{
    double *values = [self randomArrayOfSize:(order * (order + 1))/2];
    return [MCMatrix triangularMatrixWithPackedValues:values
                                ofTriangularComponent:triangularComponent
                                     leadingDimension:MCMatrixLeadingDimensionColumn
                                                order:order];
}

+ (instancetype)randomBandMatrixOfOrder:(int)order
                              bandwidth:(int)bandwidth
                    oddDiagonalLocation:(MCMatrixTriangularComponent)oddDiagonalLocation
{
    BOOL evenAmountOfBands = (bandwidth / 2.0) == round(bandwidth / 2.0);
    
    int numberOfBandValues = order;
    int numberOfBalancedUpperCodiagonals = ( bandwidth - 1 - (evenAmountOfBands ? 1 : 0) ) / 2;
    for (int i = 0; i < numberOfBalancedUpperCodiagonals; i += 1) {
        numberOfBandValues += 2 * (order - (i + 1));
    }
    if (evenAmountOfBands) {
        numberOfBandValues += order - floor(bandwidth / 2.0) - 1;
    }
    double *values = [self randomArrayOfSize:numberOfBandValues];
    return [MCMatrix bandMatrixWithValues:values
                                    order:order
                                bandwidth:bandwidth
                      oddDiagonalLocation:oddDiagonalLocation];
}

- (void)dealloc
{
    free(_values);
}

#pragma mark - Lazy-loaded properties

- (MCMatrix *)transpose
{
    if (!_transpose) {
        double *aVals = [self valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
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
            double *a = [self valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
            
            int m = _rows;
            int n = _columns;
            
            int lda = m;
            
            int *ipiv = malloc(MIN(m, n) * sizeof(int));
            
            int info = 0;
            
            // compute factorization
            dgetrf_(&m, &n, a, &lda, ipiv, &info);
        
            double wkopt;
            int lwork = -1;
            
            // query optimal workspace size
            dgetri_(&m, a, &lda, ipiv, &wkopt, &lwork, &info);
            
            lwork = wkopt;
            double *work = malloc(lwork * sizeof(double));
            
            // calculate the inverse
            dgetri_(&m, a, &lda, ipiv, work, &lwork, &info);
            
            free(ipiv);
            free(work);
            
            _inverse = [MCMatrix matrixWithValues:a
                                             rows:_rows
                                          columns:_columns
                               leadingDimension:MCMatrixLeadingDimensionColumn];
        }
    }
    
    return _inverse;
}

- (double)conditionNumber
{
    if (_conditionNumber == -1.0) {
        double *values = [self valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
        int m = self.rows;
        int n = self.columns;
        double norm = dlange_("1", &m, &n, values, &m, nil);
        
        int lda = self.rows;
        int *ipiv = malloc(m * sizeof(int));
        int info;
        dgetrf_(&m, &n, values, &lda, ipiv, &info);
        
        double conditionReciprocal;
        double *work = malloc(4 * m * sizeof(double));
        int *iwork = malloc(m * sizeof(int));
        dgecon_("1", &m, values, &lda, &norm, &conditionReciprocal, work, iwork, &info);
        
        free(ipiv);
        free(work);
        free(iwork);
        
        _conditionNumber = 1.0 / conditionReciprocal;
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
    if (!_eigendecomposition) {
        _eigendecomposition = [MCEigendecomposition eigendecompositionOfMatrix:self];
    }
    
    return _eigendecomposition;
}

- (MCTribool *)isSymmetric
{
    if (_isSymmetric.triboolValue == MCTriboolValueUnknown) {
        if (self.rows != self.columns) {
            _isSymmetric = [MCTribool triboolWithValue:MCTriboolValueNo];
            return _isSymmetric;
        } else {
            _isSymmetric = [MCTribool triboolWithValue:MCTriboolValueYes];
        }
        
        for (int i = 0; i < self.rows; i++) {
            for (int j = i + 1; j < self.columns; j++) {
                if ([self valueAtRow:i column:j] != [self valueAtRow:j column:i]) {
                    _isSymmetric = [MCTribool triboolWithValue:MCTriboolValueNo];
                    return _isSymmetric;
                }
            }
        }
    }
    
    return _isSymmetric;
}

- (MCMatrixDefiniteness)definiteness
{
    BOOL hasFoundEigenvalueStrictlyGreaterThanZero = NO;
    BOOL hasFoundEigenvalueStrictlyLesserThanZero = NO;
    BOOL hasFoundEigenvalueEqualToZero = NO;
    if (self.isSymmetric && _definiteness == MCMatrixDefinitenessUnknown) {
        MCVector *eigenvalues = self.eigendecomposition.eigenvalues;
        for (int i = 0; i < eigenvalues.length; i += 1) {
            double eigenvalue = [eigenvalues valueAtIndex:i];
            if (eigenvalue > 0) {
                hasFoundEigenvalueStrictlyGreaterThanZero = YES;
            }
            else if (eigenvalue < 0) {
                hasFoundEigenvalueStrictlyLesserThanZero = YES;
            }
            else {
                hasFoundEigenvalueEqualToZero = YES;
            }
        }
        if (hasFoundEigenvalueStrictlyGreaterThanZero
            && !hasFoundEigenvalueStrictlyLesserThanZero
            && !hasFoundEigenvalueEqualToZero) {
            _definiteness = MCMatrixDefinitenessPositiveDefinite;
        } else if (!hasFoundEigenvalueStrictlyGreaterThanZero
                   && hasFoundEigenvalueStrictlyLesserThanZero
                   && !hasFoundEigenvalueEqualToZero) {
            _definiteness = MCMatrixDefinitenessNegativeDefinite;
        } else if (hasFoundEigenvalueStrictlyGreaterThanZero
                   && !hasFoundEigenvalueStrictlyLesserThanZero
                   && hasFoundEigenvalueEqualToZero) {
            _definiteness = MCMatrixDefinitenessPositiveSemidefinite;
        } else if (!hasFoundEigenvalueStrictlyGreaterThanZero
                   && hasFoundEigenvalueStrictlyLesserThanZero
                   && hasFoundEigenvalueEqualToZero) {
            _definiteness = MCMatrixDefinitenessNegativeSemidefinite;
        } else {
            _definiteness = MCMatrixDefinitenessIndefinite;
        }
    }
    return _definiteness;
}

- (MCVector *)diagonalValues
{
    if (!_diagonalValues) {
        int length = MIN(self.rows, self.columns);
        double *values = malloc(length * sizeof(double));
        for (int i = 0; i < length; i += 1) {
            values[i] = [self valueAtRow:i column:i];
        }
        _diagonalValues = [MCVector vectorWithValues:values length:length vectorFormat:MCVectorFormatRowVector];
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

- (double)normInfinity
{
    if (isnan(_normInfinity)) {
        _normInfinity = [self normOfType:MCMatrixNormInfinity];
    }
    return _normInfinity;
}

- (double)normL1
{
    if (isnan(_normL1)) {
        _normL1 = [self normOfType:MCMatrixNormL1];
    }
    return _normL1;
}

- (double)normMax
{
    if (isnan(_normMax)) {
        _normMax = [self normOfType:MCMatrixNormMax];
    }
    return _normMax;
}

- (double)normFroebenius
{
    if (isnan(_normFroebenius)) {
        _normFroebenius = [self normOfType:MCMatrixNormFroebenius];
    }
    return _normFroebenius;
}

- (MCMatrix *)minorMatrix
{
    if (!_minorMatrix) {
        double *minorValues = malloc(self.rows * self.columns * sizeof(double));
        
        int minorIdx = 0;
        for (int row = 0; row < self.rows; row += 1) {
            for (int col = 0; col < self.columns; col += 1) {
                MCMatrix *submatrix = [MCMatrix matrixWithRows:self.rows - 1
                                                       columns:self.columns - 1
                                            leadingDimension:self.leadingDimension];
                
                for (int i = 0; i < self.rows; i++) {
                    for (int j = 0; j < self.rows; j++) {
                        if (i != row && j != col) {
                            [submatrix setEntryAtRow:i > row ? i - 1 : i
                                              column:j > col ? j - 1 : j
                                             toValue:[self valueAtRow:i column:j]];
                        }
                    }
                }
                
                minorValues[minorIdx++] = submatrix.determinant;
            }
        }
        
        _minorMatrix = [MCMatrix matrixWithValues:minorValues
                                             rows:self.rows
                                          columns:self.columns
                               leadingDimension:MCMatrixLeadingDimensionRow];
    }
    
    return _minorMatrix;
}

- (MCMatrix *)cofactorMatrix
{
    if (!_cofactorMatrix) {
        double *cofactors = malloc(self.rows * self.columns * sizeof(double));
        
        int cofactorIdx = 0;
        for (int row = 0; row < self.rows; row += 1) {
            for (int col = 0; col < self.columns; col += 1) {
                double minor = self.minorMatrix[row][col].doubleValue;
                double multiplier = pow(-1.0, row + col + 2.0);
                cofactors[cofactorIdx++] = minor * multiplier;
            }
        }
        
        _cofactorMatrix = [MCMatrix matrixWithValues:cofactors
                                                rows:self.rows
                                             columns:self.columns
                                  leadingDimension:MCMatrixLeadingDimensionRow];
    }
    
    return _cofactorMatrix;
}

- (MCMatrix *)adjugate
{
    if (!_adjugate) {
        _adjugate = self.cofactorMatrix.transpose;
    }
    
    return _adjugate;
}

#pragma mark - Matrix operations

- (void)swapRowA:(int)rowA withRowB:(int)rowB
{
    NSAssert1(rowA < self.rows, @"rowA = %u is outside the range of possible rows.", rowA);
    NSAssert1(rowB < self.rows, @"rowB = %u is outside the range of possible rows.", rowB);
    
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

- (void)swapColumnA:(int)columnA withColumnB:(int)columnB
{
    NSAssert1(columnA < self.columns, @"columnA = %u is outside the range of possible columns.", columnA);
    NSAssert1(columnB < self.columns, @"columnB = %u is outside the range of possible columns.", columnB);
    
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

- (double *)valuesWithLeadingDimension:(MCMatrixLeadingDimension)leadingDimension
{
    if (self.leadingDimension == leadingDimension) {
        double *copiedValues = malloc(self.rows * self.columns * sizeof(double));
        for (int i = 0; i < self.rows * self.columns; i += 1) {
            copiedValues[i] = self.values[i];
        }
        return copiedValues;
    }
    
    double *tVals = malloc(self.rows * self.columns * sizeof(double));
    
    int i = 0;
    for (int j = 0; j < (leadingDimension == MCMatrixLeadingDimensionRow ? self.rows : self.columns); j++) {
        for (int k = 0; k < (leadingDimension == MCMatrixLeadingDimensionRow ? self.columns : self.rows); k++) {
            int idx = ((i * (leadingDimension == MCMatrixLeadingDimensionRow ? self.rows : self.columns)) % (self.columns * self.rows)) + j;
            tVals[i] = self.values[idx];
            i++;
        }
    }
    
    return tVals;
}

- (double *)valuesFromTriangularComponent:(MCMatrixTriangularComponent)triangularComponent
                         leadingDimension:(MCMatrixLeadingDimension)leadingDimension
                            packingMethod:(MCMatrixValuePackingMethod)packingMethod
{
    NSAssert(self.rows == self.columns, @"Cannot extract triangular components from non-square matrices");
    
    int numberOfValues = packingMethod == MCMatrixValuePackingMethodPacked ? ((self.rows * (self.rows + 1)) / 2) : self.rows * self.rows;
    double *values = malloc(numberOfValues * sizeof(double));
    
    int i = 0;
    int outerLimit = self.leadingDimension == MCMatrixLeadingDimensionRow ? self.rows : self.columns;
    int innerLimit = self.leadingDimension == MCMatrixLeadingDimensionRow ? self.columns : self.rows;
    
    for (int j = 0; j < outerLimit; j++) {
        for (int k = 0; k < innerLimit; k++) {
            int row = leadingDimension == MCMatrixLeadingDimensionRow ? j : k;
            int col = leadingDimension == MCMatrixLeadingDimensionRow ? k : j;
            
            BOOL shouldStoreValueForLowerTriangle = triangularComponent == MCMatrixTriangularComponentLower && col <= row;
            BOOL shouldStoreValueForUpperTriangle = triangularComponent == MCMatrixTriangularComponentUpper && row <= col;
            
            if (shouldStoreValueForLowerTriangle || shouldStoreValueForUpperTriangle) {
                double value = [self valueAtRow:row column:col];
                values[i++] = value;
            } else if (packingMethod == MCMatrixValuePackingMethodConventional) {
                values[i++] = 0.0;
            }
        }
    }
    
    return values;
}

- (double)valueAtRow:(int)row column:(int)column
{
    NSAssert1(row >= 0 && row < self.rows, @"row = %u is outside the range of possible rows.", row);
    NSAssert1(column >= 0 && column < self.columns, @"column = %u is outside the range of possible columns.", column);
    
    switch (self.packingMethod) {
        default:
        case MCMatrixValuePackingMethodConventional: {
            if (self.leadingDimension == MCMatrixLeadingDimensionRow) {
                return self.values[row * self.columns + column];
            } else {
                return self.values[column * self.rows + row];
            }
        } break;
            
        case MCMatrixValuePackingMethodPacked: {
            if (self.triangularComponent == MCMatrixTriangularComponentLower) {
                if (column <= row || self.isSymmetric.isYes) {
                    if (column > row && self.isSymmetric.isYes) {
                        int temp = row;
                        row = column;
                        column = temp;
                    }
                    if (self.leadingDimension == MCMatrixLeadingDimensionColumn) {
                        // number of values in columns before desired column
                        int valuesInSummedColumns = ((self.rows * (self.rows + 1)) - ((self.rows - column) * (self.rows - column + 1))) / 2;
                        int index = valuesInSummedColumns + row - column;
                        return self.values[index];
                    } else {
                        // number of values in rows before desired row
                        int summedRows = row ;
                        int valuesInSummedRows = summedRows * (summedRows + 1) / 2;
                        int index = valuesInSummedRows + column;
                        return self.values[index];
                    }
                } else {
                    return 0.0;
                }
            } else /* if (self.triangularComponent == MCMatrixTriangularComponentUpper) */ {
                if (row <= column || self.isSymmetric.isYes) {
                    if (row > column && self.isSymmetric.isYes) {
                        int temp = row;
                        row = column;
                        column = temp;
                    }
                    if (self.leadingDimension == MCMatrixLeadingDimensionColumn) {
                        // number of values in columns before desired column
                        int summedColumns = column;
                        int valuesInSummedColumns = summedColumns * (summedColumns + 1) / 2;
                        int index = valuesInSummedColumns + row;
                        return self.values[index];
                    } else {
                        // number of values in rows before desired row
                        int valuesInSummedRows = ((self.columns * (self.columns + 1)) - ((self.columns - row) * (self.columns - row + 1))) / 2;
                        int index = valuesInSummedRows + column - row;
                        return self.values[index];
                    }
                } else {
                    return 0.0;
                }
            }
        } break;
            
        case MCMatrixValuePackingMethodBand: {
            int numberOfUpperCodiagonals = (self.evenAmountOfCodiagonals && self.triangularComponent == MCMatrixTriangularComponentUpper) ? 1 : 0;
            int indexIntoBandArray = ( row - column + numberOfUpperCodiagonals + 1 ) * self.columns + column;
            if (indexIntoBandArray >= 0 && indexIntoBandArray < self.bandwidth * self.columns) {
                return self.values[indexIntoBandArray];
            } else {
                return 0.0;
            }
        } break;
    }
    
}

- (MCVector *)rowVectorForRow:(int)row
{
    NSAssert1(row >= 0 && row < self.rows, @"row = %u is outside the range of possible rows.", row);
    
    double *values = malloc(self.columns * sizeof(double));
    for (int col = 0; col < self.columns; col += 1) {
        values[col] = [self valueAtRow:row column:col];
    }
    
    return [MCVector vectorWithValues:values length:self.columns vectorFormat:MCVectorFormatRowVector];
}

- (MCVector *)columnVectorForColumn:(int)column
{
    NSAssert1(column >= 0 && column < self.columns, @"column = %u is outside the range of possible columns.", column);
    
    double *values = malloc(self.rows * sizeof(double));
    for (int row = 0; row < self.rows; row += 1) {
        values[row] = [self valueAtRow:row column:column];
    }
    
    return [MCVector vectorWithValues:values length:self.rows vectorFormat:MCVectorFormatColumnVector];
}

#pragma mark - Subscripting

- (MCVector *)objectAtIndexedSubscript:(int)idx
{
    NSAssert1(idx >= 0 && idx < self.rows, @"idx = %u is outside the range of possible rows.", idx);
    
    return [self rowVectorForRow:idx];
}

#pragma mark - Mutation
- (void)setEntryAtRow:(int)row column:(int)column toValue:(double)value
{
    NSAssert1(row >= 0 && row < self.rows, @"row = %u is outside the range of possible rows.", row);
    NSAssert1(column >= 0 && column < self.columns, @"column = %u is outside the range of possible columns.", column);
    
    if (self.leadingDimension == MCMatrixLeadingDimensionRow) {
        self.values[row * self.columns + column] = value;
    } else {
        self.values[column * self.rows + row] = value;
    }
}

#pragma mark - Class-level matrix operations

+ (MCMatrix *)productOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB
{
    NSAssert(matrixA.columns == matrixB.rows, @"matrixA does not have an equal amount of columns as rows in matrixB");
    
    double *aVals = [matrixA valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    double *bVals = [matrixB valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    double *cVals = malloc(matrixA.rows * matrixB.columns * sizeof(double));
    
    vDSP_mmulD(aVals, 1, bVals, 1, cVals, 1, matrixA.rows, matrixB.columns, matrixA.columns);
    
    free(aVals);
    free(bVals);
    
    return [MCMatrix matrixWithValues:cVals rows:matrixA.rows columns:matrixB.columns leadingDimension:MCMatrixLeadingDimensionRow];
}

+ (MCMatrix *)sumOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB
{
    NSAssert(matrixA.rows == matrixB.rows, @"Matrices have mismatched amounts of rows.");
    NSAssert(matrixA.columns == matrixB.columns, @"Matrices have mismatched amounts of columns.");
    
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
    NSAssert(matrixA.rows == matrixB.rows, @"Matrices have mismatched amounts of rows.");
    NSAssert(matrixA.columns == matrixB.columns, @"Matrices have mismatched amounts of columns.");
    
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
    double *aVals = [A valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
    
    if (A.rows == A.columns) {
        // solve for square matrix A
        
        int n = A.rows;
        int nrhs = 1;
        int lda = n;
        int ldb = n;
        int info;
        int *ipiv = malloc(n * sizeof(int));
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
            free(ipiv);
            free(a);
            free(b);
            return nil;
        } else {
            double *solutionValues = malloc(n * sizeof(double));
            for (int i = 0; i < n; i++) {
                solutionValues[i] = b[i];
            }
            free(ipiv);
            free(a);
            free(b);
            return [MCMatrix matrixWithValues:solutionValues
                                         rows:n
                                      columns:1];
        }
    } else {
        // solve for general m x n rectangular matrix A
        
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
            free(a);
            free(b);
            free(work);
            return nil;
        } else {
            double *solutionValues = malloc(n * sizeof(double));
            for (int i = 0; i < n; i++) {
                solutionValues[i] = b[i];
            }
            free(a);
            free(b);
            free(work);
            return [MCMatrix matrixWithValues:solutionValues rows:n columns:1];
        }
    }
}

+ (MCVector *)productOfMatrix:(MCMatrix *)matrix andVector:(MCVector *)vector
{
    NSAssert(matrix.columns == vector.length, @"Matrix must have same amount of columns as vector length.");
    
    short order = matrix.leadingDimension == MCMatrixLeadingDimensionColumn ? CblasColMajor : CblasRowMajor;
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

+ (MCMatrix *)raiseMatrix:(MCMatrix *)matrix toPower:(NSUInteger)power
{
    NSAssert(matrix.rows == matrix.columns, @"Cannot raise a non-square matrix to exponents.");
    
    MCMatrix *product = [MCMatrix productOfMatrixA:matrix andMatrixB:matrix];
    for (int i = 0; i < power - 1; i += 1) {
        product = [MCMatrix productOfMatrixA:product andMatrixB:matrix];
    }
    return product;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MCMatrix *matrixCopy = [[self class] allocWithZone:zone];
    
    matrixCopy->_columns = _columns;
    matrixCopy->_rows = _rows;
    
    matrixCopy->_leadingDimension = _leadingDimension;
    matrixCopy->_triangularComponent = _triangularComponent;
    matrixCopy->_packingMethod = _packingMethod;
    
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
    
    if (_adjugate) {
        matrixCopy->_adjugate = _adjugate.copy;
    }
    
    if (_conditionNumber) {
        matrixCopy->_conditionNumber = _conditionNumber;
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
    
    if (_minorMatrix) {
        matrixCopy->_minorMatrix = _minorMatrix.copy;
    }
    
    if (_cofactorMatrix) {
        matrixCopy->_cofactorMatrix = _cofactorMatrix.copy;
    }
    
    matrixCopy->_isSymmetric = _isSymmetric.copy;
    matrixCopy->_definiteness = _definiteness;
    matrixCopy->_trace = _trace;
    
    matrixCopy->_normInfinity = _normInfinity;
    matrixCopy->_normL1 = _normL1;
    matrixCopy->_normFroebenius = _normFroebenius;
    matrixCopy->_normFroebenius = _normMax;
    
    return matrixCopy;
}

#pragma mark - Private interface

+ (double *)randomArrayOfSize:(int)size
{
    double *values = malloc(size * sizeof(double));
    for (int i = 0; i < size; i += 1) {
        values[i] = drand48();
    }
    return values;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _rows = 0;
        _columns = 0;
        _values = nil;
        
        _leadingDimension = MCMatrixLeadingDimensionColumn;
        _packingMethod = MCMatrixValuePackingMethodConventional;
        _triangularComponent = MCMatrixTriangularComponentBoth;
        
        _isSymmetric = [MCTribool triboolWithValue:MCTriboolValueUnknown];
        _definiteness = MCMatrixDefinitenessUnknown;
        _qrFactorization = nil;
        _luFactorization = nil;
        _singularValueDecomposition = nil;
        _eigendecomposition = nil;
        _inverse = nil;
        _transpose = nil;
        _conditionNumber = -1.0;
        _determinant = NAN;
        _diagonalValues = nil;
        _trace = NAN;
        _adjugate = nil;
        _minorMatrix = nil;
        _cofactorMatrix = nil;
        _normInfinity = NAN;
        _normL1 = NAN;
        _normMax = NAN;
        _normFroebenius = NAN;
    }
    return self;
}

- (double)normOfType:(MCMatrixNorm)normType
{
    double normResult = NAN;
    
    double *values = [self valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    int m = self.rows;
    int n = self.columns;
    char *norm = "";
    if (normType == MCMatrixNormL1) {
        norm = "1";
    } else if (normType == MCMatrixNormInfinity) {
        norm = "I";
    } else if (normType == MCMatrixNormMax) {
        norm = "M";
    } else /* if (normType == MCMatrixNormFroebenius) */ {
        norm = "F";
    }
    
    normResult = dlange_(norm, &m, &n, values, &m, nil);
    
    return normResult;
}

- (double *)unpackedValuesFromBandValues
{
    // TODO: accept a leading dimension parameter
    /*
     
     the band matrix
     
     [ a b 0 0 0
     c d e 0 0
     f g h i 0
     0 j k l m
     0 0 n o p ]
     
     is stored as the 2d array (logically) as
     
     [ [ * b e i m ]
     [ a d h l p ]
     [ c g k o * ]
     [ f j n * * ] ]
     
     which converts to the 1d array
     
     [ * b e i m a d h l p c g k o * f j n * * ]
     
     *'s must be present but are not used and need not set to particular values
     
     The values Aij inside the band width are stored in the linear array in positions [(i - j + nuca + 1) * n + j]
     
     */
    double *unpackedValues = calloc(self.columns * self.columns, sizeof(double));
    int numberOfUpperCodiagonals = (self.evenAmountOfCodiagonals && self.triangularComponent == MCMatrixTriangularComponentUpper) ? 1 : 0;
    for (int i = 0; i < self.columns; i += 1) {
        for (int j = 0; j < self.columns; j += 1) {
            int indexIntoBandArray = ( i - j + numberOfUpperCodiagonals + 1 ) * self.columns + j;
            int indexIntoUnpackedArray = j * self.columns + i;
            if (indexIntoBandArray >= 0 && indexIntoBandArray < self.bandwidth * self.columns) {
                unpackedValues[indexIntoUnpackedArray] = self.values[indexIntoBandArray];
            } else {
                unpackedValues[indexIntoUnpackedArray] = 0.0;
            }
        }
    }
    return unpackedValues;
}

- (double *)unpackedArrayFromPackedArrayWithLeadingDimension:(MCMatrixLeadingDimension)leadingDimension
{
    double *unpackedValues = malloc(self.columns * self.columns * sizeof(double));
    int k = 0; // current index in parameter array
    int z = 0; // current index in ivar array
    for (int i = 0; i < self.columns; i += 1) {
        for (int j = 0; j < self.columns; j += 1) {
            BOOL shouldTakeValue = self.triangularComponent == MCMatrixTriangularComponentUpper ? (leadingDimension == MCMatrixLeadingDimensionColumn ? j <= i : i <= j) : (leadingDimension == MCMatrixLeadingDimensionColumn ? i <= j : j <= i);
            if (shouldTakeValue) {
                unpackedValues[z++] = self.values[k++];
            } else {
                unpackedValues[z++] = 0.0;
            }
        }
    }
    return unpackedValues;
}

@end

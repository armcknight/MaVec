//
//  MAVMutableMatrix.m
//  MaVec
//
//  Created by Andrew McKnight on 6/1/14.
//  Copyright (c) 2014 AMProductions. All rights reserved.
//

#import <Accelerate/Accelerate.h>

#import "MAVMatrix-Protected.h"
#import "MAVMutableMatrix.h"
#import "MAVVector.h"

#import "MCKTribool.h"

#import "NSNumber+MCKPrecision.h"
#import "NSData+MCKPrecision.h"

@interface MAVMutableMatrix ()

@property (strong, nonatomic, readwrite) NSMutableData *values;

@end

@implementation MAVMutableMatrix

- (instancetype)initWithValues:(NSData *)values
                          rows:(int)rows
                       columns:(int)columns
              leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
                 packingMethod:(MAVMatrixValuePackingMethod)packingMethod
           triangularComponent:(MAVMatrixTriangularComponent)triangularComponent
{
	return [super initWithValues:[NSMutableData dataWithData:values]
                            rows:rows
                         columns:columns
                leadingDimension:leadingDimension
                   packingMethod:packingMethod
             triangularComponent:triangularComponent];
}

#pragma mark - Class constructors

+ (instancetype)matrixWithColumnVectors:(NSArray *)columnVectors
{
    int columns = (int)columnVectors.count;
    int rows = ((MAVVector *)columnVectors.firstObject).length;
    
    BOOL isDoublePrecision = ((MAVVector *)columnVectors[0])[0].isDoublePrecision;
    
	MAVMutableMatrix *matrix = [[self alloc] initWithValues:[[self dataFromVectors:columnVectors] mutableCopy]
	                                                   rows:rows
	                                                columns:columns
	                                       leadingDimension:MAVMatrixLeadingDimensionColumn
	                                          packingMethod:MAVMatrixValuePackingMethodConventional
	                                    triangularComponent:MAVMatrixTriangularComponentBoth];
    matrix.precision = isDoublePrecision ? MCKValuePrecisionDouble : MCKValuePrecisionSingle;
    
    return matrix;
}

+ (instancetype)matrixWithRowVectors:(NSArray *)rowVectors
{
    int rows = (int)rowVectors.count;
    int columns = ((MAVVector *)rowVectors.firstObject).length;
    
    BOOL isDoublePrecision = ((MAVVector *)rowVectors[0])[0].isDoublePrecision;
    
	MAVMutableMatrix *matrix = [[self alloc] initWithValues:[[self dataFromVectors:rowVectors] mutableCopy]
	                                                   rows:rows
	                                                columns:columns
	                                       leadingDimension:MAVMatrixLeadingDimensionRow
	                                          packingMethod:MAVMatrixValuePackingMethodConventional
	                                    triangularComponent:MAVMatrixTriangularComponentBoth];
    matrix.precision = isDoublePrecision ? MCKValuePrecisionDouble : MCKValuePrecisionSingle;
    
    return matrix;
}

+ (instancetype)matrixWithRows:(int)rows
                       columns:(int)columns
                     precision:(MCKValuePrecision)precision
{
    MAVMutableMatrix *matrix;
    
    if (precision == MCKValuePrecisionDouble) {
        NSUInteger size = rows * columns * sizeof(double);
		matrix = [[self alloc] initWithValues:[NSMutableData dataWithBytesNoCopy:malloc(size) length:size]
		                                 rows:rows
		                              columns:columns
		                     leadingDimension:MAVMatrixLeadingDimensionColumn
		                        packingMethod:MAVMatrixValuePackingMethodConventional
		                  triangularComponent:MAVMatrixTriangularComponentBoth];
    } else {
        NSUInteger size = rows * columns * sizeof(float);
		matrix = [[self alloc] initWithValues:[NSMutableData dataWithBytesNoCopy:malloc(size) length:size]
		                                 rows:rows
		                              columns:columns
		                     leadingDimension:MAVMatrixLeadingDimensionColumn
		                        packingMethod:MAVMatrixValuePackingMethodConventional
		                  triangularComponent:MAVMatrixTriangularComponentBoth];
    }
    
    return matrix;
}

+ (instancetype)matrixWithRows:(int)rows
                       columns:(int)columns
                     precision:(MCKValuePrecision)precision
              leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
{
    MAVMutableMatrix *matrix = [self matrixWithRows:rows columns:columns precision:precision];
    matrix.leadingDimension = leadingDimension;
    return matrix;
}

+ (instancetype)matrixWithValues:(NSMutableData *)values
                            rows:(int)rows
                         columns:(int)columns
{
	return [[self alloc] initWithValues:values
	                               rows:rows
	                            columns:columns
	                   leadingDimension:MAVMatrixLeadingDimensionColumn
	                      packingMethod:MAVMatrixValuePackingMethodConventional
	                triangularComponent:MAVMatrixTriangularComponentBoth];
}

+ (instancetype)matrixWithValues:(NSMutableData *)values
                            rows:(int)rows
                         columns:(int)columns
                leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
{
	return [[self alloc] initWithValues:values
	                               rows:rows
	                            columns:columns
	                   leadingDimension:leadingDimension
	                      packingMethod:MAVMatrixValuePackingMethodConventional
	                triangularComponent:MAVMatrixTriangularComponentBoth];
}

+ (instancetype)identityMatrixOfOrder:(int)order
                            precision:(MCKValuePrecision)precision
{
    MAVMutableMatrix *matrix;
    
    if (precision == MCKValuePrecisionDouble) {
        NSUInteger size = order * order * sizeof(double);
        double *values = malloc(size);
        for (int i = 0; i < order; i++) {
            for (int j = 0; j < order; j++) {
                values[i * order + j] = i == j ? 1.0 : 0.0;
            }
        }
		matrix = [self matrixWithValues:[NSMutableData dataWithBytesNoCopy:values length:size]
		                           rows:order
		                        columns:order];
    } else {
        NSUInteger size = order * order * sizeof(float);
        float *values = malloc(size);
        for (int i = 0; i < order; i++) {
            for (int j = 0; j < order; j++) {
                values[i * order + j] = i == j ? 1.0 : 0.0;
            }
        }
		matrix = [self matrixWithValues:[NSMutableData dataWithBytesNoCopy:values length:size]
		                           rows:order
		                        columns:order];
    }
    
    return matrix;
}

+ (instancetype)diagonalMatrixWithValues:(NSMutableData *)values
                                   order:(int)order
{
    return [self bandMatrixWithValues:values order:order upperCodiagonals:0 lowerCodiagonals:0];
}

+ (instancetype)triangularMatrixWithPackedValues:(NSMutableData *)values
                           ofTriangularComponent:(MAVMatrixTriangularComponent)triangularComponent
                                leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
                                           order:(int)order
{
	MAVMutableMatrix *matrix = [[self alloc] initWithValues:values
	                                                   rows:order
	                                                columns:order
	                                       leadingDimension:leadingDimension
	                                          packingMethod:MAVMatrixValuePackingMethodPacked
	                                    triangularComponent:triangularComponent];
    matrix.isSymmetric = [MCKTribool triboolWithValue:MCKTriboolValueNo];
    return matrix;
}

+ (instancetype)symmetricMatrixWithPackedValues:(NSMutableData *)values
                            triangularComponent:(MAVMatrixTriangularComponent)triangularComponent
                               leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
                                          order:(int)order
{
	MAVMutableMatrix *matrix = [[self alloc] initWithValues:values
	                                                   rows:order
	                                                columns:order
	                                       leadingDimension:leadingDimension
	                                          packingMethod:MAVMatrixValuePackingMethodPacked
	                                    triangularComponent:triangularComponent];
    matrix.isSymmetric = [MCKTribool triboolWithValue:MCKTriboolValueYes];
    return matrix;
}

+ (instancetype)bandMatrixWithValues:(NSMutableData *)values
                               order:(int)order
                    upperCodiagonals:(int)upperCodiagonals
                    lowerCodiagonals:(int)lowerCodiagonals
{
	MAVMutableMatrix *matrix = [[self alloc] initWithValues:values
                                                       rows:order
                                                    columns:order
                                           leadingDimension:MAVMatrixLeadingDimensionColumn
                                              packingMethod:MAVMatrixValuePackingMethodBand
                                        triangularComponent:upperCodiagonals == 0
                                                                ? (lowerCodiagonals == 0
                                                                   ? MAVMatrixTriangularComponentBoth
                                                                   : MAVMatrixTriangularComponentLower)
                                                                :(lowerCodiagonals == 0
                                                                   ? MAVMatrixTriangularComponentUpper
                                                                   : MAVMatrixTriangularComponentLower)];
    
    
    matrix.upperCodiagonals = upperCodiagonals;
    matrix.bandwidth = lowerCodiagonals + upperCodiagonals + 1;
    matrix.numberOfBandValues = matrix.bandwidth * order;
    matrix.precision = [values containsDoublePrecisionValues:matrix.numberOfBandValues] ? MCKValuePrecisionDouble : MCKValuePrecisionSingle;
    
    return matrix;
}

+ (instancetype)matrixForTwoDimensionalRotationWithAngle:(NSNumber *)angle direction:(MAVAngleDirection)direction
{
    NSMutableData *valueData;
    if (angle.isDoublePrecision) {
        double directedAngle = angle.doubleValue * (direction == MAVAngleDirectionClockwise ? -1.0 : 1.0);
        size_t size = 4 * sizeof(double);
        double *values = malloc(size);
        values[0] = cos(directedAngle);
        values[1] = -sin(directedAngle);
        values[2] = sin(directedAngle);
        values[3] = cos(directedAngle);
        valueData = [NSMutableData dataWithBytesNoCopy:values length:size];
    } else {
        float directedAngle = angle.floatValue * (direction == MAVAngleDirectionClockwise ? -1.0f : 1.0f);
        size_t size = 4 * sizeof(float);
        float *values = malloc(size);
        values[0] = cosf(directedAngle);
        values[1] = -sinf(directedAngle);
        values[2] = sinf(directedAngle);
        values[3] = cosf(directedAngle);
        valueData = [NSMutableData dataWithBytesNoCopy:values length:size];
    }
    return [self matrixWithValues:valueData rows:2 columns:2 leadingDimension:MAVMatrixLeadingDimensionRow];
}

+ (instancetype)matrixForThreeDimensionalRotationWithAngle:(NSNumber *)angle
                                                 aboutAxis:(MAVCoordinateAxis)axis
                                                 direction:(MAVAngleDirection)direction
{
    NSMutableData *valueData;
    if (angle.isDoublePrecision) {
        double directedAngle = angle.doubleValue * (direction == MAVAngleDirectionClockwise ? -1.0 : 1.0);
        double *values = calloc(9, sizeof(double));
        switch (axis) {
                
            case MAVCoordinateAxisX: {
                values[0] = 1.0;
                values[4] = cos(directedAngle);
                values[5] = -sin(directedAngle);
                values[7] = sin(directedAngle);
                values[8] = cos(directedAngle);
            } break;
                
            case MAVCoordinateAxisY: {
                values[0] = cos(directedAngle);
                values[2] = sin(directedAngle);
                values[4] = 1.0;
                values[6] = -sin(directedAngle);
                values[8] = cos(directedAngle);
            } break;
                
            case MAVCoordinateAxisZ: {
                values[0] = cos(directedAngle);
                values[1] = -sin(directedAngle);
                values[3] = sin(directedAngle);
                values[4] = cos(directedAngle);
                values[8] = 1.0;
            } break;
                
            default: break;
        }
        valueData = [NSMutableData dataWithBytesNoCopy:values length:9 * sizeof(double)];
    } else {
        float directedAngle = angle.floatValue * (direction == MAVAngleDirectionClockwise ? -1.0f : 1.0f);
        float *values = calloc(9, sizeof(float));
        switch (axis) {
                
            case MAVCoordinateAxisX: {
                values[0] = 1.0f;
                values[4] = cosf(directedAngle);
                values[5] = -sinf(directedAngle);
                values[7] = sinf(directedAngle);
                values[8] = cosf(directedAngle);
            } break;
                
            case MAVCoordinateAxisY: {
                values[0] = cosf(directedAngle);
                values[2] = sinf(directedAngle);
                values[4] = 1.0f;
                values[6] = -sinf(directedAngle);
                values[8] = cosf(directedAngle);
            } break;
                
            case MAVCoordinateAxisZ: {
                values[0] = cosf(directedAngle);
                values[1] = -sinf(directedAngle);
                values[3] = sinf(directedAngle);
                values[4] = cosf(directedAngle);
                values[8] = 1.0f;
            } break;
                
            default: break;
        }
        valueData = [NSMutableData dataWithBytesNoCopy:values length:9 * sizeof(float)];
    }
    return [self matrixWithValues:valueData rows:3 columns:3 leadingDimension:MAVMatrixLeadingDimensionRow];
}

+ (instancetype)randomMatrixWithRows:(int)rows
                             columns:(int)columns
                           precision:(MCKValuePrecision)precision
{
	return [self matrixWithValues:[[self randomArrayOfSize:rows * columns precision:precision] mutableCopy]
                             rows:rows
                          columns:columns];
}

+ (instancetype)randomSymmetricMatrixOfOrder:(int)order
                                   precision:(MCKValuePrecision)precision
{
	return [self symmetricMatrixWithPackedValues:[[self randomArrayOfSize:(order * (order + 1)) / 2 precision:precision] mutableCopy]
	                         triangularComponent:MAVMatrixTriangularComponentUpper
	                            leadingDimension:MAVMatrixLeadingDimensionColumn
	                                       order:order];
}

+ (instancetype)randomDiagonalMatrixOfOrder:(int)order
                                  precision:(MCKValuePrecision)precision
{
	return [self diagonalMatrixWithValues:[[self randomArrayOfSize:order precision:precision] mutableCopy]
	                                order:order];
}

+ (instancetype)randomTriangularMatrixOfOrder:(int)order
                          triangularComponent:(MAVMatrixTriangularComponent)triangularComponent
                                    precision:(MCKValuePrecision)precision
{
	return [self triangularMatrixWithPackedValues:[[self randomArrayOfSize:(order * (order + 1)) / 2 precision:precision] mutableCopy]
	                        ofTriangularComponent:triangularComponent
	                             leadingDimension:MAVMatrixLeadingDimensionColumn
	                                        order:order];
}

+ (instancetype)randomBandMatrixOfOrder:(int)order
                       upperCodiagonals:(int)upperCodiagonals
                       lowerCodiagonals:(int)lowerCodiagonals
                              precision:(MCKValuePrecision)precision
{
    int numberOfBandValues = (upperCodiagonals + lowerCodiagonals + 1) * order;
	return [self bandMatrixWithValues:[[self randomArrayOfSize:numberOfBandValues precision:precision] mutableCopy]
	                            order:order
	                 upperCodiagonals:upperCodiagonals
	                 lowerCodiagonals:lowerCodiagonals];
}

+ (instancetype)randomMatrixOfOrder:(int)order
                       definiteness:(MAVMatrixDefiniteness)definiteness
                          precision:(MCKValuePrecision)precision
{
    MAVMutableMatrix *matrix;
    
    switch(definiteness) {
            
        case MAVMatrixDefinitenessIndefinite: {
            BOOL shouldHaveZero = (arc4random() % 2) == 0;
            int zeroIndex = arc4random() % order;
            BOOL positive = (arc4random() % 2) == 0;
            NSData *valueData;
            if (precision == MCKValuePrecisionDouble) {
                size_t length = order * sizeof(double);
                double *values = malloc(length);
                for (int i = 0; i < order; i++) {
                    if (shouldHaveZero && i == zeroIndex) {
                        values[i] = 0.0;
                    } else {
                        values[i] = fabs(randomDouble) * (positive ? 1.0 : -1.0);
                        while (values[i] == 0.0 || values[i] == -0.0) {
                            values[i] = fabs(randomDouble) * (positive ? 1.0 : -1.0);
                        }
                        positive = !positive;
                    }
                }
                valueData = [NSMutableData dataWithBytesNoCopy:values length:length];
            } else {
                size_t length = order * sizeof(float);
                float *values = malloc(length);
                for (int i = 0; i < order; i++) {
                    if (shouldHaveZero && i == zeroIndex) {
                        values[i] = 0.0f;
                    } else {
                        values[i] = fabsf(randomFloat) * (positive ? 1.0f : -1.0f);
                        while (values[i] == 0.0f || values[i] == -0.0f) {
                            values[i] = fabsf(randomFloat) * (positive ? 1.0f : -1.0f);
                        }
                        positive = !positive;
                    }
                }
                valueData = [NSMutableData dataWithBytesNoCopy:values length:length];
            }
            matrix = [self diagonalMatrixWithValues:valueData order:order];
        } break;
            
        case MAVMatrixDefinitenessPositiveDefinite: {
            // A is pos. def. if A = B^T * B, B is nonsingular square
            MAVMutableMatrix *start = [MAVMutableMatrix randomMatrixWithRows:order columns:order precision:precision];
            [start multiplyByMatrix:start.transpose];
            matrix = start;
        } break;
            
        case MAVMatrixDefinitenessNegativeDefinite: {
            // A is neg. def. if A = B^T * B, B is nonsingular square with all negative values
            MAVMutableMatrix *start = [MAVMutableMatrix randomMatrixWithRows:order columns:order precision:precision];
            [[start multiplyByMatrix:start.transpose] multiplyByScalar:precision == MCKValuePrecisionDouble ? @(-1.0) : @(-1.0f)];
            matrix = start;
        } break;
            
            /*
             positive and negative semidefinite matrices are diagonal matrices whose diagonal values are ≥ (or ≤, respectively) than 0
             http://onlinelibrary.wiley.com/store/10.1002/9780470173862.app3/asset/app3.pdf?v=1&t=hu78fklx&s=a57be4e6e17e511a0722c8b666ea79ebd47d250b
             */

        case MAVMatrixDefinitenessPositiveSemidefinite: {
            int zeroIndex = arc4random() % order;
            NSMutableData *valueData;
            if (precision == MCKValuePrecisionDouble) {
                size_t length = order * sizeof(double);
                double *values = malloc(length);
                for (int i = 0; i < order; i++) {
                    if (i == zeroIndex) {
                        values[i] = 0.0;
                    } else {
                        values[i] = fabs(randomDouble);
                        while (values[i] == 0.0 || values[i] == -0.0) {
                            values[i] = fabs(randomDouble);
                        }
                    }
                }
                valueData = [NSMutableData dataWithBytesNoCopy:values length:length];
            } else {
                size_t length = order * sizeof(float);
                float *values = malloc(length);
                for (int i = 0; i < order; i++) {
                    if (i == zeroIndex) {
                        values[i] = 0.0f;
                    } else {
                        values[i] = fabsf(randomFloat);
                        while (values[i] == 0.0f || values[i] == -0.0f) {
                            values[i] = fabsf(randomFloat);
                        }
                    }
                }
                valueData = [NSMutableData dataWithBytesNoCopy:values length:length];
            }
            matrix = [self diagonalMatrixWithValues:valueData order:order];
        } break;
            
        case MAVMatrixDefinitenessNegativeSemidefinite: {
            int zeroIndex = arc4random() % order;
            NSMutableData *valueData;
            if (precision == MCKValuePrecisionDouble) {
                size_t length = order * sizeof(double);
                double *values = malloc(length);
                for (int i = 0; i < order; i++) {
                    if (i == zeroIndex) {
                        values[i] = 0.0;
                    } else {
                        values[i] = -fabs(randomDouble);
                        while (values[i] == 0.0 || values[i] == -0.0) {
                            values[i] = -fabs(randomDouble);
                        }
                    }
                }
                valueData = [NSMutableData dataWithBytesNoCopy:values length:length];
            } else {
                size_t length = order * sizeof(float);
                float *values = malloc(length);
                for (int i = 0; i < order; i++) {
                    if (i == zeroIndex) {
                        values[i] = 0.0f;
                    } else {
                        values[i] = -fabsf(randomFloat);
                        while (values[i] == 0.0f || values[i] == -0.0f) {
                            values[i] = -fabsf(randomFloat);
                        }
                    }
                }
                valueData = [NSMutableData dataWithBytesNoCopy:values length:length];
            }
            matrix = [self diagonalMatrixWithValues:valueData order:order];
        } break;
            
        case MAVMatrixDefinitenessUnknown:
            matrix = [self randomMatrixWithRows:order columns:order precision:precision];
            break;
            
        default: break;
    }
    
    matrix.definiteness = definiteness;
    return matrix;
}

+ (instancetype)randomSingularMatrixOfOrder:(int)order precision:(MCKValuePrecision)precision
{
    BOOL shouldHaveZeroColumn = (arc4random() % 2) == 0;
    int zeroVectorIndex = arc4random() % order;
    
    NSMutableArray *vectors = [NSMutableArray new];
    MAVVectorFormat vectorFormat = shouldHaveZeroColumn ? MAVVectorFormatColumnVector : MAVVectorFormatRowVector;
    for (int i = 0; i < order; i++) {
        if (i == zeroVectorIndex) {
            [vectors addObject:[MAVVector vectorFilledWithValue:(precision == MCKValuePrecisionDouble ? @0.0 : @0.0f) length:order vectorFormat:vectorFormat]];
        } else {
            [vectors addObject:[MAVVector randomVectorOfLength:order vectorFormat:vectorFormat precision:precision]];
        }
    }
    return shouldHaveZeroColumn ? [self matrixWithColumnVectors:vectors] : [MAVMatrix matrixWithRowVectors:vectors];
}

+ (instancetype)randomNonsigularMatrixOfOrder:(int)order precision:(MCKValuePrecision)precision
{
    MAVMutableMatrix *matrix = [self randomMatrixWithRows:order columns:order precision:precision];
    while ([matrix.determinant compare:(precision == MCKValuePrecisionDouble ? @0.0 : @0.0f)] == NSOrderedSame) {
        matrix = [self randomMatrixWithRows:order columns:order precision:precision];
    }
    return matrix;
}

#pragma mark - Public

// TODO: invalidate all calculated properties when mutating matrix values

- (void)swapRowA:(int)rowA withRowB:(int)rowB
{
    NSAssert1(rowA < self.rows, @"rowA = %u is outside the range of possible rows.", rowA);
    NSAssert1(rowB < self.rows, @"rowB = %u is outside the range of possible rows.", rowB);
    
    // TODO: implement using cblas_dswap
    
    for (int i = 0; i < self.columns; i++) {
        NSNumber *temp = [self valueAtRow:rowA column:i];
        [self setEntryAtRow:rowA column:i toValue:[self valueAtRow:rowB column:i]];
        [self setEntryAtRow:rowB column:i toValue:temp];
    }
}

- (void)swapColumnA:(int)columnA withColumnB:(int)columnB
{
    NSAssert1(columnA < self.columns, @"columnA = %u is outside the range of possible columns.", columnA);
    NSAssert1(columnB < self.columns, @"columnB = %u is outside the range of possible columns.", columnB);
    
    // TODO: implement using cblas_dswap
    
    for (int i = 0; i < self.rows; i++) {
        NSNumber *temp = [self valueAtRow:i column:columnA];
        [self setEntryAtRow:i column:columnA toValue:[self valueAtRow:i column:columnB]];
        [self setEntryAtRow:i column:columnB toValue:temp];
    }
}

- (void)setEntryAtRow:(int)row column:(int)column toValue:(NSNumber *)value
{
    // TODO: take into account internal representation b/t conventional, packed and band, row- vs. col- major, triangular component, bandwidth, start/finish band offset
    
    NSAssert1(row >= 0 && row < self.rows, @"row = %u is outside the range of possible rows.", row);
    NSAssert1(column >= 0 && column < self.columns, @"column = %u is outside the range of possible columns.", column);
    BOOL precisionsMatch = (self.precision == MCKValuePrecisionDouble && value.isDoublePrecision ) || (self.precision == MCKValuePrecisionSingle && value.isSinglePrecision);
    NSAssert(precisionsMatch, @"Precisions do not match.");
    
    if (self.precision == MCKValuePrecisionDouble) {
        if (self.leadingDimension == MAVMatrixLeadingDimensionRow) {
            ((double *)self.values.bytes)[row * self.columns + column] = value.doubleValue;
        } else {
            ((double *)self.values.bytes)[column * self.rows + row] = value.doubleValue;
        }
    } else {
        if (self.leadingDimension == MAVMatrixLeadingDimensionRow) {
            ((float *)self.values.bytes)[row * self.columns + column] = value.floatValue;
        } else {
            ((float *)self.values.bytes)[column * self.rows + row] = value.floatValue;
        }
    }
}

- (void)setRowVector:(MAVVector *)vector atRow:(NSUInteger)row
{
    NSAssert2(vector.length == self.columns, @"Vector length (%u) must equal amount of columns in this matrix (%u)", vector.length, self.columns);
    NSAssert2(row < self.rows, @"row (%lu) must be < the amount of rows in this matrix (%u)", (unsigned long)row, self.rows);
    
    for (int i = 0; i < self.columns; i++) {
        [self setEntryAtRow:row column:i toValue:vector[i]];
    }
}

- (void)setColumnVector:(MAVVector *)vector atColumn:(NSUInteger)column
{
    NSAssert2(vector.length == self.rows, @"Vector length (%u) must equal amount of rows in this matrix (%u)", vector.length, self.rows);
    NSAssert2(column < self.columns, @"column (%lu) must be < the amount of columns in this matrix (%u)", (unsigned long)column, self.columns);
    
    for (int i = 0; i < self.rows; i++) {
        [self setEntryAtRow:i column:column toValue:vector[i]];
    }
}

- (void)setObject:(MAVVector *)obj atIndexedSubscript:(NSUInteger)idx
{
    [self setRowVector:obj atRow:idx];
}

#pragma mark - Mathematical operations

- (MAVMutableMatrix *)multiplyByMatrix:(MAVMatrix *)matrix
{
    NSAssert(self.columns == matrix.rows, @"self does not have an equal amount of columns as rows in matrix");
    NSAssert(self.precision == matrix.precision, @"Precisions do not match.");
    
    NSData *aVals = [self valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
    NSData *bVals = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
    
    if (self.precision == MCKValuePrecisionDouble) {
        size_t size = self.rows * matrix.columns * sizeof(double);
        double *cVals = malloc(size);
        vDSP_mmulD(aVals.bytes, 1, bVals.bytes, 1, cVals, 1, self.rows, matrix.columns, self.columns);
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:cVals length:size];
    } else {
        size_t size = self.rows * matrix.columns * sizeof(float);
        float *cVals = malloc(size);
        vDSP_mmul(aVals.bytes, 1, bVals.bytes, 1, cVals, 1, self.rows, matrix.columns, self.columns);
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:cVals length:size];
    }
    
    self.columns = matrix.columns;
    self.leadingDimension = MAVMatrixLeadingDimensionRow;
    
    return self;
}

- (MAVMutableMatrix *)addMatrix:(MAVMatrix *)matrix
{
    NSAssert(self.rows == matrix.rows, @"Matrices have mismatched amounts of rows.");
    NSAssert(self.columns == matrix.columns, @"Matrices have mismatched amounts of columns.");
    NSAssert(self.precision == matrix.precision, @"Precisions do not match.");
    
    for (int i = 0; i < self.rows; i++) {
        for (int j = 0; j < self.columns; j++) {
            if (self.precision == MCKValuePrecisionDouble) {
                [self setEntryAtRow:i column:j toValue:@([self valueAtRow:i column:j].doubleValue + [matrix valueAtRow:i column:j].doubleValue)];
            } else {
                [self setEntryAtRow:i column:j toValue:@([self valueAtRow:i column:j].floatValue + [matrix valueAtRow:i column:j].floatValue)];
            }
        }
    }
    
    return self;
}

- (MAVMutableMatrix *)subtractMatrix:(MAVMatrix *)matrix
{
    NSAssert(self.rows == matrix.rows, @"Matrices have mismatched amounts of rows.");
    NSAssert(self.columns == matrix.columns, @"Matrices have mismatched amounts of columns.");
    NSAssert(self.precision == matrix.precision, @"Precisions do not match.");
    
    for (int i = 0; i < self.rows; i++) {
        for (int j = 0; j < self.columns; j++) {
            if (self.precision == MCKValuePrecisionDouble) {
                [self setEntryAtRow:i column:j toValue:@([self valueAtRow:i column:j].doubleValue - [matrix valueAtRow:i column:j].doubleValue)];
            } else {
                [self setEntryAtRow:i column:j toValue:@([self valueAtRow:i column:j].floatValue - [matrix valueAtRow:i column:j].floatValue)];
            }
        }
    }
    
    return self;
}

- (MAVMutableMatrix *)multiplyByVector:(MAVVector *)vector
{
    NSAssert(self.columns == vector.length, @"self must have same amount of columns as vector length.");
    NSAssert(self.precision == vector.precision, @"Precisions do not match.");
    
    short order = self.leadingDimension == MAVMatrixLeadingDimensionColumn ? CblasColMajor : CblasRowMajor;
    short transpose = CblasNoTrans;
    int rows = self.rows;
    int cols = self.columns;
    
    if (self.precision == MCKValuePrecisionDouble) {
        double *result = calloc(vector.length, sizeof(double));
        cblas_dgemv(order, transpose, rows, cols, 1.0, self.values.bytes, rows, vector.values.bytes, 1, 1.0, result, 1);
        [self.values replaceBytesInRange:NSMakeRange(0, vector.values.length) withBytes:result length:vector.values.length];
    } else {
        float *result = calloc(vector.length, sizeof(float));
        cblas_sgemv(order, transpose, rows, cols, 1.0f, self.values.bytes, rows, vector.values.bytes, 1, 1.0f, result, 1);
        [self.values replaceBytesInRange:NSMakeRange(0, vector.values.length) withBytes:result length:vector.values.length];
    }
    
    if (vector.vectorFormat == MAVVectorFormatColumnVector) {
        self.leadingDimension = MAVMatrixLeadingDimensionColumn;
        self.columns = 1;
    } else {
        self.leadingDimension = MAVMatrixLeadingDimensionRow;
        self.columns = vector.length;
    }
    
    
    return self;
}

- (MAVMutableMatrix *)multiplyByScalar:(NSNumber *)scalar
{
    int valueCount = self.rows * self.columns;
    if (self.precision == MCKValuePrecisionDouble) {
        size_t size = valueCount * sizeof(double);
        double *values = malloc(size);
        for (int i = 0; i < valueCount; i++) {
            values[i] = ((double *)self.values.bytes)[i] * scalar.doubleValue;
        }
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:values];
    }
    else {
        size_t size = valueCount * sizeof(float);
        float *values = malloc(size);
        for (int i = 0; i < valueCount; i++) {
            values[i] = ((float *)self.values.bytes)[i] * scalar.floatValue;
        }
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:values];
    }
    
    return self;
}

- (MAVMutableMatrix *)raiseToPower:(NSUInteger)power
{
    NSAssert(self.rows == self.columns, @"Cannot raise a non-square matrix to exponents.");
    
    MAVMatrix *original = [self copy];
    for (int i = 0; i < power - 1; i += 1) {
        [self multiplyByMatrix:original];
    }
    
    return self;
}

@end

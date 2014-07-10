//
//  MAVMatrix.m
//  MaVec
//
//  Created by andrew mcknight on 11/30/13.
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

#import "MAVMatrix.h"
#import "MAVMatrix_Private.h"
#import "MAVVector.h"
#import "MAVSingularValueDecomposition.h"
#import "MAVLUFactorization.h"
#import "MAVEigendecomposition.h"
#import "MAVQRFactorization.h"
#import "MAVMutableMatrix.h"

#import "MCKTribool.h"

#import "NSNumber+MCKPrecision.h"
#import "NSData+MCKPrecision.h"

#define randomDouble drand48()
#define randomFloat rand() / RAND_MAX

typedef enum : UInt8 {
    /**
     The maximum absolute column sum of the matrix.
     */
    MAVMatrixNormL1,
    
    /**
     The maximum absolute row sum of the matrix.
     */
    MAVMatrixNormInfinity,
    
    /**
     The maximum value of all entries in the matrix.
     */
    MAVMatrixNormMax,
    
    /**
     Square root of the sum of the squared values in the matrix.
     */
    MAVMatrixNormFroebenius
}
/**
 Constants describing types of matrix norms.
 */
MAVMatrixNorm;

@interface MAVMatrix ()

/**
 @brief Generates specified number of floating-point values.
 @param size Amount of random values to generate.
 @return C array point containing specified number of random values.
 */
+ (NSData *)randomArrayOfSize:(int)size
                    precision:(MCKValuePrecision)precision;

/**
 @brief Sets all properties to default states.
 @return A new instance of MAVMatrix in a default state with no values or row/column counts.
 */
- (instancetype)init;

/**
 @description Documentation on usage and other details can be found at http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.essl.v5r2.essl100.doc%2Fam5gr_llange.htm. More information about different matrix norms can be found at http://en.wikipedia.org/wiki/Matrix_norm.
 @brief Compute the desired norm of this matrix.
 @param normType The type of norm to compute.
 @return The calculated norm of desired type of this matrix as a floating-point value.
 */
- (NSNumber *)normOfType:(MAVMatrixNorm)normType;

@end

@implementation MAVMatrix

#pragma mark - Constructors

- (instancetype)initWithValues:(NSData *)values
                          rows:(int)rows
                       columns:(int)columns
              leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
                 packingMethod:(MAVMatrixValuePackingMethod)packingMethod
           triangularComponent:(MAVMatrixTriangularComponent)triangularComponent
{
    self = [self init];
    if (self) {
        _leadingDimension = leadingDimension;
        _packingMethod = packingMethod;
        _triangularComponent = triangularComponent;
        _values = values;
        _rows = rows;
        _columns = columns;
        
        int numberOfValues;
        switch (packingMethod) {
            case MAVMatrixValuePackingMethodPacked:
                numberOfValues = (rows * (rows + 1)) / 2;
                break;
                
            case MAVMatrixValuePackingMethodConventional:
                numberOfValues = rows * columns;
                break;
                
            case MAVMatrixValuePackingMethodBand:
                // must set in any band init methods
                numberOfValues = 1;
                break;
                
            default: break;
        }
        _precision = [values containsDoublePrecisionValues:numberOfValues] ? MCKValuePrecisionDouble : MCKValuePrecisionSingle;
    }
    return self;
}

#pragma mark - Class constructors

+ (instancetype)matrixWithColumnVectors:(NSArray *)columnVectors
{
    int columns = (int)columnVectors.count;
    int rows = ((MAVVector *)columnVectors.firstObject).length;
    
    BOOL isDoublePrecision = ((MAVVector *)columnVectors[0])[0].isDoublePrecision;
    
	MAVMatrix *matrix = [[self alloc] initWithValues:[self dataFromVectors:columnVectors]
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
    
	MAVMatrix *matrix = [[self alloc] initWithValues:[self dataFromVectors:rowVectors]
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
    MAVMatrix *matrix;
    
    if (precision == MCKValuePrecisionDouble) {
        NSUInteger size = rows * columns * sizeof(double);
		matrix = [[self alloc] initWithValues:[NSData dataWithBytesNoCopy:malloc(size) length:size]
		                                 rows:rows
		                              columns:columns
		                     leadingDimension:MAVMatrixLeadingDimensionColumn
		                        packingMethod:MAVMatrixValuePackingMethodConventional
		                  triangularComponent:MAVMatrixTriangularComponentBoth];
    } else {
        NSUInteger size = rows * columns * sizeof(float);
		matrix = [[self alloc] initWithValues:[NSData dataWithBytesNoCopy:malloc(size) length:size]
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
    MAVMatrix *matrix = [self matrixWithRows:rows columns:columns precision:precision];
    matrix.leadingDimension = leadingDimension;
    return matrix;
}

+ (instancetype)matrixWithValues:(NSData *)values
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

+ (instancetype)matrixWithValues:(NSData *)values
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
    MAVMatrix *matrix;
    
    if (precision == MCKValuePrecisionDouble) {
        NSUInteger size = order * order * sizeof(double);
        double *values = malloc(size);
        for (int i = 0; i < order; i++) {
            for (int j = 0; j < order; j++) {
                values[i * order + j] = i == j ? 1.0 : 0.0;
            }
        }
		matrix = [self matrixWithValues:[NSData dataWithBytesNoCopy:values length:size]
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
		matrix = [self matrixWithValues:[NSData dataWithBytesNoCopy:values length:size]
		                           rows:order
		                        columns:order];
    }
    
    return matrix;
}

+ (instancetype)diagonalMatrixWithValues:(NSData *)values
                                   order:(int)order
{
    return [self bandMatrixWithValues:values order:order upperCodiagonals:0 lowerCodiagonals:0];
}

+ (instancetype)triangularMatrixWithPackedValues:(NSData *)values
                           ofTriangularComponent:(MAVMatrixTriangularComponent)triangularComponent
                                leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
                                           order:(int)order
{
	MAVMatrix *matrix = [[self alloc] initWithValues:values
	                                            rows:order
	                                         columns:order
	                                leadingDimension:leadingDimension
	                                   packingMethod:MAVMatrixValuePackingMethodPacked
	                             triangularComponent:triangularComponent];
    matrix.isSymmetric = [MCKTribool triboolWithValue:MCKTriboolValueNo];
    return matrix;
}

+ (instancetype)symmetricMatrixWithPackedValues:(NSData *)values
                            triangularComponent:(MAVMatrixTriangularComponent)triangularComponent
                               leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
                                          order:(int)order
{
	MAVMatrix *matrix = [[self alloc] initWithValues:values
	                                            rows:order
	                                         columns:order
	                                leadingDimension:leadingDimension
	                                   packingMethod:MAVMatrixValuePackingMethodPacked
	                             triangularComponent:triangularComponent];
    matrix.isSymmetric = [MCKTribool triboolWithValue:MCKTriboolValueYes];
    return matrix;
}

+ (instancetype)bandMatrixWithValues:(NSData *)values
                               order:(int)order
                    upperCodiagonals:(int)upperCodiagonals
                    lowerCodiagonals:(int)lowerCodiagonals
{
	MAVMatrix *matrix = [[self alloc] initWithValues:values
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
    NSData *valueData;
    if (angle.isDoublePrecision) {
        double directedAngle = angle.doubleValue * (direction == MAVAngleDirectionClockwise ? -1.0 : 1.0);
        size_t size = 4 * sizeof(double);
        double *values = malloc(size);
        values[0] = cos(directedAngle);
        values[1] = -sin(directedAngle);
        values[2] = sin(directedAngle);
        values[3] = cos(directedAngle);
        valueData = [NSData dataWithBytesNoCopy:values length:size];
    } else {
        float directedAngle = angle.floatValue * (direction == MAVAngleDirectionClockwise ? -1.0f : 1.0f);
        size_t size = 4 * sizeof(float);
        float *values = malloc(size);
        values[0] = cosf(directedAngle);
        values[1] = -sinf(directedAngle);
        values[2] = sinf(directedAngle);
        values[3] = cosf(directedAngle);
        valueData = [NSData dataWithBytesNoCopy:values length:size];
    }
    return [self matrixWithValues:valueData rows:2 columns:2 leadingDimension:MAVMatrixLeadingDimensionRow];
}

+ (instancetype)matrixForThreeDimensionalRotationWithAngle:(NSNumber *)angle
                                                 aboutAxis:(MAVCoordinateAxis)axis
                                                 direction:(MAVAngleDirection)direction
{
    NSData *valueData;
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
        valueData = [NSData dataWithBytesNoCopy:values length:9 * sizeof(double)];
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
        valueData = [NSData dataWithBytesNoCopy:values length:9 * sizeof(float)];
    }
    return [self matrixWithValues:valueData rows:3 columns:3 leadingDimension:MAVMatrixLeadingDimensionRow];
}

+ (instancetype)randomMatrixWithRows:(int)rows
                             columns:(int)columns
                           precision:(MCKValuePrecision)precision
{
	return [self matrixWithValues:[self randomArrayOfSize:rows * columns precision:precision]
	                                 rows:rows
	                              columns:columns];
}

+ (instancetype)randomSymmetricMatrixOfOrder:(int)order
                                   precision:(MCKValuePrecision)precision
{
	return [self symmetricMatrixWithPackedValues:[self randomArrayOfSize:(order * (order + 1)) / 2 precision:precision]
	                         triangularComponent:MAVMatrixTriangularComponentUpper
	                            leadingDimension:MAVMatrixLeadingDimensionColumn
	                                       order:order];
}

+ (instancetype)randomDiagonalMatrixOfOrder:(int)order
                                  precision:(MCKValuePrecision)precision
{
	return [self diagonalMatrixWithValues:[self randomArrayOfSize:order precision:precision]
	                                order:order];
}

+ (instancetype)randomTriangularMatrixOfOrder:(int)order
                          triangularComponent:(MAVMatrixTriangularComponent)triangularComponent
                                    precision:(MCKValuePrecision)precision
{
	return [self triangularMatrixWithPackedValues:[self randomArrayOfSize:(order * (order + 1)) / 2 precision:precision]
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
	return [self bandMatrixWithValues:[self randomArrayOfSize:numberOfBandValues precision:precision]
	                            order:order
	                 upperCodiagonals:upperCodiagonals
	                 lowerCodiagonals:lowerCodiagonals];
}

+ (instancetype)randomMatrixOfOrder:(int)order
                       definiteness:(MAVMatrixDefiniteness)definiteness
                          precision:(MCKValuePrecision)precision
{
    MAVMatrix *matrix;
    
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
                valueData = [NSData dataWithBytesNoCopy:values length:length];
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
                valueData = [NSData dataWithBytesNoCopy:values length:length];
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
            NSData *valueData;
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
                valueData = [NSData dataWithBytesNoCopy:values length:length];
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
                valueData = [NSData dataWithBytesNoCopy:values length:length];
            }
            matrix = [self diagonalMatrixWithValues:valueData order:order];
        } break;
            
        case MAVMatrixDefinitenessNegativeSemidefinite: {
            int zeroIndex = arc4random() % order;
            NSData *valueData;
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
                valueData = [NSData dataWithBytesNoCopy:values length:length];
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
                valueData = [NSData dataWithBytesNoCopy:values length:length];
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
    MAVMatrix *matrix = [self randomMatrixWithRows:order columns:order precision:precision];
    while ([matrix.determinant compare:(precision == MCKValuePrecisionDouble ? @0.0 : @0.0f)] == NSOrderedSame) {
        matrix = [self randomMatrixWithRows:order columns:order precision:precision];
    }
    return matrix;
}

#pragma mark - Lazy-loaded properties

- (MAVMatrix *)transpose
{
    if (_transpose == nil) {
        NSData *aVals = [self valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
        if ([aVals containsSinglePrecisionValues:(self.rows * self.columns)]) {
            float *tVals = malloc(self.rows * self.columns * sizeof(float));
            vDSP_mtrans(aVals.bytes, 1, tVals, 1, self.columns, self.rows);
            _transpose = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:tVals length:aVals.length] rows:self.columns columns:self.rows];
        } else  {
            double *tVals = malloc(self.rows * self.columns * sizeof(double));
            vDSP_mtransD(aVals.bytes, 1, tVals, 1, self.columns, self.rows);
            _transpose = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:tVals length:aVals.length] rows:self.columns columns:self.rows];
        }
    }
    
    return _transpose;
}

- (NSNumber *)determinant
{
    if (_determinant == nil) {
        if (_rows == 2 && _columns == 2) {
            if (self[0][0].isDoublePrecision) {
                double a = self[0][0].doubleValue;
                double b = self[0][1].doubleValue;
                double c = self[1][0].doubleValue;
                double d = self[1][1].doubleValue;
                
                _determinant = @(a * d - b * c);
            } else {
                float a = self[0][0].floatValue;
                float b = self[0][1].floatValue;
                float c = self[1][0].floatValue;
                float d = self[1][1].floatValue;
                
                _determinant = @(a * d - b * c);
            }
        } else if (_rows == 3 && _columns == 3) {
            if (self[0][0].isDoublePrecision) {
                double a = self[0][0].doubleValue;
                double b = self[0][1].doubleValue;
                double c = self[0][2].doubleValue;
                double d = self[1][0].doubleValue;
                double e = self[1][1].doubleValue;
                double f = self[1][2].doubleValue;
                double g = self[2][0].doubleValue;
                double h = self[2][1].doubleValue;
                double i = self[2][2].doubleValue;
                
                _determinant = @(a * e * i + b * f * g + c * d * h - g * e * c - h * f * a - i * d * b);
            } else {
                float a = self[0][0].floatValue;
                float b = self[0][1].floatValue;
                float c = self[0][2].floatValue;
                float d = self[1][0].floatValue;
                float e = self[1][1].floatValue;
                float f = self[1][2].floatValue;
                float g = self[2][0].floatValue;
                float h = self[2][1].floatValue;
                float i = self[2][2].floatValue;
                
                _determinant = @(a * e * i + b * f * g + c * d * h - g * e * c - h * f * a - i * d * b);
            }
        } else {
            NSNumber *product = self.luFactorization.upperTriangularMatrix.diagonalValues.productOfValues;
            if (product.isDoublePrecision) {
                _determinant = @(self.luFactorization.upperTriangularMatrix.diagonalValues.productOfValues.doubleValue * pow(-1.0, self.luFactorization.numberOfPermutations));
            } else {
                _determinant = @(self.luFactorization.upperTriangularMatrix.diagonalValues.productOfValues.floatValue * powf(-1.0f, self.luFactorization.numberOfPermutations));
            }
        }
    }
    
    return _determinant;
}

- (MAVMatrix *)inverse
{
    if (_inverse == nil) {
        if (_rows == _columns) {
            NSData *columnMajorData = [self valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
            
            int m = _rows;
            int n = _columns;
            
            int lda = m;
            
            int *ipiv = malloc(MIN(m, n) * sizeof(int));
            
            int info = 0;
            
            void *a;
            if ([columnMajorData containsDoublePrecisionValues:(m * n)]) {
                a = (double *)columnMajorData.bytes;
                
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
            } else {
                a = (float *)columnMajorData.bytes;
                
                // compute factorization
                sgetrf_(&m, &n, a, &lda, ipiv, &info);
                
                float wkopt;
                int lwork = -1;
                
                // query optimal workspace size
                sgetri_(&m, a, &lda, ipiv, &wkopt, &lwork, &info);
                
                lwork = wkopt;
                float *work = malloc(lwork * sizeof(float));
                
                // calculate the inverse
                sgetri_(&m, a, &lda, ipiv, work, &lwork, &info);
                
                free(ipiv);
                free(work);
            }
            
			_inverse = [MAVMatrix matrixWithValues:[NSData dataWithBytes:a length:columnMajorData.length]
			                                  rows:_rows
			                               columns:_columns
			                      leadingDimension:MAVMatrixLeadingDimensionColumn];
        }
    }
    
    return _inverse;
}

- (NSNumber *)conditionNumber
{
    if (_conditionNumber == nil) {
        NSData *rowMajorValues = [self valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
        int m = self.rows;
        int n = self.columns;
        if ([rowMajorValues containsDoublePrecisionValues:(m * n)]) {
            double *values = (double *)rowMajorValues.bytes;
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
            
            _conditionNumber = @(1.0 / conditionReciprocal);
        } else {
            float *values = (float *)rowMajorValues.bytes;
            
            float norm = slange_("1", &m, &n, values, &m, nil);
            
            int lda = self.rows;
            int *ipiv = malloc(m * sizeof(int));
            int info;
            sgetrf_(&m, &n, values, &lda, ipiv, &info);
            
            float conditionReciprocal;
            float *work = malloc(4 * m * sizeof(float));
            int *iwork = malloc(m * sizeof(int));
            sgecon_("1", &m, values, &lda, &norm, &conditionReciprocal, work, iwork, &info);
            
            free(ipiv);
            free(work);
            free(iwork);
            
            _conditionNumber = @(1.0f / conditionReciprocal);
        }
    }
    
    return _conditionNumber;
}

- (MAVQRFactorization *)qrFactorization
{
    if (_qrFactorization == nil) {
        _qrFactorization = [MAVQRFactorization qrFactorizationOfMatrix:self];
    }
    
    return _qrFactorization;
}

- (MAVLUFactorization *)luFactorization
{
    if (_luFactorization == nil) {
        _luFactorization = [MAVLUFactorization luFactorizationOfMatrix:self];
    }
    
    return _luFactorization;
}

- (MAVSingularValueDecomposition *)singularValueDecomposition
{
    if (_singularValueDecomposition == nil) {
        _singularValueDecomposition = [MAVSingularValueDecomposition singularValueDecompositionWithMatrix:self];
    }
    
    return _singularValueDecomposition;
}

- (MAVEigendecomposition *)eigendecomposition
{
    if (_eigendecomposition == nil) {
        _eigendecomposition = [MAVEigendecomposition eigendecompositionOfMatrix:self];
    }
    
    return _eigendecomposition;
}

- (MCKTribool *)isSymmetric
{
    if (_isSymmetric.triboolValue == MCKTriboolValueUnknown) {
        if (self.rows != self.columns) {
            _isSymmetric = [MCKTribool triboolWithValue:MCKTriboolValueNo];
            return _isSymmetric;
        } else {
            _isSymmetric = [MCKTribool triboolWithValue:MCKTriboolValueYes];
        }
        
        for (int i = 0; i < self.rows; i++) {
            for (int j = i + 1; j < self.columns; j++) {
                if ([[self valueAtRow:i column:j] compare:[self valueAtRow:j column:i]] != NSOrderedSame) {
                    _isSymmetric = [MCKTribool triboolWithValue:MCKTriboolValueNo];
                    return _isSymmetric;
                }
            }
        }
    }
    
    return _isSymmetric;
}

- (MAVMatrixDefiniteness)definiteness
{
    if (self.isSymmetric && _definiteness == MAVMatrixDefinitenessUnknown) {
        BOOL hasFoundEigenvalueStrictlyGreaterThanZero = NO;
        BOOL hasFoundEigenvalueStrictlyLesserThanZero = NO;
        BOOL hasFoundEigenvalueEqualToZero = NO;
        MAVVector *eigenvalues = self.eigendecomposition.eigenvalues;
        for (int i = 0; i < eigenvalues.length; i += 1) {
            NSNumber *eigenvalue = [eigenvalues valueAtIndex:i];
            if ([eigenvalue compare:@0] == NSOrderedDescending) {
                hasFoundEigenvalueStrictlyGreaterThanZero = YES;
            }
            else if ([eigenvalue compare:@0] == NSOrderedAscending) {
                hasFoundEigenvalueStrictlyLesserThanZero = YES;
            }
            else {
                hasFoundEigenvalueEqualToZero = YES;
            }
        }
        if (hasFoundEigenvalueEqualToZero) {
            // will be semidefinite or indefinite
            if (hasFoundEigenvalueStrictlyGreaterThanZero && !hasFoundEigenvalueStrictlyLesserThanZero) {
                _definiteness = MAVMatrixDefinitenessPositiveSemidefinite;
            } else if (!hasFoundEigenvalueStrictlyGreaterThanZero && hasFoundEigenvalueStrictlyLesserThanZero) {
                _definiteness = MAVMatrixDefinitenessNegativeSemidefinite;
            } else {
                _definiteness = MAVMatrixDefinitenessIndefinite;
            }
        } else {
            // will be definite or indefinite (but not semidefinite)
            if (hasFoundEigenvalueStrictlyGreaterThanZero && !hasFoundEigenvalueStrictlyLesserThanZero) {
                _definiteness = MAVMatrixDefinitenessPositiveDefinite;
            } else if (!hasFoundEigenvalueStrictlyGreaterThanZero && hasFoundEigenvalueStrictlyLesserThanZero) {
                _definiteness = MAVMatrixDefinitenessNegativeDefinite;
            } else {
                _definiteness = MAVMatrixDefinitenessIndefinite;
            }
        }
    }
    return _definiteness;
}

- (MAVVector *)diagonalValues
{
    if (_diagonalValues == nil) {
        int length = MIN(self.rows, self.columns);
        
        if (self[0][0].isDoublePrecision) {
            double *values = malloc(length * sizeof(double));
            for (int i = 0; i < length; i += 1) {
                values[i] = [self valueAtRow:i column:i].doubleValue;
            }
            _diagonalValues = [MAVVector vectorWithValues:[NSData dataWithBytesNoCopy:values length:length * sizeof(double)] length:length vectorFormat:MAVVectorFormatRowVector];
        } else {
            float *values = malloc(length * sizeof(float));
            for (int i = 0; i < length; i += 1) {
                values[i] = [self valueAtRow:i column:i].floatValue;
            }
            _diagonalValues = [MAVVector vectorWithValues:[NSData dataWithBytesNoCopy:values length:length * sizeof(float)] length:length vectorFormat:MAVVectorFormatRowVector];
        }
    }
    return _diagonalValues;
}

- (NSNumber *)trace
{
    if (_trace == nil) {
        _trace = self.diagonalValues.sumOfValues;
    }
    return _trace;
}

- (NSNumber *)normInfinity
{
    if (_normInfinity == nil) {
        _normInfinity = [self normOfType:MAVMatrixNormInfinity];
    }
    return _normInfinity;
}

- (NSNumber *)normL1
{
    if (_normL1 == nil) {
        _normL1 = [self normOfType:MAVMatrixNormL1];
    }
    return _normL1;
}

- (NSNumber *)normMax
{
    if (_normMax == nil) {
        _normMax = [self normOfType:MAVMatrixNormMax];
    }
    return _normMax;
}

- (NSNumber *)normFroebenius
{
    if (_normFroebenius == nil) {
        _normFroebenius = [self normOfType:MAVMatrixNormFroebenius];
    }
    return _normFroebenius;
}

- (MAVMatrix *)minorMatrix
{
    if (_minorMatrix == nil) {
        if ([self.values containsDoublePrecisionValues:(self.rows * self.columns)]) {
            double *minorValues = malloc(self.rows * self.columns * sizeof(double));
            
            int minorIdx = 0;
            for (int row = 0; row < self.rows; row += 1) {
                for (int col = 0; col < self.columns; col += 1) {
					MAVMutableMatrix *submatrix = [MAVMutableMatrix matrixWithRows:self.rows - 1
					                                                       columns:self.columns - 1
					                                                     precision:MCKValuePrecisionDouble
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
                    
                    minorValues[minorIdx++] = submatrix.determinant.doubleValue;
                }
            }
            
			_minorMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:minorValues length:self.values.length]
			                                      rows:self.rows
			                                   columns:self.columns
			                          leadingDimension:MAVMatrixLeadingDimensionRow];
        } else {
            float *minorValues = malloc(self.rows * self.columns * sizeof(float));
            
            int minorIdx = 0;
            for (int row = 0; row < self.rows; row += 1) {
                for (int col = 0; col < self.columns; col += 1) {
					MAVMutableMatrix *submatrix = [MAVMutableMatrix matrixWithRows:self.rows - 1
					                                                       columns:self.columns - 1
					                                                     precision:MCKValuePrecisionSingle
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
                    
                    minorValues[minorIdx++] = submatrix.determinant.floatValue;
                }
            }
            
			_minorMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:minorValues length:self.values.length]
			                                      rows:self.rows
			                                   columns:self.columns
			                          leadingDimension:MAVMatrixLeadingDimensionRow];
        }
        
    }
    
    return _minorMatrix;
}

- (MAVMatrix *)cofactorMatrix
{
    if (_cofactorMatrix == nil) {
        if (self.precision == MCKValuePrecisionDouble) {
            size_t size = self.rows * self.columns * sizeof(double);
            double *cofactors = malloc(size);
            
            int cofactorIdx = 0;
            for (int row = 0; row < self.rows; row += 1) {
                for (int col = 0; col < self.columns; col += 1) {
                    double minor = self.minorMatrix[row][col].doubleValue;
                    double multiplier = pow(-1.0, row + col + 2.0);
                    cofactors[cofactorIdx++] = minor * multiplier;
                }
            }
            
			_cofactorMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:cofactors length:size]
			                                         rows:self.rows
			                                      columns:self.columns
			                             leadingDimension:MAVMatrixLeadingDimensionRow];
        } else {
            size_t size = self.rows * self.columns * sizeof(float);
            float *cofactors = malloc(size);
            
            int cofactorIdx = 0;
            for (int row = 0; row < self.rows; row += 1) {
                for (int col = 0; col < self.columns; col += 1) {
                    float minor = self.minorMatrix[row][col].floatValue;
                    float multiplier = powf(-1.0f, row + col + 2.0f);
                    cofactors[cofactorIdx++] = minor * multiplier;
                }
            }
            
			_cofactorMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:cofactors length:size]
			                                         rows:self.rows
			                                      columns:self.columns
			                             leadingDimension:MAVMatrixLeadingDimensionRow];
        }
    }
    
    return _cofactorMatrix;
}

- (MAVMatrix *)adjugate
{
    if (_adjugate == nil) {
        _adjugate = self.cofactorMatrix.transpose;
    }
    
    return _adjugate;
}

#pragma mark - NSObject overrides

- (BOOL)isEqualToMatrix:(MAVMatrix *)otherMatrix
{
    if (!([otherMatrix isKindOfClass:[MAVMatrix class]] && self.rows == otherMatrix.rows && self.columns == otherMatrix.columns)) {
        return NO;
    } else {
        for (int row = 0; row < self.rows; row += 1) {
            for (int col = 0; col < self.columns; col += 1) {
                if ([[self valueAtRow:row column:col] compare:[otherMatrix valueAtRow:row column:col]] != NSOrderedSame) {
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
    } else if (![object isKindOfClass:[MAVMatrix class]]) {
        return NO;
    } else {
        return [self isEqualToMatrix:(MAVMatrix *)object];
    }
}

- (NSString *)description
{
    int padding;
    
    if (self.precision == MCKValuePrecisionDouble) {
        double max = DBL_MIN;
        for (int i = 0; i < self.rows * self.columns; i++) {
            max = MAX(max, fabs(((double *)self.values.bytes)[i]));
        }
        padding = floor(log10(max)) + 5;
    } else {
        float max = DBL_MIN;
        for (int i = 0; i < self.rows * self.columns; i++) {
            max = MAX(max, fabs(((float *)self.values.bytes)[i]));
        }
        padding = floorf(log10f(max)) + 5;
    }
    
    NSMutableString *description = [@"\n" mutableCopy];
    
    for (int j = 0; j < self.rows; j++) {
        NSMutableString *line = [NSMutableString string];
        for (int k = 0; k < self.columns; k++) {
            NSString *string = [NSString stringWithFormat:@"%.1f", self.precision == MCKValuePrecisionDouble ? [self valueAtRow:j column:k].doubleValue : [self valueAtRow:j column:k].floatValue];
            [line appendString:[string stringByPaddingToLength:padding withString:@" " startingAtIndex:0]];
        }
        [description appendFormat:@"%@\n", line];
    }
    
    return description;
}

- (id)debugQuickLookObject
{
    return self.description;
}

#pragma mark - Inspection

- (NSData *)valuesWithLeadingDimension:(MAVMatrixLeadingDimension)leadingDimension
{
    NSData *data;
    
    switch (self.packingMethod) {
            
        case MAVMatrixValuePackingMethodConventional: {
            if (self.precision == MCKValuePrecisionDouble) {
                size_t size = self.rows * self.columns * sizeof(double);
                double *values = malloc(size);
                if (self.leadingDimension == leadingDimension) {
                    for (int i = 0; i < self.rows * self.columns; i += 1) {
                        values[i] = ((double *)self.values.bytes)[i];
                    }
                } else {
                    int i = 0;
                    for (int j = 0; j < (leadingDimension == MAVMatrixLeadingDimensionRow ? self.rows : self.columns); j++) {
                        for (int k = 0; k < (leadingDimension == MAVMatrixLeadingDimensionRow ? self.columns : self.rows); k++) {
                            int idx = ((i * (leadingDimension == MAVMatrixLeadingDimensionRow ? self.rows : self.columns)) % (self.columns * self.rows)) + j;
                            values[i] = ((double *)self.values.bytes)[idx];
                            i++;
                        }
                    }
                }
                data = [NSData dataWithBytesNoCopy:values length:size];
            } else {
                size_t size = self.rows * self.columns * sizeof(float);
                float *values = malloc(size);
                if (self.leadingDimension == leadingDimension) {
                    for (int i = 0; i < self.rows * self.columns; i += 1) {
                        values[i] = ((float *)self.values.bytes)[i];
                    }
                } else {
                    int i = 0;
                    for (int j = 0; j < (leadingDimension == MAVMatrixLeadingDimensionRow ? self.rows : self.columns); j++) {
                        for (int k = 0; k < (leadingDimension == MAVMatrixLeadingDimensionRow ? self.columns : self.rows); k++) {
                            int idx = ((i * (leadingDimension == MAVMatrixLeadingDimensionRow ? self.rows : self.columns)) % (self.columns * self.rows)) + j;
                            values[i] = ((float *)self.values.bytes)[idx];
                            i++;
                        }
                    }
                }
                data = [NSData dataWithBytesNoCopy:values length:size];
            }
        } break;
            
            /**
             
             upper row major/lower col major
             
             1 2 3 4
             2 5 6 7
             3 6 8 9
             4 7 9 10
             
             upper col major/lower row major
             
             1 2 4 7
             2 3 5 8
             4 5 6 9
             7 8 9 10
             
             */
            
        case MAVMatrixValuePackingMethodPacked: {
            if (self.precision == MCKValuePrecisionDouble) {
                size_t size = self.rows * self.columns * sizeof(double);
                double *values = malloc(size);
                int k = 0; // current index in ivar array
                int z = 0; // current index in constructing array
                for (int i = 0; i < self.columns; i += 1) {
                    for (int j = 0; j < self.columns; j += 1) {
                        BOOL shouldTakePackedValue = (self.triangularComponent == MAVMatrixTriangularComponentUpper)
                        ? (self.leadingDimension == MAVMatrixLeadingDimensionColumn ? j <= i : i <= j)
                        : (self.leadingDimension == MAVMatrixLeadingDimensionColumn ? i <= j : j <= i);
                        if (shouldTakePackedValue) {
                            double value = ((double *)self.values.bytes)[k++];
                            values[z++] = value;
                        } else if (self.isSymmetric.isYes) {
                            double value = [self valueAtRow:i column:j].doubleValue;
                            values[z++] = value;
                        } else {
                            values[z++] = 0.0;
                        }
                    }
                }
                if (self.leadingDimension != leadingDimension) {
                    double *cvalues = malloc(self.rows * self.columns * sizeof(double));
                    int i = 0;
                    for (int j = 0; j < self.columns; j++) {
                        for (int k = 0; k < self.rows; k++) {
                            int idx = ((i * self.columns) % (self.columns * self.rows)) + j;
                            cvalues[i] = values[idx];
                            i++;
                        }
                    }
                    free(values);
                    values = cvalues;
                }
                data = [NSData dataWithBytesNoCopy:values length:size];
            } else {
                size_t size = self.rows * self.columns * sizeof(float);
                float *values = malloc(size);
                int k = 0; // current index in ivar array
                int z = 0; // current index in constructing array
                for (int i = 0; i < self.columns; i += 1) {
                    for (int j = 0; j < self.columns; j += 1) {
                        BOOL shouldTakePackedValue = (self.triangularComponent == MAVMatrixTriangularComponentUpper)
                        ? (self.leadingDimension == MAVMatrixLeadingDimensionColumn ? j <= i : i <= j)
                        : (self.leadingDimension == MAVMatrixLeadingDimensionColumn ? i <= j : j <= i);
                        if (shouldTakePackedValue) {
                            float value = ((float *)self.values.bytes)[k++];
                            values[z++] = value;
                        } else if (self.isSymmetric.isYes) {
                            float value = [self valueAtRow:i column:j].floatValue;
                            values[z++] = value;
                        } else {
                            values[z++] = 0.f;
                        }
                    }
                }
                if (self.leadingDimension != leadingDimension) {
                    float *cvalues = malloc(self.rows * self.columns * sizeof(float));
                    int i = 0;
                    for (int j = 0; j < self.columns; j++) {
                        for (int k = 0; k < self.rows; k++) {
                            int idx = ((i * self.columns) % (self.columns * self.rows)) + j;
                            cvalues[i] = values[idx];
                            i++;
                        }
                    }
                    free(values);
                    values = cvalues;
                }
                data = [NSData dataWithBytesNoCopy:values length:size];
            }
        } break;
            
        case MAVMatrixValuePackingMethodBand: {
            /*
             
             found at http://www.roguewave.com/Portals/0/products/imsl-numerical-libraries/c-library/docs/6.0/math/default.htm?turl=matrixstoragemodes.htm
             
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
            if (self.precision == MCKValuePrecisionDouble) {
                size_t size = self.rows * self.columns * sizeof(double);
                double *values = malloc(size);
                for (int i = 0; i < self.columns; i += 1) {
                    for (int j = 0; j < self.columns; j += 1) {
                        int indexIntoBandArray = ( i - j + self.upperCodiagonals ) * self.columns + j;
                        int indexIntoUnpackedArray = (leadingDimension == MAVMatrixLeadingDimensionColumn ? j : i) * self.columns + (leadingDimension == MAVMatrixLeadingDimensionColumn ? i : j);
                        if (indexIntoBandArray >= 0 && indexIntoBandArray < self.bandwidth * self.columns) {
                            values[indexIntoUnpackedArray] = ((double *)self.values.bytes)[indexIntoBandArray];
                        } else {
                            values[indexIntoUnpackedArray] = 0.0;
                        }
                    }
                }
                data = [NSData dataWithBytesNoCopy:values length:size];
            } else {
                size_t size = self.rows * self.columns * sizeof(float);
                float *values = malloc(size);
                for (int i = 0; i < self.columns; i += 1) {
                    for (int j = 0; j < self.columns; j += 1) {
                        int indexIntoBandArray = ( i - j + self.upperCodiagonals ) * self.columns + j;
                        int indexIntoUnpackedArray = (leadingDimension == MAVMatrixLeadingDimensionColumn ? j : i) * self.columns + (leadingDimension == MAVMatrixLeadingDimensionColumn ? i : j);
                        if (indexIntoBandArray >= 0 && indexIntoBandArray < self.bandwidth * self.columns) {
                            values[indexIntoUnpackedArray] = ((float *)self.values.bytes)[indexIntoBandArray];
                        } else {
                            values[indexIntoUnpackedArray] = 0.0f;
                        }
                    }
                }
                data = [NSData dataWithBytesNoCopy:values length:size];
            }
        } break;
            
        default: break;
    }
    
    return data;
}

- (NSData *)valuesFromTriangularComponent:(MAVMatrixTriangularComponent)triangularComponent
                         leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
                            packingMethod:(MAVMatrixValuePackingMethod)packingMethod
{
    NSAssert(self.rows == self.columns, @"Cannot extract triangular components from non-square matrices");
    
    NSData *data;
    
    int numberOfValues = packingMethod == MAVMatrixValuePackingMethodPacked ? ((self.rows * (self.rows + 1)) / 2) : self.rows * self.rows;
    int i = 0;
    int outerLimit = self.leadingDimension == MAVMatrixLeadingDimensionRow ? self.rows : self.columns;
    int innerLimit = self.leadingDimension == MAVMatrixLeadingDimensionRow ? self.columns : self.rows;
    
    if (self.precision == MCKValuePrecisionDouble) {
        size_t size = numberOfValues * sizeof(double);
        double *values = malloc(size);
        for (int j = 0; j < outerLimit; j++) {
            for (int k = 0; k < innerLimit; k++) {
                int row = leadingDimension == MAVMatrixLeadingDimensionRow ? j : k;
                int col = leadingDimension == MAVMatrixLeadingDimensionRow ? k : j;
                
                BOOL shouldStoreValueForLowerTriangle = triangularComponent == MAVMatrixTriangularComponentLower && col <= row;
                BOOL shouldStoreValueForUpperTriangle = triangularComponent == MAVMatrixTriangularComponentUpper && row <= col;
                
                if (shouldStoreValueForLowerTriangle || shouldStoreValueForUpperTriangle) {
                    double value = [self valueAtRow:row column:col].doubleValue;
                    values[i++] = value;
                } else if (packingMethod == MAVMatrixValuePackingMethodConventional) {
                    values[i++] = 0.0;
                }
            }
        }
        data = [NSData dataWithBytesNoCopy:values length:size];
    } else {
        size_t size = numberOfValues * sizeof(float);
        float *values = malloc(size);
        for (int j = 0; j < outerLimit; j++) {
            for (int k = 0; k < innerLimit; k++) {
                int row = leadingDimension == MAVMatrixLeadingDimensionRow ? j : k;
                int col = leadingDimension == MAVMatrixLeadingDimensionRow ? k : j;
                
                BOOL shouldStoreValueForLowerTriangle = triangularComponent == MAVMatrixTriangularComponentLower && col <= row;
                BOOL shouldStoreValueForUpperTriangle = triangularComponent == MAVMatrixTriangularComponentUpper && row <= col;
                
                if (shouldStoreValueForLowerTriangle || shouldStoreValueForUpperTriangle) {
                    float value = [self valueAtRow:row column:col].floatValue;
                    values[i++] = value;
                } else if (packingMethod == MAVMatrixValuePackingMethodConventional) {
                    values[i++] = 0.0f;
                }
            }
        }
        data = [NSData dataWithBytesNoCopy:values length:size];
    }
    
    return data;
}

- (NSData *)valuesInBandBetweenUpperCodiagonal:(int)upperCodiagonal
                               lowerCodiagonal:(int)lowerCodiagonal
{
    NSAssert(self.rows == self.columns, @"Cannot extract bands from rectangular matrices.");
    
    // TODO: handle rectangular matrices
    
    NSData *data;
    
    int bandwidth = upperCodiagonal + lowerCodiagonal + 1;
    int numberOfValues = bandwidth * self.columns;
    int i = 0;
    
    if (self.precision == MCKValuePrecisionDouble) {
        size_t size = numberOfValues * sizeof(double);
        double *values = malloc(size);
        for (int col = upperCodiagonal; col >= 0; col--) {
            for (int row = -col; row < self.rows - col; row++) {
                if (row < 0) {
                    values[i++] = 0.0;
                } else {
                    double value = [self valueAtRow:row column:col + row].doubleValue;
                    values[i++] = value;
                }
            }
        }
        
        for (int row = 1; row <= lowerCodiagonal; row++) {
            for (int col = 0; col < self.columns; col++) {
                if (col < self.columns - row) {
                    double value = [self valueAtRow:row + col column:col].doubleValue;
                    values[i++] = value;
                } else {
                    values[i++] = 0.0;
                }
            }
        }
        data = [NSData dataWithBytesNoCopy:values length:size];
    } else {
        size_t size = numberOfValues * sizeof(float);
        float *values = malloc(size);
        for (int col = upperCodiagonal; col >= 0; col--) {
            for (int row = -col; row < self.rows - col; row++) {
                if (row < 0) {
                    values[i++] = 0.0f;
                } else {
                    float value = [self valueAtRow:row column:col + row].floatValue;
                    values[i++] = value;
                }
            }
        }
        
        for (int row = 1; row <= lowerCodiagonal; row++) {
            for (int col = 0; col < self.columns; col++) {
                if (col < self.columns - row) {
                    float value = [self valueAtRow:row + col column:col].floatValue;
                    values[i++] = value;
                } else {
                    values[i++] = 0.0f;
                }
            }
        }
        data = [NSData dataWithBytesNoCopy:values length:size];
    }
    
    return data;
}

- (NSNumber *)valueAtRow:(int)row column:(int)column
{
    NSAssert1(row >= 0 && row < self.rows, @"row = %u is outside the range of possible rows.", row);
    NSAssert1(column >= 0 && column < self.columns, @"column = %u is outside the range of possible columns.", column);
    
    switch (self.packingMethod) {
            
        case MAVMatrixValuePackingMethodConventional: {
            if (self.leadingDimension == MAVMatrixLeadingDimensionRow) {
                return @(self.precision == MCKValuePrecisionDouble ? ((double *)self.values.bytes)[row * self.columns + column] : ((float *)self.values.bytes)[row * self.columns + column]);
            } else {
                return @(self.precision == MCKValuePrecisionDouble ? ((double *)self.values.bytes)[column * self.rows + row] : ((float *)self.values.bytes)[column * self.rows + row]);
            }
        } break;
            
        case MAVMatrixValuePackingMethodPacked: {
            if (self.triangularComponent == MAVMatrixTriangularComponentLower) {
                if (column <= row || self.isSymmetric.isYes) {
                    if (column > row && self.isSymmetric.isYes) {
                        int temp = row;
                        row = column;
                        column = temp;
                    }
                    if (self.leadingDimension == MAVMatrixLeadingDimensionColumn) {
                        // number of values in columns before desired column
                        int valuesInSummedColumns = ((self.rows * (self.rows + 1)) - ((self.rows - column) * (self.rows - column + 1))) / 2;
                        int index = valuesInSummedColumns + row - column;
                        return @(self.precision == MCKValuePrecisionDouble ? ((double *)self.values.bytes)[index] : ((float *)self.values.bytes)[index]);
                    } else {
                        // number of values in rows before desired row
                        int summedRows = row ;
                        int valuesInSummedRows = summedRows * (summedRows + 1) / 2;
                        int index = valuesInSummedRows + column;
                        return @(self.precision == MCKValuePrecisionDouble ? ((double *)self.values.bytes)[index] : ((float *)self.values.bytes)[index]);
                    }
                } else {
                    return self.precision == MCKValuePrecisionDouble ? @0.0 : @0.0f;
                }
            } else /* if (self.triangularComponent == MAVMatrixTriangularComponentUpper) */ {
                if (row <= column || self.isSymmetric.isYes) {
                    if (row > column && self.isSymmetric.isYes) {
                        int temp = row;
                        row = column;
                        column = temp;
                    }
                    if (self.leadingDimension == MAVMatrixLeadingDimensionColumn) {
                        // number of values in columns before desired column
                        int summedColumns = column;
                        int valuesInSummedColumns = summedColumns * (summedColumns + 1) / 2;
                        int index = valuesInSummedColumns + row;
                        return @(self.precision == MCKValuePrecisionDouble ? ((double *)self.values.bytes)[index] : ((float *)self.values.bytes)[index]);
                    } else {
                        // number of values in rows before desired row
                        int valuesInSummedRows = ((self.columns * (self.columns + 1)) - ((self.columns - row) * (self.columns - row + 1))) / 2;
                        int index = valuesInSummedRows + column - row;
                        return @(self.precision == MCKValuePrecisionDouble ? ((double *)self.values.bytes)[index] : ((float *)self.values.bytes)[index]);
                    }
                } else {
                    return self.precision == MCKValuePrecisionDouble ? @0.0 : @0.0f;
                }
            }
        } break;
            
        case MAVMatrixValuePackingMethodBand: {
            int indexIntoBandArray = ( row - column + self.upperCodiagonals ) * self.columns + column;
            if (indexIntoBandArray >= 0 && indexIntoBandArray < self.bandwidth * self.columns) {
                return @(self.precision == MCKValuePrecisionDouble ? ((double *)self.values.bytes)[indexIntoBandArray] : ((float *)self.values.bytes)[indexIntoBandArray]);
            } else {
                return self.precision == MCKValuePrecisionDouble ? @0.0 : @0.0f;
            }
        } break;
            
        default: break;
    }
}

- (MAVVector *)rowVectorForRow:(int)row
{
    NSAssert1(row >= 0 && row < self.rows, @"row = %u is outside the range of possible rows.", row);
    
    MAVVector *vector;
    
    if (self.precision == MCKValuePrecisionDouble) {
        size_t size = self.columns * sizeof(double);
        double *values = malloc(size);
        for (int col = 0; col < self.columns; col += 1) {
            values[col] = [self valueAtRow:row column:col].doubleValue;
        }
        vector = [MAVVector vectorWithValues:[NSData dataWithBytesNoCopy:values length:size] length:self.columns vectorFormat:MAVVectorFormatRowVector];
    } else {
        size_t size = self.columns * sizeof(float);
        float *values = malloc(size);
        for (int col = 0; col < self.columns; col += 1) {
            values[col] = [self valueAtRow:row column:col].floatValue;
        }
        vector = [MAVVector vectorWithValues:[NSData dataWithBytesNoCopy:values length:size] length:self.columns vectorFormat:MAVVectorFormatRowVector];
    }
    
    return vector;
}

- (MAVVector *)columnVectorForColumn:(int)column
{
    NSAssert1(column >= 0 && column < self.columns, @"column = %u is outside the range of possible columns.", column);
    
    MAVVector *vector;
    
    if (self.precision == MCKValuePrecisionDouble) {
        size_t size = self.rows * sizeof(double);
        double *values = malloc(size);
        for (int row = 0; row < self.rows; row += 1) {
            values[row] = [self valueAtRow:row column:column].doubleValue;
        }
        vector = [MAVVector vectorWithValues:[NSData dataWithBytesNoCopy:values length:size] length:self.rows vectorFormat:MAVVectorFormatColumnVector];
    } else {
        size_t size = self.rows * sizeof(float);
        float *values = malloc(size);
        for (int row = 0; row < self.rows; row += 1) {
            values[row] = [self valueAtRow:row column:column].floatValue;
        }
        vector = [MAVVector vectorWithValues:[NSData dataWithBytesNoCopy:values length:size] length:self.rows vectorFormat:MAVVectorFormatColumnVector];
    }
    
    return vector;
}

- (NSArray *)rowVectors
{
    NSMutableArray *vectors = [NSMutableArray new];
    for (int i = 0; i < self.rows; i++) {
        [vectors addObject:[self rowVectorForRow:i]];
    }
    return vectors;
}

- (NSArray *)columnVectors
{
    NSMutableArray *vectors = [NSMutableArray new];
    for (int i = 0; i < self.columns; i++) {
        [vectors addObject:[self columnVectorForColumn:i]];
    }
    return vectors;
}

#pragma mark - Subscripting

- (MAVVector *)objectAtIndexedSubscript:(int)idx
{
    NSAssert1(idx >= 0 && idx < self.rows, @"idx = %u is outside the range of possible rows.", idx);
    
    return [self rowVectorForRow:idx];
}

#pragma mark - Class-level matrix operations

// TODO: this should really return a vector instead of a matrix
+ (MAVMatrix *)solveLinearSystemWithMatrixA:(MAVMatrix *)A
                                   valuesB:(MAVMatrix *)B
{
    NSAssert(A.precision == B.precision, @"Precisions do not match.");
    
    MAVMatrix *matrix;
    
    NSData *aData = [A valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
    
    if (A.rows == A.columns) {
        // solve for square matrix A
        
        int n = A.rows;
        int nrhs = 1;
        int lda = n;
        int ldb = n;
        int info;
        int *ipiv = malloc(n * sizeof(int));
        int nb = B.rows;
        
        if (A.precision == MCKValuePrecisionDouble) {
            double *a = malloc(n * n * sizeof(double));
            for (int i = 0; i < n * n; i++) {
                a[i] = ((double*)aData.bytes)[i];
            } // TODO: maybe call -copy on aData instead of looping for deep copy here
            double *b = malloc(nb * sizeof(double));
            for (int i = 0; i < nb; i++) {
                b[i] = ((double *)B.values.bytes)[i];
            } // TODO: maybe call -copy on B.values here instead of looping for deep copy
            
            dgesv_(&n, &nrhs, a, &lda, ipiv, b, &ldb, &info);
            
            if (info != 0) {
                free(ipiv);
                free(a);
                free(b);
                return nil;
            } else {
                size_t size = n * sizeof(double);
                double *solutionValues = malloc(size);
                for (int i = 0; i < n; i++) {
                    solutionValues[i] = b[i];
                }
                free(ipiv);
                free(a);
                free(b);
				matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:solutionValues length:size]
				                                rows:n
				                             columns:1];
            }
        } else {
            float *a = malloc(n * n * sizeof(float));
            for (int i = 0; i < n * n; i++) {
                a[i] = ((float*)aData.bytes)[i];
            } // TODO: maybe call -copy on aData instead of looping for deep copy here
            float *b = malloc(nb * sizeof(float));
            for (int i = 0; i < nb; i++) {
                b[i] = ((float *)B.values.bytes)[i];
            } // TODO: maybe call -copy on B.values here instead of looping for deep copy
            
            sgesv_(&n, &nrhs, a, &lda, ipiv, b, &ldb, &info);
            
            if (info != 0) {
                free(ipiv);
                free(a);
                free(b);
                return nil;
            } else {
                size_t size = n * sizeof(float);
                float *solutionValues = malloc(size);
                for (int i = 0; i < n; i++) {
                    solutionValues[i] = b[i];
                }
                free(ipiv);
                free(a);
                free(b);
				matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:solutionValues length:size]
				                                rows:n
				                             columns:1];
            }
        }
    } else {
        // solve for general m x n rectangular matrix A
        
        /*
         solution interpretation:
         
         if  m >= n, rows 1 to n of b contain the least
         squares solution vectors; the residual sum of squares for the
         solution in each column is given by the sum of squares of
         elements N+1 to M in that column;
         
         if  m < n, rows 1 to n of b contain the
         minimum norm solution vectors;
         */
        
        int m = A.rows;
        int n = A.columns;
        int nrhs = 1;
        int lda = A.rows;
        int ldb = A.rows;
        int info;
        int lwork = -1;
        int nb = B.rows;
        
        if (A.precision == MCKValuePrecisionDouble) {
            double wkopt;
            double* work;
            double *a = malloc(m * n * sizeof(double));
            for (int i = 0; i < m * n; i++) {
                a[i] = ((double *)aData.bytes)[i];
            } // TODO: maybe call -copy on aData instead of looping for deep copy here
            double *b = malloc(nb * sizeof(double));
            for (int i = 0; i < nb; i++) {
                b[i] = ((double *)B.values.bytes)[i];
            } // TODO: maybe call -copy on B.values here instead of looping for deep copy
            
            // get the optimal workspace
            dgels_("No transpose", &m, &n, &nrhs, a, &lda, b, &ldb, &wkopt, &lwork, &info);
            
            lwork = (int)wkopt;
            work = (double*)malloc(lwork * sizeof(double));
            
            // solve the system of equations
            dgels_("No transpose", &m, &n, &nrhs, a, &lda, b, &ldb, work, &lwork, &info);
            
            if (info != 0) {
                free(a);
                free(b);
                free(work);
                return nil;
            } else {
                size_t size = n * sizeof(double);
                double *solutionValues = malloc(size);
                for (int i = 0; i < n; i++) {
                    solutionValues[i] = b[i];
                }
                free(a);
                free(b);
                free(work);
				matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:solutionValues length:size]
				                                rows:n
				                             columns:1];
            }
        } else {
            float wkopt;
            float* work;
            float *a = malloc(m * n * sizeof(float));
            for (int i = 0; i < m * n; i++) {
                a[i] = ((float *)aData.bytes)[i];
            } // TODO: maybe call -copy on aData instead of looping for deep copy here
            float *b = malloc(nb * sizeof(float));
            for (int i = 0; i < nb; i++) {
                b[i] = ((float *)B.values.bytes)[i];
            } // TODO: maybe call -copy on B.values here instead of looping for deep copy
            
            // get the optimal workspace
            sgels_("No transpose", &m, &n, &nrhs, a, &lda, b, &ldb, &wkopt, &lwork, &info);
            
            lwork = (int)wkopt;
            work = (float*)malloc(lwork * sizeof(float));
            
            // solve the system of equations
            sgels_("No transpose", &m, &n, &nrhs, a, &lda, b, &ldb, work, &lwork, &info);
            
            if (info != 0) {
                free(a);
                free(b);
                free(work);
                return nil;
            } else {
                size_t size = n * sizeof(float);
                float *solutionValues = malloc(size);
                for (int i = 0; i < n; i++) {
                    solutionValues[i] = b[i];
                }
                free(a);
                free(b);
                free(work);
				matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:solutionValues length:size]
				                                rows:n
				                             columns:1];
            }
        }
    }
    
    return matrix;
}

+ (MAVMatrix *)productOfMatrices:(NSArray *)matrices
{
    // TODO: implement hu-shing partitioning algorithm
    
    return nil;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MAVMatrix *matrixCopy = [[self class] allocWithZone:zone];
    
    [self deepCopyMatrix:self intoNewMatrix:matrixCopy];
    
    return matrixCopy;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    MAVMutableMatrix *mutableCopy = [MAVMutableMatrix allocWithZone:zone];
    
    [self deepCopyMatrix:self intoNewMatrix:mutableCopy];
    
    return mutableCopy;
}

#pragma mark - Private interface

- (void)deepCopyMatrix:(MAVMatrix *)matrix intoNewMatrix:(MAVMatrix *)newMatrix
{
    newMatrix->_columns = matrix->_columns;
    newMatrix->_rows = matrix->_rows;
    newMatrix->_leadingDimension = matrix->_leadingDimension;
    newMatrix->_triangularComponent = matrix->_triangularComponent;
    newMatrix->_packingMethod = matrix->_packingMethod;
    newMatrix->_definiteness = matrix->_definiteness;
    newMatrix->_precision = matrix->_precision;
    
    if (_precision == MCKValuePrecisionDouble) {
        double *values = malloc(matrix->_values.length);
        for (int i = 0; i < matrix->_values.length / sizeof(double); i++) {
            values[i] = ((double *)matrix->_values.bytes)[i];
        }
        newMatrix->_values = [NSData dataWithBytesNoCopy:values length:matrix->_values.length];
    } else {
        float *values = malloc(matrix->_values.length);
        for (int i = 0; i < matrix->_values.length / sizeof(float); i++) {
            values[i] = ((float *)matrix->_values.bytes)[i];
        }
        newMatrix->_values = [NSData dataWithBytesNoCopy:values length:matrix->_values.length];
    }
    
    newMatrix->_transpose = matrix->_transpose.copy;
    newMatrix->_determinant = matrix->_determinant.copy;
    newMatrix->_inverse = matrix->_inverse.copy;
    newMatrix->_adjugate = matrix->_adjugate.copy;
    newMatrix->_conditionNumber = matrix->_conditionNumber.copy;
    newMatrix->_qrFactorization = matrix->_qrFactorization.copy;
    newMatrix->_luFactorization = matrix->_luFactorization.copy;
    newMatrix->_singularValueDecomposition = matrix->_singularValueDecomposition.copy;
    newMatrix->_eigendecomposition = matrix->_eigendecomposition.copy;
    newMatrix->_diagonalValues = matrix->_diagonalValues.copy;
    newMatrix->_minorMatrix = matrix->_minorMatrix.copy;
    newMatrix->_cofactorMatrix = matrix->_cofactorMatrix.copy;
    newMatrix->_isSymmetric = matrix->_isSymmetric.copy;
    newMatrix->_trace = matrix->_trace.copy;
    newMatrix->_normInfinity = matrix->_normInfinity.copy;
    newMatrix->_normL1 = matrix->_normL1.copy;
    newMatrix->_normFroebenius = matrix->_normFroebenius.copy;
    newMatrix->_normMax = matrix->_normMax.copy;
    
    newMatrix->_bandwidth = matrix->_bandwidth;
    newMatrix->_numberOfBandValues = matrix->_numberOfBandValues;
    newMatrix->_upperCodiagonals = matrix->_upperCodiagonals;
}

+ (NSData *)randomArrayOfSize:(int)size
                    precision:(MCKValuePrecision)precision
{
    NSData *data;
    
    if (precision == MCKValuePrecisionDouble) {
        NSUInteger dataSize = size * sizeof(double);
        double *values = malloc(dataSize);
        for (int i = 0; i < size; i += 1) {
            values[i] = randomDouble;
        }
        data = [NSData dataWithBytesNoCopy:values length:dataSize];
    } else {
        NSUInteger dataSize = size * sizeof(float);
        float *values = malloc(dataSize);
        for (int i = 0; i < size; i += 1) {
            values[i] = randomFloat;
        }
        data = [NSData dataWithBytesNoCopy:values length:dataSize];
    }
    
    return data;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _rows = 0;
        _columns = 0;
        _values = nil;
        _precision = MCKValuePrecisionSingle;
        
        _leadingDimension = MAVMatrixLeadingDimensionColumn;
        _packingMethod = MAVMatrixValuePackingMethodConventional;
        _triangularComponent = MAVMatrixTriangularComponentBoth;
        
        _isSymmetric = [MCKTribool triboolWithValue:MCKTriboolValueUnknown];
        _definiteness = MAVMatrixDefinitenessUnknown;
        _qrFactorization = nil;
        _luFactorization = nil;
        _singularValueDecomposition = nil;
        _eigendecomposition = nil;
        _inverse = nil;
        _transpose = nil;
        _conditionNumber = nil;
        _determinant = nil;
        _diagonalValues = nil;
        _trace = nil;
        _adjugate = nil;
        _minorMatrix = nil;
        _cofactorMatrix = nil;
        _normInfinity = nil;
        _normL1 = nil;
        _normMax = nil;
        _normFroebenius = nil;
    }
    return self;
}

- (NSNumber *)normOfType:(MAVMatrixNorm)normType
{
    NSNumber *normResult;
    
    int m = self.rows;
    int n = self.columns;
    NSData *valueData = [self valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
    char *norm = "";
    if (normType == MAVMatrixNormL1) {
        norm = "1";
    } else if (normType == MAVMatrixNormInfinity) {
        norm = "I";
    } else if (normType == MAVMatrixNormMax) {
        norm = "M";
    } else /* if (normType == MAVMatrixNormFroebenius) */ {
        norm = "F";
    }
    
    if (self.precision == MCKValuePrecisionDouble) {
        normResult = @(dlange_(norm, &m, &n, (double *)valueData.bytes, &m, nil));
    } else {
        normResult = @(slange_(norm, &m, &n, (float *)valueData.bytes, &m, nil));
    }
    
    return normResult;
}

+ (NSData *)dataFromVectors:(NSArray *)vectors
{
    MAVVector *firstVector = vectors.firstObject;
    int rows = firstVector.vectorFormat == MAVVectorFormatRowVector ? (int)vectors.count : firstVector.length;
    int columns = firstVector.vectorFormat == MAVVectorFormatRowVector ? firstVector.length : (int)vectors.count;

    NSData * data;

    if (((MAVVector *)vectors[0])[0].isDoublePrecision) {
        size_t size = rows * columns * sizeof(double);
        double *values = malloc(size);
        [vectors enumerateObjectsUsingBlock:^(MAVVector *rowVector, NSUInteger row, BOOL *stop) {
            for(int i = 0; i < columns; i++) {
                NSNumber *value = [rowVector valueAtIndex:i];
                values[row * columns + i] = value.doubleValue;
            }
        }];
        data = [NSData dataWithBytesNoCopy:values length:size];
    } else {
        size_t size = rows * columns * sizeof(float);
        float *values = malloc(size);
        [vectors enumerateObjectsUsingBlock:^(MAVVector *rowVector, NSUInteger row, BOOL *stop) {
            for(int i = 0; i < columns; i++) {
                NSNumber *value = [rowVector valueAtIndex:i];
                values[row * columns + i] = value.floatValue;
            }
        }];
        data = [NSData dataWithBytesNoCopy:values length:size];
    }
    
    return data;
}

@end

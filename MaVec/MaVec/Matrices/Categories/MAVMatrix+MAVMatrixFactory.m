//
//  MAVMatrix+MAVMatrixFactory.m
//  MaVec
//
//  Created by Andrew McKnight on 12/26/15.
//
//  Copyright © 2015 AMProductions
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

#import <MCKNumerics/MCKNumerics.h>

#import "MAVMatrix+MAVMatrixFactory.h"
#import "MAVMatrix-Protected.h"
#import "MAVMutableMatrix.h"
#import "MAVVector.h"
#import "NSData+MAVMatrixData.h"

@implementation MAVMatrix (MAVMatrixFactory)

+ (instancetype)matrixWithColumnVectors:(NSArray *)columnVectors
{
    MAVIndex columns = (MAVIndex)columnVectors.count;
    MAVIndex rows = ((MAVVector *)columnVectors.firstObject).length;

    BOOL isDoublePrecision = ((MAVVector *)columnVectors[0])[0].isDoublePrecision;

    MAVMatrix *matrix = [[self alloc] initWithValues:[NSData dataFromVectors:columnVectors]
                                                rows:rows
                                             columns:columns
                                    leadingDimension:MAVMatrixLeadingDimensionColumn
                                       packingMethod:MAVMatrixValuePackingMethodConventional
                                 triangularComponent:MAVMatrixTriangularComponentBoth];
    matrix.precision = isDoublePrecision ? MCKPrecisionDouble : MCKPrecisionSingle;

    return matrix;
}

+ (instancetype)matrixWithRowVectors:(NSArray *)rowVectors
{
    MAVIndex rows = (MAVIndex)rowVectors.count;
    MAVIndex columns = ((MAVVector *)rowVectors.firstObject).length;

    BOOL isDoublePrecision = ((MAVVector *)rowVectors[0])[0].isDoublePrecision;

    MAVMatrix *matrix = [[self alloc] initWithValues:[NSData dataFromVectors:rowVectors]
                                                rows:rows
                                             columns:columns
                                    leadingDimension:MAVMatrixLeadingDimensionRow
                                       packingMethod:MAVMatrixValuePackingMethodConventional
                                 triangularComponent:MAVMatrixTriangularComponentBoth];
    matrix.precision = isDoublePrecision ? MCKPrecisionDouble : MCKPrecisionSingle;

    return matrix;
}

+ (instancetype)matrixWithRows:(MAVIndex)rows
                       columns:(MAVIndex)columns
                     precision:(MCKPrecision)precision
{
    MAVMatrix *matrix;

    if (precision == MCKPrecisionDouble) {
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

+ (instancetype)matrixWithRows:(MAVIndex)rows
                       columns:(MAVIndex)columns
                     precision:(MCKPrecision)precision
              leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
{
    MAVMatrix *matrix = [self matrixWithRows:rows columns:columns precision:precision];
    matrix.leadingDimension = leadingDimension;
    return matrix;
}

+ (instancetype)matrixWithValues:(NSData *)values
                            rows:(MAVIndex)rows
                         columns:(MAVIndex)columns
{
    return [[self alloc] initWithValues:values
                                   rows:rows
                                columns:columns
                       leadingDimension:MAVMatrixLeadingDimensionColumn
                          packingMethod:MAVMatrixValuePackingMethodConventional
                    triangularComponent:MAVMatrixTriangularComponentBoth];
}

+ (instancetype)matrixWithValues:(NSData *)values
                            rows:(MAVIndex)rows
                         columns:(MAVIndex)columns
                leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
{
    return [[self alloc] initWithValues:values
                                   rows:rows
                                columns:columns
                       leadingDimension:leadingDimension
                          packingMethod:MAVMatrixValuePackingMethodConventional
                    triangularComponent:MAVMatrixTriangularComponentBoth];
}



+ (instancetype)matrixFilledWithValue:(NSNumber *)value
                                 rows:(MAVIndex)rows
                              columns:(MAVIndex)columns
{
    MAVMatrix *matrix = [self matrixWithValues:[NSData dataForArrayFilledWithValue:value length:rows * columns]
                                          rows:rows
                                       columns:columns];
    matrix.symmetric = [MCKTribool triboolWithValue:MCKTriboolValueYes];
    return matrix;
}

+ (instancetype)triangularMatrixFilledWithValue:(NSNumber *)value
                                          order:(MAVIndex)order
                            triangularComponent:(MAVMatrixTriangularComponent)triangularComponent
{
    size_t valueCount = (order * (order + 1)) / 2;
    return [self triangularMatrixWithPackedValues:[NSData dataForArrayFilledWithValue:value length:valueCount]
                            ofTriangularComponent:triangularComponent
                                 leadingDimension:MAVMatrixLeadingDimensionColumn
                                            order:order];
}

+ (instancetype)bandMatrixFilledWithValue:(NSNumber *)value
                                    order:(MAVIndex)order
                         upperCodiagonals:(MAVIndex)upperCodiagonals
                         lowerCodiagonals:(MAVIndex)lowerCodiagonals
{
    size_t valueCount = (lowerCodiagonals + upperCodiagonals + 1) * order;
    return [MAVMatrix bandMatrixWithValues:[NSData dataForArrayFilledWithValue:value length:valueCount]
                                     order:order
                          upperCodiagonals:upperCodiagonals
                          lowerCodiagonals:lowerCodiagonals];
}

+ (instancetype)identityMatrixOfOrder:(MAVIndex)order
                            precision:(MCKPrecision)precision
{
    MAVMatrix *matrix;

    if (precision == MCKPrecisionDouble) {
        NSUInteger size = order * order * sizeof(double);
        double *values = malloc(size);
        for (MAVIndex i = 0; i < order; i++) {
            for (MAVIndex j = 0; j < order; j++) {
                values[i * order + j] = i == j ? 1.0 : 0.0;
            }
        }
        matrix = [self matrixWithValues:[NSData dataWithBytesNoCopy:values length:size]
                                   rows:order
                                columns:order];
    } else {
        NSUInteger size = order * order * sizeof(float);
        float *values = malloc(size);
        for (MAVIndex i = 0; i < order; i++) {
            for (MAVIndex j = 0; j < order; j++) {
                values[i * order + j] = i == j ? 1.0f : 0.0f;
            }
        }
        matrix = [self matrixWithValues:[NSData dataWithBytesNoCopy:values length:size]
                                   rows:order
                                columns:order];
    }

    matrix.isIdentity = [MCKTribool triboolWithValue:MCKTriboolValueYes];

    return matrix;
}

+ (instancetype)diagonalMatrixWithValues:(NSData *)values
                                   order:(MAVIndex)order
{
    return [self bandMatrixWithValues:values order:order upperCodiagonals:0 lowerCodiagonals:0];
}

+ (instancetype)triangularMatrixWithPackedValues:(NSData *)values
                           ofTriangularComponent:(MAVMatrixTriangularComponent)triangularComponent
                                leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
                                           order:(MAVIndex)order
{
    MAVMatrix *matrix = [[self alloc] initWithValues:values
                                                rows:order
                                             columns:order
                                    leadingDimension:leadingDimension
                                       packingMethod:MAVMatrixValuePackingMethodPacked
                                 triangularComponent:triangularComponent];
    matrix.symmetric = [MCKTribool triboolWithValue:MCKTriboolValueNo];
    return matrix;
}

+ (instancetype)symmetricMatrixWithPackedValues:(NSData *)values
                            triangularComponent:(MAVMatrixTriangularComponent)triangularComponent
                               leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
                                          order:(MAVIndex)order
{
    MAVMatrix *matrix = [[self alloc] initWithValues:values
                                                rows:order
                                             columns:order
                                    leadingDimension:leadingDimension
                                       packingMethod:MAVMatrixValuePackingMethodPacked
                                 triangularComponent:triangularComponent];
    matrix.symmetric = [MCKTribool triboolWithValue:MCKTriboolValueYes];
    return matrix;
}

+ (instancetype)bandMatrixWithValues:(NSData *)values
                               order:(MAVIndex)order
                    upperCodiagonals:(MAVIndex)upperCodiagonals
                    lowerCodiagonals:(MAVIndex)lowerCodiagonals
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
    matrix.precision = [values containsDoublePrecisionValues:matrix.numberOfBandValues] ? MCKPrecisionDouble : MCKPrecisionSingle;

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

+ (instancetype)randomMatrixWithRows:(MAVIndex)rows
                             columns:(MAVIndex)columns
                           precision:(MCKPrecision)precision
{
    return [self matrixWithValues:[self randomArrayOfSize:rows * columns precision:precision]
                             rows:rows
                          columns:columns];
}

+ (instancetype)randomSymmetricMatrixOfOrder:(MAVIndex)order
                                   precision:(MCKPrecision)precision
{
    return [self symmetricMatrixWithPackedValues:[self randomArrayOfSize:(order * (order + 1)) / 2 precision:precision]
                             triangularComponent:MAVMatrixTriangularComponentUpper
                                leadingDimension:MAVMatrixLeadingDimensionColumn
                                           order:order];
}

+ (instancetype)randomDiagonalMatrixOfOrder:(MAVIndex)order
                                  precision:(MCKPrecision)precision
{
    return [self diagonalMatrixWithValues:[self randomArrayOfSize:order precision:precision]
                                    order:order];
}

+ (instancetype)randomTriangularMatrixOfOrder:(MAVIndex)order
                          triangularComponent:(MAVMatrixTriangularComponent)triangularComponent
                                    precision:(MCKPrecision)precision
{
    return [self triangularMatrixWithPackedValues:[self randomArrayOfSize:(order * (order + 1)) / 2 precision:precision]
                            ofTriangularComponent:triangularComponent
                                 leadingDimension:MAVMatrixLeadingDimensionColumn
                                            order:order];
}

+ (instancetype)randomBandMatrixOfOrder:(MAVIndex)order
                       upperCodiagonals:(MAVIndex)upperCodiagonals
                       lowerCodiagonals:(MAVIndex)lowerCodiagonals
                              precision:(MCKPrecision)precision
{
    size_t numberOfBandValues = (upperCodiagonals + lowerCodiagonals + 1) * order;
    return [self bandMatrixWithValues:[self randomArrayOfSize:numberOfBandValues precision:precision]
                                order:order
                     upperCodiagonals:upperCodiagonals
                     lowerCodiagonals:lowerCodiagonals];
}

+ (instancetype)randomMatrixOfOrder:(MAVIndex)order
                       definiteness:(MAVMatrixDefiniteness)definiteness
                          precision:(MCKPrecision)precision
{
    MAVMatrix *matrix;

    switch(definiteness) {

        case MAVMatrixDefinitenessIndefinite: {
            BOOL shouldHaveZero = (arc4random() % 2) == 0;
            MAVIndex zeroIndex = arc4random() % order;
            BOOL positive = (arc4random() % 2) == 0;
            NSData *valueData;
            if (precision == MCKPrecisionDouble) {
                size_t length = order * sizeof(double);
                double *values = malloc(length);
                for (MAVIndex i = 0; i < order; i++) {
                    if (shouldHaveZero && i == zeroIndex) {
                        values[i] = 0.0;
                    } else {
                        values[i] = fabs([NSNumber mck_randomDouble].doubleValue) * (positive ? 1.0 : -1.0);
                        while (values[i] == 0.0 || values[i] == -0.0) {
                            values[i] = fabs([NSNumber mck_randomDouble].doubleValue) * (positive ? 1.0 : -1.0);
                        }
                        positive = !positive;
                    }
                }
                valueData = [NSData dataWithBytesNoCopy:values length:length];
            } else {
                size_t length = order * sizeof(float);
                float *values = malloc(length);
                for (MAVIndex i = 0; i < order; i++) {
                    if (shouldHaveZero && i == zeroIndex) {
                        values[i] = 0.0f;
                    } else {
                        values[i] = fabsf([NSNumber mck_randomFloat].floatValue) * (positive ? 1.0f : -1.0f);
                        while (values[i] == 0.0f || values[i] == -0.0f) {
                            values[i] = fabsf([NSNumber mck_randomFloat].floatValue) * (positive ? 1.0f : -1.0f);
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
            [[start multiplyByMatrix:start.transpose] multiplyByScalar:precision == MCKPrecisionDouble ? @(-1.0) : @(-1.0f)];
            matrix = start;
        } break;

            /*
             positive and negative semidefinite matrices are diagonal matrices whose diagonal values are ≥ (or ≤, respectively) than 0
             http://onlinelibrary.wiley.com/store/10.1002/9780470173862.app3/asset/app3.pdf?v=1&t=hu78fklx&s=a57be4e6e17e511a0722c8b666ea79ebd47d250b
             */

        case MAVMatrixDefinitenessPositiveSemidefinite: {
            MAVIndex zeroIndex = arc4random() % order;
            NSData *valueData;
            if (precision == MCKPrecisionDouble) {
                size_t length = order * sizeof(double);
                double *values = malloc(length);
                for (MAVIndex i = 0; i < order; i++) {
                    if (i == zeroIndex) {
                        values[i] = 0.0;
                    } else {
                        values[i] = fabs([NSNumber mck_randomDouble].doubleValue);
                        while (values[i] == 0.0 || values[i] == -0.0) {
                            values[i] = fabs([NSNumber mck_randomDouble].doubleValue);
                        }
                    }
                }
                valueData = [NSData dataWithBytesNoCopy:values length:length];
            } else {
                size_t length = order * sizeof(float);
                float *values = malloc(length);
                for (MAVIndex i = 0; i < order; i++) {
                    if (i == zeroIndex) {
                        values[i] = 0.0f;
                    } else {
                        values[i] = fabsf([NSNumber mck_randomFloat].floatValue);
                        while (values[i] == 0.0f || values[i] == -0.0f) {
                            values[i] = fabsf([NSNumber mck_randomFloat].floatValue);
                        }
                    }
                }
                valueData = [NSData dataWithBytesNoCopy:values length:length];
            }
            matrix = [self diagonalMatrixWithValues:valueData order:order];
        } break;

        case MAVMatrixDefinitenessNegativeSemidefinite: {
            MAVIndex zeroIndex = arc4random() % order;
            NSData *valueData;
            if (precision == MCKPrecisionDouble) {
                size_t length = order * sizeof(double);
                double *values = malloc(length);
                for (MAVIndex i = 0; i < order; i++) {
                    if (i == zeroIndex) {
                        values[i] = 0.0;
                    } else {
                        values[i] = -fabs([NSNumber mck_randomDouble].doubleValue);
                        while (values[i] == 0.0 || values[i] == -0.0) {
                            values[i] = -fabs([NSNumber mck_randomDouble].doubleValue);
                        }
                    }
                }
                valueData = [NSData dataWithBytesNoCopy:values length:length];
            } else {
                size_t length = order * sizeof(float);
                float *values = malloc(length);
                for (MAVIndex i = 0; i < order; i++) {
                    if (i == zeroIndex) {
                        values[i] = 0.0f;
                    } else {
                        values[i] = -fabsf([NSNumber mck_randomFloat].floatValue);
                        while (values[i] == 0.0f || values[i] == -0.0f) {
                            values[i] = -fabsf([NSNumber mck_randomFloat].floatValue);
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

+ (instancetype)randomSingularMatrixOfOrder:(MAVIndex)order precision:(MCKPrecision)precision
{
    BOOL shouldHaveZeroColumn = (arc4random() % 2) == 0;
    MAVIndex zeroVectorIndex = arc4random() % order;

    NSMutableArray *vectors = [NSMutableArray new];
    MAVVectorFormat vectorFormat = shouldHaveZeroColumn ? MAVVectorFormatColumnVector : MAVVectorFormatRowVector;
    for (MAVIndex i = 0; i < order; i++) {
        if (i == zeroVectorIndex) {
            [vectors addObject:[MAVVector vectorFilledWithValue:(precision == MCKPrecisionDouble ? @0.0 : @0.0f) length:order vectorFormat:vectorFormat]];
        } else {
            [vectors addObject:[MAVVector randomVectorOfLength:order vectorFormat:vectorFormat precision:precision]];
        }
    }
    return shouldHaveZeroColumn ? [self matrixWithColumnVectors:vectors] : [MAVMatrix matrixWithRowVectors:vectors];
}

+ (instancetype)randomNonsigularMatrixOfOrder:(MAVIndex)order precision:(MCKPrecision)precision
{
    MAVMatrix *matrix = [self randomMatrixWithRows:order columns:order precision:precision];
    while ([matrix.determinant compare:(precision == MCKPrecisionDouble ? @0.0 : @0.0f)] == NSOrderedSame) {
        matrix = [self randomMatrixWithRows:order columns:order precision:precision];
    }
    return matrix;
}

@end

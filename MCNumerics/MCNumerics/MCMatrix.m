//
//  Matrix.m
//  AccelerometerPlot
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

#import "MCMatrix.h"
#import "MCVector.h"
#import "MCSingularValueDecomposition.h"
#import "MCLUFactorization.h"
#import "MCEigendecomposition.h"
#import "MCQRFactorization.h"
#import "MCTribool.h"

#define randomDouble drand48()
#define randomFloat rand() / RAND_MAX

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
@property (strong, readwrite, nonatomic) NSData *values;
@property (strong, readwrite, nonatomic) MCMatrix *transpose;
@property (strong, readwrite, nonatomic) MCQRFactorization *qrFactorization;
@property (strong, readwrite, nonatomic) MCLUFactorization *luFactorization;
@property (strong, readwrite, nonatomic) MCSingularValueDecomposition *singularValueDecomposition;
@property (strong, readwrite, nonatomic) MCEigendecomposition *eigendecomposition;
@property (strong, readwrite, nonatomic) MCMatrix *inverse;
@property (strong, readwrite, nonatomic) NSNumber *determinant;
@property (strong, readwrite, nonatomic) NSNumber *conditionNumber;
@property (assign, readwrite, nonatomic) MCMatrixDefiniteness definiteness;
@property (strong, readwrite, nonatomic) MCTribool *isSymmetric;
@property (strong, readwrite, nonatomic) MCVector *diagonalValues;
@property (strong, readwrite, nonatomic) NSNumber *trace;
@property (strong, readwrite, nonatomic) MCMatrix *adjugate;
@property (strong, readwrite, nonatomic) MCMatrix *minorMatrix;
@property (strong, readwrite, nonatomic) MCMatrix *cofactorMatrix;
@property (strong, readwrite, nonatomic) NSNumber *normL1;
@property (strong, readwrite, nonatomic) NSNumber *normInfinity;
@property (strong, readwrite, nonatomic) NSNumber *normFroebenius;
@property (strong, readwrite, nonatomic) NSNumber *normMax;
@property (assign, readwrite, nonatomic) MCMatrixTriangularComponent triangularComponent;
@property (assign, readwrite, nonatomic) MCValuePrecision precision;

// private properties for band matrices
@property (assign, nonatomic) int bandwidth;
@property (assign, nonatomic) int numberOfBandValues;
@property (assign, nonatomic) int upperCodiagonals;

/**
 @brief Generates specified number of floating-point values.
 @param size Amount of random values to generate.
 @return C array point containing specified number of random values.
 */
+ (NSData *)randomArrayOfSize:(int)size
                    precision:(MCValuePrecision)precision;

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
- (NSNumber *)normOfType:(MCMatrixNorm)normType;

@end

@implementation MCMatrix

#pragma mark - Constructors

- (instancetype)initWithValues:(NSData *)values
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
        
        int numberOfValues;
        switch (packingMethod) {
            case MCMatrixValuePackingMethodPacked:
                numberOfValues = (rows * (rows + 1)) / 2;
                break;
                
            case MCMatrixValuePackingMethodConventional:
                numberOfValues = rows * columns;
                break;
                
            case MCMatrixValuePackingMethodBand:
                // must set in any band init methods
                numberOfValues = 1;
                break;
                
            default: break;
        }
        _precision = kMCIsDoubleType(values.length / numberOfValues) ? MCValuePrecisionDouble : MCValuePrecisionSingle;
    }
    return self;
}

#pragma mark - Class constructors

+ (instancetype)matrixWithColumnVectors:(NSArray *)columnVectors
{
    int columns = (int)columnVectors.count;
    int rows = ((MCVector *)columnVectors.firstObject).length;
    
    MCMatrix *matrix;
    
    if (kMCIsDoubleEncoding(((MCVector *)columnVectors[0])[0].objCType)) {
        size_t size = rows * columns * sizeof(double);
        double *values = malloc(size);
        [columnVectors enumerateObjectsUsingBlock:^(MCVector *columnVector, NSUInteger column, BOOL *stop) {
            for(int i = 0; i < rows; i++) {
                values[column * rows + i] = columnVector[i].doubleValue;
            }
        }];
        matrix = [[MCMatrix alloc] initWithValues:[NSData dataWithBytes:values length:size]
                                             rows:rows
                                          columns:columns
                                 leadingDimension:MCMatrixLeadingDimensionColumn
                                    packingMethod:MCMatrixValuePackingMethodConventional
                              triangularComponent:MCMatrixTriangularComponentBoth];
        matrix.precision = MCValuePrecisionDouble;
    } else {
        size_t size = rows * columns * sizeof(float);
        float *values = malloc(size);
        [columnVectors enumerateObjectsUsingBlock:^(MCVector *columnVector, NSUInteger column, BOOL *stop) {
            for(int i = 0; i < rows; i++) {
                values[column * rows + i] = columnVector[i].floatValue;
            }
        }];
        matrix = [[MCMatrix alloc] initWithValues:[NSData dataWithBytes:values length:size]
                                             rows:rows
                                          columns:columns
                                 leadingDimension:MCMatrixLeadingDimensionColumn
                                    packingMethod:MCMatrixValuePackingMethodConventional
                              triangularComponent:MCMatrixTriangularComponentBoth];
        matrix.precision = MCValuePrecisionSingle;
    }
    
    return matrix;
}

+ (instancetype)matrixWithRowVectors:(NSArray *)rowVectors
{
    int rows = (int)rowVectors.count;
    int columns = ((MCVector *)rowVectors.firstObject).length;
    
    MCMatrix *matrix;
    
    if (kMCIsDoubleEncoding(((MCVector *)rowVectors[0])[0].objCType)) {
        size_t size = rows * columns * sizeof(double);
        double *values = malloc(size);
        [rowVectors enumerateObjectsUsingBlock:^(MCVector *rowVector, NSUInteger row, BOOL *stop) {
            for(int i = 0; i < columns; i++) {
                NSNumber *value = [rowVector valueAtIndex:i];
                values[row * columns + i] = value.doubleValue;
            }
        }];
        matrix = [[MCMatrix alloc] initWithValues:[NSData dataWithBytes:values length:size]
                                             rows:rows
                                          columns:columns
                                 leadingDimension:MCMatrixLeadingDimensionRow
                                    packingMethod:MCMatrixValuePackingMethodConventional
                              triangularComponent:MCMatrixTriangularComponentBoth];
    } else {
        size_t size = rows * columns * sizeof(float);
        float *values = malloc(size);
        [rowVectors enumerateObjectsUsingBlock:^(MCVector *rowVector, NSUInteger row, BOOL *stop) {
            for(int i = 0; i < columns; i++) {
                NSNumber *value = [rowVector valueAtIndex:i];
                values[row * columns + i] = value.floatValue;
            }
        }];
        matrix = [[MCMatrix alloc] initWithValues:[NSData dataWithBytes:values length:size]
                                             rows:rows
                                          columns:columns
                                 leadingDimension:MCMatrixLeadingDimensionRow
                                    packingMethod:MCMatrixValuePackingMethodConventional
                              triangularComponent:MCMatrixTriangularComponentBoth];
    }
    
    return matrix;
}

+ (instancetype)matrixWithRows:(int)rows
                       columns:(int)columns
                     precision:(MCValuePrecision)precision
{
    MCMatrix *matrix;
    
    if (precision == MCValuePrecisionDouble) {
        NSUInteger size = rows * columns * sizeof(double);
        matrix = [[MCMatrix alloc] initWithValues:[NSData dataWithBytes:malloc(size) length:size]
                                             rows:rows
                                          columns:columns
                                 leadingDimension:MCMatrixLeadingDimensionColumn
                                    packingMethod:MCMatrixValuePackingMethodConventional
                              triangularComponent:MCMatrixTriangularComponentBoth];
    } else {
        NSUInteger size = rows * columns * sizeof(float);
        matrix = [[MCMatrix alloc] initWithValues:[NSData dataWithBytes:malloc(size) length:size]
                                             rows:rows
                                          columns:columns
                                 leadingDimension:MCMatrixLeadingDimensionColumn
                                    packingMethod:MCMatrixValuePackingMethodConventional
                              triangularComponent:MCMatrixTriangularComponentBoth];
    }
    
    return matrix;
}

+ (instancetype)matrixWithRows:(int)rows
                       columns:(int)columns
                     precision:(MCValuePrecision)precision
              leadingDimension:(MCMatrixLeadingDimension)leadingDimension
{
    MCMatrix *matrix = [self matrixWithRows:rows columns:columns precision:precision];
    matrix.leadingDimension = leadingDimension;
    return matrix;
}

+ (instancetype)matrixWithValues:(NSData *)values
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

+ (instancetype)matrixWithValues:(NSData *)values
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

+ (instancetype)identityMatrixOfOrder:(int)order
                            precision:(MCValuePrecision)precision
{
    MCMatrix *matrix;
    
    if (precision == MCValuePrecisionDouble) {
        NSUInteger size = order * order * sizeof(double);
        double *values = malloc(size);
        for (int i = 0; i < order; i++) {
            for (int j = 0; j < order; j++) {
                values[i * order + j] = i == j ? 1.0 : 0.0;
            }
        }
        matrix = [MCMatrix matrixWithValues:[NSData dataWithBytes:values length:size]
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
        matrix = [MCMatrix matrixWithValues:[NSData dataWithBytes:values length:size]
                                       rows:order
                                    columns:order];
    }
    
    return matrix;
}

+ (instancetype)diagonalMatrixWithValues:(NSData *)values
                                   order:(int)order
{
    return [MCMatrix bandMatrixWithValues:values order:order upperCodiagonals:0 lowerCodiagonals:0];
}

+ (instancetype)triangularMatrixWithPackedValues:(NSData *)values
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

+ (instancetype)symmetricMatrixWithPackedValues:(NSData *)values
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

+ (instancetype)bandMatrixWithValues:(NSData *)values
                               order:(int)order
                    upperCodiagonals:(int)upperCodiagonals
                    lowerCodiagonals:(int)lowerCodiagonals
{
    MCMatrix *matrix = [[MCMatrix alloc] initWithValues:values
                                                   rows:order
                                                columns:order
                                       leadingDimension:MCMatrixLeadingDimensionColumn
                                          packingMethod:MCMatrixValuePackingMethodBand
                                    triangularComponent:upperCodiagonals == 0
                                                        ? (lowerCodiagonals == 0
                                                           ? MCMatrixTriangularComponentBoth
                                                           : MCMatrixTriangularComponentLower)
                                                        : (lowerCodiagonals == 0
                                                           ? MCMatrixTriangularComponentBoth
                                                           : MCMatrixTriangularComponentUpper)]; // TODO: need to swap ...Both and ...Upper in the else branch of the outer ternary expression
    
    
    matrix.upperCodiagonals = upperCodiagonals;
    matrix.bandwidth = lowerCodiagonals + upperCodiagonals + 1;
    matrix.numberOfBandValues = matrix.bandwidth * order;
    matrix.precision = kMCIsDoubleType(values.length / matrix.numberOfBandValues) ? MCValuePrecisionDouble : MCValuePrecisionSingle;
    
    return matrix;
}

+ (instancetype)matrixForTwoDimensionalRotationWithAngle:(NSNumber *)angle direction:(MCAngleDirection)direction
{
    NSData *valueData;
    if (kMCIsDoubleEncoding(angle.objCType)) {
        double directedAngle = angle.doubleValue * (direction == MCAngleDirectionClockwise ? -1.0 : 1.0);
        size_t size = 4 * sizeof(double);
        double *values = malloc(size);
        values[0] = cos(directedAngle);
        values[1] = -sin(directedAngle);
        values[2] = sin(directedAngle);
        values[3] = cos(directedAngle);
        valueData = [NSData dataWithBytes:values length:size];
    } else {
        float directedAngle = angle.floatValue * (direction == MCAngleDirectionClockwise ? -1.0f : 1.0f);
        size_t size = 4 * sizeof(float);
        float *values = malloc(size);
        values[0] = cosf(directedAngle);
        values[1] = -sinf(directedAngle);
        values[2] = sinf(directedAngle);
        values[3] = cosf(directedAngle);
        valueData = [NSData dataWithBytes:values length:size];
    }
    return [MCMatrix matrixWithValues:valueData rows:2 columns:2 leadingDimension:MCMatrixLeadingDimensionRow];
}

+ (instancetype)matrixForThreeDimensionalRotationWithAngle:(NSNumber *)angle
                                                 aboutAxis:(MCCoordinateAxis)axis
                                                 direction:(MCAngleDirection)direction
{
    NSData *valueData;
    if (kMCIsDoubleEncoding(angle.objCType)) {
        double directedAngle = angle.doubleValue * (direction == MCAngleDirectionClockwise ? -1.0 : 1.0);
        double *values = calloc(9, sizeof(double));
        switch (axis) {
            
            case MCCoordinateAxisX: {
                values[0] = 1.0;
                values[4] = cos(directedAngle);
                values[5] = -sin(directedAngle);
                values[7] = sin(directedAngle);
                values[8] = cos(directedAngle);
            } break;
            
            case MCCoordinateAxisY: {
                values[0] = cos(directedAngle);
                values[2] = sin(directedAngle);
                values[4] = 1.0;
                values[6] = -sin(directedAngle);
                values[8] = cos(directedAngle);
            } break;
                
            case MCCoordinateAxisZ: {
                values[0] = cos(directedAngle);
                values[1] = -sin(directedAngle);
                values[3] = sin(directedAngle);
                values[4] = cos(directedAngle);
                values[8] = 1.0;
            } break;
                
            default: break;
        }
        valueData = [NSData dataWithBytes:values length:9 * sizeof(double)];
    } else {
        float directedAngle = angle.floatValue * (direction == MCAngleDirectionClockwise ? -1.0f : 1.0f);
        float *values = calloc(9, sizeof(float));
        switch (axis) {
                
            case MCCoordinateAxisX: {
                values[0] = 1.0f;
                values[4] = cosf(directedAngle);
                values[5] = -sinf(directedAngle);
                values[7] = sinf(directedAngle);
                values[8] = cosf(directedAngle);
            } break;
                
            case MCCoordinateAxisY: {
                values[0] = cosf(directedAngle);
                values[2] = sinf(directedAngle);
                values[4] = 1.0f;
                values[6] = -sinf(directedAngle);
                values[8] = cosf(directedAngle);
            } break;
                
            case MCCoordinateAxisZ: {
                values[0] = cosf(directedAngle);
                values[1] = -sinf(directedAngle);
                values[3] = sinf(directedAngle);
                values[4] = cosf(directedAngle);
                values[8] = 1.0f;
            } break;
                
            default: break;
        }
        valueData = [NSData dataWithBytes:values length:9 * sizeof(float)];
    }
    return [MCMatrix matrixWithValues:valueData rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow];
}

+ (instancetype)randomMatrixWithRows:(int)rows
                             columns:(int)columns
                           precision:(MCValuePrecision)precision
{
    return [MCMatrix matrixWithValues:[self randomArrayOfSize:rows * columns precision:precision]
                                 rows:rows
                              columns:columns];
}

+ (instancetype)randomSymmetricMatrixOfOrder:(int)order
                                   precision:(MCValuePrecision)precision
{
    return [MCMatrix symmetricMatrixWithPackedValues:[self randomArrayOfSize:(order * (order + 1))/2 precision:precision]
                                 triangularComponent:MCMatrixTriangularComponentUpper
                                    leadingDimension:MCMatrixLeadingDimensionColumn
                                               order:order];
}

+ (instancetype)randomDiagonalMatrixOfOrder:(int)order
                                  precision:(MCValuePrecision)precision
{
    return [MCMatrix diagonalMatrixWithValues:[self randomArrayOfSize:order precision:precision]
                                        order:order];
}

+ (instancetype)randomTriangularMatrixOfOrder:(int)order
                          triangularComponent:(MCMatrixTriangularComponent)triangularComponent
                                    precision:(MCValuePrecision)precision
{
    return [MCMatrix triangularMatrixWithPackedValues:[self randomArrayOfSize:(order * (order + 1))/2 precision:precision]
                                ofTriangularComponent:triangularComponent
                                     leadingDimension:MCMatrixLeadingDimensionColumn
                                                order:order];
}

+ (instancetype)randomBandMatrixOfOrder:(int)order
                       upperCodiagonals:(int)upperCodiagonals
                       lowerCodiagonals:(int)lowerCodiagonals
                              precision:(MCValuePrecision)precision
{
    int numberOfBandValues = (upperCodiagonals + lowerCodiagonals + 1) * order;
    return [MCMatrix bandMatrixWithValues:[self randomArrayOfSize:numberOfBandValues precision:precision]
                                    order:order
                         upperCodiagonals:upperCodiagonals
                         lowerCodiagonals:lowerCodiagonals];
}

+ (instancetype)randomMatrixOfOrder:(int)order
                       definiteness:(MCMatrixDefiniteness)definiteness
                          precision:(MCValuePrecision)precision
{
    MCMatrix *matrix;
    
    switch(definiteness) {
            
        case MCMatrixDefinitenessIndefinite: {
            BOOL shouldHaveZero = (arc4random() % 2) == 0;
            int zeroIndex = arc4random() % order;
            BOOL positive = (arc4random() % 2) == 0;
            NSData *valueData;
            if (precision == MCValuePrecisionDouble) {
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
                valueData = [NSData dataWithBytes:values length:length];
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
                valueData = [NSData dataWithBytes:values length:length];
            }
            matrix = [MCMatrix diagonalMatrixWithValues:valueData order:order];
        } break;
            
        case MCMatrixDefinitenessPositiveDefinite: {
            // A is pos. def. if A = B^T * B, B is nonsingular square
            MCMatrix *start = [MCMatrix randomMatrixWithRows:order columns:order precision:precision];
            matrix = [MCMatrix productOfMatrixA:start andMatrixB:start.transpose];
        } break;
            
        case MCMatrixDefinitenessNegativeDefinite: {
            // A is neg. def. if A = B^T * B, B is nonsingular square with all negative values
            MCMatrix *start = [MCMatrix randomMatrixWithRows:order columns:order precision:precision];
            matrix = [MCMatrix productOfMatrix:[MCMatrix productOfMatrixA:start andMatrixB:start.transpose] andScalar:precision == MCValuePrecisionDouble ? @(-1.0) : @(-1.0f)];
        } break;
            
        /*
         positive and negative semidefinite matrices are diagonal matrices whose diagonal values are ≥ (or ≤, respectively) than 0
         http://onlinelibrary.wiley.com/store/10.1002/9780470173862.app3/asset/app3.pdf?v=1&t=hu78fklx&s=a57be4e6e17e511a0722c8b666ea79ebd47d250b
         */
            
        case MCMatrixDefinitenessPositiveSemidefinite: {
            int zeroIndex = arc4random() % order;
            NSData *valueData;
            if (precision == MCValuePrecisionDouble) {
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
                valueData = [NSData dataWithBytes:values length:length];
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
                valueData = [NSData dataWithBytes:values length:length];
            }
            matrix = [MCMatrix diagonalMatrixWithValues:valueData order:order];
        } break;
            
        case MCMatrixDefinitenessNegativeSemidefinite: {
            int zeroIndex = arc4random() % order;
            NSData *valueData;
            if (precision == MCValuePrecisionDouble) {
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
                valueData = [NSData dataWithBytes:values length:length];
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
                valueData = [NSData dataWithBytes:values length:length];
            }
            matrix = [MCMatrix diagonalMatrixWithValues:valueData order:order];
        } break;
            
        case MCMatrixDefinitenessUnknown:
            matrix = [MCMatrix randomMatrixWithRows:order columns:order precision:precision];
            break;
            
        default: break;
    }
    
    matrix.definiteness = definiteness;
    return matrix;
}

+ (instancetype)randomSingularMatrixOfOrder:(int)order precision:(MCValuePrecision)precision
{
    BOOL shouldHaveZeroColumn = (arc4random() % 2) == 0;
    int zeroVectorIndex = arc4random() % order;
    
    NSMutableArray *vectors = [NSMutableArray new];
    MCVectorFormat vectorFormat = shouldHaveZeroColumn ? MCVectorFormatColumnVector : MCVectorFormatRowVector;
    for (int i = 0; i < order; i++) {
        if (i == zeroVectorIndex) {
            [vectors addObject:[MCVector vectorFilledWithValue:(precision == MCValuePrecisionDouble ? @0.0 : @0.0f) length:order vectorFormat:vectorFormat]];
        } else {
            [vectors addObject:[MCVector randomVectorOfLength:order vectorFormat:vectorFormat precision:precision]];
        }
    }
    return shouldHaveZeroColumn ? [MCMatrix matrixWithColumnVectors:vectors] : [MCMatrix matrixWithRowVectors:vectors];
}

+ (instancetype)randomNonsigularMatrixOfOrder:(int)order precision:(MCValuePrecision)precision
{
    MCMatrix *matrix = [MCMatrix randomMatrixWithRows:order columns:order precision:precision];
    while ([matrix.determinant compare:(precision == MCValuePrecisionDouble ? @0.0 : @0.0f)] == NSOrderedSame) {
        matrix = [MCMatrix randomMatrixWithRows:order columns:order precision:precision];
    }
    return matrix;
}

#pragma mark - Lazy-loaded properties

- (MCMatrix *)transpose
{
    if (_transpose == nil) {
        NSData *aVals = [self valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
        size_t elementSize = aVals.length / (self.rows * self.columns);
        void *tVals;
        if (kMCIsFloatType(elementSize)) {
            tVals = malloc(self.rows * self.columns * sizeof(float));
            vDSP_mtrans(aVals.bytes, 1, tVals, 1, self.columns, self.rows);
        } else  {
            tVals = malloc(self.rows * self.columns * sizeof(double));
            vDSP_mtransD(aVals.bytes, 1, tVals, 1, self.columns, self.rows);
        }
        
        _transpose = [MCMatrix matrixWithValues:[NSData dataWithBytes:tVals length:aVals.length] rows:self.columns columns:self.rows];
    }
    
    return _transpose;
}

- (NSNumber *)determinant
{
    if (_determinant == nil) {
        if (_rows == 2 && _columns == 2) {
            if (kMCIsDoubleEncoding(self[0][0].objCType)) {
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
            if (kMCIsDoubleEncoding(self[0][0].objCType)) {
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
            if (kMCIsDoubleEncoding(product.objCType)) {
                _determinant = @(self.luFactorization.upperTriangularMatrix.diagonalValues.productOfValues.doubleValue * pow(-1.0, self.luFactorization.numberOfPermutations));
            } else {
                _determinant = @(self.luFactorization.upperTriangularMatrix.diagonalValues.productOfValues.floatValue * powf(-1.f, self.luFactorization.numberOfPermutations));
            }
        }
    }
    
    return _determinant;
}

- (MCMatrix *)inverse
{
    if (_inverse == nil) {
        if (_rows == _columns) {
            NSData *columnMajorData = [self valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
            
            int m = _rows;
            int n = _columns;
            
            int lda = m;
            
            int *ipiv = malloc(MIN(m, n) * sizeof(int));
            
            int info = 0;
            
            size_t valueType = columnMajorData.length / (m * n);
            void *a;
            if (kMCIsDoubleType(valueType)) {
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
            
            _inverse = [MCMatrix matrixWithValues:[NSData dataWithBytes:a length:columnMajorData.length]
                                             rows:_rows
                                          columns:_columns
                               leadingDimension:MCMatrixLeadingDimensionColumn];
        }
    }
    
    return _inverse;
}

- (NSNumber *)conditionNumber
{
    if (_conditionNumber == nil) {
        NSData *rowMajorValues = [self valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
        int m = self.rows;
        int n = self.columns;
        size_t valueType = rowMajorValues.length / (m * n);
        if (kMCIsDoubleType(valueType)) {
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
            
            _conditionNumber = @(1.f / conditionReciprocal);
        }
    }
    
    return _conditionNumber;
}

- (MCQRFactorization *)qrFactorization
{
    if (_qrFactorization == nil) {
        _qrFactorization = [MCQRFactorization qrFactorizationOfMatrix:self];
    }
    
    return _qrFactorization;
}

- (MCLUFactorization *)luFactorization
{
    if (_luFactorization == nil) {
        _luFactorization = [MCLUFactorization luFactorizationOfMatrix:self];
    }
    
    return _luFactorization;
}

- (MCSingularValueDecomposition *)singularValueDecomposition
{
    if (_singularValueDecomposition == nil) {
        _singularValueDecomposition = [MCSingularValueDecomposition singularValueDecompositionWithMatrix:self];
    }
    
    return _singularValueDecomposition;
}

- (MCEigendecomposition *)eigendecomposition
{
    if (_eigendecomposition == nil) {
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
                if ([[self valueAtRow:i column:j] compare:[self valueAtRow:j column:i]] != NSOrderedSame) {
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
    if (self.isSymmetric && _definiteness == MCMatrixDefinitenessUnknown) {
        BOOL hasFoundEigenvalueStrictlyGreaterThanZero = NO;
        BOOL hasFoundEigenvalueStrictlyLesserThanZero = NO;
        BOOL hasFoundEigenvalueEqualToZero = NO;
        MCVector *eigenvalues = self.eigendecomposition.eigenvalues;
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
                _definiteness = MCMatrixDefinitenessPositiveSemidefinite;
            } else if (!hasFoundEigenvalueStrictlyGreaterThanZero && hasFoundEigenvalueStrictlyLesserThanZero) {
                _definiteness = MCMatrixDefinitenessNegativeSemidefinite;
            } else {
                _definiteness = MCMatrixDefinitenessIndefinite;
            }
        } else {
            // will be definite or indefinite (but not semidefinite)
            if (hasFoundEigenvalueStrictlyGreaterThanZero && !hasFoundEigenvalueStrictlyLesserThanZero) {
                _definiteness = MCMatrixDefinitenessPositiveDefinite;
            } else if (!hasFoundEigenvalueStrictlyGreaterThanZero && hasFoundEigenvalueStrictlyLesserThanZero) {
                _definiteness = MCMatrixDefinitenessNegativeDefinite;
            } else {
                _definiteness = MCMatrixDefinitenessIndefinite;
            }
        }
    }
    return _definiteness;
}

- (MCVector *)diagonalValues
{
    if (_diagonalValues == nil) {
        int length = MIN(self.rows, self.columns);
        
        if (kMCIsDoubleEncoding(self[0][0].objCType)) {
            double *values = malloc(length * sizeof(double));
            for (int i = 0; i < length; i += 1) {
                values[i] = [self valueAtRow:i column:i].doubleValue;
            }
            _diagonalValues = [MCVector vectorWithValues:[NSData dataWithBytes:values length:length * sizeof(double)] length:length vectorFormat:MCVectorFormatRowVector];
        } else {
            float *values = malloc(length * sizeof(float));
            for (int i = 0; i < length; i += 1) {
                values[i] = [self valueAtRow:i column:i].floatValue;
            }
            _diagonalValues = [MCVector vectorWithValues:[NSData dataWithBytes:values length:length * sizeof(float)] length:length vectorFormat:MCVectorFormatRowVector];
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
        _normInfinity = [self normOfType:MCMatrixNormInfinity];
    }
    return _normInfinity;
}

- (NSNumber *)normL1
{
    if (_normL1 == nil) {
        _normL1 = [self normOfType:MCMatrixNormL1];
    }
    return _normL1;
}

- (NSNumber *)normMax
{
    if (_normMax == nil) {
        _normMax = [self normOfType:MCMatrixNormMax];
    }
    return _normMax;
}

- (NSNumber *)normFroebenius
{
    if (_normFroebenius == nil) {
        _normFroebenius = [self normOfType:MCMatrixNormFroebenius];
    }
    return _normFroebenius;
}

- (MCMatrix *)minorMatrix
{
    if (_minorMatrix == nil) {
        size_t valueType = self.values.length / (self.rows * self.columns);
        if (kMCIsDoubleType(valueType)) {
            double *minorValues = malloc(self.rows * self.columns * sizeof(double));
            
            int minorIdx = 0;
            for (int row = 0; row < self.rows; row += 1) {
                for (int col = 0; col < self.columns; col += 1) {
                    MCMatrix *submatrix = [MCMatrix matrixWithRows:self.rows - 1
                                                           columns:self.columns - 1
                                                         precision:MCValuePrecisionDouble
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
            
            _minorMatrix = [MCMatrix matrixWithValues:[NSData dataWithBytes:minorValues length:self.values.length]
                                                 rows:self.rows
                                              columns:self.columns
                                     leadingDimension:MCMatrixLeadingDimensionRow];
        } else if (kMCIsFloatType(valueType)) {
            float *minorValues = malloc(self.rows * self.columns * sizeof(float));
            
            int minorIdx = 0;
            for (int row = 0; row < self.rows; row += 1) {
                for (int col = 0; col < self.columns; col += 1) {
                    MCMatrix *submatrix = [MCMatrix matrixWithRows:self.rows - 1
                                                           columns:self.columns - 1
                                                         precision:MCValuePrecisionSingle
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
            
            _minorMatrix = [MCMatrix matrixWithValues:[NSData dataWithBytes:minorValues length:self.values.length]
                                                 rows:self.rows
                                              columns:self.columns
                                     leadingDimension:MCMatrixLeadingDimensionRow];
        }
        
    }
    
    return _minorMatrix;
}

- (MCMatrix *)cofactorMatrix
{
    if (_cofactorMatrix == nil) {
        if (self.precision == MCValuePrecisionDouble) {
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
            
            _cofactorMatrix = [MCMatrix matrixWithValues:[NSData dataWithBytes:cofactors length:size]
                                                    rows:self.rows
                                                 columns:self.columns
                                        leadingDimension:MCMatrixLeadingDimensionRow];
        } else {
            size_t size = self.rows * self.columns * sizeof(float);
            float *cofactors = malloc(size);
            
            int cofactorIdx = 0;
            for (int row = 0; row < self.rows; row += 1) {
                for (int col = 0; col < self.columns; col += 1) {
                    float minor = self.minorMatrix[row][col].floatValue;
                    float multiplier = powf(-1.f, row + col + 2.f);
                    cofactors[cofactorIdx++] = minor * multiplier;
                }
            }
            
            _cofactorMatrix = [MCMatrix matrixWithValues:[NSData dataWithBytes:cofactors length:size]
                                                    rows:self.rows
                                                 columns:self.columns
                                        leadingDimension:MCMatrixLeadingDimensionRow];
        }
    }
    
    return _cofactorMatrix;
}

- (MCMatrix *)adjugate
{
    if (_adjugate == nil) {
        _adjugate = self.cofactorMatrix.transpose;
    }
    
    return _adjugate;
}

#pragma mark - NSObject overrides

- (BOOL)isEqualToMatrix:(MCMatrix *)otherMatrix
{
    if (!([otherMatrix isKindOfClass:[MCMatrix class]] && self.rows == otherMatrix.rows && self.columns == otherMatrix.columns)) {
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
    } else if (![object isKindOfClass:[MCMatrix class]]) {
        return NO;
    } else {
        return [self isEqualToMatrix:(MCMatrix *)object];
    }
}

- (NSString *)description
{
    int padding;
    
    if (self.precision == MCValuePrecisionDouble) {
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
            NSString *string = [NSString stringWithFormat:@"%.1f", self.precision == MCValuePrecisionDouble ? [self valueAtRow:j column:k].doubleValue : [self valueAtRow:j column:k].floatValue];
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

- (NSData *)valuesWithLeadingDimension:(MCMatrixLeadingDimension)leadingDimension
{
    NSData *data;
    
    switch (self.packingMethod) {
            
        case MCMatrixValuePackingMethodConventional: {
            if (self.precision == MCValuePrecisionDouble) {
                size_t size = self.rows * self.columns * sizeof(double);
                double *values = malloc(size);
                if (self.leadingDimension == leadingDimension) {
                    for (int i = 0; i < self.rows * self.columns; i += 1) {
                        values[i] = ((double *)self.values.bytes)[i];
                    }
                } else {
                    int i = 0;
                    for (int j = 0; j < (leadingDimension == MCMatrixLeadingDimensionRow ? self.rows : self.columns); j++) {
                        for (int k = 0; k < (leadingDimension == MCMatrixLeadingDimensionRow ? self.columns : self.rows); k++) {
                            int idx = ((i * (leadingDimension == MCMatrixLeadingDimensionRow ? self.rows : self.columns)) % (self.columns * self.rows)) + j;
                            values[i] = ((double *)self.values.bytes)[idx];
                            i++;
                        }
                    }
                }
                data = [NSData dataWithBytes:values length:size];
            } else {
                size_t size = self.rows * self.columns * sizeof(float);
                float *values = malloc(size);
                if (self.leadingDimension == leadingDimension) {
                    for (int i = 0; i < self.rows * self.columns; i += 1) {
                        values[i] = ((float *)self.values.bytes)[i];
                    }
                } else {
                    int i = 0;
                    for (int j = 0; j < (leadingDimension == MCMatrixLeadingDimensionRow ? self.rows : self.columns); j++) {
                        for (int k = 0; k < (leadingDimension == MCMatrixLeadingDimensionRow ? self.columns : self.rows); k++) {
                            int idx = ((i * (leadingDimension == MCMatrixLeadingDimensionRow ? self.rows : self.columns)) % (self.columns * self.rows)) + j;
                            values[i] = ((float *)self.values.bytes)[idx];
                            i++;
                        }
                    }
                }
                data = [NSData dataWithBytes:values length:size];
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
            
        case MCMatrixValuePackingMethodPacked: {
            if (self.precision == MCValuePrecisionDouble) {
                size_t size = self.rows * self.columns * sizeof(double);
                double *values = malloc(size);
                int k = 0; // current index in ivar array
                int z = 0; // current index in constructing array
                for (int i = 0; i < self.columns; i += 1) {
                    for (int j = 0; j < self.columns; j += 1) {
                        BOOL shouldTakePackedValue = (self.triangularComponent == MCMatrixTriangularComponentUpper)
                        ? (self.leadingDimension == MCMatrixLeadingDimensionColumn ? j <= i : i <= j)
                        : (self.leadingDimension == MCMatrixLeadingDimensionColumn ? i <= j : j <= i);
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
                    values = cvalues;
                }
                data = [NSData dataWithBytes:values length:size];
            } else {
                size_t size = self.rows * self.columns * sizeof(float);
                float *values = malloc(size);
                int k = 0; // current index in ivar array
                int z = 0; // current index in constructing array
                for (int i = 0; i < self.columns; i += 1) {
                    for (int j = 0; j < self.columns; j += 1) {
                        BOOL shouldTakePackedValue = (self.triangularComponent == MCMatrixTriangularComponentUpper)
                        ? (self.leadingDimension == MCMatrixLeadingDimensionColumn ? j <= i : i <= j)
                        : (self.leadingDimension == MCMatrixLeadingDimensionColumn ? i <= j : j <= i);
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
                    values = cvalues;
                }
                data = [NSData dataWithBytes:values length:size];
            }
        } break;
            
        case MCMatrixValuePackingMethodBand: {
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
            if (self.precision == MCValuePrecisionDouble) {
                size_t size = self.rows * self.columns * sizeof(double);
                double *values = malloc(size);
                for (int i = 0; i < self.columns; i += 1) {
                    for (int j = 0; j < self.columns; j += 1) {
                        int indexIntoBandArray = ( i - j + self.upperCodiagonals ) * self.columns + j;
                        int indexIntoUnpackedArray = (leadingDimension == MCMatrixLeadingDimensionColumn ? j : i) * self.columns + (leadingDimension == MCMatrixLeadingDimensionColumn ? i : j);
                        if (indexIntoBandArray >= 0 && indexIntoBandArray < self.bandwidth * self.columns) {
                            values[indexIntoUnpackedArray] = ((double *)self.values.bytes)[indexIntoBandArray];
                        } else {
                            values[indexIntoUnpackedArray] = 0.0;
                        }
                    }
                }
                data = [NSData dataWithBytes:values length:size];
            } else {
                size_t size = self.rows * self.columns * sizeof(float);
                float *values = malloc(size);
                for (int i = 0; i < self.columns; i += 1) {
                    for (int j = 0; j < self.columns; j += 1) {
                        int indexIntoBandArray = ( i - j + self.upperCodiagonals ) * self.columns + j;
                        int indexIntoUnpackedArray = (leadingDimension == MCMatrixLeadingDimensionColumn ? j : i) * self.columns + (leadingDimension == MCMatrixLeadingDimensionColumn ? i : j);
                        if (indexIntoBandArray >= 0 && indexIntoBandArray < self.bandwidth * self.columns) {
                            values[indexIntoUnpackedArray] = ((float *)self.values.bytes)[indexIntoBandArray];
                        } else {
                            values[indexIntoUnpackedArray] = 0.0f;
                        }
                    }
                }
                data = [NSData dataWithBytes:values length:size];
            }
        } break;
            
        default: break;
    }
    
    return data;
}

- (NSData *)valuesFromTriangularComponent:(MCMatrixTriangularComponent)triangularComponent
                         leadingDimension:(MCMatrixLeadingDimension)leadingDimension
                            packingMethod:(MCMatrixValuePackingMethod)packingMethod
{
    NSAssert(self.rows == self.columns, @"Cannot extract triangular components from non-square matrices");
    
    NSData *data;
    
    int numberOfValues = packingMethod == MCMatrixValuePackingMethodPacked ? ((self.rows * (self.rows + 1)) / 2) : self.rows * self.rows;
    int i = 0;
    int outerLimit = self.leadingDimension == MCMatrixLeadingDimensionRow ? self.rows : self.columns;
    int innerLimit = self.leadingDimension == MCMatrixLeadingDimensionRow ? self.columns : self.rows;
    
    if (self.precision == MCValuePrecisionDouble) {
        size_t size = numberOfValues * sizeof(double);
        double *values = malloc(size);
        for (int j = 0; j < outerLimit; j++) {
            for (int k = 0; k < innerLimit; k++) {
                int row = leadingDimension == MCMatrixLeadingDimensionRow ? j : k;
                int col = leadingDimension == MCMatrixLeadingDimensionRow ? k : j;
                
                BOOL shouldStoreValueForLowerTriangle = triangularComponent == MCMatrixTriangularComponentLower && col <= row;
                BOOL shouldStoreValueForUpperTriangle = triangularComponent == MCMatrixTriangularComponentUpper && row <= col;
                
                if (shouldStoreValueForLowerTriangle || shouldStoreValueForUpperTriangle) {
                    double value = [self valueAtRow:row column:col].doubleValue;
                    values[i++] = value;
                } else if (packingMethod == MCMatrixValuePackingMethodConventional) {
                    values[i++] = 0.0;
                }
            }
        }
        data = [NSData dataWithBytes:values length:size];
    } else {
        size_t size = numberOfValues * sizeof(float);
        float *values = malloc(size);
        for (int j = 0; j < outerLimit; j++) {
            for (int k = 0; k < innerLimit; k++) {
                int row = leadingDimension == MCMatrixLeadingDimensionRow ? j : k;
                int col = leadingDimension == MCMatrixLeadingDimensionRow ? k : j;
                
                BOOL shouldStoreValueForLowerTriangle = triangularComponent == MCMatrixTriangularComponentLower && col <= row;
                BOOL shouldStoreValueForUpperTriangle = triangularComponent == MCMatrixTriangularComponentUpper && row <= col;
                
                if (shouldStoreValueForLowerTriangle || shouldStoreValueForUpperTriangle) {
                    float value = [self valueAtRow:row column:col].floatValue;
                    values[i++] = value;
                } else if (packingMethod == MCMatrixValuePackingMethodConventional) {
                    values[i++] = 0.0f;
                }
            }
        }
        data = [NSData dataWithBytes:values length:size];
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
    
    if (self.precision == MCValuePrecisionDouble) {
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
        data = [NSData dataWithBytes:values length:size];
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
        data = [NSData dataWithBytes:values length:size];
    }
    
    return data;
}

- (NSNumber *)valueAtRow:(int)row column:(int)column
{
    NSAssert1(row >= 0 && row < self.rows, @"row = %u is outside the range of possible rows.", row);
    NSAssert1(column >= 0 && column < self.columns, @"column = %u is outside the range of possible columns.", column);
    
    switch (self.packingMethod) {
            
        case MCMatrixValuePackingMethodConventional: {
            if (self.leadingDimension == MCMatrixLeadingDimensionRow) {
                return @(self.precision == MCValuePrecisionDouble ? ((double *)self.values.bytes)[row * self.columns + column] : ((float *)self.values.bytes)[row * self.columns + column]);
            } else {
                return @(self.precision == MCValuePrecisionDouble ? ((double *)self.values.bytes)[column * self.rows + row] : ((float *)self.values.bytes)[column * self.rows + row]);
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
                        return @(self.precision == MCValuePrecisionDouble ? ((double *)self.values.bytes)[index] : ((float *)self.values.bytes)[index]);
                    } else {
                        // number of values in rows before desired row
                        int summedRows = row ;
                        int valuesInSummedRows = summedRows * (summedRows + 1) / 2;
                        int index = valuesInSummedRows + column;
                        return @(self.precision == MCValuePrecisionDouble ? ((double *)self.values.bytes)[index] : ((float *)self.values.bytes)[index]);
                    }
                } else {
                    return self.precision == MCValuePrecisionDouble ? @0.0 : @0.0f;
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
                        return @(self.precision == MCValuePrecisionDouble ? ((double *)self.values.bytes)[index] : ((float *)self.values.bytes)[index]);
                    } else {
                        // number of values in rows before desired row
                        int valuesInSummedRows = ((self.columns * (self.columns + 1)) - ((self.columns - row) * (self.columns - row + 1))) / 2;
                        int index = valuesInSummedRows + column - row;
                        return @(self.precision == MCValuePrecisionDouble ? ((double *)self.values.bytes)[index] : ((float *)self.values.bytes)[index]);
                    }
                } else {
                    return self.precision == MCValuePrecisionDouble ? @0.0 : @0.0f;
                }
            }
        } break;
            
        case MCMatrixValuePackingMethodBand: {
            int indexIntoBandArray = ( row - column + self.upperCodiagonals ) * self.columns + column;
            if (indexIntoBandArray >= 0 && indexIntoBandArray < self.bandwidth * self.columns) {
                return @(self.precision == MCValuePrecisionDouble ? ((double *)self.values.bytes)[indexIntoBandArray] : ((float *)self.values.bytes)[indexIntoBandArray]);
            } else {
                return self.precision == MCValuePrecisionDouble ? @0.0 : @0.0f;
            }
        } break;
            
        default: break;
    }
}

- (MCVector *)rowVectorForRow:(int)row
{
    NSAssert1(row >= 0 && row < self.rows, @"row = %u is outside the range of possible rows.", row);
    
    MCVector *vector;
    
    if (self.precision == MCValuePrecisionDouble) {
        size_t size = self.columns * sizeof(double);
        double *values = malloc(size);
        for (int col = 0; col < self.columns; col += 1) {
            values[col] = [self valueAtRow:row column:col].doubleValue;
        }
        vector = [MCVector vectorWithValues:[NSData dataWithBytes:values length:size] length:self.columns vectorFormat:MCVectorFormatRowVector];
    } else {
        size_t size = self.columns * sizeof(float);
        float *values = malloc(size);
        for (int col = 0; col < self.columns; col += 1) {
            values[col] = [self valueAtRow:row column:col].floatValue;
        }
        vector = [MCVector vectorWithValues:[NSData dataWithBytes:values length:size] length:self.columns vectorFormat:MCVectorFormatRowVector];
    }
    
    return vector;
}

- (MCVector *)columnVectorForColumn:(int)column
{
    NSAssert1(column >= 0 && column < self.columns, @"column = %u is outside the range of possible columns.", column);
    
    MCVector *vector;
    
    if (self.precision == MCValuePrecisionDouble) {
        size_t size = self.rows * sizeof(double);
        double *values = malloc(size);
        for (int row = 0; row < self.rows; row += 1) {
            values[row] = [self valueAtRow:row column:column].doubleValue;
        }
        vector = [MCVector vectorWithValues:[NSData dataWithBytes:values length:size] length:self.rows vectorFormat:MCVectorFormatColumnVector];
    } else {
        size_t size = self.rows * sizeof(float);
        float *values = malloc(size);
        for (int row = 0; row < self.rows; row += 1) {
            values[row] = [self valueAtRow:row column:column].floatValue;
        }
        vector = [MCVector vectorWithValues:[NSData dataWithBytes:values length:size] length:self.rows vectorFormat:MCVectorFormatColumnVector];
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

- (MCVector *)objectAtIndexedSubscript:(int)idx
{
    NSAssert1(idx >= 0 && idx < self.rows, @"idx = %u is outside the range of possible rows.", idx);
    
    return [self rowVectorForRow:idx];
}

#pragma mark - Mutation

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
    // TODO: take into account internal representation
    
    NSAssert1(row >= 0 && row < self.rows, @"row = %u is outside the range of possible rows.", row);
    NSAssert1(column >= 0 && column < self.columns, @"column = %u is outside the range of possible columns.", column);
    BOOL precisionsMatch = (self.precision == MCValuePrecisionDouble && kMCIsDoubleEncoding(value.objCType)) || (self.precision == MCValuePrecisionSingle && kMCIsFloatEncoding(value.objCType));
    NSAssert(precisionsMatch, @"Precisions do not match.");
    
    if (self.precision == MCValuePrecisionDouble) {
        if (self.leadingDimension == MCMatrixLeadingDimensionRow) {
            ((double *)self.values.bytes)[row * self.columns + column] = value.doubleValue;
        } else {
            ((double *)self.values.bytes)[column * self.rows + row] = value.doubleValue;
        }
    } else {
        if (self.leadingDimension == MCMatrixLeadingDimensionRow) {
            ((float *)self.values.bytes)[row * self.columns + column] = value.floatValue;
        } else {
            ((float *)self.values.bytes)[column * self.rows + row] = value.floatValue;
        }
    }
}

#pragma mark - Class-level matrix operations

+ (MCMatrix *)productOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB
{
    NSAssert(matrixA.columns == matrixB.rows, @"matrixA does not have an equal amount of columns as rows in matrixB");
    NSAssert(matrixA.precision == matrixB.precision, @"Precisions do not match.");
    
    MCMatrix *matrix;
    
    NSData *aVals = [matrixA valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    NSData *bVals = [matrixB valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    
    if (matrixA.precision == MCValuePrecisionDouble) {
        size_t size = matrixA.rows * matrixB.columns * sizeof(double);
        double *cVals = malloc(size);
        vDSP_mmulD(aVals.bytes, 1, bVals.bytes, 1, cVals, 1, matrixA.rows, matrixB.columns, matrixA.columns);
        matrix = [MCMatrix matrixWithValues:[NSData dataWithBytes:cVals length:size] rows:matrixA.rows columns:matrixB.columns leadingDimension:MCMatrixLeadingDimensionRow];
    } else {
        size_t size = matrixA.rows * matrixB.columns * sizeof(float);
        float *cVals = malloc(size);
        vDSP_mmul(aVals.bytes, 1, bVals.bytes, 1, cVals, 1, matrixA.rows, matrixB.columns, matrixA.columns);
        matrix = [MCMatrix matrixWithValues:[NSData dataWithBytes:cVals length:size] rows:matrixA.rows columns:matrixB.columns leadingDimension:MCMatrixLeadingDimensionRow];
    }
    
    return matrix;
}

+ (MCMatrix *)sumOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB
{
    NSAssert(matrixA.rows == matrixB.rows, @"Matrices have mismatched amounts of rows.");
    NSAssert(matrixA.columns == matrixB.columns, @"Matrices have mismatched amounts of columns.");
    NSAssert(matrixA.precision == matrixB.precision, @"Precisions do not match.");
    
    MCMatrix *sum = [MCMatrix matrixWithRows:matrixA.rows columns:matrixA.columns precision:matrixA.precision];
    for (int i = 0; i < matrixA.rows; i++) {
        for (int j = 0; j < matrixA.columns; j++) {
            if (matrixA.precision == MCValuePrecisionDouble) {
                [sum setEntryAtRow:i column:j toValue:@([matrixA valueAtRow:i column:j].doubleValue + [matrixB valueAtRow:i column:j].doubleValue)];
            } else {
                [sum setEntryAtRow:i column:j toValue:@([matrixA valueAtRow:i column:j].floatValue + [matrixB valueAtRow:i column:j].floatValue)];
            }
        }
    }
    
    return sum;
}

+ (MCMatrix *)differenceOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB
{
    NSAssert(matrixA.rows == matrixB.rows, @"Matrices have mismatched amounts of rows.");
    NSAssert(matrixA.columns == matrixB.columns, @"Matrices have mismatched amounts of columns.");
    NSAssert(matrixA.precision == matrixB.precision, @"Precisions do not match.");
    
    MCMatrix *sum = [MCMatrix matrixWithRows:matrixA.rows columns:matrixA.columns precision:matrixA.precision];
    for (int i = 0; i < matrixA.rows; i++) {
        for (int j = 0; j < matrixA.columns; j++) {
            if (matrixA.precision == MCValuePrecisionDouble) {
                [sum setEntryAtRow:i column:j toValue:@([matrixA valueAtRow:i column:j].doubleValue - [matrixB valueAtRow:i column:j].doubleValue)];
            } else {
                [sum setEntryAtRow:i column:j toValue:@([matrixA valueAtRow:i column:j].floatValue - [matrixB valueAtRow:i column:j].floatValue)];
            }
        }
    }
    
    return sum;
}

// TODO: this should really return a vector instead of a matrix
+ (MCMatrix *)solveLinearSystemWithMatrixA:(MCMatrix *)A
                                   valuesB:(MCMatrix *)B
{
    NSAssert(A.precision == B.precision, @"Precisions do not match.");
    
    MCMatrix *matrix;
    
    NSData *aData = [A valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
    
    if (A.rows == A.columns) {
        // solve for square matrix A
        
        int n = A.rows;
        int nrhs = 1;
        int lda = n;
        int ldb = n;
        int info;
        int *ipiv = malloc(n * sizeof(int));
        int nb = B.rows;
        
        if (A.precision == MCValuePrecisionDouble) {
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
                matrix = [MCMatrix matrixWithValues:[NSData dataWithBytes:solutionValues length:size]
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
                matrix = [MCMatrix matrixWithValues:[NSData dataWithBytes:solutionValues length:size]
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
        
        if (A.precision == MCValuePrecisionDouble) {
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
                matrix = [MCMatrix matrixWithValues:[NSData dataWithBytes:solutionValues length:size]
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
                matrix = [MCMatrix matrixWithValues:[NSData dataWithBytes:solutionValues length:size]
                                               rows:n
                                            columns:1];
            }
        }
    }
    
    return matrix;
}

+ (MCVector *)productOfMatrix:(MCMatrix *)matrix andVector:(MCVector *)vector
{
    NSAssert(matrix.columns == vector.length, @"Matrix must have same amount of columns as vector length.");
    NSAssert(matrix.precision == vector.precision, @"Precisions do not match.");
    
    MCVector *product;
    
    short order = matrix.leadingDimension == MCMatrixLeadingDimensionColumn ? CblasColMajor : CblasRowMajor;
    short transpose = CblasNoTrans;
    int rows = matrix.rows;
    int cols = matrix.columns;
    
    if (matrix.precision == MCValuePrecisionDouble) {
        double *result = calloc(vector.length, sizeof(double));
        cblas_dgemv(order, transpose, rows, cols, 1.0, matrix.values.bytes, rows, vector.values.bytes, 1, 1.0, result, 1);
        product = [MCVector vectorWithValues:[NSData dataWithBytes:result length:vector.values.length] length:vector.length];
    } else {
        float *result = calloc(vector.length, sizeof(float));
        cblas_sgemv(order, transpose, rows, cols, 1.0f, matrix.values.bytes, rows, vector.values.bytes, 1, 1.0f, result, 1);
        product = [MCVector vectorWithValues:[NSData dataWithBytes:result length:vector.values.length] length:vector.length];
    }
    
    return product;
}

+ (MCMatrix *)productOfMatrix:(MCMatrix *)matrix andScalar:(NSNumber *)scalar
{
    MCMatrix *product;
    
    int valueCount = matrix.rows * matrix.columns;
    if (matrix.precision == MCValuePrecisionDouble) {
        size_t size = valueCount * sizeof(double);
        double *values = malloc(size);
        for (int i = 0; i < valueCount; i++) {
            values[i] = ((double *)matrix.values.bytes)[i] * scalar.doubleValue;
        }
        product = [MCMatrix matrixWithValues:[NSData dataWithBytes:values length:size]
                                        rows:matrix.rows
                                     columns:matrix.columns
                            leadingDimension:matrix.leadingDimension];
    }
    else {
        size_t size = valueCount * sizeof(float);
        float *values = malloc(size);
        for (int i = 0; i < valueCount; i++) {
            values[i] = ((float *)matrix.values.bytes)[i] * scalar.floatValue;
        }
        product = [MCMatrix matrixWithValues:[NSData dataWithBytes:values length:size]
                                        rows:matrix.rows
                                     columns:matrix.columns
                            leadingDimension:matrix.leadingDimension];
    }
    
    return product;
}

+ (MCMatrix *)raiseMatrix:(MCMatrix *)matrix toPower:(NSUInteger)power
{
    NSAssert(matrix.rows == matrix.columns, @"Cannot raise a non-square matrix to exponents.");
    
    MCMatrix *product = [MCMatrix productOfMatrixA:matrix andMatrixB:matrix];
    for (int i = 0; i < power - 2; i += 1) {
        product = [MCMatrix productOfMatrixA:matrix andMatrixB:product];
    }
    return product;
}

+ (MCMatrix *)productOfMatrices:(NSArray *)matrices
{
    // TODO: implement hu-shing partitioning algorithm
    
    return nil;
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
    matrixCopy->_definiteness = _definiteness;
    matrixCopy->_precision = _precision;
    
    if (_precision == MCValuePrecisionDouble) {
        double *values = malloc(_values.length);
        for (int i = 0; i < _values.length / sizeof(double); i++) {
            values[i] = ((double *)_values.bytes)[i];
        }
        matrixCopy->_values = [NSData dataWithBytes:values length:_values.length];
    } else {
        float *values = malloc(_values.length);
        for (int i = 0; i < _values.length / sizeof(float); i++) {
            values[i] = ((float *)_values.bytes)[i];
        }
        matrixCopy->_values = [NSData dataWithBytes:values length:_values.length];
    }
    
    matrixCopy->_transpose = _transpose.copy;
    matrixCopy->_determinant = _determinant.copy;
    matrixCopy->_inverse = _inverse.copy;
    matrixCopy->_adjugate = _adjugate.copy;
    matrixCopy->_conditionNumber = _conditionNumber.copy;
    matrixCopy->_qrFactorization = _qrFactorization.copy;
    matrixCopy->_luFactorization = _luFactorization.copy;
    matrixCopy->_singularValueDecomposition = _singularValueDecomposition.copy;
    matrixCopy->_eigendecomposition = _eigendecomposition.copy;
    matrixCopy->_diagonalValues = _diagonalValues.copy;
    matrixCopy->_minorMatrix = _minorMatrix.copy;
    matrixCopy->_cofactorMatrix = _cofactorMatrix.copy;
    matrixCopy->_isSymmetric = _isSymmetric.copy;
    matrixCopy->_trace = _trace.copy;
    matrixCopy->_normInfinity = _normInfinity.copy;
    matrixCopy->_normL1 = _normL1.copy;
    matrixCopy->_normFroebenius = _normFroebenius.copy;
    matrixCopy->_normMax = _normMax.copy;
    
    matrixCopy->_bandwidth = _bandwidth;
    matrixCopy->_numberOfBandValues = _numberOfBandValues;
    matrixCopy->_upperCodiagonals = _upperCodiagonals;
    
    return matrixCopy;
}

#pragma mark - Private interface

+ (NSData *)randomArrayOfSize:(int)size
                    precision:(MCValuePrecision)precision
{
    NSData *data;
    
    if (precision == MCValuePrecisionDouble) {
        NSUInteger dataSize = size * sizeof(double);
        double *values = malloc(dataSize);
        for (int i = 0; i < size; i += 1) {
            values[i] = randomDouble;
        }
        data = [NSData dataWithBytes:values length:dataSize];
    } else {
        NSUInteger dataSize = size * sizeof(float);
        float *values = malloc(dataSize);
        for (int i = 0; i < size; i += 1) {
            values[i] = randomFloat;
        }
        data = [NSData dataWithBytes:values length:dataSize];
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
        _precision = MCValuePrecisionSingle;
        
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

- (NSNumber *)normOfType:(MCMatrixNorm)normType
{
    NSNumber *normResult;
    
    int m = self.rows;
    int n = self.columns;
    NSData *valueData = [self valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
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
    
    if (self.precision == MCValuePrecisionDouble) {
        normResult = @(dlange_(norm, &m, &n, (double *)valueData.bytes, &m, nil));
    } else {
        normResult = @(slange_(norm, &m, &n, (float *)valueData.bytes, &m, nil));
    }
    
    return normResult;
}

@end

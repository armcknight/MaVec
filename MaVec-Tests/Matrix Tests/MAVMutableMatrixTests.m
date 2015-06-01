//
//  MAVMutableMatrixTests.m
//  MaVec
//
//  Created by Andrew McKnight on 10/25/14.
//  Copyright (c) 2014 AMProductions. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MAVMutableMatrix.h"
#import "MAVVector.h"

#import "MAVTypedefs.h"

#import "MCKTribool.h"

typedef NS_ENUM(NSUInteger, MAVMatrixInternalRepresentation)
{
    MAVMatrixInternalRepresentationConventionalRowMajor,
    MAVMatrixInternalRepresentationConventionalColumnMajor,
    MAVMatrixInternalRepresentationUpperTriangularRowMajor,
    MAVMatrixInternalRepresentationLowerTriangularRowMajor,
    MAVMatrixInternalRepresentationUpperTriangularColumnMajor,
    MAVMatrixInternalRepresentationLowerTriangularColumnMajor,
    MAVMatrixInternalRepresentationSymmetricRowMajorFromLower,
    MAVMatrixInternalRepresentationSymmetricColumnMajorFromLower,
    MAVMatrixInternalRepresentationSymmetricRowMajorFromUpper,
    MAVMatrixInternalRepresentationSymmetricColumnMajorFromUpper,
    MAVMatrixInternalRepresentationBandBalanced,
    MAVMatrixInternalRepresentationBandTopHeavy,
    MAVMatrixInternalRepresentationBandBottomHeavy,
    MAVMatrixInternalRepresentationDiagonal
};

static const MAVIndex rows = 3;
static const MAVIndex columns = 3;

@interface MAVMutableMatrixTests : XCTestCase

@end

@implementation MAVMutableMatrixTests

- (NSArray *)matrixCombinations
{
    NSMutableArray *matrices = [NSMutableArray array];
    for (NSNumber *precision in @[@(MCKPrecisionSingle), @(MCKPrecisionDouble)]) {
        for (NSNumber *matrixType in @[
                                       @(MAVMatrixInternalRepresentationConventionalRowMajor),
                                       @(MAVMatrixInternalRepresentationConventionalColumnMajor),
                                       @(MAVMatrixInternalRepresentationUpperTriangularRowMajor),
                                       @(MAVMatrixInternalRepresentationLowerTriangularRowMajor),
                                       @(MAVMatrixInternalRepresentationUpperTriangularColumnMajor),
                                       @(MAVMatrixInternalRepresentationLowerTriangularColumnMajor),
                                       @(MAVMatrixInternalRepresentationSymmetricRowMajorFromLower),
                                       @(MAVMatrixInternalRepresentationSymmetricColumnMajorFromLower),
                                       @(MAVMatrixInternalRepresentationSymmetricRowMajorFromUpper),
                                       @(MAVMatrixInternalRepresentationSymmetricColumnMajorFromUpper),
                                       @(MAVMatrixInternalRepresentationBandBalanced),
                                       @(MAVMatrixInternalRepresentationBandTopHeavy),
                                       @(MAVMatrixInternalRepresentationBandBottomHeavy),
                                       @(MAVMatrixInternalRepresentationDiagonal)
                                       ]) {
            [matrices addObject:[self matrixOfRepresentationType:(MAVMatrixInternalRepresentation)matrixType.unsignedIntegerValue withPrecision:(MCKPrecision)precision.unsignedIntegerValue]];
        }
    }

    return matrices;
}

- (void)testValueAssignment
{
    NSNumber *const doubleInput = @999.0;
    NSNumber *const floatInput = @999.0f;

    NSArray *matrices = [self matrixCombinations];
    
    for (MAVMutableMatrix *matrix in matrices) {
        for (MAVIndex row = 0; row < rows; row++) {
            for (MAVIndex column = 0; column < columns; column++) {
                NSNumber *newValue = matrix.precision == MCKPrecisionDouble ? doubleInput : floatInput;
                
                // test assigning an invalid precision
                XCTAssertThrows([matrix setEntryAtRow:row column:column toValue:matrix.precision == MCKPrecisionDouble ? floatInput : doubleInput], @"Should not be able to assign %@ precision value into a %@ precision matrix", matrix.precision == MCKPrecisionDouble ? @"single" : @"double", matrix.precision == MCKPrecisionDouble ? @"double" : @"single");

                // test the assignment and validate that it happened at the correct location
                MAVMatrix *matrixCopy = matrix.copy;
                [matrix setEntryAtRow:row column:column toValue:newValue];
                NSLog(@"%@", matrix);
                NSNumber *newlySetEntry = matrix[row][column];
                XCTAssertTrue([newlySetEntry isEqualToNumber:newValue], @"The value of the desired location in the matrix was not changed.");
                
                // make sure no other values changed
                for (MAVIndex copyRow = 0; copyRow < matrix.rows; copyRow++) {
                    for (MAVIndex copyCol = 0; copyCol  <matrix.columns; copyCol++) {
                        if (copyCol != column && copyRow != row) {
                            XCTAssertTrue([matrixCopy[copyRow][copyCol] isEqualToNumber:matrix[copyRow][copyCol]], @"Another value changed that should not have.");
                        }
                    }
                }
            }
        }
    }
}

- (void)testAddition
{
    [self checkResultsOfAddition:YES];
}

- (void)testSubtraction
{
    [self checkResultsOfAddition:NO];
}

- (void)checkResultsOfAddition:(BOOL)addition
{
    for (MAVMutableMatrix *matrix in [self matrixCombinations]) {
        NSNumber *value = matrix.precision == MCKPrecisionDouble ? @1.0 : @1.0f;
        MAVMatrix *addendOrSubtrahend = [MAVMatrix matrixFilledWithValue:value
                                                                    rows:matrix.rows
                                                                 columns:matrix.columns];
        MAVMatrix *original = matrix.copy;
        if (addition) {
            [matrix addMatrix:addendOrSubtrahend];
        } else {
            [matrix subtractMatrix:addendOrSubtrahend];
        }
        for (__CLPK_integer row = 0; row < matrix.rows; row++) {
            for (__CLPK_integer column = 0; column < matrix.columns; column++) {
                if ([value isDoublePrecision]) {
                    double resultValue = matrix[row][column].doubleValue;
                    double computedValue = original[row][column].doubleValue + 1.0 * (addition ? 1.0 : -1.0);
                    XCTAssertEqual(resultValue, computedValue, @"Value at (%lu, %lu) %@ incorrectly in double precision matrix", row, column, addition ? @"added" : @"subtracted");
                } else {
                    float resultValue = matrix[row][column].floatValue;
                    float computedValue = original[row][column].floatValue + 1.0f * (addition ? 1.0f : -1.0f);
                    XCTAssertEqual(resultValue, computedValue, @"Value at (%lu, %lu) %@ incorrectly in single precision matrix", row, column, addition ? @"added" : @"subtracted");
                }
            }
        }
    }
}

- (void)testScalarMultiplication
{
    for (MAVMutableMatrix *matrix in [self matrixCombinations]) {
        BOOL isDouble = matrix.precision == MCKPrecisionDouble;
        MAVMatrix *original = matrix.copy;
        [matrix multiplyByScalar:(isDouble ? @5.0 : @5.0f)];
        for (__CLPK_integer row = 0; row < matrix.rows; row++) {
            for (__CLPK_integer column = 0; column < matrix.columns; column++) {
                if (isDouble) {
                    double computedValue = matrix[row][column].doubleValue;
                    double solution = original[row][column].doubleValue * 5.0;
                    XCTAssertEqual(computedValue, solution, @"Entry at (%lu, %lu) not multiplied correctly in double-precision matrix.", row, column);
                } else {
                    float computedValue = matrix[row][column].floatValue;
                    float solution = original[row][column].floatValue * 5.0f;
                    XCTAssertEqual(computedValue, solution, @"Entry at (%lu, %lu) not multiplied correctly in single-precision matrix.", row, column);
                }
            }
        }
    }
}

- (void)testDimensionalSwaps
{
    for (MAVMutableMatrix *matrix in [self matrixCombinations]) {
        for (NSNumber *dimensionValue in @[@(MAVMatrixLeadingDimensionRow), @(MAVMatrixLeadingDimensionColumn)]) {
            MAVMatrixLeadingDimension dimension = (MAVMatrixLeadingDimension)dimensionValue.unsignedIntegerValue;
            __CLPK_integer vectorCount = dimension == MAVMatrixLeadingDimensionRow ? matrix.rows : matrix.columns;
            for (__CLPK_integer vectorA = 0; vectorA < vectorCount - 1; vectorA += 1) {
                for (__CLPK_integer vectorB = vectorA + 1; vectorB < vectorCount; vectorB += 1) {
                    MAVMatrix *originalMatrix = [matrix copy];
                    if (dimension == MAVMatrixLeadingDimensionRow) {
                        [matrix swapRowA:vectorA withRowB:vectorB];
                    } else {
                        [matrix swapColumnA:vectorA withColumnB:vectorB];
                    }
                    for (__CLPK_integer row = 0; row < matrix.rows; row += 1) {
                        for (__CLPK_integer column = 0; column < matrix.columns; column += 1) {
                            if (dimension == MAVMatrixLeadingDimensionRow) {
                                if (row == vectorA) {
                                    XCTAssert([matrix[vectorA][column] isEqualToNumber:originalMatrix[vectorB][column]], @"Entry did not get swapped correctly.");
                                } else if (row == vectorB) {
                                    XCTAssert([matrix[vectorB][column] isEqualToNumber:originalMatrix[vectorA][column]], @"Entry did not get swapped correctly.");
                                } else {
                                    XCTAssert([matrix[row][column] isEqualToNumber:originalMatrix[row][column]], @"Entry changed that should not have during swap.");
                                }
                            } else {
                                if (column == vectorA) {
                                    XCTAssert([matrix[row][vectorA] isEqualToNumber:originalMatrix[row][vectorB]], @"Entry did not get swapped correctly.");
                                } else if (column == vectorB) {
                                    XCTAssert([matrix[row][vectorB] isEqualToNumber:originalMatrix[row][vectorA]], @"Entry did not get swapped correctly.");
                                } else {
                                    XCTAssert([matrix[row][column] isEqualToNumber:originalMatrix[row][column]], @"Entry changed that should not have during swap.");
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)testRowAssignment
{
    [self checkRowAssignment:YES];
}

- (void)testColumnAssigment
{
    [self checkRowAssignment:NO];
}

- (void)checkRowAssignment:(BOOL)rowAssignment
{
    for (MAVMutableMatrix *matrix in [self matrixCombinations]) {
        for (__CLPK_integer dimension = 0; dimension < (rowAssignment ? matrix.rows : matrix.columns); dimension++) {
            MAVMutableMatrix *mutatedMatrix = matrix.mutableCopy;
            NSMutableArray *values = [NSMutableArray array];
            BOOL isDouble = matrix.precision == MCKPrecisionDouble;
            for (__CLPK_integer entry = 0; entry < (rowAssignment ? matrix.columns : matrix.rows); entry++) {
                if (isDouble) {
                    [values addObject:@(900.0 + entry * 1.0)];
                } else {
                    [values addObject:@(900.0f + entry * 1.0f)];
                }
            }
            MAVVector *vector = [MAVVector vectorWithValuesInArray:values vectorFormat:rowAssignment ? MAVVectorFormatRowVector : MAVVectorFormatColumnVector];
            if (rowAssignment) {
                [mutatedMatrix setRowVector:vector atRow:dimension];
            } else {
                [mutatedMatrix setColumnVector:vector atColumn:dimension];
            }
            for (__CLPK_integer row = 0; row < matrix.rows; row++) {
                for (__CLPK_integer column = 0; column < matrix.columns; column++) {
                    if ((rowAssignment && row == dimension) || (!rowAssignment && column == dimension)) {
                        if (isDouble) {
                            XCTAssertEqual(vector[rowAssignment ? column : row].doubleValue, mutatedMatrix[row][column].doubleValue, @"Mutated %@ in double-precision matrix was not set correctly checking (%lu, %lu)", rowAssignment ? @"row" : @"column", row, column);
                        } else {
                            XCTAssertEqual(vector[rowAssignment ? column : row].floatValue, mutatedMatrix[row][column].floatValue, @"Mutated %@ in single-precision matrix was not set correctly checking (%lu, %lu)", rowAssignment ? @"row" : @"column", row, column);
                        }
                    } else {
                        if (isDouble) {
                            XCTAssertEqual(matrix[row][column].doubleValue, mutatedMatrix[row][column].doubleValue, @"%@ not mutated in double-precision row was incorrectly changed checking (%lu, %lu).", rowAssignment ? @"row" : @"column", row, column);
                        } else {
                            XCTAssertEqual(matrix[row][column].floatValue, mutatedMatrix[row][column].floatValue, @"%@ not mutated in single-precision row was incorrectly changed checking (%lu, %lu).", rowAssignment ? @"row" : @"column", row, column);
                        }
                    }
                }
            }
        }
    }
}

- (MAVMutableMatrix *)matrixOfRepresentationType:(MAVMatrixInternalRepresentation)representation withPrecision:(MCKPrecision)precision
{
    MAVMutableMatrix *matrix;
    
    switch (representation) {
        case MAVMatrixInternalRepresentationBandBalanced: {
            if (precision == MCKPrecisionDouble) {
                double values[9] = {
                    0.0, 1.0, 2.0,
                    3.0, 4.0, 5.0,
                    6.0, 7.0, 0.0
                };
                matrix = [MAVMutableMatrix bandMatrixWithValues:[NSData dataWithBytes:values length:9 * sizeof(double)] order:3 upperCodiagonals:1 lowerCodiagonals:1];
            } else {
                float values[9] = {
                    0.0f, 1.0f, 2.0f,
                    3.0f, 4.0f, 5.0f,
                    6.0f, 7.0f, 0.0f
                };
                matrix = [MAVMutableMatrix bandMatrixWithValues:[NSData dataWithBytes:values length:9 * sizeof(float)] order:3 upperCodiagonals:1 lowerCodiagonals:1];
            }
        } break;

        case MAVMatrixInternalRepresentationBandTopHeavy: {
            if (precision == MCKPrecisionDouble) {
                double values[6] = {
                    0.0, 1.0, 2.0,
                    3.0, 4.0, 5.0
                };
                matrix = [MAVMutableMatrix bandMatrixWithValues:[NSData dataWithBytes:values length:6 * sizeof(double)] order:3 upperCodiagonals:1 lowerCodiagonals:0];
            } else {
                float values[6] = {
                    0.0f, 1.0f, 2.0f,
                    3.0f, 4.0f, 5.0f
                };
                matrix = [MAVMutableMatrix bandMatrixWithValues:[NSData dataWithBytes:values length:6 * sizeof(float)] order:3 upperCodiagonals:1 lowerCodiagonals:0];
            }
        } break;

        case MAVMatrixInternalRepresentationBandBottomHeavy: {
            if (precision == MCKPrecisionDouble) {
                double values[6] = {
                    1.0, 2.0, 3.0,
                    4.0, 5.0, 0.0
                };
                matrix = [MAVMutableMatrix bandMatrixWithValues:[NSData dataWithBytes:values length:6 * sizeof(double)] order:3 upperCodiagonals:0 lowerCodiagonals:1];
            } else {
                float values[6] = {
                    1.0f, 2.0f, 3.0f,
                    4.0f, 5.0f, 0.0f
                };
                matrix = [MAVMutableMatrix bandMatrixWithValues:[NSData dataWithBytes:values length:6 * sizeof(float)] order:3 upperCodiagonals:0 lowerCodiagonals:1];
            }
        } break;

        case MAVMatrixInternalRepresentationDiagonal: {
            if (precision == MCKPrecisionDouble) {
                double values[3] = {
                    1.0, 2.0, 3.0
                };
                matrix = [MAVMutableMatrix diagonalMatrixWithValues:[NSData dataWithBytes:values length:3 * sizeof(double)] order:3];
            } else {
                float values[3] = {
                    1.0f, 2.0f, 3.0f
                };
                matrix = [MAVMutableMatrix diagonalMatrixWithValues:[NSData dataWithBytes:values length:3 * sizeof(float)] order:3];
            }
        } break;
            
        case MAVMatrixInternalRepresentationSymmetricRowMajorFromUpper: {
            if (precision == MCKPrecisionDouble) {
                double values[6] = {
                    1.0, 2.0, 3.0,
                    4.0, 5.0,
                    6.0
                };
                matrix = [MAVMutableMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(double)] triangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionRow order:3];
            } else {
                float values[6] = {
                    1.0f, 2.0f, 3.0f,
                          4.0f, 5.0f,
                                6.0f
                };
                matrix = [MAVMutableMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(float)] triangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionRow order:3];
            }
        } break;
            
        case MAVMatrixInternalRepresentationSymmetricColumnMajorFromUpper: {
            if (precision == MCKPrecisionDouble) {
                double values[6] = {
                    1.0,
                    2.0, 4.0,
                    3.0, 5.0, 6.0
                };
                matrix = [MAVMutableMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(double)] triangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionColumn order:3];
            } else {
                float values[6] = {
                    1.0f,
                    2.0f, 4.0f,
                    3.0f, 5.0f, 6.0f
                };
                matrix = [MAVMutableMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(float)] triangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionColumn order:3];
            }
        } break;
            
        case MAVMatrixInternalRepresentationSymmetricRowMajorFromLower: {
            if (precision == MCKPrecisionDouble) {
                double values[6] = {
                    1.0, 2.0, 4.0,
                    3.0, 5.0,
                    6.0
                };
                matrix = [MAVMutableMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(double)] triangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionRow order:3];
            } else {
                float values[6] = {
                    1.0f,
                    2.0f, 4.0f,
                    3.0f, 5.0f, 6.0f
                };
                matrix = [MAVMutableMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(float)] triangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionRow order:3];
            }
        } break;
            
        case MAVMatrixInternalRepresentationSymmetricColumnMajorFromLower: {
            if (precision == MCKPrecisionDouble) {
                double values[6] = {
                    1.0, 2.0, 3.0,
                    4.0, 5.0,
                    6.0
                };
                matrix = [MAVMutableMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(double)] triangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionColumn order:3];
            } else {
                float values[6] = {
                    1.0f, 2.0f, 3.0f,
                    4.0f, 5.0f,
                    6.0f
                };
                matrix = [MAVMutableMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(float)] triangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionColumn order:3];
            }
        } break;
            
        case MAVMatrixInternalRepresentationLowerTriangularColumnMajor: {
            if (precision == MCKPrecisionDouble) {
                double values[6] = {
                    1.0, 2.0, 4.0,
                         3.0, 5.0,
                              6.0
                };
                matrix = [MAVMutableMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(double)] ofTriangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionColumn order:rows];
            } else {
                float values[6] = {
                    1.0f, 2.0f, 4.0f,
                          3.0f, 5.0f,
                                6.0f
                };
                matrix = [MAVMutableMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(float)] ofTriangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionColumn order:rows];
            }
        } break;
            
        case MAVMatrixInternalRepresentationUpperTriangularColumnMajor: {
            if (precision == MCKPrecisionDouble) {
                double values[6] = {
                    1.0,
                    2.0, 4.0,
                    3.0, 5.0, 6.0
                };
                matrix = [MAVMutableMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(double)] ofTriangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionColumn order:rows];
            } else {
                float values[6] = {
                    1.0f,
                    2.0f, 4.0f,
                    3.0f, 5.0f, 6.0f
                };
                matrix = [MAVMutableMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(float)] ofTriangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionColumn order:rows];
            }
        } break;
            
        case MAVMatrixInternalRepresentationLowerTriangularRowMajor: {
            if (precision == MCKPrecisionDouble) {
                double values[6] = {
                    1.0,
                    2.0, 3.0,
                    4.0, 5.0, 6.0
                };
                matrix = [MAVMutableMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(double)] ofTriangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionRow order:rows];
            } else {
                float values[6] = {
                    1.0f,
                    2.0f, 3.0f,
                    4.0f, 5.0f, 6.0f
                };
                matrix = [MAVMutableMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(float)] ofTriangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionRow order:rows];
            }
        } break;
            
        case MAVMatrixInternalRepresentationUpperTriangularRowMajor: {
            if (precision == MCKPrecisionDouble) {
                double values[6] = {
                    1.0, 2.0, 3.0,
                    4.0, 5.0,
                    6.0
                };
                matrix = [MAVMutableMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(double)] ofTriangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionRow order:rows];
            } else {
                float values[6] = {
                    1.0f, 2.0f, 3.0f,
                    4.0f, 5.0f,
                    6.0f
                };
                matrix = [MAVMutableMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:values length:6 * sizeof(float)] ofTriangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionRow order:rows];
            }
        } break;
            
        case MAVMatrixInternalRepresentationConventionalRowMajor: {
            if (precision == MCKPrecisionDouble) {
                double values[9] = {
                    1.0, 2.0, 3.0,
                    4.0, 5.0, 6.0,
                    7.0, 8.0, 9.0
                };
                matrix =  [MAVMutableMatrix matrixWithValues:[NSData dataWithBytes:values length:9 * sizeof(double)] rows:rows columns:columns leadingDimension:MAVMatrixLeadingDimensionRow];
            } else {
                float values[9] = {
                    1.0f, 2.0f, 3.0f,
                    4.0f, 5.0f, 6.0f,
                    7.0f, 8.0f, 9.0f
                };
                matrix = [MAVMutableMatrix matrixWithValues:[NSData dataWithBytes:values length:9 * sizeof(float)] rows:rows columns:columns leadingDimension:MAVMatrixLeadingDimensionRow];
            }
        } break;
            
        case MAVMatrixInternalRepresentationConventionalColumnMajor: {
            if (precision == MCKPrecisionDouble) {
                double values[9] = {
                    1.0, 4.0, 7.0,
                    2.0, 5.0, 8.0,
                    3.0, 6.0, 9.0
                };
                matrix =  [MAVMutableMatrix matrixWithValues:[NSData dataWithBytes:values length:9 * sizeof(double)] rows:rows columns:columns leadingDimension:MAVMatrixLeadingDimensionColumn];
            } else {
                float values[9] = {
                    1.0f, 4.0f, 7.0f,
                    2.0f, 5.0f, 8.0f,
                    3.0f, 6.0f, 9.0f
                };
                matrix = [MAVMutableMatrix matrixWithValues:[NSData dataWithBytes:values length:9 * sizeof(float)] rows:rows columns:columns leadingDimension:MAVMatrixLeadingDimensionColumn];
            }
        } break;
            
        default: break;
    }
    
    return matrix;
}

@end

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

typedef NS_ENUM(NSUInteger, MAVMatrixInternalRepresentation) {
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

- (void)testValueAssignment
{
    NSNumber *const doubleInput = @999.0;
    NSNumber *const floatInput = @999.0f;
    
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

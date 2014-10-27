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

typedef NS_ENUM(NSUInteger, MAVMatrixInternalRepresentation) {
    MAVMatrixInternalRepresentationConventionalRowMajor,
    MAVMatrixInternalRepresentationConventionalColumnMajor,
    MAVMatrixInternalRepresentationUpperTriangular,
    MAVMatrixInternalRepresentationLowerTriangular,
    MAVMatrixInternalRepresentationSymmetrix,
    MAVMatrixInternalRepresentationBand
};


static const MAVIndex rows = 3;
static const MAVIndex columns = 3;

@interface MAVMutableMatrixTests : XCTestCase

@end

@implementation MAVMutableMatrixTests

- (void)testValueAssignmentConventionalRowMajor
{
    self measureBlock:<#^(void)block#>
    NSNumber *const doubleInput = @999.0;
    NSNumber *const floatInput = @999.0f;
    for (MAVMutableMatrix *matrix in @[
                                       [self matrixOfRepresentationType:MAVMatrixInternalRepresentationConventionalColumnMajor withPrecision:MCKPrecisionDouble],
                                       [self matrixOfRepresentationType:MAVMatrixInternalRepresentationConventionalColumnMajor withPrecision:MCKPrecisionSingle]
                                       ]) {
        for (MAVIndex row = 0; row < rows; row++) {
            for (MAVIndex column = 0; column < columns; column++) {
                XCTAssertThrows([matrix setEntryAtRow:row column:column toValue:matrix.precision == MCKPrecisionDouble ? floatInput : doubleInput]);
                NSNumber *newValue = matrix.precision == MCKPrecisionDouble ? doubleInput : floatInput;
                [matrix setEntryAtRow:row column:column toValue:newValue];
                NSNumber *newlySetEntry = matrix[row][column];
                NSLog(@"row: %d, col: %d, newEntry: %@, newlySetEntry: %@\nmatrix: %@", row, column, newValue.description, newlySetEntry.description, matrix.description);
                XCTAssertTrue([newlySetEntry isEqualToNumber:newValue]);
            }
        }
    }
}

- (MAVMutableMatrix *)matrixOfRepresentationType:(MAVMatrixInternalRepresentation)representation withPrecision:(MCKPrecision)precision
{
    MAVMutableMatrix *matrix;
    
    switch (representation) {
        case MAVMatrixInternalRepresentationBand: {
            if (precision == MCKPrecisionDouble) {
                
            } else {
                
            }
        } break;
            
        case MAVMatrixInternalRepresentationSymmetrix: {
            if (precision == MCKPrecisionDouble) {
                
            } else {
                
            }
        } break;
            
        case MAVMatrixInternalRepresentationLowerTriangular: {
            if (precision == MCKPrecisionDouble) {
                
            } else {
                
            }
        } break;
            
        case MAVMatrixInternalRepresentationUpperTriangular: {
            if (precision == MCKPrecisionDouble) {
                
            } else {
                
            }
        } break;
            
        case MAVMatrixInternalRepresentationConventionalRowMajor: {
            if (precision == MCKPrecisionDouble) {
                double *values = malloc(rows * columns * sizeof(double));
                for (MAVIndex row = 0; row < rows; row++) {
                    for (MAVIndex column = 0; column < columns; column++) {
                        NSUInteger index = row * rows + column;
                        values[index] = index + 1.0;
                    }
                }
                matrix =  [MAVMutableMatrix matrixWithValues:[NSData dataWithBytes:values length:9 * sizeof(double)] rows:rows columns:columns leadingDimension:MAVMatrixLeadingDimensionRow];
            } else {
                float *values = malloc(rows * columns * sizeof(float));
                for (MAVIndex row = 0; row < rows; row++) {
                    for (MAVIndex column = 0; column < columns; column++) {
                        NSUInteger index = row * rows + column;
                        values[index] = index + 1.0f;
                    }
                }
                matrix = [MAVMutableMatrix matrixWithValues:[NSData dataWithBytes:values length:9 * sizeof(float)] rows:rows columns:columns leadingDimension:MAVMatrixLeadingDimensionRow];
            }
        } break;
            
        case MAVMatrixInternalRepresentationConventionalColumnMajor: {
            if (precision == MCKPrecisionDouble) {
                double *values = malloc(rows * columns * sizeof(double));
                for (MAVIndex column = 0; column < columns; column++) {
                    for (MAVIndex row = 0; row < rows; row++) {
                        NSUInteger index = column * columns + row;
                        values[index] = index + 1.0;
                    }
                }
                matrix =  [MAVMutableMatrix matrixWithValues:[NSData dataWithBytes:values length:9 * sizeof(double)] rows:rows columns:columns leadingDimension:MAVMatrixLeadingDimensionColumn];
            } else {
                float *values = malloc(rows * columns * sizeof(float));
                for (MAVIndex column = 0; column < columns; column++) {
                    for (MAVIndex row = 0; row < rows; row++) {
                        NSUInteger index = column * columns + row;
                        values[index] = index + 1.0f;
                    }
                }
                matrix = [MAVMutableMatrix matrixWithValues:[NSData dataWithBytes:values length:9 * sizeof(float)] rows:rows columns:columns leadingDimension:MAVMatrixLeadingDimensionColumn];
            }
        } break;
            
        default: break;
    }
    
    return matrix;
}

@end

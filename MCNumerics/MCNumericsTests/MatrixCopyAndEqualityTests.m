//
//  MatrixCopyAndEqualityTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/8/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"

@interface MatrixCopyAndEqualityTests : XCTestCase

@end

@implementation MatrixCopyAndEqualityTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testMatrixEqualityComparison
{
    int size = 16;
    double *aValues = malloc(size * sizeof(double));
    for (int i = 0; i < size; i++) {
        aValues[i] = i;
    }
    double *bValues = malloc(size * sizeof(double));
    for (int i = 0; i < size; i++) {
        bValues[i] = i;
    }
    
    MCMatrix *a = [MCMatrix matrixWithValues:aValues rows:4 columns:4];
    MCMatrix *b = [MCMatrix matrixWithValues:bValues rows:4 columns:4];
    
    XCTAssertEqual([a isEqual:[NSArray array]], NO, @"Thought an MCMatrix was equal to an NSArray using isEqual:");
    XCTAssertEqual([a isEqual:a], YES, @"Couldn't tell an MCMatrix was equal to itself (same instance object) using isEqual:");
    XCTAssertEqual([a isEqual:b], YES, @"Couldn't tell different MCMatrix instances with identical values were equal using isEqual:");
    XCTAssertEqual([a isEqualToMatrix:(MCMatrix *)[NSArray array]], NO, @"Thought an MCMatrix was equal to an NSArray using isEqualToMatrix:");
    XCTAssertEqual([a isEqualToMatrix:a], YES, @"Couldn't tell an MCMatrix was equal to itself (same instance object) using isEqualToMatrix:");
    XCTAssertEqual([a isEqualToMatrix:b], YES, @"Couldn't tell different MCMatrix instances with identical values were equal using isEqualToMatrix:");
    
    double *cValues = malloc(size * sizeof(double));
    for (int i = 0; i < size; i++) {
        cValues[i] = i;
    }
    MCMatrix *c = [MCMatrix matrixWithValues:cValues rows:4 columns:4];
    MCMatrix *cr = [MCMatrix matrixWithValues:[c valuesWithLeadingDimension:MCMatrixLeadingDimensionRow] rows:c.rows columns:c.columns leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            double oldCValue = [c valueAtRow:i column:j];
            [c setEntryAtRow:i column:j toValue:-1.0];
            double oldCRValue = [cr valueAtRow:i column:j];
            [cr setEntryAtRow:i column:j toValue:-1.0];
            XCTAssertEqual([a isEqual:c], NO, @"Couldn't tell two MCMatrix objects differing at value %u are unequal using isEqual:", i);
            XCTAssertEqual([a isEqualToMatrix:c], NO, @"Couldn't tell two MCMatrix objects differing at value %u are unequal using isEqualToMatrix:", i);
            XCTAssertEqual([a isEqual:cr], NO, @"Couldn't tell two MCMatrix objects with different value storage formats differing at value %u are unequal using isEqual:", i);
            XCTAssertEqual([a isEqualToMatrix:cr], NO, @"Couldn't tell two MCMatrix objects with different value storage formats  differing at value %u are unequal using isEqualToMatrix:", i);
            [c setEntryAtRow:i column:j toValue:oldCValue];
            [cr setEntryAtRow:i column:j toValue:oldCRValue];
        }
    }
    
    int smallerSize = 12;
    double *dValues = malloc(smallerSize * sizeof(double));
    for (int i = 0; i < smallerSize; i++) {
        dValues[i] = i;
    }
    MCMatrix *d = [MCMatrix matrixWithValues:dValues rows:4 columns:3];
    XCTAssertEqual([a isEqual:d], NO, @"Couldn't tell two MCMatrix objects with different amounts of columns are unequal using isEqual:");
    XCTAssertEqual([a isEqualToMatrix:d], NO, @"Couldn't tell two MCMatrix objects with different amounts of columns are unequal using isEqualToMatrix:");
    dValues = malloc(smallerSize * sizeof(double));
    for (int i = 0; i < smallerSize; i++) {
        dValues[i] = i;
    }
    d = [MCMatrix matrixWithValues:dValues rows:3 columns:4];
    XCTAssertEqual([a isEqual:d], NO, @"Couldn't tell two MCMatrix objects with different amounts of rows are unequal using isEqual:");
    XCTAssertEqual([a isEqualToMatrix:d], NO, @"Couldn't tell two MCMatrix objects with different amounts of rows are unequal using isEqualToMatrix:");
    
    smallerSize = 9;
    dValues = malloc(smallerSize * sizeof(double));
    for (int i = 0; i < smallerSize; i++) {
        dValues[i] = i;
    }
    d = [MCMatrix matrixWithValues:dValues rows:3 columns:3];
    XCTAssertEqual([a isEqual:d], NO, @"Couldn't tell two MCMatrix objects with different amounts of rows and columns are unequal using isEqual:");
    XCTAssertEqual([a isEqualToMatrix:d], NO, @"Couldn't tell two MCMatrix objects with different amounts of rows and  columns are unequal using isEqualToMatrix:");
    
    MCMatrix *r = [MCMatrix matrixWithValues:[b valuesWithLeadingDimension:MCMatrixLeadingDimensionRow] rows:b.rows columns:b.columns leadingDimension:MCMatrixLeadingDimensionRow];
    r.leadingDimension = MCMatrixLeadingDimensionRow;
    XCTAssertEqual([a isEqual:r], YES, @"Couldn't tell two MCMatrix objects with identical values but different storage formats were equal using isEqual:");
    XCTAssertEqual([a isEqualToMatrix:r], YES, @"Couldn't tell two MCMatrix objects with identical values but different storage formats were equal using isEqualToMatrix:");
}

- (void)testMatrixCopy
{
    double *values = malloc(9 * sizeof(double));
    values[0] = 1.0;
    values[1] = 2.0;
    values[2] = -3.0;
    values[3] = 2.0;
    values[4] = 1.0;
    values[5] = 1.0;
    values[6] = -1.0;
    values[7] = -2.0;
    values[8] = 1.0;
    
    MCMatrix *a = [MCMatrix matrixWithValues:values rows:3 columns:3];
    a.luFactorization;
    a.singularValueDecomposition;
    a.transpose;
    
    MCMatrix *b = a.copy;
    
    XCTAssertNotEqual(a.self, b.self, @"The copied matrix is the same instance as its source.");
    XCTAssertTrue([a isEqualToMatrix:b], @"Matrix copy is not equal to its source.");
}

- (void)testMatrixValueCopyByLeadingDimension
{
    double *values = malloc(9 * sizeof(double));
    values[0] = 1.0;
    values[1] = 2.0;
    values[2] = -3.0;
    
    values[3] = 2.0;
    values[4] = 1.0;
    values[5] = 1.0;
    
    values[6] = -1.0;
    values[7] = -2.0;
    values[8] = 1.0;
    
    MCMatrix *a = [MCMatrix matrixWithValues:values rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionColumn];
    
    double *rowMajorValues = [a valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    
    XCTAssertEqual(values[0], rowMajorValues[0], @"Value at 0, 0 incorrect");
    XCTAssertEqual(values[1], rowMajorValues[3], @"Value at 1, 3 incorrect");
    XCTAssertEqual(values[2], rowMajorValues[6], @"Value at 2, 6 incorrect");
    XCTAssertEqual(values[3], rowMajorValues[1], @"Value at 3, 1 incorrect");
    XCTAssertEqual(values[4], rowMajorValues[4], @"Value at 4, 4 incorrect");
    XCTAssertEqual(values[5], rowMajorValues[7], @"Value at 5, 7 incorrect");
    XCTAssertEqual(values[6], rowMajorValues[2], @"Value at 6, 2 incorrect");
    XCTAssertEqual(values[7], rowMajorValues[5], @"Value at 7, 5 incorrect");
    XCTAssertEqual(values[8], rowMajorValues[8], @"Value at 8, 8 incorrect");
    
    values = malloc(9 * sizeof(double));
    values[0] = 1.0;
    values[1] = 2.0;
    values[2] = -3.0;
    
    values[3] = 2.0;
    values[4] = 1.0;
    values[5] = 1.0;
    
    values[6] = -1.0;
    values[7] = -2.0;
    values[8] = 1.0;
    
    MCMatrix *b = [MCMatrix matrixWithValues:values rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow];
    
    double *columnMajorValues = [b valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
    
    XCTAssertEqual(values[0], columnMajorValues[0], @"Value at 0, 0 incorrect");
    XCTAssertEqual(values[1], columnMajorValues[3], @"Value at 1, 3 incorrect");
    XCTAssertEqual(values[2], columnMajorValues[6], @"Value at 2, 6 incorrect");
    XCTAssertEqual(values[3], columnMajorValues[1], @"Value at 3, 1 incorrect");
    XCTAssertEqual(values[4], columnMajorValues[4], @"Value at 4, 4 incorrect");
    XCTAssertEqual(values[5], columnMajorValues[7], @"Value at 5, 7 incorrect");
    XCTAssertEqual(values[6], columnMajorValues[2], @"Value at 6, 2 incorrect");
    XCTAssertEqual(values[7], columnMajorValues[5], @"Value at 7, 5 incorrect");
    XCTAssertEqual(values[8], columnMajorValues[8], @"Value at 8, 8 incorrect");
}

- (void)testRowMatrixTriangularComponentValueCopy
{
    /*
     0  1  2
     3  4  5
     6  7  8
     */
    double *values = malloc(9 * sizeof(double));
    values[0] = 0.0;
    values[1] = 1.0;
    values[2] = 2.0;
    
    values[3] = 3.0;
    values[4] = 4.0;
    values[5] = 5.0;
    
    values[6] = 6.0;
    values[7] = 7.0;
    values[8] = 8.0;
    
    MCMatrix *a = [MCMatrix matrixWithValues:values rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow];
    
    /*
     0  1  2
     -  4  5
     -  -  8
     */
    double *packedUpperTriangularValuesRowMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                   leadingDimension:MCMatrixLeadingDimensionRow
                                                                     packingMethod:MCMatrixValuePackingMethodPacked];
    XCTAssertEqual(values[0], packedUpperTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], packedUpperTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[2], packedUpperTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[4], packedUpperTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[5], packedUpperTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedUpperTriangularValuesRowMajor[5], @"Value incorrect");
    free(packedUpperTriangularValuesRowMajor);
    
    double *packedUpperTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                      leadingDimension:MCMatrixLeadingDimensionColumn
                                                                        packingMethod:MCMatrixValuePackingMethodPacked];
    XCTAssertEqual(values[0], packedUpperTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], packedUpperTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[4], packedUpperTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[2], packedUpperTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[5], packedUpperTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedUpperTriangularValuesColumnMajor[5], @"Value incorrect");
    free(packedUpperTriangularValuesColumnMajor);
    
    double *unpackedUpperTriangularValuesRowMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                     leadingDimension:MCMatrixLeadingDimensionRow
                                                                       packingMethod:MCMatrixValuePackingMethodConventional];
    XCTAssertEqual(values[0], unpackedUpperTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], unpackedUpperTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[2], unpackedUpperTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedUpperTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[4], unpackedUpperTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[5], unpackedUpperTriangularValuesRowMajor[5], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedUpperTriangularValuesRowMajor[6], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedUpperTriangularValuesRowMajor[7], @"Value incorrect");
    XCTAssertEqual(values[8], unpackedUpperTriangularValuesRowMajor[8], @"Value incorrect");
    free(unpackedUpperTriangularValuesRowMajor);
    
    double *unpackedUpperTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                        leadingDimension:MCMatrixLeadingDimensionColumn
                                                                          packingMethod:MCMatrixValuePackingMethodConventional];
    XCTAssertEqual(values[0], unpackedUpperTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedUpperTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedUpperTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[1], unpackedUpperTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[4], unpackedUpperTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedUpperTriangularValuesColumnMajor[5], @"Value incorrect");
    XCTAssertEqual(values[2], unpackedUpperTriangularValuesColumnMajor[6], @"Value incorrect");
    XCTAssertEqual(values[5], unpackedUpperTriangularValuesColumnMajor[7], @"Value incorrect");
    XCTAssertEqual(values[8], unpackedUpperTriangularValuesColumnMajor[8], @"Value incorrect");
    free(unpackedUpperTriangularValuesColumnMajor);
    
    /*
     0  -  -
     3  4  -
     6  7  8
     */
    double *packedLowerTriangularValuesRowMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                   leadingDimension:MCMatrixLeadingDimensionRow
                                                                     packingMethod:MCMatrixValuePackingMethodPacked];
    XCTAssertEqual(values[0], packedLowerTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], packedLowerTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[4], packedLowerTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[6], packedLowerTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[7], packedLowerTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedLowerTriangularValuesRowMajor[5], @"Value incorrect");
    free(packedLowerTriangularValuesRowMajor);
    
    double *packedLowerTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                      leadingDimension:MCMatrixLeadingDimensionColumn
                                                                        packingMethod:MCMatrixValuePackingMethodPacked];
    XCTAssertEqual(values[0], packedLowerTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], packedLowerTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[6], packedLowerTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[4], packedLowerTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[7], packedLowerTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedLowerTriangularValuesColumnMajor[5], @"Value incorrect");
    free(packedLowerTriangularValuesColumnMajor);
    
    double *unpackedLowerTriangularValuesRowMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                     leadingDimension:MCMatrixLeadingDimensionRow
                                                                       packingMethod:MCMatrixValuePackingMethodConventional];
    XCTAssertEqual(values[0], unpackedLowerTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedLowerTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedLowerTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[3], unpackedLowerTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[4], unpackedLowerTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedLowerTriangularValuesRowMajor[5], @"Value incorrect");
    XCTAssertEqual(values[6], unpackedLowerTriangularValuesRowMajor[6], @"Value incorrect");
    XCTAssertEqual(values[7], unpackedLowerTriangularValuesRowMajor[7], @"Value incorrect");
    XCTAssertEqual(values[8], unpackedLowerTriangularValuesRowMajor[8], @"Value incorrect");
    free(unpackedLowerTriangularValuesRowMajor);
    
    double *unpackedLowerTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                        leadingDimension:MCMatrixLeadingDimensionColumn
                                                                          packingMethod:MCMatrixValuePackingMethodConventional];
    XCTAssertEqual(values[0], unpackedLowerTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], unpackedLowerTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[6], unpackedLowerTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedLowerTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[4], unpackedLowerTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[7], unpackedLowerTriangularValuesColumnMajor[5], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedLowerTriangularValuesColumnMajor[6], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedLowerTriangularValuesColumnMajor[7], @"Value incorrect");
    XCTAssertEqual(values[8], unpackedLowerTriangularValuesColumnMajor[8], @"Value incorrect");
    free(unpackedLowerTriangularValuesColumnMajor);
}

- (void)testColumnMatrixTriangularComponentValueCopy
{
    /*
     0  3  6
     1  4  7
     2  5  8
     */
    double *values = malloc(9 * sizeof(double));
    values[0] = 0.0;
    values[1] = 1.0;
    values[2] = 2.0;
    
    values[3] = 3.0;
    values[4] = 4.0;
    values[5] = 5.0;
    
    values[6] = 6.0;
    values[7] = 7.0;
    values[8] = 8.0;
    
    MCMatrix *a = [MCMatrix matrixWithValues:values rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionColumn];
    
    /*
     0  3  6
     -  4  7
     -  -  8
     */
    double *packedUpperTriangularValuesRowMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                             leadingDimension:MCMatrixLeadingDimensionRow
                                                                           packingMethod:MCMatrixValuePackingMethodPacked];
    XCTAssertEqual(values[0], packedUpperTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], packedUpperTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[6], packedUpperTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[4], packedUpperTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[7], packedUpperTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedUpperTriangularValuesRowMajor[5], @"Value incorrect");
    free(packedUpperTriangularValuesRowMajor);
    
    double *packedUpperTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                                leadingDimension:MCMatrixLeadingDimensionColumn
                                                                              packingMethod:MCMatrixValuePackingMethodPacked];
    XCTAssertEqual(values[0], packedUpperTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], packedUpperTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[4], packedUpperTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[6], packedUpperTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[7], packedUpperTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedUpperTriangularValuesColumnMajor[5], @"Value incorrect");
    free(packedUpperTriangularValuesColumnMajor);
    
    double *unpackedUpperTriangularValuesRowMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                               leadingDimension:MCMatrixLeadingDimensionRow
                                                                             packingMethod:MCMatrixValuePackingMethodConventional];
    XCTAssertEqual(values[0], unpackedUpperTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], unpackedUpperTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[6], unpackedUpperTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedUpperTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[4], unpackedUpperTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[7], unpackedUpperTriangularValuesRowMajor[5], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedUpperTriangularValuesRowMajor[6], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedUpperTriangularValuesRowMajor[7], @"Value incorrect");
    XCTAssertEqual(values[8], unpackedUpperTriangularValuesRowMajor[8], @"Value incorrect");
    free(unpackedUpperTriangularValuesRowMajor);
    
    double *unpackedUpperTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                                  leadingDimension:MCMatrixLeadingDimensionColumn
                                                                                packingMethod:MCMatrixValuePackingMethodConventional];
    XCTAssertEqual(values[0], unpackedUpperTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedUpperTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedUpperTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[3], unpackedUpperTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[4], unpackedUpperTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedUpperTriangularValuesColumnMajor[5], @"Value incorrect");
    XCTAssertEqual(values[6], unpackedUpperTriangularValuesColumnMajor[6], @"Value incorrect");
    XCTAssertEqual(values[7], unpackedUpperTriangularValuesColumnMajor[7], @"Value incorrect");
    XCTAssertEqual(values[8], unpackedUpperTriangularValuesColumnMajor[8], @"Value incorrect");
    free(unpackedUpperTriangularValuesColumnMajor);
    
    /*
     0  -  -
     1  4  -
     2  5  8
     */
    double *packedLowerTriangularValuesRowMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                             leadingDimension:MCMatrixLeadingDimensionRow
                                                                           packingMethod:MCMatrixValuePackingMethodPacked];
    XCTAssertEqual(values[0], packedLowerTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], packedLowerTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[4], packedLowerTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[2], packedLowerTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[5], packedLowerTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedLowerTriangularValuesRowMajor[5], @"Value incorrect");
    free(packedLowerTriangularValuesRowMajor);
    
    double *packedLowerTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                                leadingDimension:MCMatrixLeadingDimensionColumn
                                                                              packingMethod:MCMatrixValuePackingMethodPacked];
    XCTAssertEqual(values[0], packedLowerTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], packedLowerTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[2], packedLowerTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[4], packedLowerTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[5], packedLowerTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedLowerTriangularValuesColumnMajor[5], @"Value incorrect");
    free(packedLowerTriangularValuesColumnMajor);
    
    double *unpackedLowerTriangularValuesRowMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                               leadingDimension:MCMatrixLeadingDimensionRow
                                                                             packingMethod:MCMatrixValuePackingMethodConventional];
    XCTAssertEqual(values[0], unpackedLowerTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedLowerTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedLowerTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[1], unpackedLowerTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[4], unpackedLowerTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedLowerTriangularValuesRowMajor[5], @"Value incorrect");
    XCTAssertEqual(values[2], unpackedLowerTriangularValuesRowMajor[6], @"Value incorrect");
    XCTAssertEqual(values[5], unpackedLowerTriangularValuesRowMajor[7], @"Value incorrect");
    XCTAssertEqual(values[8], unpackedLowerTriangularValuesRowMajor[8], @"Value incorrect");
    free(unpackedLowerTriangularValuesRowMajor);
    
    double *unpackedLowerTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                                  leadingDimension:MCMatrixLeadingDimensionColumn
                                                                                packingMethod:MCMatrixValuePackingMethodConventional];
    XCTAssertEqual(values[0], unpackedLowerTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], unpackedLowerTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[2], unpackedLowerTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedLowerTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[4], unpackedLowerTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[5], unpackedLowerTriangularValuesColumnMajor[5], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedLowerTriangularValuesColumnMajor[6], @"Value incorrect");
    XCTAssertEqual(0.0, unpackedLowerTriangularValuesColumnMajor[7], @"Value incorrect");
    XCTAssertEqual(values[8], unpackedLowerTriangularValuesColumnMajor[8], @"Value incorrect");
    free(unpackedLowerTriangularValuesColumnMajor);
}

@end

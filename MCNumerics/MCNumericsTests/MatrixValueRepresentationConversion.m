//
//  MatrixValueRepresentationConversion.m
//  MCNumerics
//
//  Created by andrew mcknight on 4/6/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"

#import "DynamicArrayUtility.h"

@interface MatrixValueRepresentationConversion : XCTestCase

@end

@implementation MatrixValueRepresentationConversion

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRowToColumnMajor
{
    /*
     0  1  2
     3  4  5
     6  7  8
     */
    double values[9] = {
        0.0, 1.0, 2.0,
        3.0, 4.0, 5.0,
        6.0, 7.0, 8.0
    };
    
    MCMatrix *a = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:values size:9] rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow];
    
    double *columnMajorValues = [a valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
    
    double solutionValues[9] = {
        0.0, 3.0, 6.0,
        1.0, 4.0, 7.0,
        2.0, 5.0, 8.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(columnMajorValues[i], solutionValues[i], @"Value incorrect");
    }
}

- (void)testColumnToRowMajor
{
    /*
     0  1  2
     3  4  5
     6  7  8
     */
    double values[9] = {
        0.0, 3.0, 6.0,
        1.0, 4.0, 7.0,
        2.0, 5.0, 8.0
    };
    
    MCMatrix *a = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:values size:9] rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionColumn];
    
    double *rowMajorValues = [a valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    
    double solutionValues[9] = {
        0.0, 1.0, 2.0,
        3.0, 4.0, 5.0,
        6.0, 7.0, 8.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(rowMajorValues[i], solutionValues[i], @"Value incorrect");
    }
}

- (void)testRowMajorConventionalToBand
{
    double values[16] = {
        0.0,  1.0,  2.0,  3.0,
        4.0,  5.0,  6.0,  7.0,
        8.0,  9.0,  10.0, 11.0,
        12.0, 13.0, 14.0, 15.0
    };
    
    MCMatrix *matrix = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:values size:16] rows:4 columns:4 leadingDimension:MCMatrixLeadingDimensionRow];
    
    double *balancedBandValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    
    double bandSolutionValues[12] = {
        0.0, 1.0, 6.0, 11.0,
        0.0, 5.0, 10.0, 15.0,
        4.0, 9.0, 14.0, 0.0
    };
    
    for (int i = 0; i < 12; i++) {
        XCTAssertEqual(balancedBandValues[i], bandSolutionValues[i], @"Incorrect value.");
    }
    
    double *extraUpperBandValues = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:1];
    
    double extraUpperSolutionValues[16] = {
        0.0, 0.0, 2.0,  7.0,
        0.0, 1.0, 6.0,  11.0,
        0.0, 5.0, 10.0, 15.0,
        4.0, 9.0, 14.0, 0.0
    };
    
    for (int i = 0; i < 12; i++) {
        XCTAssertEqual(extraUpperBandValues[i], extraUpperSolutionValues[i], @"Incorrect value.");
    }
    
    double *extraLowerBandValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:2];
    
    double extraLowerSolutionValues[16] = {
        0.0, 1.0,  6.0,  11.0,
        0.0, 5.0,  10.0, 15.0,
        4.0, 9.0,  14.0, 0.0,
        8.0, 13.0, 0.0,  0.0
    };
    
    for (int i = 0; i < 12; i++) {
        XCTAssertEqual(extraLowerBandValues[i], extraLowerSolutionValues[i], @"Incorrect value.");
    }
}

- (void)testColumnMajorConventionalToBand
{
    double values[16] = {
        0.0, 4.0, 8.0,  12.0,
        1.0, 5.0, 9.0,  13.0,
        2.0, 6.0, 10.0, 14.0,
        3.0, 7.0, 11.0, 15.0
    };
    
    MCMatrix *matrix = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:values size:16] rows:4 columns:4 leadingDimension:MCMatrixLeadingDimensionColumn];
    
    double *balancedBandValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    
    double bandSolutionValues[12] = {
        0.0, 1.0, 6.0, 11.0,
        0.0, 5.0, 10.0, 15.0,
        4.0, 9.0, 14.0, 0.0
    };
    
    for (int i = 0; i < 12; i++) {
        XCTAssertEqual(balancedBandValues[i], bandSolutionValues[i], @"Incorrect value.");
    }
    
    double *extraUpperBandValues = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:1];
    
    double extraUpperSolutionValues[16] = {
        0.0, 0.0, 2.0,  7.0,
        0.0, 1.0, 6.0,  11.0,
        0.0, 5.0, 10.0, 15.0,
        4.0, 9.0, 14.0, 0.0
    };
    
    for (int i = 0; i < 12; i++) {
        XCTAssertEqual(extraUpperBandValues[i], extraUpperSolutionValues[i], @"Incorrect value.");
    }
    
    double *extraLowerBandValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:2];
    
    double extraLowerSolutionValues[16] = {
        0.0, 1.0,  6.0,  11.0,
        0.0, 5.0,  10.0, 15.0,
        4.0, 9.0,  14.0, 0.0,
        8.0, 13.0, 0.0,  0.0
    };
    
    for (int i = 0; i < 12; i++) {
        XCTAssertEqual(extraLowerBandValues[i], extraLowerSolutionValues[i], @"Incorrect value.");
    }
}

- (void)testRowMajorConventionalToTriangular
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

- (void)testColumnMajorConventionalToTriangular
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

- (void)testRowMajorTriangularToConventional
{
    //
    // upper triangular
    //
    
    double upperValues[6] = {
        1.0, 2.0, 3.0,
             4.0, 5.0,
                  6.0
    };
    MCMatrix *matrix = [MCMatrix triangularMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:upperValues size:6] ofTriangularComponent:MCMatrixTriangularComponentUpper leadingDimension:MCMatrixLeadingDimensionRow order:3];
    
    // to row major conventional
    
    double *upperRowMajorConventionalValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    
    double upperRowMajorConventionalValuesSolution[9] = {
        1.0, 2.0, 3.0,
        0.0, 4.0, 5.0,
        0.0, 0.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperRowMajorConventionalValues[i], upperRowMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    free(upperRowMajorConventionalValues);
    
    // to column major conventional
    
    double *upperColumnMajorConventionalValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
    
    double upperColumnMajorConventionalValuesSolution[9] = {
        1.0, 0.0, 0.0,
        2.0, 4.0, 0.0,
        3.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperColumnMajorConventionalValues[i], upperColumnMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    free(upperColumnMajorConventionalValues);
    
    //
    // lower triangular
    //
    
    double lowerValues[6] = {
        1.0,
        2.0, 3.0,
        4.0, 5.0, 6.0
    };
    matrix = [MCMatrix triangularMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:lowerValues size:6] ofTriangularComponent:MCMatrixTriangularComponentLower leadingDimension:MCMatrixLeadingDimensionRow order:3];
    
    // to row major conventional
    
    double *lowerRowMajorConventionalValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    
    double lowerRowMajorConventionalValuesSolution[9] = {
        1.0, 0.0, 0.0,
        2.0, 3.0, 0.0,
        4.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerRowMajorConventionalValues[i], lowerRowMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    free(lowerRowMajorConventionalValues);
    
    // to column major conventional
    
    double *lowerColumnMajorConventionalValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
    
    double lowerColumnMajorConventionalValuesSolution[9] = {
        1.0, 2.0, 4.0,
        0.0, 3.0, 5.0,
        0.0, 0.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerColumnMajorConventionalValues[i], lowerColumnMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    free(lowerColumnMajorConventionalValues);
}

- (void)testColumnMajorTriangularToConventional
{
    //
    // upper triangular
    //
    
    double upperValues[6] = {
        1.0,
        2.0, 4.0,
        3.0, 5.0, 6.0
    };
    MCMatrix *matrix = [MCMatrix triangularMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:upperValues size:6] ofTriangularComponent:MCMatrixTriangularComponentUpper leadingDimension:MCMatrixLeadingDimensionColumn order:3];
    
    // to row major conventional
    
    double *upperRowMajorConventionalValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    
    double upperRowMajorConventionalValuesSolution[9] = {
        1.0, 2.0, 3.0,
        0.0, 4.0, 5.0,
        0.0, 0.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperRowMajorConventionalValues[i], upperRowMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    free(upperRowMajorConventionalValues);
    
    // to column major conventional
    
    double *upperColumnMajorConventionalValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
    
    double upperColumnMajorConventionalValuesSolution[9] = {
        1.0, 0.0, 0.0,
        2.0, 4.0, 0.0,
        3.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperColumnMajorConventionalValues[i], upperColumnMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    free(upperColumnMajorConventionalValues);
    
    //
    // lower triangular
    //
    
    double lowerValues[6] = {
        1.0, 2.0, 4.0,
        3.0, 5.0,
        6.0
    };
    matrix = [MCMatrix triangularMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:lowerValues size:6] ofTriangularComponent:MCMatrixTriangularComponentLower leadingDimension:MCMatrixLeadingDimensionColumn order:3];
    
    // to row major conventional
    
    double *lowerRowMajorConventionalValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    
    double lowerRowMajorConventionalValuesSolution[9] = {
        1.0, 0.0, 0.0,
        2.0, 3.0, 0.0,
        4.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerRowMajorConventionalValues[i], lowerRowMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    free(lowerRowMajorConventionalValues);
    
    // to column major conventional
    
    double *lowerColumnMajorConventionalValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
    
    double lowerColumnMajorConventionalValuesSolution[9] = {
        1.0, 2.0, 4.0,
        0.0, 3.0, 5.0,
        0.0, 0.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerColumnMajorConventionalValues[i], lowerColumnMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    free(lowerColumnMajorConventionalValues);
}

- (void)testRowMajorTriangularToBand
{
    //
    // upper triangular
    //
    
    double upperValues[6] = {
        1.0, 2.0, 3.0,
             4.0, 5.0,
                  6.0
    };
    MCMatrix *matrix = [MCMatrix triangularMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:upperValues size:6] ofTriangularComponent:MCMatrixTriangularComponentUpper leadingDimension:MCMatrixLeadingDimensionRow order:3];
    
    // tridiagonal
    double *upperTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double upperTridiagonalValuesSolution[9] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0,
        0.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperTridiagonalValues[i], upperTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    double *upperOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double upperOneUpperSolution[6] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(upperOneUpper[i], upperOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    double *upperTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double upperTwoUpperSolution[9] = {
        0.0, 0.0, 3.0,
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperTwoUpper[i], upperTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    double *upperOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double upperOneLowerSolution[6] = {
        1.0, 4.0, 6.0,
        0.0, 0.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(upperOneLower[i], upperOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    double *upperTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double upperTwoLowerSolution[9] = {
        1.0, 4.0, 6.0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperTwoLower[i], upperTwoLowerSolution[i], @"Incorrect value.");
    }
    
    //
    // lower triangular
    //
    
    double lowerValues[6] = {
        1.0,
        2.0, 3.0,
        4.0, 5.0, 6.0
    };
    matrix = [MCMatrix triangularMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:lowerValues size:6] ofTriangularComponent:MCMatrixTriangularComponentLower leadingDimension:MCMatrixLeadingDimensionRow order:3];
    
    // tridiagonal
    double *lowerTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double lowerTridiagonalValuesSolution[9] = {
        0.0, 0.0, 0.0,
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerTridiagonalValues[i], lowerTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    double *lowerOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double lowerOneUpperSolution[6] = {
        0.0, 0.0, 0.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(lowerOneUpper[i], lowerOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    double *lowerTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double lowerTwoUpperSolution[9] = {
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerTwoUpper[i], lowerTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    double *lowerOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double lowerOneLowerSolution[6] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(lowerOneLower[i], lowerOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    double *lowerTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double lowerTwoLowerSolution[9] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0,
        4.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerTwoLower[i], lowerTwoLowerSolution[i], @"Incorrect value.");
    }
}

- (void)testColumnMajorTriangularToBand
{
    //
    // upper triangular
    //
    
    double upperValues[6] = {
        1.0,
        2.0, 4.0,
        3.0, 5.0, 6.0
    };
    MCMatrix *matrix = [MCMatrix triangularMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:upperValues size:6] ofTriangularComponent:MCMatrixTriangularComponentUpper leadingDimension:MCMatrixLeadingDimensionColumn order:3];
    
    // tridiagonal
    double *upperTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double upperTridiagonalValuesSolution[9] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0,
        0.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperTridiagonalValues[i], upperTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    double *upperOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double upperOneUpperSolution[6] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(upperOneUpper[i], upperOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    double *upperTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double upperTwoUpperSolution[9] = {
        0.0, 0.0, 3.0,
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperTwoUpper[i], upperTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    double *upperOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double upperOneLowerSolution[6] = {
        1.0, 4.0, 6.0,
        0.0, 0.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(upperOneLower[i], upperOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    double *upperTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double upperTwoLowerSolution[9] = {
        1.0, 4.0, 6.0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperTwoLower[i], upperTwoLowerSolution[i], @"Incorrect value.");
    }
    
    //
    // lower triangular
    //
    
    double lowerValues[6] = {
        1.0, 2.0, 4.0,
        3.0, 5.0,
        6.0
    };
    matrix = [MCMatrix triangularMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:lowerValues size:6] ofTriangularComponent:MCMatrixTriangularComponentLower leadingDimension:MCMatrixLeadingDimensionColumn order:3];
    
    // tridiagonal
    double *lowerTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double lowerTridiagonalValuesSolution[9] = {
        0.0, 0.0, 0.0,
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerTridiagonalValues[i], lowerTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    double *lowerOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double lowerOneUpperSolution[6] = {
        0.0, 0.0, 0.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(lowerOneUpper[i], lowerOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    double *lowerTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double lowerTwoUpperSolution[9] = {
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerTwoUpper[i], lowerTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    double *lowerOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double lowerOneLowerSolution[6] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(lowerOneLower[i], lowerOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    double *lowerTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double lowerTwoLowerSolution[9] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0,
        4.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerTwoLower[i], lowerTwoLowerSolution[i], @"Incorrect value.");
    }
}

- (void)testRowMajorSymmetricToConventional
{
    //
    // upper triangular
    //
    
    /*
     1 2 3
     2 4 5
     3 5 6
     */
    
    double upperValues[6] = {
        1.0, 2.0, 3.0,
             4.0, 5.0,
                6.0
    };
    MCMatrix *matrix = [MCMatrix symmetricMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:upperValues size:6] triangularComponent:MCMatrixTriangularComponentUpper leadingDimension:MCMatrixLeadingDimensionRow order:3];
    
    double *upperConventionalRowMajorValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    double *upperConventionalColumnMajorValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
    
    double upperSolution[9] = {
        1.0, 2.0, 3.0,
        2.0, 4.0, 5.0,
        3.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperConventionalRowMajorValues[i], upperSolution[i], @"Incorrect values");
    }
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperConventionalColumnMajorValues[i], upperSolution[i], @"Incorrect values");
    }
    
    //
    // lower triangular
    //
    
    /*
     1 2 4
     2 3 5
     4 5 6
     */
    
    double lowerValues[6] = {
        1.0,
        2.0, 3.0,
        4.0, 5.0, 6.0
    };
    matrix = [MCMatrix symmetricMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:lowerValues size:6] triangularComponent:MCMatrixTriangularComponentLower leadingDimension:MCMatrixLeadingDimensionRow order:3];
    
    double *lowerConventionalRowMajorValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    double *lowerConventionalColumnMajorValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
    
    double lowerSolution[9] = {
        1.0, 2.0, 4.0,
        2.0, 3.0, 5.0,
        4.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerConventionalRowMajorValues[i], lowerSolution[i], @"Incorrect values");
    }
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerConventionalColumnMajorValues[i], lowerSolution[i], @"Incorrect values");
    }
}

- (void)testColumnMajorSymmetricToConventional
{
    //
    // upper triangular
    //
    
    /*
     1 2 3
     2 4 5
     3 5 6
     */
    
    double upperValues[6] = {
        1.0,
        2.0, 4.0,
        3.0, 5.0, 6.0
    };
    MCMatrix *matrix = [MCMatrix symmetricMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:upperValues size:6] triangularComponent:MCMatrixTriangularComponentUpper leadingDimension:MCMatrixLeadingDimensionColumn order:3];
    
    double *upperConventionalRowMajorValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    double *upperConventionalColumnMajorValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
    
    double upperSolution[9] = {
        1.0, 2.0, 3.0,
        2.0, 4.0, 5.0,
        3.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperConventionalRowMajorValues[i], upperSolution[i], @"Incorrect values");
    }
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperConventionalColumnMajorValues[i], upperSolution[i], @"Incorrect values");
    }
    
    
    //
    // lower triangular
    //
    
    /*
     1 2 4
     2 3 5
     4 5 6
     */
    
    double lowerValues[6] = {
        1.0, 2.0, 4.0,
        3.0, 5.0,
        6.0
    };
    matrix = [MCMatrix symmetricMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:lowerValues size:6] triangularComponent:MCMatrixTriangularComponentLower leadingDimension:MCMatrixLeadingDimensionColumn order:3];
    
    double *lowerConventionalRowMajorValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    double *lowerConventionalColumnMajorValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
    
    double lowerSolution[9] = {
        1.0, 2.0, 4.0,
        2.0, 3.0, 5.0,
        4.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerConventionalRowMajorValues[i], lowerSolution[i], @"Incorrect values");
    }
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerConventionalColumnMajorValues[i], lowerSolution[i], @"Incorrect values");
    }
}

- (void)testRowMajorSymmetricToBand
{
    //
    // upper triangular
    //
    
    /*
     1 2 3
     2 4 5
     3 5 6
     */
    
    double upperValues[6] = {
        1.0, 2.0, 3.0,
             4.0, 5.0,
                  6.0
    };
    MCMatrix *matrix = [MCMatrix symmetricMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:upperValues size:6] triangularComponent:MCMatrixTriangularComponentUpper leadingDimension:MCMatrixLeadingDimensionRow order:3];
    
    // tridiagonal
    double *upperTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double upperTridiagonalValuesSolution[9] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperTridiagonalValues[i], upperTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    double *upperOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double upperOneUpperSolution[6] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(upperOneUpper[i], upperOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    double *upperTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double upperTwoUpperSolution[9] = {
        0.0, 0.0, 3.0,
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperTwoUpper[i], upperTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    double *upperOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double upperOneLowerSolution[6] = {
        1.0, 4.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(upperOneLower[i], upperOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    double *upperTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double upperTwoLowerSolution[9] = {
        1.0, 4.0, 6.0,
        2.0, 5.0, 0.0,
        3.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperTwoLower[i], upperTwoLowerSolution[i], @"Incorrect value.");
    }
    
    //
    // lower triangular
    //
    
    /*
     1 2 4
     2 3 5
     4 5 6
     */
    
    double lowerValues[6] = {
        1.0,
        2.0, 3.0,
        4.0, 5.0, 6.0
    };
    matrix = [MCMatrix symmetricMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:lowerValues size:6] triangularComponent:MCMatrixTriangularComponentLower leadingDimension:MCMatrixLeadingDimensionRow order:3];
    
    // tridiagonal
    double *lowerTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double lowerTridiagonalValuesSolution[9] = {
        0.0, 2.0, 5.0,
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerTridiagonalValues[i], lowerTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    double *lowerOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double lowerOneUpperSolution[6] = {
        0.0, 2.0, 5.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(lowerOneUpper[i], lowerOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    double *lowerTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double lowerTwoUpperSolution[9] = {
        0.0, 0.0, 4.0,
        0.0, 2.0, 5.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerTwoUpper[i], lowerTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    double *lowerOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double lowerOneLowerSolution[6] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(lowerOneLower[i], lowerOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    double *lowerTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double lowerTwoLowerSolution[9] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0,
        4.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerTwoLower[i], lowerTwoLowerSolution[i], @"Incorrect value.");
    }
}

- (void)testColumnMajorSymmetricToBand
{
    //
    // upper triangular
    //
    
    /*
     1 2 3
     2 4 5
     3 5 6
     */
    
    double upperValues[6] = {
        1.0,
        2.0, 4.0,
        3.0, 5.0, 6.0
    };
    MCMatrix *matrix = [MCMatrix symmetricMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:upperValues size:6] triangularComponent:MCMatrixTriangularComponentUpper leadingDimension:MCMatrixLeadingDimensionColumn order:3];
    
    // tridiagonal
    double *upperTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double upperTridiagonalValuesSolution[9] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperTridiagonalValues[i], upperTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    double *upperOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double upperOneUpperSolution[6] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(upperOneUpper[i], upperOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    double *upperTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double upperTwoUpperSolution[9] = {
        0.0, 0.0, 3.0,
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperTwoUpper[i], upperTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    double *upperOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double upperOneLowerSolution[6] = {
        1.0, 4.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(upperOneLower[i], upperOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    double *upperTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double upperTwoLowerSolution[9] = {
        1.0, 4.0, 6.0,
        2.0, 5.0, 0.0,
        3.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(upperTwoLower[i], upperTwoLowerSolution[i], @"Incorrect value.");
    }
    
    //
    // lower triangular
    //
    
    /*
     1 2 4
     2 3 5
     4 5 6
     */
    
    double lowerValues[6] = {
        1.0, 2.0, 4.0,
        3.0, 5.0,
        6.0
    };
    matrix = [MCMatrix symmetricMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:lowerValues size:6] triangularComponent:MCMatrixTriangularComponentLower leadingDimension:MCMatrixLeadingDimensionColumn order:3];
    
    // tridiagonal
    double *lowerTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double lowerTridiagonalValuesSolution[9] = {
        0.0, 2.0, 5.0,
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerTridiagonalValues[i], lowerTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    double *lowerOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double lowerOneUpperSolution[6] = {
        0.0, 2.0, 5.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(lowerOneUpper[i], lowerOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    double *lowerTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double lowerTwoUpperSolution[9] = {
        0.0, 0.0, 4.0,
        0.0, 2.0, 5.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerTwoUpper[i], lowerTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    double *lowerOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double lowerOneLowerSolution[6] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(lowerOneLower[i], lowerOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    double *lowerTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double lowerTwoLowerSolution[9] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0,
        4.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(lowerTwoLower[i], lowerTwoLowerSolution[i], @"Incorrect value.");
    }
}

- (void)testBandToConventional
{
    double bandValues[16] = {
        0.0, 0.0, 2.0,  7.0,
        0.0, 1.0, 6.0,  11.0,
        0.0, 5.0, 10.0, 15.0,
        4.0, 9.0, 14.0, 0.0
    };
    
    MCMatrix *bandMatrix = [MCMatrix bandMatrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:bandValues size:16] order:4 upperCodiagonals:2 lowerCodiagonals:1];
    
    double *rowMajorValues = [bandMatrix valuesWithLeadingDimension:MCMatrixLeadingDimensionRow];
    double rowMajorSolution[16] = {
        0.0,  1.0,  2.0,  0.0,
        4.0,  5.0,  6.0,  7.0,
        0.0,  9.0,  10.0, 11.0,
        0.0,  0.0,  14.0, 15.0
    };
    for (int i = 0; i < 16; i++) {
        XCTAssertEqual(rowMajorValues[i], rowMajorSolution[i], @"Incorrect value.");
    }
    
    double *columnMajorValues = [bandMatrix valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
    double columnMajorSolution[16] = {
        0.0, 4.0, 0.0,  0.0,
        1.0, 5.0, 9.0,  0.0,
        2.0, 6.0, 10.0, 14.0,
        0.0, 7.0, 11.0, 15.0
    };
    for (int i = 0; i < 16; i++) {
        XCTAssertEqual(columnMajorValues[i], columnMajorSolution[i], @"Incorrect value.");
    }
}

- (void)testBandToTriangular
{
    double bandValues[16] = {
        0.0, 0.0, 2.0,  7.0,
        0.0, 1.0, 6.0,  11.0,
        0.0, 5.0, 10.0, 15.0,
        4.0, 9.0, 14.0, 0.0
    };
    
    MCMatrix *bandMatrix = [MCMatrix bandMatrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:bandValues size:16] order:4 upperCodiagonals:2 lowerCodiagonals:1];
    
    // packed upper row major
    double *packedUpperRowMajorValues = [bandMatrix valuesFromTriangularComponent:MCMatrixTriangularComponentUpper leadingDimension:MCMatrixLeadingDimensionRow packingMethod:MCMatrixValuePackingMethodPacked];
    double packedUpperRowMajorValuesSolution[10] = {
        0.0,  1.0,  2.0,  0.0,
              5.0,  6.0,  7.0,
                    10.0, 11.0,
                          15.0
    };
    for (int i = 0; i < 10; i++) {
        XCTAssertEqual(packedUpperRowMajorValues[i], packedUpperRowMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // packed upper col major
    double *packedUpperColumnMajorValues = [bandMatrix valuesFromTriangularComponent:MCMatrixTriangularComponentUpper leadingDimension:MCMatrixLeadingDimensionColumn packingMethod:MCMatrixValuePackingMethodPacked];
    double packedUpperColumnMajorValuesSolution[10] = {
        0.0,
        1.0, 5.0,
        2.0, 6.0, 10.0,
        0.0, 7.0, 11.0, 15.0
    };
    for (int i = 0; i < 10; i++) {
        XCTAssertEqual(packedUpperColumnMajorValues[i], packedUpperColumnMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // unpacked upper row major
    double *unpackedUpperRowMajorValues = [bandMatrix valuesFromTriangularComponent:MCMatrixTriangularComponentUpper leadingDimension:MCMatrixLeadingDimensionRow packingMethod:MCMatrixValuePackingMethodConventional];
    double unpackedUpperRowMajorValuesSolution[16] = {
        0.0,  1.0,  2.0,  0.0,
        0.0,  5.0,  6.0,  7.0,
        0.0,  0.0,  10.0, 11.0,
        0.0,  0.0,  0.0,  15.0
    };
    for (int i = 0; i < 16; i++) {
        XCTAssertEqual(unpackedUpperRowMajorValues[i], unpackedUpperRowMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // unpacked upper col major
    double *unpackedUpperColumnMajorValues = [bandMatrix valuesFromTriangularComponent:MCMatrixTriangularComponentUpper leadingDimension:MCMatrixLeadingDimensionColumn packingMethod:MCMatrixValuePackingMethodConventional];
    double unpackedUpperColumnMajorValuesSolution[16] = {
        0.0, 0.0, 0.0,  0.0,
        1.0, 5.0, 0.0,  0.0,
        2.0, 6.0, 10.0, 0.0,
        0.0, 7.0, 11.0, 15.0
    };
    for (int i = 0; i < 16; i++) {
        XCTAssertEqual(unpackedUpperColumnMajorValues[i], unpackedUpperColumnMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // packed lower row major
    double *packedLowerRowMajorValues = [bandMatrix valuesFromTriangularComponent:MCMatrixTriangularComponentLower leadingDimension:MCMatrixLeadingDimensionRow packingMethod:MCMatrixValuePackingMethodPacked];
    double packedLowerRowMajorValuesSolution[10] = {
        0.0,
        4.0,  5.0,
        0.0,  9.0,  10.0,
        0.0,  0.0,  14.0, 15.0
    };
    for (int i = 0; i < 10; i++) {
        XCTAssertEqual(packedLowerRowMajorValues[i], packedLowerRowMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // packed lower col major
    double *packedLowerColumnMajorValues = [bandMatrix valuesFromTriangularComponent:MCMatrixTriangularComponentLower leadingDimension:MCMatrixLeadingDimensionColumn packingMethod:MCMatrixValuePackingMethodPacked];
    double packedLowerColumnMajorValuesSolution[10] = {
        0.0, 4.0, 0.0,  0.0,
             5.0, 9.0,  0.0,
                  10.0, 14.0,
                        15.0
    };
    for (int i = 0; i < 10; i++) {
        XCTAssertEqual(packedLowerColumnMajorValues[i], packedLowerColumnMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // unpacked lower row major
    double *unpackedLowerRowMajorValues = [bandMatrix valuesFromTriangularComponent:MCMatrixTriangularComponentLower leadingDimension:MCMatrixLeadingDimensionRow packingMethod:MCMatrixValuePackingMethodConventional];
    double unpackedLowerRowMajorValuesSolution[16] = {
        0.0,  0.0,  0.0,  0.0,
        4.0,  5.0,  0.0,  0.0,
        0.0,  9.0,  10.0, 0.0,
        0.0,  0.0,  14.0, 15.0
    };
    for (int i = 0; i < 16; i++) {
        XCTAssertEqual(unpackedLowerRowMajorValues[i], unpackedLowerRowMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // unpacked lower col major
    double *unpackedLowerColumnMajorValues = [bandMatrix valuesFromTriangularComponent:MCMatrixTriangularComponentLower leadingDimension:MCMatrixLeadingDimensionColumn packingMethod:MCMatrixValuePackingMethodConventional];
    double unpackedLowerColumnMajorValuesSolution[16] = {
        0.0, 4.0, 0.0,  0.0,
        0.0, 5.0, 9.0,  0.0,
        0.0, 0.0, 10.0, 14.0,
        0.0, 0.0, 0.0,  15.0
    };
    for (int i = 0; i < 16; i++) {
        XCTAssertEqual(unpackedLowerColumnMajorValues[i], unpackedLowerColumnMajorValuesSolution[i], @"Incorrect value.");
    }
}

@end

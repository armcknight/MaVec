//
//  MAVMatrixValueRepresentationConversion.m
//  MaVec
//
//  Created by andrew mcknight on 4/6/14.
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

#import <XCTest/XCTest.h>

@interface MAVMatrixValueRepresentationConversion : XCTestCase

@end

@implementation MAVMatrixValueRepresentationConversion

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
    
    MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:9*sizeof(double)] rows:3 columns:3 leadingDimension:MAVMatrixLeadingDimensionRow];
    
    NSData *columnMajorValues = [a valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
    
    double solutionValues[9] = {
        0.0, 3.0, 6.0,
        1.0, 4.0, 7.0,
        2.0, 5.0, 8.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)columnMajorValues.bytes)[i], solutionValues[i], @"Value incorrect");
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
    
    MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:9*sizeof(double)] rows:3 columns:3 leadingDimension:MAVMatrixLeadingDimensionColumn];
    
    NSData *rowMajorValues = [a valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
    
    double solutionValues[9] = {
        0.0, 1.0, 2.0,
        3.0, 4.0, 5.0,
        6.0, 7.0, 8.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)rowMajorValues.bytes)[i], solutionValues[i], @"Value incorrect");
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
    
    MAVMatrix *matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:16*sizeof(double)] rows:4 columns:4 leadingDimension:MAVMatrixLeadingDimensionRow];
    
    NSData *balancedBandValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    
    double bandSolutionValues[12] = {
        0.0, 1.0, 6.0, 11.0,
        0.0, 5.0, 10.0, 15.0,
        4.0, 9.0, 14.0, 0.0
    };
    
    for (int i = 0; i < 12; i++) {
        XCTAssertEqual(((double *)balancedBandValues.bytes)[i], bandSolutionValues[i], @"Incorrect value.");
    }
    
    NSData *extraUpperBandValues = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:1];
    
    double extraUpperSolutionValues[16] = {
        0.0, 0.0, 2.0,  7.0,
        0.0, 1.0, 6.0,  11.0,
        0.0, 5.0, 10.0, 15.0,
        4.0, 9.0, 14.0, 0.0
    };
    
    for (int i = 0; i < 12; i++) {
        XCTAssertEqual(((double *)extraUpperBandValues.bytes)[i], extraUpperSolutionValues[i], @"Incorrect value.");
    }
    
    NSData *extraLowerBandValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:2];
    
    double extraLowerSolutionValues[16] = {
        0.0, 1.0,  6.0,  11.0,
        0.0, 5.0,  10.0, 15.0,
        4.0, 9.0,  14.0, 0.0,
        8.0, 13.0, 0.0,  0.0
    };
    
    for (int i = 0; i < 12; i++) {
        XCTAssertEqual(((double *)extraLowerBandValues.bytes)[i], extraLowerSolutionValues[i], @"Incorrect value.");
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
    
    MAVMatrix *matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:16*sizeof(double)] rows:4 columns:4 leadingDimension:MAVMatrixLeadingDimensionColumn];
    
    NSData *balancedBandValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    
    double bandSolutionValues[12] = {
        0.0, 1.0, 6.0, 11.0,
        0.0, 5.0, 10.0, 15.0,
        4.0, 9.0, 14.0, 0.0
    };
    
    for (int i = 0; i < 12; i++) {
        XCTAssertEqual(((double *)balancedBandValues.bytes)[i], bandSolutionValues[i], @"Incorrect value.");
    }
    
    NSData *extraUpperBandValues = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:1];
    
    double extraUpperSolutionValues[16] = {
        0.0, 0.0, 2.0,  7.0,
        0.0, 1.0, 6.0,  11.0,
        0.0, 5.0, 10.0, 15.0,
        4.0, 9.0, 14.0, 0.0
    };
    
    for (int i = 0; i < 12; i++) {
        XCTAssertEqual(((double *)extraUpperBandValues.bytes)[i], extraUpperSolutionValues[i], @"Incorrect value.");
    }
    
    NSData *extraLowerBandValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:2];
    
    double extraLowerSolutionValues[16] = {
        0.0, 1.0,  6.0,  11.0,
        0.0, 5.0,  10.0, 15.0,
        4.0, 9.0,  14.0, 0.0,
        8.0, 13.0, 0.0,  0.0
    };
    
    for (int i = 0; i < 12; i++) {
        XCTAssertEqual(((double *)extraLowerBandValues.bytes)[i], extraLowerSolutionValues[i], @"Incorrect value.");
    }
}

- (void)testRowMajorConventionalToTriangular
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
    
    MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:9*sizeof(double)] rows:3 columns:3 leadingDimension:MAVMatrixLeadingDimensionRow];
    
    /*
     0  1  2
     -  4  5
     -  -  8
     */
    NSData *packedUpperTriangularValuesRowMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentUpper
                                                                  leadingDimension:MAVMatrixLeadingDimensionRow
                                                                     packingMethod:MAVMatrixValuePackingMethodPacked];
    double packedUpperTriangularValuesRowMajorSolution[6] = {
        0.0, 1.0, 2.0,
             4.0, 5.0,
                  8.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)packedUpperTriangularValuesRowMajor.bytes)[i], packedUpperTriangularValuesRowMajorSolution[i], @"Value incorrect");
    }
    
    NSData *packedUpperTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentUpper
                                                                     leadingDimension:MAVMatrixLeadingDimensionColumn
                                                                        packingMethod:MAVMatrixValuePackingMethodPacked];
    double packedUpperTriangularValuesColumnMajorSolution[6] = {
        0.0,
        1.0, 4.0,
        2.0, 5.0, 8.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)packedUpperTriangularValuesColumnMajor.bytes)[i], packedUpperTriangularValuesColumnMajorSolution[i], @"Value incorrect");
    }
    
    NSData *unpackedUpperTriangularValuesRowMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentUpper
                                                                    leadingDimension:MAVMatrixLeadingDimensionRow
                                                                       packingMethod:MAVMatrixValuePackingMethodConventional];
    double unpackedUpperTriangularValuesRowMajorSolution[9] = {
        0.0, 1.0, 2.0,
        0.0, 4.0, 5.0,
        0.0, 0.0, 8.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)unpackedUpperTriangularValuesRowMajor.bytes)[i], unpackedUpperTriangularValuesRowMajorSolution[i], @"Value incorrect");
    }
    
    NSData *unpackedUpperTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentUpper
                                                                       leadingDimension:MAVMatrixLeadingDimensionColumn
                                                                          packingMethod:MAVMatrixValuePackingMethodConventional];
    double unpackedUpperTriangularValuesColumnMajorSolution[9] = {
        0.0, 0.0, 0.0,
        1.0, 4.0, 0.0,
        2.0, 5.0, 8.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)unpackedUpperTriangularValuesColumnMajor.bytes)[i], unpackedUpperTriangularValuesColumnMajorSolution[i], @"Value incorrect");
    }
    
    /*
     0  -  -
     3  4  -
     6  7  8
     */
    NSData *packedLowerTriangularValuesRowMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentLower
                                                                  leadingDimension:MAVMatrixLeadingDimensionRow
                                                                     packingMethod:MAVMatrixValuePackingMethodPacked];
    double packedLowerTriangularValuesRowMajorSolution[6] = {
        0.0,
        3.0, 4.0,
        6.0, 7.0, 8.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)packedLowerTriangularValuesRowMajor.bytes)[i], packedLowerTriangularValuesRowMajorSolution[i], @"Value incorrect");
    }
    
    NSData *packedLowerTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentLower
                                                                     leadingDimension:MAVMatrixLeadingDimensionColumn
                                                                        packingMethod:MAVMatrixValuePackingMethodPacked];
    double packedLowerTriangularValuesColumnMajorSolution[6] = {
        0.0, 3.0, 6.0,
             4.0, 7.0,
                  8.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)packedLowerTriangularValuesColumnMajor.bytes)[i], packedLowerTriangularValuesColumnMajorSolution[i], @"Value incorrect");
    }
    
    NSData *unpackedLowerTriangularValuesRowMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentLower
                                                                    leadingDimension:MAVMatrixLeadingDimensionRow
                                                                       packingMethod:MAVMatrixValuePackingMethodConventional];
    double unpackedLowerTriangularValuesRowMajorSolution[9] = {
        0.0, 0.0, 0.0,
        3.0, 4.0, 0.0,
        6.0, 7.0, 8.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)unpackedLowerTriangularValuesRowMajor.bytes)[i], unpackedLowerTriangularValuesRowMajorSolution[i], @"Value incorrect");
    }
    
    NSData *unpackedLowerTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentLower
                                                                       leadingDimension:MAVMatrixLeadingDimensionColumn
                                                                          packingMethod:MAVMatrixValuePackingMethodConventional];
    double unpackedLowerTriangularValuesColumnMajorSolution[9] = {
        0.0, 3.0, 6.0,
        0.0, 4.0, 7.0,
        0.0, 0.0, 8.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)unpackedLowerTriangularValuesColumnMajor.bytes)[i], unpackedLowerTriangularValuesColumnMajorSolution[i], @"Value incorrect");
    }
}

- (void)testColumnMajorConventionalToTriangular
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
    
    MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:9*sizeof(double)] rows:3 columns:3 leadingDimension:MAVMatrixLeadingDimensionColumn];
    
    /*
     0  1  2
     -  4  5
     -  -  8
     */
    NSData *packedUpperTriangularValuesRowMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentUpper
                                                                  leadingDimension:MAVMatrixLeadingDimensionRow
                                                                     packingMethod:MAVMatrixValuePackingMethodPacked];
    double packedUpperTriangularValuesRowMajorSolution[6] = {
        0.0, 1.0, 2.0,
        4.0, 5.0,
        8.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)packedUpperTriangularValuesRowMajor.bytes)[i], packedUpperTriangularValuesRowMajorSolution[i], @"Value incorrect");
    }
    
    NSData *packedUpperTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentUpper
                                                                     leadingDimension:MAVMatrixLeadingDimensionColumn
                                                                        packingMethod:MAVMatrixValuePackingMethodPacked];
    double packedUpperTriangularValuesColumnMajorSolution[6] = {
        0.0,
        1.0, 4.0,
        2.0, 5.0, 8.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)packedUpperTriangularValuesColumnMajor.bytes)[i], packedUpperTriangularValuesColumnMajorSolution[i], @"Value incorrect");
    }
    
    NSData *unpackedUpperTriangularValuesRowMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentUpper
                                                                    leadingDimension:MAVMatrixLeadingDimensionRow
                                                                       packingMethod:MAVMatrixValuePackingMethodConventional];
    double unpackedUpperTriangularValuesRowMajorSolution[9] = {
        0.0, 1.0, 2.0,
        0.0, 4.0, 5.0,
        0.0, 0.0, 8.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)unpackedUpperTriangularValuesRowMajor.bytes)[i], unpackedUpperTriangularValuesRowMajorSolution[i], @"Value incorrect");
    }
    
    NSData *unpackedUpperTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentUpper
                                                                       leadingDimension:MAVMatrixLeadingDimensionColumn
                                                                          packingMethod:MAVMatrixValuePackingMethodConventional];
    double unpackedUpperTriangularValuesColumnMajorSolution[9] = {
        0.0, 0.0, 0.0,
        1.0, 4.0, 0.0,
        2.0, 5.0, 8.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)unpackedUpperTriangularValuesColumnMajor.bytes)[i], unpackedUpperTriangularValuesColumnMajorSolution[i], @"Value incorrect");
    }
    
    /*
     0  -  -
     3  4  -
     6  7  8
     */
    NSData *packedLowerTriangularValuesRowMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentLower
                                                                  leadingDimension:MAVMatrixLeadingDimensionRow
                                                                     packingMethod:MAVMatrixValuePackingMethodPacked];
    double packedLowerTriangularValuesRowMajorSolution[6] = {
        0.0,
        3.0, 4.0,
        6.0, 7.0, 8.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)packedLowerTriangularValuesRowMajor.bytes)[i], packedLowerTriangularValuesRowMajorSolution[i], @"Value incorrect");
    }
    
    NSData *packedLowerTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentLower
                                                                     leadingDimension:MAVMatrixLeadingDimensionColumn
                                                                        packingMethod:MAVMatrixValuePackingMethodPacked];
    double packedLowerTriangularValuesColumnMajorSolution[6] = {
        0.0, 3.0, 6.0,
        4.0, 7.0,
        8.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)packedLowerTriangularValuesColumnMajor.bytes)[i], packedLowerTriangularValuesColumnMajorSolution[i], @"Value incorrect");
    }
    
    NSData *unpackedLowerTriangularValuesRowMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentLower
                                                                    leadingDimension:MAVMatrixLeadingDimensionRow
                                                                       packingMethod:MAVMatrixValuePackingMethodConventional];
    double unpackedLowerTriangularValuesRowMajorSolution[9] = {
        0.0, 0.0, 0.0,
        3.0, 4.0, 0.0,
        6.0, 7.0, 8.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)unpackedLowerTriangularValuesRowMajor.bytes)[i], unpackedLowerTriangularValuesRowMajorSolution[i], @"Value incorrect");
    }
    
    NSData *unpackedLowerTriangularValuesColumnMajor = [a valuesFromTriangularComponent:MAVMatrixTriangularComponentLower
                                                                       leadingDimension:MAVMatrixLeadingDimensionColumn
                                                                          packingMethod:MAVMatrixValuePackingMethodConventional];
    double unpackedLowerTriangularValuesColumnMajorSolution[9] = {
        0.0, 3.0, 6.0,
        0.0, 4.0, 7.0,
        0.0, 0.0, 8.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)unpackedLowerTriangularValuesColumnMajor.bytes)[i], unpackedLowerTriangularValuesColumnMajorSolution[i], @"Value incorrect");
    }
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
    MAVMatrix *matrix = [MAVMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:upperValues length:6*sizeof(double)] ofTriangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionRow order:3];
    
    // to row major conventional
    
    NSData *upperRowMajorConventionalValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
    
    double upperRowMajorConventionalValuesSolution[9] = {
        1.0, 2.0, 3.0,
        0.0, 4.0, 5.0,
        0.0, 0.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperRowMajorConventionalValues.bytes)[i], upperRowMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    
    // to column major conventional
    
    NSData *upperColumnMajorConventionalValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
    
    double upperColumnMajorConventionalValuesSolution[9] = {
        1.0, 0.0, 0.0,
        2.0, 4.0, 0.0,
        3.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperColumnMajorConventionalValues.bytes)[i], upperColumnMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    
    //
    // lower triangular
    //
    
    double lowerValues[6] = {
        1.0,
        2.0, 3.0,
        4.0, 5.0, 6.0
    };
    matrix = [MAVMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:lowerValues length:6*sizeof(double)] ofTriangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionRow order:3];
    
    // to row major conventional
    
    NSData *lowerRowMajorConventionalValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
    
    double lowerRowMajorConventionalValuesSolution[9] = {
        1.0, 0.0, 0.0,
        2.0, 3.0, 0.0,
        4.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerRowMajorConventionalValues.bytes)[i], lowerRowMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    
    // to column major conventional
    
    NSData *lowerColumnMajorConventionalValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
    
    double lowerColumnMajorConventionalValuesSolution[9] = {
        1.0, 2.0, 4.0,
        0.0, 3.0, 5.0,
        0.0, 0.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerColumnMajorConventionalValues.bytes)[i], lowerColumnMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
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
    MAVMatrix *matrix = [MAVMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:upperValues length:6*sizeof(double)] ofTriangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionColumn order:3];
    
    // to row major conventional
    
    NSData *upperRowMajorConventionalValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
    
    double upperRowMajorConventionalValuesSolution[9] = {
        1.0, 2.0, 3.0,
        0.0, 4.0, 5.0,
        0.0, 0.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperRowMajorConventionalValues.bytes)[i], upperRowMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    
    // to column major conventional
    
    NSData *upperColumnMajorConventionalValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
    
    double upperColumnMajorConventionalValuesSolution[9] = {
        1.0, 0.0, 0.0,
        2.0, 4.0, 0.0,
        3.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperColumnMajorConventionalValues.bytes)[i], upperColumnMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    
    //
    // lower triangular
    //
    
    double lowerValues[6] = {
        1.0, 2.0, 4.0,
        3.0, 5.0,
        6.0
    };
    matrix = [MAVMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:lowerValues length:6*sizeof(double)] ofTriangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionColumn order:3];
    
    // to row major conventional
    
    NSData *lowerRowMajorConventionalValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
    
    double lowerRowMajorConventionalValuesSolution[9] = {
        1.0, 0.0, 0.0,
        2.0, 3.0, 0.0,
        4.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerRowMajorConventionalValues.bytes)[i], lowerRowMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
    
    // to column major conventional
    
    NSData *lowerColumnMajorConventionalValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
    
    double lowerColumnMajorConventionalValuesSolution[9] = {
        1.0, 2.0, 4.0,
        0.0, 3.0, 5.0,
        0.0, 0.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerColumnMajorConventionalValues.bytes)[i], lowerColumnMajorConventionalValuesSolution[i], @"%dth value incorrect", i);
    }
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
    MAVMatrix *matrix = [MAVMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:upperValues length:6*sizeof(double)] ofTriangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionRow order:3];
    
    // tridiagonal
    NSData *upperTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double upperTridiagonalValuesSolution[9] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0,
        0.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperTridiagonalValues.bytes)[i], upperTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    NSData *upperOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double upperOneUpperSolution[6] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)upperOneUpper.bytes)[i], upperOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    NSData *upperTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double upperTwoUpperSolution[9] = {
        0.0, 0.0, 3.0,
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperTwoUpper.bytes)[i], upperTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    NSData *upperOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double upperOneLowerSolution[6] = {
        1.0, 4.0, 6.0,
        0.0, 0.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)upperOneLower.bytes)[i], upperOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    NSData *upperTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double upperTwoLowerSolution[9] = {
        1.0, 4.0, 6.0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperTwoLower.bytes)[i], upperTwoLowerSolution[i], @"Incorrect value.");
    }
    
    //
    // lower triangular
    //
    
    double lowerValues[6] = {
        1.0,
        2.0, 3.0,
        4.0, 5.0, 6.0
    };
    matrix = [MAVMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:lowerValues length:6*sizeof(double)] ofTriangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionRow order:3];
    
    // tridiagonal
    NSData *lowerTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double lowerTridiagonalValuesSolution[9] = {
        0.0, 0.0, 0.0,
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerTridiagonalValues.bytes)[i], lowerTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    NSData *lowerOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double lowerOneUpperSolution[6] = {
        0.0, 0.0, 0.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)lowerOneUpper.bytes)[i], lowerOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    NSData *lowerTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double lowerTwoUpperSolution[9] = {
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerTwoUpper.bytes)[i], lowerTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    NSData *lowerOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double lowerOneLowerSolution[6] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)lowerOneLower.bytes)[i], lowerOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    NSData *lowerTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double lowerTwoLowerSolution[9] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0,
        4.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerTwoLower.bytes)[i], lowerTwoLowerSolution[i], @"Incorrect value.");
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
    MAVMatrix *matrix = [MAVMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:upperValues length:6*sizeof(double)] ofTriangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionColumn order:3];
    
    // tridiagonal
    NSData *upperTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double upperTridiagonalValuesSolution[9] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0,
        0.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperTridiagonalValues.bytes)[i], upperTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    NSData *upperOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double upperOneUpperSolution[6] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)upperOneUpper.bytes)[i], upperOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    NSData *upperTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double upperTwoUpperSolution[9] = {
        0.0, 0.0, 3.0,
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperTwoUpper.bytes)[i], upperTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    NSData *upperOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double upperOneLowerSolution[6] = {
        1.0, 4.0, 6.0,
        0.0, 0.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)upperOneLower.bytes)[i], upperOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    NSData *upperTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double upperTwoLowerSolution[9] = {
        1.0, 4.0, 6.0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperTwoLower.bytes)[i], upperTwoLowerSolution[i], @"Incorrect value.");
    }
    
    //
    // lower triangular
    //
    
    double lowerValues[6] = {
        1.0, 2.0, 4.0,
        3.0, 5.0,
        6.0
    };
    matrix = [MAVMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:lowerValues length:6*sizeof(double)] ofTriangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionColumn order:3];
    
    // tridiagonal
    NSData *lowerTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double lowerTridiagonalValuesSolution[9] = {
        0.0, 0.0, 0.0,
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerTridiagonalValues.bytes)[i], lowerTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    NSData *lowerOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double lowerOneUpperSolution[6] = {
        0.0, 0.0, 0.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)lowerOneUpper.bytes)[i], lowerOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    NSData *lowerTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double lowerTwoUpperSolution[9] = {
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerTwoUpper.bytes)[i], lowerTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    NSData *lowerOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double lowerOneLowerSolution[6] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)lowerOneLower.bytes)[i], lowerOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    NSData *lowerTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double lowerTwoLowerSolution[9] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0,
        4.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerTwoLower.bytes)[i], lowerTwoLowerSolution[i], @"Incorrect value.");
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
    MAVMatrix *matrix = [MAVMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:upperValues length:6*sizeof(double)] triangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionRow order:3];
    
    NSData *upperConventionalRowMajorValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
    NSData *upperConventionalColumnMajorValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
    
    double upperSolution[9] = {
        1.0, 2.0, 3.0,
        2.0, 4.0, 5.0,
        3.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperConventionalRowMajorValues.bytes)[i], upperSolution[i], @"Incorrect values");
    }
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperConventionalColumnMajorValues.bytes)[i], upperSolution[i], @"Incorrect values");
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
    matrix = [MAVMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:lowerValues length:6*sizeof(double)] triangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionRow order:3];
    
    NSData *lowerConventionalRowMajorValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
    NSData *lowerConventionalColumnMajorValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
    
    double lowerSolution[9] = {
        1.0, 2.0, 4.0,
        2.0, 3.0, 5.0,
        4.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerConventionalRowMajorValues.bytes)[i], lowerSolution[i], @"Incorrect values");
    }
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerConventionalColumnMajorValues.bytes)[i], lowerSolution[i], @"Incorrect values");
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
    MAVMatrix *matrix = [MAVMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:upperValues length:6*sizeof(double)] triangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionColumn order:3];
    
    NSData *upperConventionalRowMajorValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
    NSData *upperConventionalColumnMajorValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
    
    double upperSolution[9] = {
        1.0, 2.0, 3.0,
        2.0, 4.0, 5.0,
        3.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperConventionalRowMajorValues.bytes)[i], upperSolution[i], @"Incorrect values");
    }
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperConventionalColumnMajorValues.bytes)[i], upperSolution[i], @"Incorrect values");
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
    matrix = [MAVMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:lowerValues length:6*sizeof(double)] triangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionColumn order:3];
    
    NSData *lowerConventionalRowMajorValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
    NSData *lowerConventionalColumnMajorValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
    
    double lowerSolution[9] = {
        1.0, 2.0, 4.0,
        2.0, 3.0, 5.0,
        4.0, 5.0, 6.0
    };
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerConventionalRowMajorValues.bytes)[i], lowerSolution[i], @"Incorrect values");
    }
    
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerConventionalColumnMajorValues.bytes)[i], lowerSolution[i], @"Incorrect values");
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
    MAVMatrix *matrix = [MAVMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:upperValues length:6*sizeof(double)] triangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionRow order:3];
    
    // tridiagonal
    NSData *upperTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double upperTridiagonalValuesSolution[9] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperTridiagonalValues.bytes)[i], upperTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    NSData *upperOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double upperOneUpperSolution[6] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)upperOneUpper.bytes)[i], upperOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    NSData *upperTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double upperTwoUpperSolution[9] = {
        0.0, 0.0, 3.0,
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperTwoUpper.bytes)[i], upperTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    NSData *upperOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double upperOneLowerSolution[6] = {
        1.0, 4.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)upperOneLower.bytes)[i], upperOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    NSData *upperTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double upperTwoLowerSolution[9] = {
        1.0, 4.0, 6.0,
        2.0, 5.0, 0.0,
        3.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperTwoLower.bytes)[i], upperTwoLowerSolution[i], @"Incorrect value.");
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
    matrix = [MAVMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:lowerValues length:6*sizeof(double)] triangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionRow order:3];
    
    // tridiagonal
    NSData *lowerTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double lowerTridiagonalValuesSolution[9] = {
        0.0, 2.0, 5.0,
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerTridiagonalValues.bytes)[i], lowerTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    NSData *lowerOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double lowerOneUpperSolution[6] = {
        0.0, 2.0, 5.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)lowerOneUpper.bytes)[i], lowerOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    NSData *lowerTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double lowerTwoUpperSolution[9] = {
        0.0, 0.0, 4.0,
        0.0, 2.0, 5.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerTwoUpper.bytes)[i], lowerTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    NSData *lowerOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double lowerOneLowerSolution[6] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)lowerOneLower.bytes)[i], lowerOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    NSData *lowerTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double lowerTwoLowerSolution[9] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0,
        4.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerTwoLower.bytes)[i], lowerTwoLowerSolution[i], @"Incorrect value.");
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
    MAVMatrix *matrix = [MAVMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:upperValues length:6*sizeof(double)] triangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionColumn order:3];
    
    // tridiagonal
    NSData *upperTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double upperTridiagonalValuesSolution[9] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperTridiagonalValues.bytes)[i], upperTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    NSData *upperOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double upperOneUpperSolution[6] = {
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)upperOneUpper.bytes)[i], upperOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    NSData *upperTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double upperTwoUpperSolution[9] = {
        0.0, 0.0, 3.0,
        0.0, 2.0, 5.0,
        1.0, 4.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperTwoUpper.bytes)[i], upperTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    NSData *upperOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double upperOneLowerSolution[6] = {
        1.0, 4.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)upperOneLower.bytes)[i], upperOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    NSData *upperTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double upperTwoLowerSolution[9] = {
        1.0, 4.0, 6.0,
        2.0, 5.0, 0.0,
        3.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)upperTwoLower.bytes)[i], upperTwoLowerSolution[i], @"Incorrect value.");
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
    matrix = [MAVMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:lowerValues length:6*sizeof(double)] triangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionColumn order:3];
    
    // tridiagonal
    NSData *lowerTridiagonalValues = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:1];
    double lowerTridiagonalValuesSolution[9] = {
        0.0, 2.0, 5.0,
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerTridiagonalValues.bytes)[i], lowerTridiagonalValuesSolution[i], @"Incorrect value.");
    }
    
    // main + 1 upper
    NSData *lowerOneUpper = [matrix valuesInBandBetweenUpperCodiagonal:1 lowerCodiagonal:0];
    double lowerOneUpperSolution[6] = {
        0.0, 2.0, 5.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)lowerOneUpper.bytes)[i], lowerOneUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 2 upper
    NSData *lowerTwoUpper = [matrix valuesInBandBetweenUpperCodiagonal:2 lowerCodiagonal:0];
    double lowerTwoUpperSolution[9] = {
        0.0, 0.0, 4.0,
        0.0, 2.0, 5.0,
        1.0, 3.0, 6.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerTwoUpper.bytes)[i], lowerTwoUpperSolution[i], @"Incorrect value.");
    }
    
    // main + 1 lower
    NSData *lowerOneLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:1];
    double lowerOneLowerSolution[6] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0
    };
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(((double *)lowerOneLower.bytes)[i], lowerOneLowerSolution[i], @"Incorrect value.");
    }
    
    // main + 2 lower
    NSData *lowerTwoLower = [matrix valuesInBandBetweenUpperCodiagonal:0 lowerCodiagonal:2];
    double lowerTwoLowerSolution[9] = {
        1.0, 3.0, 6.0,
        2.0, 5.0, 0.0,
        4.0, 0.0, 0.0
    };
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(((double *)lowerTwoLower.bytes)[i], lowerTwoLowerSolution[i], @"Incorrect value.");
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
    
    MAVMatrix *bandMatrix = [MAVMatrix bandMatrixWithValues:[NSData dataWithBytes:bandValues length:16*sizeof(double)] order:4 upperCodiagonals:2 lowerCodiagonals:1];
    
    NSData *rowMajorValues = [bandMatrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow];
    double rowMajorSolution[16] = {
        0.0,  1.0,  2.0,  0.0,
        4.0,  5.0,  6.0,  7.0,
        0.0,  9.0,  10.0, 11.0,
        0.0,  0.0,  14.0, 15.0
    };
    for (int i = 0; i < 16; i++) {
        XCTAssertEqual(((double *)rowMajorValues.bytes)[i], rowMajorSolution[i], @"Incorrect value.");
    }
    
    NSData *columnMajorValues = [bandMatrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
    double columnMajorSolution[16] = {
        0.0, 4.0, 0.0,  0.0,
        1.0, 5.0, 9.0,  0.0,
        2.0, 6.0, 10.0, 14.0,
        0.0, 7.0, 11.0, 15.0
    };
    for (int i = 0; i < 16; i++) {
        XCTAssertEqual(((double *)columnMajorValues.bytes)[i], columnMajorSolution[i], @"Incorrect value.");
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
    
    MAVMatrix *bandMatrix = [MAVMatrix bandMatrixWithValues:[NSData dataWithBytes:bandValues length:16*sizeof(double)] order:4 upperCodiagonals:2 lowerCodiagonals:1];
    
    // packed upper row major
    NSData *packedUpperRowMajorValues = [bandMatrix valuesFromTriangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionRow packingMethod:MAVMatrixValuePackingMethodPacked];
    double packedUpperRowMajorValuesSolution[10] = {
        0.0,  1.0,  2.0,  0.0,
              5.0,  6.0,  7.0,
                    10.0, 11.0,
                          15.0
    };
    for (int i = 0; i < 10; i++) {
        XCTAssertEqual(((double *)packedUpperRowMajorValues.bytes)[i], packedUpperRowMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // packed upper col major
    NSData *packedUpperColumnMajorValues = [bandMatrix valuesFromTriangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionColumn packingMethod:MAVMatrixValuePackingMethodPacked];
    double packedUpperColumnMajorValuesSolution[10] = {
        0.0,
        1.0, 5.0,
        2.0, 6.0, 10.0,
        0.0, 7.0, 11.0, 15.0
    };
    for (int i = 0; i < 10; i++) {
        XCTAssertEqual(((double *)packedUpperColumnMajorValues.bytes)[i], packedUpperColumnMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // unpacked upper row major
    NSData *unpackedUpperRowMajorValues = [bandMatrix valuesFromTriangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionRow packingMethod:MAVMatrixValuePackingMethodConventional];
    double unpackedUpperRowMajorValuesSolution[16] = {
        0.0,  1.0,  2.0,  0.0,
        0.0,  5.0,  6.0,  7.0,
        0.0,  0.0,  10.0, 11.0,
        0.0,  0.0,  0.0,  15.0
    };
    for (int i = 0; i < 16; i++) {
        XCTAssertEqual(((double *)unpackedUpperRowMajorValues.bytes)[i], unpackedUpperRowMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // unpacked upper col major
    NSData *unpackedUpperColumnMajorValues = [bandMatrix valuesFromTriangularComponent:MAVMatrixTriangularComponentUpper leadingDimension:MAVMatrixLeadingDimensionColumn packingMethod:MAVMatrixValuePackingMethodConventional];
    double unpackedUpperColumnMajorValuesSolution[16] = {
        0.0, 0.0, 0.0,  0.0,
        1.0, 5.0, 0.0,  0.0,
        2.0, 6.0, 10.0, 0.0,
        0.0, 7.0, 11.0, 15.0
    };
    for (int i = 0; i < 16; i++) {
        XCTAssertEqual(((double *)unpackedUpperColumnMajorValues.bytes)[i], unpackedUpperColumnMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // packed lower row major
    NSData *packedLowerRowMajorValues = [bandMatrix valuesFromTriangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionRow packingMethod:MAVMatrixValuePackingMethodPacked];
    double packedLowerRowMajorValuesSolution[10] = {
        0.0,
        4.0,  5.0,
        0.0,  9.0,  10.0,
        0.0,  0.0,  14.0, 15.0
    };
    for (int i = 0; i < 10; i++) {
        XCTAssertEqual(((double *)packedLowerRowMajorValues.bytes)[i], packedLowerRowMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // packed lower col major
    NSData *packedLowerColumnMajorValues = [bandMatrix valuesFromTriangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionColumn packingMethod:MAVMatrixValuePackingMethodPacked];
    double packedLowerColumnMajorValuesSolution[10] = {
        0.0, 4.0, 0.0,  0.0,
             5.0, 9.0,  0.0,
                  10.0, 14.0,
                        15.0
    };
    for (int i = 0; i < 10; i++) {
        XCTAssertEqual(((double *)packedLowerColumnMajorValues.bytes)[i], packedLowerColumnMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // unpacked lower row major
    NSData *unpackedLowerRowMajorValues = [bandMatrix valuesFromTriangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionRow packingMethod:MAVMatrixValuePackingMethodConventional];
    double unpackedLowerRowMajorValuesSolution[16] = {
        0.0,  0.0,  0.0,  0.0,
        4.0,  5.0,  0.0,  0.0,
        0.0,  9.0,  10.0, 0.0,
        0.0,  0.0,  14.0, 15.0
    };
    for (int i = 0; i < 16; i++) {
        XCTAssertEqual(((double *)unpackedLowerRowMajorValues.bytes)[i], unpackedLowerRowMajorValuesSolution[i], @"Incorrect value.");
    }
    
    // unpacked lower col major
    NSData *unpackedLowerColumnMajorValues = [bandMatrix valuesFromTriangularComponent:MAVMatrixTriangularComponentLower leadingDimension:MAVMatrixLeadingDimensionColumn packingMethod:MAVMatrixValuePackingMethodConventional];
    double unpackedLowerColumnMajorValuesSolution[16] = {
        0.0, 4.0, 0.0,  0.0,
        0.0, 5.0, 9.0,  0.0,
        0.0, 0.0, 10.0, 14.0,
        0.0, 0.0, 0.0,  15.0
    };
    for (int i = 0; i < 16; i++) {
        XCTAssertEqual(((double *)unpackedLowerColumnMajorValues.bytes)[i], unpackedLowerColumnMajorValuesSolution[i], @"Incorrect value.");
    }
}

@end

//
//  MatrixConstructionTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/8/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"
#import "MCVector.h"

@interface MatrixConstructionTests : XCTestCase

@end

@implementation MatrixConstructionTests

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

- (void)testDiagonalMatrixCreation
{
    double *diagonalValues = malloc(4 * sizeof(double));
    diagonalValues[0] = 1.0;
    diagonalValues[1] = 2.0;
    diagonalValues[2] = 3.0;
    diagonalValues[3] = 4.0;
    MCMatrix *diagonal = [MCMatrix diagonalMatrixWithValues:diagonalValues order:4];
    
    double *solution = malloc(16 * sizeof(double));
    solution[0] = 1.0;
    solution[1] = 0.0;
    solution[2] = 0.0;
    solution[3] = 0.0;
    solution[4] = 0.0;
    solution[5] = 2.0;
    solution[6] = 0.0;
    solution[7] = 0.0;
    solution[8] = 0.0;
    solution[9] = 0.0;
    solution[10] = 3.0;
    solution[11] = 0.0;
    solution[12] = 0.0;
    solution[13] = 0.0;
    solution[14] = 0.0;
    solution[15] = 4.0;
    MCMatrix *s = [MCMatrix matrixWithValues:solution rows:4 columns:4];
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            XCTAssertEqual([diagonal valueAtRow:i column:j], [s valueAtRow:i column:j], @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testIdentityMatrixCreation
{
    MCMatrix *identity = [MCMatrix identityMatrixOfOrder:4];
    
    double *solution = malloc(16 * sizeof(double));
    solution[0] = 1.0;
    solution[1] = 0.0;
    solution[2] = 0.0;
    solution[3] = 0.0;
    solution[4] = 0.0;
    solution[5] = 1.0;
    solution[6] = 0.0;
    solution[7] = 0.0;
    solution[8] = 0.0;
    solution[9] = 0.0;
    solution[10] = 1.0;
    solution[11] = 0.0;
    solution[12] = 0.0;
    solution[13] = 0.0;
    solution[14] = 0.0;
    solution[15] = 1.0;
    MCMatrix *s = [MCMatrix matrixWithValues:solution rows:4 columns:4];
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            XCTAssertEqual([identity valueAtRow:i column:j], [s valueAtRow:i column:j], @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testSymmetricMatrixCreation
{
    double solutionValues[9] = {
        1.0, 2.0, 3.0,
        2.0, 5.0, 7.0,
        3.0, 7.0, 12.0
    };
    MCMatrix *solutionMatrix = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:solutionValues size:9] rows:3 columns:3];
    
    // packed row-major upper triangular
    double rowMajorPackedUpperValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    MCMatrix *matrix = [MCMatrix symmetricMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:rowMajorPackedUpperValues size:6]
                                             triangularComponent:MCMatrixTriangularComponentUpper
                                                leadingDimension:MCMatrixLeadingDimensionRow
                                                           order:3];
    XCTAssert(matrix.isSymmetric, @"Packed row-major symmetric matrix constructed incorrectly.");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([solutionMatrix valueAtRow:i column:j], [matrix valueAtRow:i column:j], @"Value at %u, %u incorrect.", i, j);
        }
    }
    
    // packed row-major lower triangular
    double rowMajorPackedLowerValues[6] = {
        1.0,
        2.0, 5.0,
        3.0, 7.0, 12.0
    };
    matrix = [MCMatrix symmetricMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:rowMajorPackedLowerValues size:6]
                                   triangularComponent:MCMatrixTriangularComponentLower
                                      leadingDimension:MCMatrixLeadingDimensionRow
                                                 order:3];
    XCTAssert(matrix.isSymmetric, @"Packed row-major symmetric matrix constructed incorrectly.");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([solutionMatrix valueAtRow:i column:j], [matrix valueAtRow:i column:j], @"Value at %u, %u incorrect.", i, j);
        }
    }
    
    // packed column-major lower triangular
    double columnMajorPackedLowerValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    matrix = [MCMatrix symmetricMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:columnMajorPackedLowerValues size:6]
                                   triangularComponent:MCMatrixTriangularComponentLower
                                      leadingDimension:MCMatrixLeadingDimensionColumn
                                                 order:3];
    XCTAssert(matrix.isSymmetric, @"Packed column-major symmetric matrix constructed incorrectly.");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([solutionMatrix valueAtRow:i column:j], [matrix valueAtRow:i column:j], @"Value at %u, %u incorrect.", i, j);
        }
    }
    
    // packed column-major upper triangular
    double columnMajorPackedUpperValues[6] = {
        1.0,
        2.0, 5.0,
        3.0, 7.0, 12.0
    };
    matrix = [MCMatrix symmetricMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:columnMajorPackedUpperValues size:6]
                                   triangularComponent:MCMatrixTriangularComponentUpper
                                      leadingDimension:MCMatrixLeadingDimensionColumn
                                                 order:3];
    XCTAssert(matrix.isSymmetric, @"Packed column-major symmetric matrix constructed incorrectly.");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([solutionMatrix valueAtRow:i column:j], [matrix valueAtRow:i column:j], @"Value at %u, %u incorrect.", i, j);
        }
    }
}

- (void)testTriangularMatrixCreation
{
    double upperSolutionValues[9] = {
        1.0,   2.0,   3.0,
        0.0,   5.0,   7.0,
        0.0,   0.0,   12.0
    };
    MCMatrix *upperSolution = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:upperSolutionValues size:9]
                                                    rows:3
                                                 columns:3
                                        leadingDimension:MCMatrixLeadingDimensionRow];
    
    // upper row-major
    double rowMajorUpperValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    MCMatrix *matrix = [MCMatrix triangularMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:rowMajorUpperValues size:6]
                                            ofTriangularComponent:MCMatrixTriangularComponentUpper
                                                 leadingDimension:MCMatrixLeadingDimensionRow
                                                            order:3];
    XCTAssert([matrix isEqualToMatrix:upperSolution], @"Upper triangular row major matrix incorrectly created.");
    
    // upper column-major
    double columnMajorUpperValues[6] = {
        1.0, 2.0, 5.0,
        3.0, 7.0,
        12.0
    };
    matrix = [MCMatrix triangularMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:columnMajorUpperValues size:6]
                                  ofTriangularComponent:MCMatrixTriangularComponentUpper
                                       leadingDimension:MCMatrixLeadingDimensionColumn
                                                  order:3];
    XCTAssert([matrix isEqualToMatrix:upperSolution], @"Upper triangular column major matrix incorrectly created.");
    
    double lowerSolutionValues[9] = {
        1.0,   0.0,   0.0,
        2.0,   5.0,   0.0,
        3.0,   7.0,   12.0
    };
    MCMatrix *lowerSolution = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:lowerSolutionValues size:9]
                                                    rows:3
                                                 columns:3
                                        leadingDimension:MCMatrixLeadingDimensionRow];
    
    // lower row-major
    double rowMajorLowerValues[6] = {
        1.0, 2.0, 5.0,
        3.0, 7.0,
        12.0
    };
    matrix = [MCMatrix triangularMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:rowMajorLowerValues size:6]
                                  ofTriangularComponent:MCMatrixTriangularComponentLower
                                       leadingDimension:MCMatrixLeadingDimensionRow
                                                  order:3];
    XCTAssert([matrix isEqualToMatrix:lowerSolution], @"Lower triangular row major matrix incorrectly created.");
    
    // lower column-major
    double columnMajorLowerValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    matrix = [MCMatrix triangularMatrixWithPackedValues:[DynamicArrayUtility dynamicArrayForStaticArray:columnMajorLowerValues size:6]
                                  ofTriangularComponent:MCMatrixTriangularComponentLower
                                       leadingDimension:MCMatrixLeadingDimensionColumn
                                                  order:3];
    XCTAssert([matrix isEqualToMatrix:lowerSolution], @"Lower triangular column major matrix incorrectly created.");
}

- (void)testBandMatrixCreation
{
    // balanced codiagonals
    double balancedBandValues[15] = {
        0.0,  1.0,  2.0,  3.0,  4.0,
        10.0, 20.0, 30.0, 40.0, 50.0,
        5.0,  6.0,  7.0,  8.0,  0.0
    };
    MCMatrix *matrix = [MCMatrix bandMatrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:balancedBandValues size:15]
                                                order:5
                                     upperCodiagonals:1
                                     lowerCodiagonals:1];
    
    double oddBandwidthSolutionValues[25] = {
        10.0,  1.0,   0.0,   0.0,   0.0,
        5.0,   20.0,  2.0,   0.0,   0.0,
        0.0,   6.0,   30.0,  3.0,   0.0,
        0.0,   0.0,   7.0,   40.0,  4.0,
        0.0,   0.0,   0.0,   8.0,   50.0
    };
    MCMatrix *solution = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:oddBandwidthSolutionValues size:25]
                                               rows:5
                                            columns:5
                                   leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 5; row += 1) {
        for (int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col], [solution valueAtRow:row column:col], @"Incorrect value at %u, %u in constructed band matrix with balanced codiagonals.", row, col);
        }
    }
    
    // extra upper codiagonal
    double bandValuesWithExtraUpper[20] = {
        0.0,  0.0,  -1.0, -2.0, -3.0,
        0.0,  1.0,  2.0,  3.0,  4.0,
        10.0, 20.0, 30.0, 40.0, 50.0,
        5.0,  6.0,  7.0,  8.0,  0.0
    };
    matrix = [MCMatrix bandMatrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:bandValuesWithExtraUpper size:20]
                                      order:5
                           upperCodiagonals:2
                           lowerCodiagonals:1];
    
    double solutionValuesWithExtraUpper[25] = {
        10.0,  1.0,   -1.0,   0.0,   0.0,
        5.0,   20.0,  2.0,    -2.0,  0.0,
        0.0,   6.0,   30.0,   3.0,   -3.0,
        0.0,   0.0,   7.0,    40.0,  4.0,
        0.0,   0.0,   0.0,    8.0,   50.0
    };
    solution = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:solutionValuesWithExtraUpper size:25]
                                     rows:5
                                  columns:5
                         leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 5; row += 1) {
        for (int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col], [solution valueAtRow:row column:col], @"Incorrect value at %u, %u in constructed band matrix with extra upper codiagonal.", row, col);
        }
    }
    
    // extra lower codiagonal
    double bandValuesWithExtraLower[20] = {
        0.0,  1.0,  2.0,  3.0,  4.0,
        10.0, 20.0, 30.0, 40.0, 50.0,
        5.0,  6.0,  7.0,  8.0,  0.0,
        -1.0, -2.0, -3.0, 0.0,  0.0
    };
    matrix = [MCMatrix bandMatrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:bandValuesWithExtraLower size:20]
                                      order:5
                           upperCodiagonals:1
                           lowerCodiagonals:2];

    double solutionValuesWithExtraLower[25] = {
        10.0,  1.0,   0.0,   0.0,   0.0,
        5.0,   20.0,  2.0,   0.0,   0.0,
        -1.0,   6.0,   30.0,  3.0,   0.0,
        0.0,   -2.0,   7.0,   40.0,  4.0,
        0.0,   0.0,   -3.0,   8.0,   50.0
    };
    solution = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:solutionValuesWithExtraLower size:25]
                                     rows:5
                                  columns:5
                         leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 5; row += 1) {
        for (int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col], [solution valueAtRow:row column:col], @"Incorrect value at %u, %u in constructed band matrix with extra lower codiagonal.", row, col);
        }
    }
    
    // two upper, no lower
    double bandValuesWithTwoUpper[15] = {
        0.0,  0.0,  -1.0, -2.0, -3.0,
        0.0,  1.0,  2.0,  3.0,  4.0,
        10.0, 20.0, 30.0, 40.0, 50.0
    };
    matrix = [MCMatrix bandMatrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:bandValuesWithTwoUpper size:15]
                                      order:5
                           upperCodiagonals:2
                           lowerCodiagonals:0];
    
    double solutionValuesWithTwoUpper[25] = {
        10.0,  1.0,   -1.0,   0.0,   0.0,
        0.0,   20.0,  2.0,    -2.0,  0.0,
        0.0,   0.0,   30.0,   3.0,   -3.0,
        0.0,   0.0,   0.0,    40.0,  4.0,
        0.0,   0.0,   0.0,    0.0,   50.0
    };
    solution = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:solutionValuesWithTwoUpper size:25]
                                     rows:5
                                  columns:5
                         leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 5; row += 1) {
        for (int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col], [solution valueAtRow:row column:col], @"Incorrect value at %u, %u in constructed band matrix with extra lower codiagonal.", row, col);
        }
    }
    
    // two lower, no upper
    double bandValuesWithTwoLower[15] = {
        10.0, 20.0, 30.0, 40.0, 50.0,
        5.0,  6.0,  7.0,  8.0,  0.0,
        -1.0, -2.0, -3.0, 0.0,  0.0
    };
    matrix = [MCMatrix bandMatrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:bandValuesWithTwoLower size:15]
                                      order:5
                           upperCodiagonals:0
                           lowerCodiagonals:2];
    
    double solutionValuesWithTwoLower[25] = {
        10.0,  0.0,   0.0,   0.0,   0.0,
        5.0,   20.0,  0.0,   0.0,   0.0,
        -1.0,  6.0,   30.0,  0.0,   0.0,
        0.0,   -2.0,  7.0,   40.0,  0.0,
        0.0,   0.0,   -3.0,  8.0,   50.0
    };
    solution = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:solutionValuesWithTwoLower size:25]
                                     rows:5
                                  columns:5
                         leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 5; row += 1) {
        for (int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col], [solution valueAtRow:row column:col], @"Incorrect value at %u, %u in constructed band matrix with extra lower codiagonal.", row, col);
        }
    }
}

- (void)testMatrixCreationFromVectors
{
    MCVector *v1 = [MCVector vectorWithValuesInArray:@[@1, @2, @3]];
    MCVector *v2 = [MCVector vectorWithValuesInArray:@[@4, @5, @6]];
    MCVector *v3 = [MCVector vectorWithValuesInArray:@[@7, @8, @9]];
    
    /* create the matrix
     [ 1  4  7
     2  5  8
     3  6  9 ]
     */
    MCMatrix *a = [MCMatrix matrixWithColumnVectors:@[v1, v2, v3]];
    
    /* create the matrix
     [ 1  2  3
     4  5  6
     7  8  9 ]
     */
    MCMatrix *b = [MCMatrix matrixWithRowVectors:@[v1, v2, v3]];
}

@end

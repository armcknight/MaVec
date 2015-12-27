//
//  MAVMatrixConstructionTests.m
//  MaVec
//
//  Created by Andrew McKnight on 3/8/14.
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

#import <XCTest/XCTest.h>

@interface MAVMatrixConstructionTests : XCTestCase

@end

@implementation MAVMatrixConstructionTests

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
    size_t size = 4 * sizeof(double);
    double *diagonalValues = malloc(size);
    diagonalValues[0] = 1.0;
    diagonalValues[1] = 2.0;
    diagonalValues[2] = 3.0;
    diagonalValues[3] = 4.0;
    MAVMatrix *diagonal = [MAVMatrix diagonalMatrixWithValues:[NSData dataWithBytes:diagonalValues length:size] order:4];
    
    size = 16 * sizeof(double);
    double *solution = malloc(size);
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
    MAVMatrix *s = [MAVMatrix matrixWithValues:[NSData dataWithBytes:solution length:size] rows:4 columns:4];
    
    for (unsigned int i = 0; i < 4; i++) {
        for (unsigned int j = 0; j < 4; j++) {
            XCTAssertEqual([diagonal valueAtRow:i column:j].doubleValue, [s valueAtRow:i column:j].doubleValue, @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testIdentityMatrixCreation
{
    MAVMatrix *identity = [MAVMatrix identityMatrixOfOrder:4 precision:MCKPrecisionDouble];
    
    size_t size = 16 * sizeof(double);
    double *solution = malloc(size);
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
    MAVMatrix *s = [MAVMatrix matrixWithValues:[NSData dataWithBytes:solution length:size] rows:4 columns:4];
    
    for (unsigned int i = 0; i < 4; i++) {
        for (unsigned int j = 0; j < 4; j++) {
            XCTAssertEqual([identity valueAtRow:i column:j].doubleValue, [s valueAtRow:i column:j].doubleValue, @"Value at row %u and column %u incorrect", i, j);
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
    MAVMatrix *solutionMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:solutionValues length:9*sizeof(double)] rows:3 columns:3];
    
    // packed row-major upper triangular
    double rowMajorPackedUpperValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    MAVMatrix *matrix = [MAVMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:rowMajorPackedUpperValues length:6*sizeof(double)]
                                             triangularComponent:MAVMatrixTriangularComponentUpper
                                                leadingDimension:MAVMatrixLeadingDimensionRow
                                                           order:3];
    XCTAssert(matrix.isSymmetric, @"Packed row-major symmetric matrix constructed incorrectly.");
    for (unsigned int i = 0; i < 3; i++) {
        for (unsigned int j = 0; j < 3; j++) {
            XCTAssertEqual([solutionMatrix valueAtRow:i column:j].doubleValue, [matrix valueAtRow:i column:j].doubleValue, @"Value at %u, %u incorrect.", i, j);
        }
    }
    
    // packed row-major lower triangular
    double rowMajorPackedLowerValues[6] = {
        1.0,
        2.0, 5.0,
        3.0, 7.0, 12.0
    };
    matrix = [MAVMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:rowMajorPackedLowerValues length:6*sizeof(double)]
                                   triangularComponent:MAVMatrixTriangularComponentLower
                                      leadingDimension:MAVMatrixLeadingDimensionRow
                                                 order:3];
    XCTAssert(matrix.isSymmetric, @"Packed row-major symmetric matrix constructed incorrectly.");
    for (unsigned int i = 0; i < 3; i++) {
        for (unsigned int j = 0; j < 3; j++) {
            XCTAssertEqual([solutionMatrix valueAtRow:i column:j].doubleValue, [matrix valueAtRow:i column:j].doubleValue, @"Value at %u, %u incorrect.", i, j);
        }
    }
    
    // packed column-major lower triangular
    double columnMajorPackedLowerValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    matrix = [MAVMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:columnMajorPackedLowerValues length:6*sizeof(double)]
                                   triangularComponent:MAVMatrixTriangularComponentLower
                                      leadingDimension:MAVMatrixLeadingDimensionColumn
                                                 order:3];
    XCTAssert(matrix.isSymmetric, @"Packed column-major symmetric matrix constructed incorrectly.");
    for (unsigned int i = 0; i < 3; i++) {
        for (unsigned int j = 0; j < 3; j++) {
            XCTAssertEqual([solutionMatrix valueAtRow:i column:j].doubleValue, [matrix valueAtRow:i column:j].doubleValue, @"Value at %u, %u incorrect.", i, j);
        }
    }
    
    // packed column-major upper triangular
    double columnMajorPackedUpperValues[6] = {
        1.0,
        2.0, 5.0,
        3.0, 7.0, 12.0
    };
    matrix = [MAVMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:columnMajorPackedUpperValues length:6*sizeof(double)]
                                   triangularComponent:MAVMatrixTriangularComponentUpper
                                      leadingDimension:MAVMatrixLeadingDimensionColumn
                                                 order:3];
    XCTAssert(matrix.isSymmetric, @"Packed column-major symmetric matrix constructed incorrectly.");
    for (unsigned int i = 0; i < 3; i++) {
        for (unsigned int j = 0; j < 3; j++) {
            XCTAssertEqual([solutionMatrix valueAtRow:i column:j].doubleValue, [matrix valueAtRow:i column:j].doubleValue, @"Value at %u, %u incorrect.", i, j);
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
    MAVMatrix *upperSolution = [MAVMatrix matrixWithValues:[NSData dataWithBytes:upperSolutionValues length:9*sizeof(double)]
                                                    rows:3
                                                 columns:3
                                        leadingDimension:MAVMatrixLeadingDimensionRow];
    
    // upper row-major
    double rowMajorUpperValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    MAVMatrix *matrix = [MAVMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:rowMajorUpperValues length:6*sizeof(double)]
                                            ofTriangularComponent:MAVMatrixTriangularComponentUpper
                                                 leadingDimension:MAVMatrixLeadingDimensionRow
                                                            order:3];
    XCTAssert([matrix isEqualToMatrix:upperSolution], @"Upper triangular row major matrix incorrectly created.");
    
    // upper column-major
    double columnMajorUpperValues[6] = {
        1.0, 2.0, 5.0,
        3.0, 7.0,
        12.0
    };
    matrix = [MAVMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:columnMajorUpperValues length:6*sizeof(double)]
                                  ofTriangularComponent:MAVMatrixTriangularComponentUpper
                                       leadingDimension:MAVMatrixLeadingDimensionColumn
                                                  order:3];
    XCTAssert([matrix isEqualToMatrix:upperSolution], @"Upper triangular column major matrix incorrectly created.");
    
    double lowerSolutionValues[9] = {
        1.0,   0.0,   0.0,
        2.0,   5.0,   0.0,
        3.0,   7.0,   12.0
    };
    MAVMatrix *lowerSolution = [MAVMatrix matrixWithValues:[NSData dataWithBytes:lowerSolutionValues length:9*sizeof(double)]
                                                    rows:3
                                                 columns:3
                                        leadingDimension:MAVMatrixLeadingDimensionRow];
    
    // lower row-major
    double rowMajorLowerValues[6] = {
        1.0, 2.0, 5.0,
        3.0, 7.0,
        12.0
    };
    matrix = [MAVMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:rowMajorLowerValues length:6*sizeof(double)]
                                  ofTriangularComponent:MAVMatrixTriangularComponentLower
                                       leadingDimension:MAVMatrixLeadingDimensionRow
                                                  order:3];
    XCTAssert([matrix isEqualToMatrix:lowerSolution], @"Lower triangular row major matrix incorrectly created.");
    
    // lower column-major
    double columnMajorLowerValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    matrix = [MAVMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:columnMajorLowerValues length:6*sizeof(double)]
                                  ofTriangularComponent:MAVMatrixTriangularComponentLower
                                       leadingDimension:MAVMatrixLeadingDimensionColumn
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
    MAVMatrix *matrix = [MAVMatrix bandMatrixWithValues:[NSData dataWithBytes:balancedBandValues length:15*sizeof(double)]
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
    MAVMatrix *solution = [MAVMatrix matrixWithValues:[NSData dataWithBytes:oddBandwidthSolutionValues length:25*sizeof(double)]
                                               rows:5
                                            columns:5
                                   leadingDimension:MAVMatrixLeadingDimensionRow];
    
    for (unsigned int row = 0; row < 5; row += 1) {
        for (unsigned int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col].doubleValue, [solution valueAtRow:row column:col].doubleValue, @"Incorrect value at %u, %u in constructed band matrix with balanced codiagonals.", row, col);
        }
    }
    
    // extra upper codiagonal
    double bandValuesWithExtraUpper[20] = {
        0.0,  0.0,  -1.0, -2.0, -3.0,
        0.0,  1.0,  2.0,  3.0,  4.0,
        10.0, 20.0, 30.0, 40.0, 50.0,
        5.0,  6.0,  7.0,  8.0,  0.0
    };
    matrix = [MAVMatrix bandMatrixWithValues:[NSData dataWithBytes:bandValuesWithExtraUpper length:20*sizeof(double)]
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
    solution = [MAVMatrix matrixWithValues:[NSData dataWithBytes:solutionValuesWithExtraUpper length:25*sizeof(double)]
                                     rows:5
                                  columns:5
                         leadingDimension:MAVMatrixLeadingDimensionRow];
    
    for (unsigned int row = 0; row < 5; row += 1) {
        for (unsigned int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col].doubleValue, [solution valueAtRow:row column:col].doubleValue, @"Incorrect value at %u, %u in constructed band matrix with extra upper codiagonal.", row, col);
        }
    }
    
    // extra lower codiagonal
    double bandValuesWithExtraLower[20] = {
        0.0,  1.0,  2.0,  3.0,  4.0,
        10.0, 20.0, 30.0, 40.0, 50.0,
        5.0,  6.0,  7.0,  8.0,  0.0,
        -1.0, -2.0, -3.0, 0.0,  0.0
    };
    matrix = [MAVMatrix bandMatrixWithValues:[NSData dataWithBytes:bandValuesWithExtraLower length:20*sizeof(double)]
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
    solution = [MAVMatrix matrixWithValues:[NSData dataWithBytes:solutionValuesWithExtraLower length:25*sizeof(double)]
                                     rows:5
                                  columns:5
                         leadingDimension:MAVMatrixLeadingDimensionRow];
    
    for (unsigned int row = 0; row < 5; row += 1) {
        for (unsigned int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col].doubleValue, [solution valueAtRow:row column:col].doubleValue, @"Incorrect value at %u, %u in constructed band matrix with extra lower codiagonal.", row, col);
        }
    }
    
    // two upper, no lower
    double bandValuesWithTwoUpper[15] = {
        0.0,  0.0,  -1.0, -2.0, -3.0,
        0.0,  1.0,  2.0,  3.0,  4.0,
        10.0, 20.0, 30.0, 40.0, 50.0
    };
    matrix = [MAVMatrix bandMatrixWithValues:[NSData dataWithBytes:bandValuesWithTwoUpper length:15*sizeof(double)]
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
    solution = [MAVMatrix matrixWithValues:[NSData dataWithBytes:solutionValuesWithTwoUpper length:25*sizeof(double)]
                                     rows:5
                                  columns:5
                         leadingDimension:MAVMatrixLeadingDimensionRow];
    
    for (unsigned int row = 0; row < 5; row += 1) {
        for (unsigned int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col].doubleValue, [solution valueAtRow:row column:col].doubleValue, @"Incorrect value at %u, %u in constructed band matrix with extra lower codiagonal.", row, col);
        }
    }
    
    // two lower, no upper
    double bandValuesWithTwoLower[15] = {
        10.0, 20.0, 30.0, 40.0, 50.0,
        5.0,  6.0,  7.0,  8.0,  0.0,
        -1.0, -2.0, -3.0, 0.0,  0.0
    };
    matrix = [MAVMatrix bandMatrixWithValues:[NSData dataWithBytes:bandValuesWithTwoLower length:15*sizeof(double)]
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
    solution = [MAVMatrix matrixWithValues:[NSData dataWithBytes:solutionValuesWithTwoLower length:25*sizeof(double)]
                                     rows:5
                                  columns:5
                         leadingDimension:MAVMatrixLeadingDimensionRow];
    
    for (unsigned int row = 0; row < 5; row += 1) {
        for (unsigned int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col].doubleValue, [solution valueAtRow:row column:col].doubleValue, @"Incorrect value at %u, %u in constructed band matrix with extra lower codiagonal.", row, col);
        }
    }
}

- (void)testMatrixCreationFromVectors
{
    MAVVector *v1 = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0]];
    MAVVector *v2 = [MAVVector vectorWithValuesInArray:@[@4.0, @5.0, @6.0]];
    MAVVector *v3 = [MAVVector vectorWithValuesInArray:@[@7.0, @8.0, @9.0]];
    
    /* create the matrix
     [ 1  4  7
     2  5  8
     3  6  9 ]
     */
    MAVMatrix *a = [MAVMatrix matrixWithColumnVectors:@[v1, v2, v3]];
    for (MAVIndex i = 0; i < 3; i++) {
        for (MAVIndex j = 0; j < 3; j++) {
            MAVVector *vector = j == 0 ? v1 : j == 1 ? v2 : v3;
            XCTAssertEqual(a[i][j].doubleValue, vector[i].doubleValue, @"Value incorrect at [%ldd][%ld]", i, j);
        }
    }
    
    /* create the matrix
     [ 1  2  3
     4  5  6
     7  8  9 ]
     */
    MAVMatrix *b = [MAVMatrix matrixWithRowVectors:@[v1, v2, v3]];
    for (MAVIndex i = 0; i < 3; i++) {
        MAVVector *vector = i == 0 ? v1 : i == 1 ? v2 : v3;
        for (MAVIndex j = 0; j < 3; j++) {
            XCTAssertEqual(b[i][j].doubleValue, vector[j].doubleValue, @"Value incorrect at [%ld][%ld]", i, j);
        }
    }
}

- (void)testRandomDefiniteMatrices
{
    int numberOfTests = 97;
    
    int positiveDefiniteFails = 0;
    int negativeDefiniteFails = 0;
    int positiveSemidefiniteFails = 0;
    int negativeSemidefiniteFails = 0;
    int indefiniteFails = 0;
    
    MAVMatrix *test;
    
    int order = 3;
    for(int i = 0; i < numberOfTests; i++) {
        MAVMatrix *positiveDefinite = [MAVMatrix randomMatrixOfOrder:order definiteness:MAVMatrixDefinitenessPositiveDefinite precision:MCKPrecisionDouble];
        test = [MAVMatrix matrixWithValues:[positiveDefinite valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn] rows:order columns:order];
        if (test.definiteness != MAVMatrixDefinitenessPositiveDefinite) {
            positiveDefiniteFails++;
        }
        
        MAVMatrix *negativeDefinite = [MAVMatrix randomMatrixOfOrder:order definiteness:MAVMatrixDefinitenessNegativeDefinite precision:MCKPrecisionDouble];
        test = [MAVMatrix matrixWithValues:[negativeDefinite valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn] rows:order columns:order];
        if (test.definiteness != MAVMatrixDefinitenessNegativeDefinite) {
            negativeDefiniteFails++;
        }
        
        MAVMatrix *positiveSemidefinite = [MAVMatrix randomMatrixOfOrder:order definiteness:MAVMatrixDefinitenessPositiveSemidefinite precision:MCKPrecisionDouble];
        test = [MAVMatrix matrixWithValues:[positiveSemidefinite valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn] rows:order columns:order];
        if (test.definiteness != MAVMatrixDefinitenessPositiveSemidefinite) {
            positiveSemidefiniteFails++;
        }
        
        MAVMatrix *negativeSemidefinite = [MAVMatrix randomMatrixOfOrder:order definiteness:MAVMatrixDefinitenessNegativeSemidefinite precision:MCKPrecisionDouble];
        test = [MAVMatrix matrixWithValues:[negativeSemidefinite valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn] rows:order columns:order];
        if (test.definiteness != MAVMatrixDefinitenessNegativeSemidefinite) {
            negativeSemidefiniteFails++;
        }
        
        MAVMatrix *indefinite = [MAVMatrix randomMatrixOfOrder:order definiteness:MAVMatrixDefinitenessIndefinite precision:MCKPrecisionDouble];
        test = [MAVMatrix matrixWithValues:[indefinite valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn] rows:order columns:order];
        if (test.definiteness != MAVMatrixDefinitenessIndefinite) {
            indefiniteFails++;
        }
        
        order++;
    }
    
    XCTAssert(positiveDefiniteFails == 0, @"%i positive definite failures", positiveDefiniteFails);
    XCTAssert(negativeDefiniteFails == 0, @"%i negative definite failures", negativeDefiniteFails);
    XCTAssert(positiveSemidefiniteFails == 0, @"%i positive semidefinite failures", positiveSemidefiniteFails);
    XCTAssert(negativeSemidefiniteFails == 0, @"%i negative semidefinite failures", negativeSemidefiniteFails);
    XCTAssert(indefiniteFails == 0, @"%i indefinite failures", indefiniteFails);
}

- (void)testRandomSingularMatrices
{
    int numberOfTests = 5;
    
    int singularFails = 0;
    
    int order = 3;
    for(int i = 0; i < numberOfTests; i++) {
        MAVMatrix *singular = [MAVMatrix randomSingularMatrixOfOrder:order precision:MCKPrecisionDouble];
        if ([singular.determinant compare:@0.0] != NSOrderedSame) {
            singularFails++;
            NSLog(@"randomSingularMatrixOfOrder returned %@", singular);
        }
        order++;
    }
    
    XCTAssert(singularFails == 0, @"%i singular failures", singularFails);
}

- (void)testRandomNonsingularMatrices
{
    int numberOfTests = 5;
    
    int nonsingularFails = 0;
    
    int order = 3;
    for(int i = 0; i < numberOfTests; i++) {
        MAVMatrix *nonsingular = [MAVMatrix randomNonsigularMatrixOfOrder:order precision:MCKPrecisionDouble];
        if ([nonsingular.determinant compare:@0.0] == NSOrderedSame) {
            nonsingularFails++;
            NSLog(@"randomNonsigularMatrixOfOrder returned %@", nonsingular);
        }
        order++;
    }
    
    XCTAssert(nonsingularFails == 0, @"%i nonsingular failures", nonsingularFails);
}

- (void)testGeneralMatrixFilledWithValue {
    // double precision
    NSNumber *value = [NSNumber mck_randomDouble];
    MAVIndex rows = 5;
    MAVIndex columns = 5;
    MAVMatrix *generalMatrix = [MAVMatrix matrixFilledWithValue:value
                                                           rows:rows
                                                        columns:columns];
    for (MAVIndex column = 0; column < columns; column++) {
        for (MAVIndex row = 0; row < rows; row++) {
            XCTAssert([value isEqualToNumber:generalMatrix[row][column]], @"A different double value was retrieved from the matrix than the one the matrix was filled with.");
        }
    }

    // single-precision
    value = [NSNumber mck_randomFloat];
    generalMatrix = [MAVMatrix matrixFilledWithValue:value
                                                rows:rows
                                             columns:columns];
    for (MAVIndex column = 0; column < columns; column++) {
        for (MAVIndex row = 0; row < rows; row++) {
            XCTAssert([value isEqualToNumber:generalMatrix[row][column]], @"A different float value was retrieved from the matrix than the one the matrix was filled with.");
        }
    }
}

- (void)testTriangularMatrixFilledWithValue {
    // double-precision lower triangular
    NSNumber *value = [NSNumber mck_randomDouble];
    MAVIndex order = 5;
    MAVMatrix *triangularMatrix = [MAVMatrix triangularMatrixFilledWithValue:value
                                                                       order:order
                                                         triangularComponent:MAVMatrixTriangularComponentLower];
    for (MAVIndex column = 0; column < order; column++) {
        for (MAVIndex row = 0; row < order; row++) {
            if (row >= column) {
                XCTAssert([value isEqualToNumber:triangularMatrix[row][column]], @"A different double value was retrieved from the matrix than the one the matrix' lower triangular component was filled with.");
            } else {
                XCTAssert([@0 isEqualToNumber:triangularMatrix[row][column]], @"The upper part of the double-precision lower triangular matrix did not contain a 0.");
            }
        }
    }

    // single-precision lower triangular
    value = [NSNumber mck_randomFloat];
    triangularMatrix = [MAVMatrix triangularMatrixFilledWithValue:value
                                                            order:order
                                              triangularComponent:MAVMatrixTriangularComponentLower];
    for (MAVIndex column = 0; column < order; column++) {
        for (MAVIndex row = 0; row < order; row++) {
            if (row >= column) {
                XCTAssert([value isEqualToNumber:triangularMatrix[row][column]], @"A different float value was retrieved from the matrix than the one the matrix' lower triangular component was filled with.");
            } else {
                XCTAssert([@0 isEqualToNumber:triangularMatrix[row][column]], @"The upper part of the single-precision lower triangular matrix did not contain a 0.");
            }
        }
    }

    // double-precision lower triangular
    value = [NSNumber mck_randomDouble];
    triangularMatrix = [MAVMatrix triangularMatrixFilledWithValue:value
                                                            order:order
                                              triangularComponent:MAVMatrixTriangularComponentUpper];
    for (MAVIndex column = 0; column < order; column++) {
        for (MAVIndex row = 0; row < order; row++) {
            if (row <= column) {
                XCTAssert([value isEqualToNumber:triangularMatrix[row][column]], @"A different double value was retrieved from the matrix than the one the matrix' upper triangular component was filled with.");
            } else {
                XCTAssert([@0 isEqualToNumber:triangularMatrix[row][column]], @"The lower part of the double-precision upper triangular matrix did not contain a 0.");
            }
        }
    }

    // single-precision lower triangular
    value = [NSNumber mck_randomFloat];
    triangularMatrix = [MAVMatrix triangularMatrixFilledWithValue:value
                                                            order:order
                                              triangularComponent:MAVMatrixTriangularComponentUpper];
    for (MAVIndex column = 0; column < order; column++) {
        for (MAVIndex row = 0; row < order; row++) {
            if (row <= column) {
                XCTAssert([value isEqualToNumber:triangularMatrix[row][column]], @"A different float value was retrieved from the matrix than the one the matrix' upper triangular component was filled with.");
            } else {
                XCTAssert([@0 isEqualToNumber:triangularMatrix[row][column]], @"The lower part of the single-precision upper triangular matrix did not contain a 0.");
            }
        }
    }
}

- (void)testBandMatrixFilledWithValue {
    // double-precision diagonal
    [NSNumber mck_randomDouble];
    NSNumber *value = [NSNumber mck_randomDouble];
    MAVIndex order = 5;
    MAVMatrix *bandMatrix = [MAVMatrix bandMatrixFilledWithValue:value
                                                           order:order
                                                upperCodiagonals:0
                                                lowerCodiagonals:0];
    for (MAVIndex column = 0; column < order; column++) {
        for (MAVIndex row = 0; row < order; row++) {
            if (row == column) {
                NSNumber *retrieved = bandMatrix[row][column];
                XCTAssert([value isEqualToNumber:retrieved], @"A different double value was retrieved from the matrix than the one the matrix' diagonal was filled with.");
            } else {
                XCTAssert([@0 isEqualToNumber:bandMatrix[row][column]], @"The region outside of the double-precision diagonal matrix did not contain a 0.");
            }
        }
    }

    // single-precision diagonal
    value = [NSNumber mck_randomFloat];
    bandMatrix = [MAVMatrix bandMatrixFilledWithValue:value
                                                order:order
                                     upperCodiagonals:0
                                     lowerCodiagonals:0];
    for (MAVIndex column = 0; column < order; column++) {
        for (MAVIndex row = 0; row < order; row++) {
            if (row == column) {
                XCTAssert([value isEqualToNumber:bandMatrix[row][column]], @"A different float value was retrieved from the matrix than the one the matrix' diagonal was filled with.");
            } else {
                XCTAssert([@0 isEqualToNumber:bandMatrix[row][column]], @"The region outside of the single-precision diagonal matrix did not contain a 0.");
            }
        }
    }

    // double-precision top-only
    double topOnlyDoublePrecisionSolution[25] = {
        1.0, 1.0, 1.0, 0.0, 0.0,
        0.0, 1.0, 1.0, 1.0, 0.0,
        0.0, 0.0, 1.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 0.0, 1.0
    };
    MAVMatrix *solutionMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:topOnlyDoublePrecisionSolution length:25 * sizeof(double)]
                                                       rows:5
                                                    columns:5
                                           leadingDimension:MAVMatrixLeadingDimensionRow];
    bandMatrix = [MAVMatrix bandMatrixFilledWithValue:@1.0
                                                order:order
                                     upperCodiagonals:2
                                     lowerCodiagonals:0];
    XCTAssert([solutionMatrix isEqualToMatrix:bandMatrix], @"Band matrix filled with values was not constructed correctly.");

    // single-precision top-heavy
    float topOnlySinglePrecisionSolution[25] = {
        1.0f, 1.0f, 1.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 1.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 1.0f, 1.0f, 1.0f,
        0.0f, 0.0f, 0.0f, 1.0f, 1.0f,
        0.0f, 0.0f, 0.0f, 0.0f, 1.0f
    };
    solutionMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:topOnlySinglePrecisionSolution length:25 * sizeof(float)]
                                            rows:5
                                         columns:5
                                leadingDimension:MAVMatrixLeadingDimensionRow];
    bandMatrix = [MAVMatrix bandMatrixFilledWithValue:@1.0f
                                                order:order
                                     upperCodiagonals:2
                                     lowerCodiagonals:0];
    XCTAssert([solutionMatrix isEqualToMatrix:bandMatrix], @"Band matrix filled with values was not constructed correctly.");

    // double-precision bottom-only
    double bottomOnlyDoublePrecisionSolution[25] = {
        1.0, 0.0, 0.0, 0.0, 0.0,
        1.0, 1.0, 0.0, 0.0, 0.0,
        1.0, 1.0, 1.0, 0.0, 0.0,
        0.0, 1.0, 1.0, 1.0, 0.0,
        0.0, 0.0, 1.0, 1.0, 1.0
    };
    solutionMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:bottomOnlyDoublePrecisionSolution length:25 * sizeof(double)]
                                            rows:5
                                         columns:5
                                leadingDimension:MAVMatrixLeadingDimensionRow];
    bandMatrix = [MAVMatrix bandMatrixFilledWithValue:@1.0
                                                order:order
                                     upperCodiagonals:0
                                     lowerCodiagonals:2];
    XCTAssert([solutionMatrix isEqualToMatrix:bandMatrix], @"Band matrix filled with values was not constructed correctly.");

    // single-precision bottom-only
    float bottomOnlySinglePrecisionSolution[25] = {
        1.0f, 0.0f, 0.0f, 0.0f, 0.0f,
        1.0f, 1.0f, 0.0f, 0.0f, 0.0f,
        1.0f, 1.0f, 1.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 1.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 1.0f, 1.0f, 1.0f
    };
    solutionMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:bottomOnlySinglePrecisionSolution length:25 * sizeof(float)]
                                            rows:5
                                         columns:5
                                leadingDimension:MAVMatrixLeadingDimensionRow];
    bandMatrix = [MAVMatrix bandMatrixFilledWithValue:@1.0f
                                                order:order
                                     upperCodiagonals:0
                                     lowerCodiagonals:2];
    XCTAssert([solutionMatrix isEqualToMatrix:bandMatrix], @"Band matrix filled with values was not constructed correctly.");

    // double-precision bottom-heavy
    double bottomHeavyDoublePrecisionSolution[25] = {
        1.0, 1.0, 0.0, 0.0, 0.0,
        1.0, 1.0, 1.0, 0.0, 0.0,
        1.0, 1.0, 1.0, 1.0, 0.0,
        0.0, 1.0, 1.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0, 1.0
    };
    solutionMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:bottomHeavyDoublePrecisionSolution length:25 * sizeof(double)]
                                            rows:5
                                         columns:5
                                leadingDimension:MAVMatrixLeadingDimensionRow];
    bandMatrix = [MAVMatrix bandMatrixFilledWithValue:@1.0
                                                order:order
                                     upperCodiagonals:1
                                     lowerCodiagonals:2];
    XCTAssert([solutionMatrix isEqualToMatrix:bandMatrix], @"Band matrix filled with values was not constructed correctly.");

    // single-precision bottom-heavy
    float bottomHeavySinglePrecisionSolution[25] = {
        1.0f, 1.0f, 0.0f, 0.0f, 0.0f,
        1.0f, 1.0f, 1.0f, 0.0f, 0.0f,
        1.0f, 1.0f, 1.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 1.0f, 1.0f, 1.0f,
        0.0f, 0.0f, 1.0f, 1.0f, 1.0f
    };
    solutionMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:bottomHeavySinglePrecisionSolution length:25 * sizeof(float)]
                                            rows:5
                                         columns:5
                                leadingDimension:MAVMatrixLeadingDimensionRow];
    bandMatrix = [MAVMatrix bandMatrixFilledWithValue:@1.0f
                                                order:order
                                     upperCodiagonals:1
                                     lowerCodiagonals:2];
    XCTAssert([solutionMatrix isEqualToMatrix:bandMatrix], @"Band matrix filled with values was not constructed correctly.");

    // double-precision top-heavy
    double topHeavyDoublePrecisionSolution[25] = {
        1.0, 1.0, 1.0, 0.0, 0.0,
        1.0, 1.0, 1.0, 1.0, 0.0,
        0.0, 1.0, 1.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0, 1.0
    };
    solutionMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:topHeavyDoublePrecisionSolution length:25 * sizeof(double)]
                                            rows:5
                                         columns:5
                                leadingDimension:MAVMatrixLeadingDimensionRow];
    bandMatrix = [MAVMatrix bandMatrixFilledWithValue:@1.0
                                                order:order
                                     upperCodiagonals:2
                                     lowerCodiagonals:1];
    XCTAssert([solutionMatrix isEqualToMatrix:bandMatrix], @"Band matrix filled with values was not constructed correctly.");

    // single-precision top-heavy
    float topHeavySinglePrecisionSolution[25] = {
        1.0f, 1.0f, 1.0f, 0.0f, 0.0f,
        1.0f, 1.0f, 1.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 1.0f, 1.0f, 1.0f,
        0.0f, 0.0f, 1.0f, 1.0f, 1.0f,
        0.0f, 0.0f, 0.0f, 1.0f, 1.0f
    };
    solutionMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:topHeavySinglePrecisionSolution length:25 * sizeof(float)]
                                            rows:5
                                         columns:5
                                leadingDimension:MAVMatrixLeadingDimensionRow];
    bandMatrix = [MAVMatrix bandMatrixFilledWithValue:@1.0f
                                                order:order
                                     upperCodiagonals:2
                                     lowerCodiagonals:1];
    XCTAssert([solutionMatrix isEqualToMatrix:bandMatrix], @"Band matrix filled with values was not constructed correctly.");
}

@end

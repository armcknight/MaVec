//
//  MCMatrixTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 2/16/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//
//  Many tests were created and validated using
//  https://www.wolframalpha.com/examples/Matrices.html and
//  http://www.arndt-bruenner.de/mathe/scripts/engl_eigenwert.htm
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"
#import "MCVector.h"
#import "MCSingularValueDecomposition.h"
#import "MCLUFactorization.h"
#import "MCTribool.h"
#import "MCEigendecomposition.h"
#import "MCQRFactorization.h"

@interface MCMatrixTests : XCTestCase

@end

@implementation MCMatrixTests

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

- (void)testMultiplySquareMatrices
{
    double *aVals = malloc(4 * sizeof(double));
    double *bVals = malloc(4 * sizeof(double));
    aVals[0] = 1.0;
    aVals[1] = 3.0;
    aVals[2] = 2.0;
    aVals[3] = 5.0;
    
    bVals[0] = 6.0;
    bVals[1] = 8.0;
    bVals[2] = 7.0;
    bVals[3] = 9.0;
    MCMatrix *a = [MCMatrix matrixWithValues:aVals rows:2 columns:2];
    MCMatrix *b = [MCMatrix matrixWithValues:bVals rows:2 columns:2];
    
    MCMatrix *p = [MCMatrix productOfMatrixA:a andMatrixB:b];
    
    double *solution = malloc(4 * sizeof(double));
    solution[0] = 22.0;
    solution[1] = 58.0;
    solution[2] = 25.0;
    solution[3] = 66.0;
    
    MCMatrix *s = [MCMatrix matrixWithValues:solution rows:2 columns:2];
    
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            XCTAssertEqual([p valueAtRow:i column:j], [s valueAtRow:i column:j], @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testMultiplyRectangularMatrices
{
    double *aVals = malloc(6 * sizeof(double));
    double *bVals = malloc(9 * sizeof(double));
    aVals[0] = 0.0;
    aVals[1] = 1.0;
    aVals[2] = 1.0;
    aVals[3] = 0.0;
    aVals[4] = -1.0;
    aVals[5] = 1.0;
    
    bVals[0] = 1.0;
    bVals[1] = 4.0;
    bVals[2] = 7.0;
    bVals[3] = 2.0;
    bVals[4] = 5.0;
    bVals[5] = 8.0;
    bVals[6] = 3.0;
    bVals[7] = 6.0;
    bVals[8] = 9.0;
    MCMatrix *a = [MCMatrix matrixWithValues:aVals rows:2 columns:3];
    MCMatrix *b = [MCMatrix matrixWithValues:bVals rows:3 columns:3];
    
    MCMatrix *p = [MCMatrix productOfMatrixA:a andMatrixB:b];
    
    double *solution = malloc(6 * sizeof(double));
    solution[0] = -3.0;
    solution[1] = 8.0;
    solution[2] = -3.0;
    solution[3] = 10.0;
    solution[4] = -3.0;
    solution[5] = 12.0;
    MCMatrix *s = [MCMatrix matrixWithValues:solution rows:2 columns:3];
    
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([p valueAtRow:i column:j], [s valueAtRow:i column:j], @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testFirstSVDTest
{
    // page 568 example 12.5 from Sauer
    double *values = malloc(6 * sizeof(double));
    values[0] = 0.0;
    values[1] = 3.0;
    values[2] = 0.0;
    values[3] = -0.5;
    values[4] = 0.0;
    values[5] = 0.0;
    MCMatrix *a = [MCMatrix matrixWithValues:values rows:3 columns:2];
    
    MCSingularValueDecomposition *svd = a.singularValueDecomposition;
    
    MCMatrix *intermediate = [MCMatrix productOfMatrixA:svd.u andMatrixB:svd.s];
    MCMatrix *original = [MCMatrix productOfMatrixA:intermediate andMatrixB:svd.vT];
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 2; j++) {
            XCTAssertEqualWithAccuracy([a valueAtRow:i column:j], [original valueAtRow:i column:j], __DBL_EPSILON__ * 10.0, @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testSecondSVDTest
{
    // page 574 example 12.9 from Sauer
    double *values = malloc(8 * sizeof(double));
    values[0] = 3.0;
    values[1] = 2.0;
    values[2] = 2.0;
    values[3] = 4.0;
    values[4] = -2.0;
    values[5] = -1.0;
    values[6] = -3.0;
    values[7] = -5.0;
    MCMatrix *a = [MCMatrix matrixWithValues:values rows:2 columns:4];
    
    MCSingularValueDecomposition *svd = a.singularValueDecomposition;
    
    MCMatrix *intermediate = [MCMatrix productOfMatrixA:svd.u andMatrixB:svd.s];
    MCMatrix *original = [MCMatrix productOfMatrixA:intermediate andMatrixB:svd.vT];
    
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 4; j++) {
            XCTAssertEqualWithAccuracy([a valueAtRow:i column:j], [original valueAtRow:i column:j], __DBL_EPSILON__ * 10.0, @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testOverdeterminedSystem
{
    double *aVals = malloc(6 * sizeof(double));
    double *bVals = malloc(3 * sizeof(double));
    aVals[0] = 1.0;
    aVals[1] = 1.0;
    aVals[2] = 1.0;
    aVals[3] = 1.0;
    aVals[4] = -1.0;
    aVals[5] = 1.0;
    
    bVals[0] = 2.0;
    bVals[1] = 1.0;
    bVals[2] = 3.0;
    MCMatrix *a = [MCMatrix matrixWithValues:aVals rows:3 columns:2];
    MCMatrix *b = [MCMatrix matrixWithValues:bVals rows:3 columns:1];
    
    MCMatrix *coefficients = [MCMatrix solveLinearSystemWithMatrixA:a valuesB:b];
    
    double *solution = malloc(2 * sizeof(double));
    solution[0] = 7.0 / 4.0;
    solution[1] = 3.0 / 4.0;
    MCMatrix *s = [MCMatrix matrixWithValues:solution rows:2 columns:1];
    
    for (int i = 0; i < 2; i++) {
        XCTAssertEqualWithAccuracy([s valueAtRow:i column:0], [coefficients valueAtRow:i column:0], __DBL_EPSILON__ * 10.0, @"Coefficient %u incorrect", i);
    }
}

- (void)testNormalSystemOfEquations
{
    double *aVals = malloc(16 * sizeof(double));
    double *bVals = malloc(4 * sizeof(double));
    aVals[0] = 8.0;
    aVals[1] = 0.0;
    aVals[2] = 0.0;
    aVals[3] = 0.0;
    aVals[4] = 0.0;
    aVals[5] = 4.0;
    aVals[6] = 0.0;
    aVals[7] = 0.0;
    aVals[8] = 0.0;
    aVals[9] = 0.0;
    aVals[10] = 4.0;
    aVals[11] = 0.0;
    aVals[12] = 0.0;
    aVals[13] = 0.0;
    aVals[14] = 0.0;
    aVals[15] = 4.0;
    
    bVals[0] = -15.6;
    bVals[1] = -2.9778;
    bVals[2] = -10.2376;
    bVals[3] = 4.5;
    MCMatrix *a = [MCMatrix matrixWithValues:aVals rows:4 columns:4];
    MCMatrix *b = [MCMatrix matrixWithValues:bVals rows:4 columns:1];
    
    MCMatrix *coefficients = [MCMatrix solveLinearSystemWithMatrixA:a valuesB:b];
    
    double *solution = malloc(4 * sizeof(double));
    solution[0] = -1.95;
    solution[1] = -0.7445;
    solution[2] = -2.5594;
    solution[3] = 1.125;
    MCMatrix *s = [MCMatrix matrixWithValues:solution rows:4 columns:1];
    
    for (int i = 0; i < 4; i++) {
        XCTAssertEqualWithAccuracy([s valueAtRow:i column:0], [coefficients valueAtRow:i column:0], 0.0005, @"Coefficient %u incorrect", i);
    }
}

- (void)testDiagonalMatrixCreation
{
    double *diagonalValues = malloc(4 * sizeof(double));
    diagonalValues[0] = 1.0;
    diagonalValues[1] = 2.0;
    diagonalValues[2] = 3.0;
    diagonalValues[3] = 4.0;
    MCMatrix *diagonal = [MCMatrix diagonalMatrixWithValues:diagonalValues size:4];
    
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
    MCMatrix *identity = [MCMatrix identityMatrixWithSize:4];
    
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
    MCMatrix *cr = c.copy;
    cr.leadingDimension = MCMatrixLeadingDimensionRow;
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
    
    MCMatrix *r = b.copy;
    r.leadingDimension = MCMatrixLeadingDimensionRow;
    XCTAssertEqual([a isEqual:r], YES, @"Couldn't tell two MCMatrix objects with identical values but different storage formats were equal using isEqual:");
    XCTAssertEqual([a isEqualToMatrix:r], YES, @"Couldn't tell two MCMatrix objects with identical values but different storage formats were equal using isEqualToMatrix:");
}

- (void)testMatrixDescription
{
    double *values = malloc(9 * sizeof(double));
    values[0] = 1.0;
    values[1] = 22.0;
    values[2] = 333.0;
    values[3] = 4444.0;
    values[4] = 55555.0;
    values[5] = 666666.0;
    values[6] = 7777777.0;
    values[7] = 88888888.0;
    values[8] = 999999999.0;
    MCMatrix *a = [MCMatrix diagonalMatrixWithValues:values size:9];
    NSLog(@"Column major");
    NSLog(@"");
    NSLog(a.description);
    NSLog(@"Row major");
    NSLog(@"");
    MCMatrix *b = a.copy;
    b.leadingDimension = MCMatrixLeadingDimensionRow;
    NSLog(b.description);
}

- (void)testLUDecompositionOfSquareMatrix1
{
    // pg 85 of Sauer
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
    
    MCMatrix *m = [MCMatrix matrixWithValues:values rows:3 columns:3];
    
    MCLUFactorization *f = m.luFactorization;
    
    //    MCMatrix *i = [MCMatrix productOfMatrixA:f.lowerTriangularMatrix andMatrixB:f.upperTriangularMatrix];
    //    MCMatrix *product = [MCMatrix productOfMatrixA:i andMatrixB:f.permutationMatrix];
    MCMatrix *pl = [MCMatrix productOfMatrixA:f.permutationMatrix andMatrixB:f.lowerTriangularMatrix];
    MCMatrix *product = [MCMatrix productOfMatrixA:pl andMatrixB:f.upperTriangularMatrix];
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            double a = [m valueAtRow:i column:j];
            double b = [product valueAtRow:i column:j];
            XCTAssertEqualWithAccuracy(a, b, 0.0000000000000003, @"Value at row %i and column %i was not recomputed correctly", i, j);
        }
    }
}

- (void)testLUDecompositionOfSquareMatrix2
{
    // pg 85 of Sauer
    double *values = malloc(4 * sizeof(double));
    values[0] = 1.0;
    values[1] = 3.0;
    values[2] = 1.0;
    values[3] = -4.0;
    
    MCMatrix *m = [MCMatrix matrixWithValues:values rows:2 columns:2];
    
    MCLUFactorization *f = m.luFactorization;
    
    MCMatrix *pl = [MCMatrix productOfMatrixA:f.permutationMatrix andMatrixB:f.lowerTriangularMatrix];
    MCMatrix *product = [MCMatrix productOfMatrixA:pl andMatrixB:f.upperTriangularMatrix];
    
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            double a = [m valueAtRow:i column:j];
            double b = [product valueAtRow:i column:j];
            XCTAssertEqualWithAccuracy(a, b, 0.0000000000000003, @"Value at row %i and column %i was not recomputed correctly", i, j);
        }
    }
}

- (void)testMinorCalculation
{
    /*
     1 2 3
     4 5 6
     7 8 9
     */
    double *values = malloc(9 * sizeof(double));
    values[0] = 1.0;
    values[1] = 2.0;
    values[2] = 3.0;
    values[3] = 4.0;
    values[4] = 5.0;
    values[5] = 6.0;
    values[6] = 7.0;
    values[7] = 8.0;
    values[8] = 9.0;
    MCMatrix *original = [MCMatrix matrixWithValues:values
                                               rows:3
                                            columns:3
                                 leadingDimension:MCMatrixLeadingDimensionRow];
    
    MCMatrix *minorMatrix = original.minorMatrix;
    
    double minorSolutionValues[9] = {
        -3.0, -6.0, -3.0,
        -6.0, -12.0, -6.0,
        -3.0, -6.0, -3.0
    };
    MCMatrix *minorSolutions = [MCMatrix matrixWithValues:minorSolutionValues
                                                     rows:3
                                                  columns:3
                                       leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 3; row += 1) {
        for (int col = 0; col < 3; col += 1) {
            double a = [minorMatrix valueAtRow:row column:col];
            double b = [minorSolutions valueAtRow:row column:col];
            XCTAssertEqual(a, b, @"Minor at (%u, %u) calculated incorrectly", row, col);
        }
    }
}

- (void)testCofactorCalculation
{
    double *values = malloc(9 * sizeof(double));
    values[0] = 1.0;
    values[1] = 2.0;
    values[2] = 3.0;
    values[3] = 4.0;
    values[4] = 5.0;
    values[5] = 6.0;
    values[6] = 7.0;
    values[7] = 8.0;
    values[8] = 9.0;
    MCMatrix *original = [MCMatrix matrixWithValues:values
                                               rows:3
                                            columns:3
                                 leadingDimension:MCMatrixLeadingDimensionRow];
    
    MCMatrix *cofactorMatrix = original.cofactorMatrix;
    
    double cofactorSolutionValues[9] = {
        -3.0, 6.0, -3.0,
        6.0, -12.0, 6.0,
        -3.0, 6.0, -3.0
    };
    MCMatrix *cofactorSolutions = [MCMatrix matrixWithValues:cofactorSolutionValues
                                                        rows:3
                                                     columns:3
                                          leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 3; row += 1) {
        for (int col = 0; col < 3; col += 1) {
            double a = [cofactorMatrix valueAtRow:row column:col];
            double b = [cofactorSolutions valueAtRow:row column:col];
            XCTAssertEqual(a, b, @"Cofactor at (%u, %u) calculated incorrectly", row, col);
        }
    }
}

- (void)testAdjugateCalculation
{
    // example from https://www.wolframalpha.com/input/?i=adjugate+%7B%7B8%2C7%2C7%7D%2C%7B6%2C9%2C2%7D%2C%7B-6%2C9%2C-2%7D%7D&lk=3
    double values[9] = {
        8.0, 7.0, 7.0,
        6.0, 9.0, 2.0,
        -6.0, 9.0, -2.0
    };
    MCMatrix *original = [MCMatrix matrixWithValues:values
                                               rows:3
                                            columns:3
                                 leadingDimension:MCMatrixLeadingDimensionRow];
    
    MCMatrix *adjugate = original.adjugate;
    
    double adjugateSolutionValues[9] = {
        -36.0, 77.0, -49.0,
        -0.0, 26.0, 26.0,
        108.0, -114.0, 30.0
    };
    MCMatrix *adjugateSolutions = [MCMatrix matrixWithValues:adjugateSolutionValues
                                                        rows:3
                                                     columns:3
                                          leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 3; row += 1) {
        for (int col = 0; col < 3; col += 1) {
            double a = [adjugate valueAtRow:row column:col];
            double b = [adjugateSolutions valueAtRow:row column:col];
            XCTAssertEqual(a, b, @"Adjugate value at (%u, %u) calculated incorrectly", row, col);
        }
    }
}

- (void)testMatrixAddition
{
    double *aValues = malloc(9 * sizeof(double));
    aValues[0] = 1.0;
    aValues[1] = 2.0;
    aValues[2] = 3.0;
    aValues[3] = 4.0;
    aValues[4] = 5.0;
    aValues[5] = 6.0;
    aValues[6] = 7.0;
    aValues[7] = 8.0;
    aValues[8] = 9.0;
    MCMatrix *a = [MCMatrix matrixWithValues:aValues rows:3 columns:3];
    
    double *bValues = malloc(9 * sizeof(double));
    bValues[0] = 9.0;
    bValues[1] = 8.0;
    bValues[2] = 7.0;
    bValues[3] = 6.0;
    bValues[4] = 5.0;
    bValues[5] = 4.0;
    bValues[6] = 3.0;
    bValues[7] = 2.0;
    bValues[8] = 1.0;
    MCMatrix *b = [MCMatrix matrixWithValues:bValues rows:3 columns:3];
    
    MCMatrix *sum = [MCMatrix sumOfMatrixA:a andMatrixB:b];
    
    for (int i = 0; i < 3; i++) {
        for (int j; j < 3; j++) {
            XCTAssertEqual(10.0, [sum valueAtRow:i column:j], @"Value at %u,%u incorrectly added", i, j);
        }
    }
    
    XCTAssertThrows([MCMatrix sumOfMatrixA:[MCMatrix matrixWithRows:4 columns:5]
                                andMatrixB:[MCMatrix matrixWithRows:5 columns:5]], @"Should throw an exception for mismatched row amount");
    XCTAssertThrows([MCMatrix sumOfMatrixA:[MCMatrix matrixWithRows:5 columns:4]
                                andMatrixB:[MCMatrix matrixWithRows:5 columns:5]], @"Should throw an exception for mismatched column amount");
}

- (void)testMatrixSubtraction
{
    double *aValues = malloc(9 * sizeof(double));
    aValues[0] = 10.0;
    aValues[1] = 10.0;
    aValues[2] = 10.0;
    aValues[3] = 10.0;
    aValues[4] = 10.0;
    aValues[5] = 10.0;
    aValues[6] = 10.0;
    aValues[7] = 10.0;
    aValues[8] = 10.0;
    MCMatrix *a = [MCMatrix matrixWithValues:aValues rows:3 columns:3];
    
    double *bValues = malloc(9 * sizeof(double));
    bValues[0] = 9.0;
    bValues[1] = 8.0;
    bValues[2] = 7.0;
    bValues[3] = 6.0;
    bValues[4] = 5.0;
    bValues[5] = 4.0;
    bValues[6] = 3.0;
    bValues[7] = 2.0;
    bValues[8] = 1.0;
    MCMatrix *b = [MCMatrix matrixWithValues:bValues rows:3 columns:3];
    
    double *sValues = malloc(9 * sizeof(double));
    sValues[0] = 1.0;
    sValues[1] = 2.0;
    sValues[2] = 3.0;
    sValues[3] = 4.0;
    sValues[4] = 5.0;
    sValues[5] = 6.0;
    sValues[6] = 7.0;
    sValues[7] = 8.0;
    sValues[8] = 9.0;
    MCMatrix *solution = [MCMatrix matrixWithValues:sValues rows:3 columns:3];
    
    MCMatrix *difference = [MCMatrix differenceOfMatrixA:a andMatrixB:b];
    
    for (int i = 0; i < 3; i++) {
        for (int j; j < 3; j++) {
            XCTAssertEqual([solution valueAtRow:i column:j], [difference valueAtRow:i column:j], @"Value at %u,%u incorrectly subtracted", i, j);
        }
    }
    
    XCTAssertThrows([MCMatrix sumOfMatrixA:[MCMatrix matrixWithRows:4 columns:5]
                                andMatrixB:[MCMatrix matrixWithRows:5 columns:5]], @"Should throw an exception for mismatched row amount");
    XCTAssertThrows([MCMatrix sumOfMatrixA:[MCMatrix matrixWithRows:5 columns:4]
                                andMatrixB:[MCMatrix matrixWithRows:5 columns:5]], @"Should throw an exception for mismatched column amount");
}

- (void)testTransposition
{
    double *aVals= malloc(9 * sizeof(double));
    aVals[0] = 1.0;
    aVals[1] = 2.0;
    aVals[2] = 3.0;
    aVals[3] = 4.0;
    aVals[4] = 5.0;
    aVals[5] = 6.0;
    aVals[6] = 7.0;
    aVals[7] = 8.0;
    aVals[8] = 9.0;
    MCMatrix *a = [MCMatrix matrixWithValues:aVals rows:3 columns:3];
    
    double *tVals= malloc(9 * sizeof(double));
    tVals[0] = 1.0;
    tVals[1] = 4.0;
    tVals[2] = 7.0;
    tVals[3] = 2.0;
    tVals[4] = 5.0;
    tVals[5] = 8.0;
    tVals[6] = 3.0;
    tVals[7] = 6.0;
    tVals[8] = 9.0;
    MCMatrix *t = [MCMatrix matrixWithValues:tVals rows:3 columns:3].transpose;
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([a valueAtRow:i column:j], [t valueAtRow:i column:j], @"Value at row %u and column %u incorrect", i, j);
        }
    }
    
    aVals= malloc(9 * sizeof(double));
    aVals[0] = 1.0;
    aVals[1] = 2.0;
    aVals[2] = 3.0;
    aVals[3] = 4.0;
    aVals[4] = 5.0;
    aVals[5] = 6.0;
    aVals[6] = 7.0;
    aVals[7] = 8.0;
    aVals[8] = 9.0;
    a = [MCMatrix matrixWithValues:aVals rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow];
    
    tVals= malloc(9 * sizeof(double));
    tVals[0] = 1.0;
    tVals[1] = 4.0;
    tVals[2] = 7.0;
    tVals[3] = 2.0;
    tVals[4] = 5.0;
    tVals[5] = 8.0;
    tVals[6] = 3.0;
    tVals[7] = 6.0;
    tVals[8] = 9.0;
    t = [MCMatrix matrixWithValues:tVals rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow].transpose;
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([a valueAtRow:i column:j], [t valueAtRow:i column:j], @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testMatrixCreationFromRowVectors
{
    MCVector *v1 = [MCVector vectorWithValuesInArray:@[@1, @2, @3]];
    MCVector *v2 = [MCVector vectorWithValuesInArray:@[@4, @5, @6]];
    MCVector *v3 = [MCVector vectorWithValuesInArray:@[@7, @8, @9]];
    
    /* create the matrix
     [ 1  4  7
     2  5  8
     3  6  9 ]
     */
    MCMatrix *a = [MCMatrix matrixWithColumnVectors:@[v1,v2, v3]];
    NSLog(a.description);
    
    /* create the matrix
     [ 1  2  3
     4  5  6
     7  8  9 ]
     */
    MCMatrix *b = [MCMatrix matrixWithRowVectors:@[v1, v2, v3]];
    NSLog(b.description);
}

- (void)test3x3MatrixMultiplicationRuntime
{
    double accelerateTime = 0;
    double mcTime = 0;
    
    for(int i = 0; i < 20000; i++) {
        
        // test plain accelerate function with c array of doubles
        double *aValues = malloc(9 * sizeof(double));
        aValues[0] = drand48();
        aValues[1] = drand48();
        aValues[2] = drand48();
        aValues[3] = drand48();
        aValues[4] = drand48();
        aValues[5] = drand48();
        aValues[6] = drand48();
        aValues[7] = drand48();
        aValues[8] = drand48();
        double *bValues = malloc(9 * sizeof(double));
        bValues[0] = drand48();
        bValues[1] = drand48();
        bValues[2] = drand48();
        bValues[3] = drand48();
        bValues[4] = drand48();
        bValues[5] = drand48();
        bValues[6] = drand48();
        bValues[7] = drand48();
        bValues[8] = drand48();
        double *cValues = malloc(9 * sizeof(double));
        
        NSDate *startTime = [NSDate date];
        vDSP_mmulD(aValues, 1, bValues, 1, cValues, 1, 3, 3, 3);
        NSDate *endTime = [NSDate date];
        accelerateTime += [endTime timeIntervalSinceDate:startTime];
        
        // test with MCMatrix objects constructed from MCVector objects
        MCMatrix *a = [MCMatrix matrixWithRowVectors:@[
                                                       [MCVector vectorWithValuesInArray:@[
                                                                                           @(drand48()),
                                                                                           @(drand48()),
                                                                                           @(drand48())
                                                                                           ]],
                                                       [MCVector vectorWithValuesInArray:@[
                                                                                           @(drand48()),
                                                                                           @(drand48()),
                                                                                           @(drand48())
                                                                                           ]],
                                                       [MCVector vectorWithValuesInArray:@[
                                                                                           @(drand48()),
                                                                                           @(drand48()),
                                                                                           @(drand48())
                                                                                           ]]
                                                       ]];
        MCMatrix *b = [MCMatrix matrixWithRowVectors:@[
                                                       [MCVector vectorWithValuesInArray:@[
                                                                                           @(drand48()),
                                                                                           @(drand48()),
                                                                                           @(drand48())
                                                                                           ]],
                                                       [MCVector vectorWithValuesInArray:@[
                                                                                           @(drand48()),
                                                                                           @(drand48()),
                                                                                           @(drand48())
                                                                                           ]],
                                                       [MCVector vectorWithValuesInArray:@[
                                                                                           @(drand48()),
                                                                                           @(drand48()),
                                                                                           @(drand48())
                                                                                           ]]
                                                       ]];
        
        startTime = [NSDate date];
        MCMatrix *c = [MCMatrix productOfMatrixA:a andMatrixB:b];
        
        endTime = [NSDate date];
        mcTime += [endTime timeIntervalSinceDate:startTime];
    }
    
    NSLog(@"plain accelerate runtime: %.2f\nMCMatrix runtime: %.2f", accelerateTime, mcTime);
}

- (void)testMatrixSymmetryQuerying
{
    double *aValues = malloc(9 * sizeof(double));
    aValues[0] = 1.0;
    aValues[1] = 2.0;
    aValues[2] = 3.0;
    aValues[3] = 4.0;
    aValues[4] = 5.0;
    aValues[5] = 6.0;
    aValues[6] = 7.0;
    aValues[7] = 8.0;
    aValues[8] = 9.0;
    MCMatrix *a = [MCMatrix matrixWithValues:aValues rows:3 columns:3];
    
    
    XCTAssertFalse(a.isSymmetric.isYes, @"Nonsymmetric matrix reported to be symmetric.");
    
    aValues[0] = 1.0;
    aValues[1] = 2.0;
    aValues[2] = 3.0;
    
    aValues[3] = 2.0;
    aValues[4] = 1.0;
    aValues[5] = 6.0;
    
    aValues[6] = 3.0;
    aValues[7] = 6.0;
    aValues[8] = 1.0;
    a = [MCMatrix matrixWithValues:aValues rows:3 columns:3];
    
    XCTAssertTrue(a.isSymmetric.isYes, @"Symmetric matrix not reported to be symmetric.");
    
    double *bValues = malloc(12 * sizeof(double));
    bValues[0] = 1.0;
    bValues[1] = 2.0;
    bValues[2] = 3.0;
    bValues[3] = 4.0;
    bValues[4] = 5.0;
    bValues[5] = 6.0;
    bValues[6] = 7.0;
    bValues[7] = 8.0;
    bValues[8] = 9.0;
    bValues[9] = 9.0;
    bValues[10] = 9.0;
    bValues[11] = 9.0;
    a = [MCMatrix matrixWithValues:bValues rows:3 columns:4];
    
    XCTAssertFalse(a.isSymmetric.isYes, @"Nonsquare matrix reported to be symmetric.");
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

- (void)testSymmetricMatrixEigendecomposition
{
    // example from http://software.intel.com/sites/products/documentation/doclib/mkl_sa/11/mkl_lapack_examples/dsyevd_ex.c.htm; more located at http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.essl.v5r2.essl100.doc%2Fam5gr_eigevd.htm
    double values[25] = {
        6.39,   0.13,  -8.23,   5.71,  -3.18,
        0.13,   8.37,  -4.46,  -6.10,   7.21,
        -8.23,  -4.46,  -9.58,  -9.25,  -7.42,
        5.71,  -6.10,  -9.25,   3.72,   8.54,
        -3.18,   7.21,  -7.42,   8.54,   2.51
    };
    
    MCMatrix *o = [MCMatrix matrixWithValues:values rows:5 columns:5 leadingDimension:MCMatrixLeadingDimensionRow];
    MCEigendecomposition *e = o.eigendecomposition;
    
    for (int i = 0; i < 5; i += 1) {
        MCVector *eigenvector = [e.eigenvectors columnVectorForColumn:i];
        double eigenvalue = [e.eigenvalues valueAtIndex:i];
        MCVector *left = [MCMatrix productOfMatrix:o andVector:eigenvector];
        MCVector *right = [eigenvector vectorByMultiplyingByScalar:eigenvalue];
        for (int j = 0; j < 5; j += 1) {
            double a = [left valueAtIndex:j];
            double b = [right valueAtIndex:j];
            double accuracy = 0.0000000001;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"Values at index %u differ by more than %f", j, accuracy);
        }
    }
}

- (void)testNonsymmetricMatrixEigendecomposition
{
    // example from http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.essl.v5r2.essl100.doc%2Fam5gr_eigevd.htm
    double values[16] = {
        -2.0,  2.0,  2.0,  2.0,
        -3.0,  3.0,  2.0,  2.0,
        -2.0,  0.0,  4.0,  2.0,
        -1.0,  0.0,  0.0,  5.0
    };
    
    MCMatrix *source = [MCMatrix matrixWithValues:values rows:4 columns:4 leadingDimension:MCMatrixLeadingDimensionRow];
    MCEigendecomposition *e = source.eigendecomposition;
    
    for (int i = 0; i < 4; i += 1) {
        MCVector *eigenvector = [e.eigenvectors columnVectorForColumn:i];
        double eigenvalue = [e.eigenvalues valueAtIndex:i];
        MCVector *left = [MCMatrix productOfMatrix:source andVector:eigenvector];
        MCVector *right = [eigenvector vectorByMultiplyingByScalar:eigenvalue];
        NSLog(left.description);
        NSLog(right.description);
        for (int j = 0; j < 4; j += 1) {
            double a = [left valueAtIndex:j];
            double b = [right valueAtIndex:j];
            double accuracy = 1.0e-6;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"Values at index %u differ by more than %f", j, accuracy);
        }
    }
}

- (void)testMatrixValueCopyByStorageFormat
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
    
    double *rowMajorValues = [a valuesInStorageFormat:MCMatrixLeadingDimensionRow];
    
    XCTAssertEqual(values[0], rowMajorValues[0], @"Value at 0, 0 incorrect");
    XCTAssertEqual(values[1], rowMajorValues[3], @"Value at 1, 3 incorrect");
    XCTAssertEqual(values[2], rowMajorValues[6], @"Value at 2, 6 incorrect");
    XCTAssertEqual(values[3], rowMajorValues[1], @"Value at 3, 1 incorrect");
    XCTAssertEqual(values[4], rowMajorValues[4], @"Value at 4, 4 incorrect");
    XCTAssertEqual(values[5], rowMajorValues[7], @"Value at 5, 7 incorrect");
    XCTAssertEqual(values[6], rowMajorValues[2], @"Value at 6, 2 incorrect");
    XCTAssertEqual(values[7], rowMajorValues[5], @"Value at 7, 5 incorrect");
    XCTAssertEqual(values[8], rowMajorValues[8], @"Value at 8, 8 incorrect");
    
    MCMatrix *b = [MCMatrix matrixWithValues:values rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow];
    
    double *columnMajorValues = [b valuesInStorageFormat:MCMatrixLeadingDimensionColumn];
    
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
    double *packedUpperTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                             inStorageFormat:MCMatrixLeadingDimensionRow
                                                                           withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedUpperTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], packedUpperTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[2], packedUpperTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[4], packedUpperTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[5], packedUpperTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedUpperTriangularValuesRowMajor[5], @"Value incorrect");
    free(packedUpperTriangularValuesRowMajor);
    
    double *packedUpperTriangularValuesColumnMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                                inStorageFormat:MCMatrixLeadingDimensionColumn
                                                                              withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedUpperTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], packedUpperTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[4], packedUpperTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[2], packedUpperTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[5], packedUpperTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedUpperTriangularValuesColumnMajor[5], @"Value incorrect");
    free(packedUpperTriangularValuesColumnMajor);
    
    double *unpackedUpperTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                               inStorageFormat:MCMatrixLeadingDimensionRow
                                                                             withPackingFormat:MCMatrixValuePackingFormatConventional];
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
    
    double *unpackedUpperTriangularValuesColumnMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                                  inStorageFormat:MCMatrixLeadingDimensionColumn
                                                                                withPackingFormat:MCMatrixValuePackingFormatConventional];
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
    double *packedLowerTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                             inStorageFormat:MCMatrixLeadingDimensionRow
                                                                           withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedLowerTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], packedLowerTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[4], packedLowerTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[6], packedLowerTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[7], packedLowerTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedLowerTriangularValuesRowMajor[5], @"Value incorrect");
    free(packedLowerTriangularValuesRowMajor);
    
    double *packedLowerTriangularValuesColumnMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                                inStorageFormat:MCMatrixLeadingDimensionColumn
                                                                              withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedLowerTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], packedLowerTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[6], packedLowerTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[4], packedLowerTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[7], packedLowerTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedLowerTriangularValuesColumnMajor[5], @"Value incorrect");
    free(packedLowerTriangularValuesColumnMajor);
    
    double *unpackedLowerTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                               inStorageFormat:MCMatrixLeadingDimensionRow
                                                                             withPackingFormat:MCMatrixValuePackingFormatConventional];
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
    
    double *unpackedLowerTriangularValuesColumnMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                                  inStorageFormat:MCMatrixLeadingDimensionColumn
                                                                                withPackingFormat:MCMatrixValuePackingFormatConventional];
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
    double *packedUpperTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                             inStorageFormat:MCMatrixLeadingDimensionRow
                                                                           withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedUpperTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], packedUpperTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[6], packedUpperTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[4], packedUpperTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[7], packedUpperTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedUpperTriangularValuesRowMajor[5], @"Value incorrect");
    free(packedUpperTriangularValuesRowMajor);
    
    double *packedUpperTriangularValuesColumnMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                                inStorageFormat:MCMatrixLeadingDimensionColumn
                                                                              withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedUpperTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], packedUpperTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[4], packedUpperTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[6], packedUpperTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[7], packedUpperTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedUpperTriangularValuesColumnMajor[5], @"Value incorrect");
    free(packedUpperTriangularValuesColumnMajor);
    
    double *unpackedUpperTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                               inStorageFormat:MCMatrixLeadingDimensionRow
                                                                             withPackingFormat:MCMatrixValuePackingFormatConventional];
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
    
    double *unpackedUpperTriangularValuesColumnMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                                  inStorageFormat:MCMatrixLeadingDimensionColumn
                                                                                withPackingFormat:MCMatrixValuePackingFormatConventional];
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
    double *packedLowerTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                             inStorageFormat:MCMatrixLeadingDimensionRow
                                                                           withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedLowerTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], packedLowerTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[4], packedLowerTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[2], packedLowerTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[5], packedLowerTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedLowerTriangularValuesRowMajor[5], @"Value incorrect");
    free(packedLowerTriangularValuesRowMajor);
    
    double *packedLowerTriangularValuesColumnMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                                inStorageFormat:MCMatrixLeadingDimensionColumn
                                                                              withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedLowerTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], packedLowerTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[2], packedLowerTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[4], packedLowerTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[5], packedLowerTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedLowerTriangularValuesColumnMajor[5], @"Value incorrect");
    free(packedLowerTriangularValuesColumnMajor);
    
    double *unpackedLowerTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                               inStorageFormat:MCMatrixLeadingDimensionRow
                                                                             withPackingFormat:MCMatrixValuePackingFormatConventional];
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
    
    double *unpackedLowerTriangularValuesColumnMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                                  inStorageFormat:MCMatrixLeadingDimensionColumn
                                                                                withPackingFormat:MCMatrixValuePackingFormatConventional];
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

- (void)testQRDecompositionOfSquareMatrix
{
    // example from wikipedia: http://en.wikipedia.org/wiki/QR_decomposition#Example
    MCMatrix *source = [MCMatrix matrixWithColumnVectors:@[
                                                           [MCVector vectorWithValuesInArray:@[@12, @6, @(-4)]],
                                                           [MCVector vectorWithValuesInArray:@[@(-51), @167, @24]],
                                                           [MCVector vectorWithValuesInArray:@[@4, @(-68), @(-41)]],
                                                           ]];
    
    MCQRFactorization *qrFactorization = source.qrFactorization;
    
    MCMatrix *qrProduct = [MCMatrix productOfMatrixA:qrFactorization.q andMatrixB:qrFactorization.r];
    
    for(NSUInteger row = 0; row < qrProduct.rows; row += 1) {
        for(NSUInteger col = 0; col < qrProduct.columns; col += 1) {
            double a = [source valueAtRow:row column:col];
            double b = [qrProduct valueAtRow:row column:col];
            double accuracy = 1.0e-10;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"value at (%u, %u) incorrect beyond accuracy = %f", row, col, accuracy);
        }
    }
}

- (void)testQRDecompositionOfGeneralMatrix
{
    double values[12] = {
        0.0, 2.0, 2.0, 0.0, 2.0, 2.0,
        2.0, -1.0, -1.0, 1.5, -1.0, -1.0
    };
    MCMatrix *source = [MCMatrix matrixWithValues:values
                                             rows:6
                                          columns:2
                                 leadingDimension:MCMatrixLeadingDimensionColumn];
    
    MCQRFactorization *qrFactorization = source.qrFactorization.thinFactorization;
    
    // need to take the 'thin QR factorization' of the general rectangular matrix
    MCMatrix *qrProduct = [MCMatrix productOfMatrixA:qrFactorization.q andMatrixB:qrFactorization.r];
    
    for(NSUInteger row = 0; row < qrProduct.rows; row += 1) {
        for(NSUInteger col = 0; col < qrProduct.columns; col += 1) {
            double a = [source valueAtRow:row column:col];
            double b = [qrProduct valueAtRow:row column:col];
            double accuracy = 1.0e-10;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"value at (%u, %u) incorrect beyond accuracy = %f", row, col, accuracy);
        }
    }
}

- (void)testDeterminantCalculation
{
    double values2x2[4] = {
        1.0, 2.0,
        3.0, 4.0
    };
    MCMatrix *matrix = [MCMatrix matrixWithValues:values2x2
                                             rows:2
                                          columns:2
                                 leadingDimension:MCMatrixLeadingDimensionRow];
    
    XCTAssertEqual(matrix.determinant, -2.0, @"Determinant not correct");
    
    double values3x3[9] = {
        6.0, 1.0, 1.0,
        4.0, -2.0, 5.0,
        2.0, 8.0, 7.0
    };
    matrix = [MCMatrix matrixWithValues:values3x3
                                   rows:3
                                columns:3
                       leadingDimension:MCMatrixLeadingDimensionRow];
    
    XCTAssertEqual(matrix.determinant, -306.0, @"Determinant not correct");
    
    double values4x4[16] = {
        3.0, 2.0, 0.0, 1.0,
        4.0, 0.0, 1.0, 2.0,
        3.0, 0.0, 2.0, 1.0,
        9.0, 2.0, 3.0, 1.0
    };
    matrix = [MCMatrix matrixWithValues:values4x4
                                   rows:4
                                columns:4
                       leadingDimension:MCMatrixLeadingDimensionRow];
    
    XCTAssertEqual(matrix.determinant, 24.0, @"Determinant not correct");
}

- (void)testInverseOfSquareMatrix
{
    // example from https://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.essl.v5r2.essl100.doc%2Fam5gr_hsgeicd.htm
    double values[81] = {
         1.0,  1.0,  1.0,  1.0,  0.0,  0.0,   0.0,   0.0,   0.0,
         1.0,  1.0,  1.0,  1.0,  1.0,  0.0,   0.0,   0.0,   0.0,
         4.0,  1.0,  1.0,  1.0,  1.0,  1.0,   0.0,   0.0,   0.0,
         0.0,  5.0,  1.0,  1.0,  1.0,  1.0,   1.0,   0.0,   0.0,
         0.0,  0.0,  6.0,  1.0,  1.0,  1.0,   1.0,   1.0,   0.0,
         0.0,  0.0,  0.0,  7.0,  1.0,  1.0,   1.0,   1.0,   1.0,
         0.0,  0.0,  0.0,  0.0,  8.0,  1.0,   1.0,   1.0,   1.0,
         0.0,  0.0,  0.0,  0.0,  0.0,  9.0,   1.0,   1.0,   1.0,
         0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  10.0,  11.0,  12.0
    };
    
    MCMatrix *original = [MCMatrix matrixWithValues:values rows:9 columns:9 leadingDimension:MCMatrixLeadingDimensionRow];
    
    MCMatrix *inverse = original.inverse;
    
    NSLog(original.description);
    NSLog(inverse.description);
    
    double inverseValues[81] = {
            0.333,   -0.667,   0.333,  0.000,  0.000,  0.000,   0.042, -0.042,  0.000,
           56.833,  -52.167,  -1.167, -0.500, -0.500, -0.357,   6.836, -0.479, -0.500,
          -55.167,   51.833,   0.833,  0.500,  0.500,  0.214,  -6.735,  0.521,  0.500,
           -1.000,    1.000,   0.000,  0.000,  0.000,  0.143,  -0.143,  0.000,  0.000,
           -1.000,    1.000,   0.000,  0.000,  0.000,  0.000,   0.000,  0.000,  0.000,
           -1.000,    1.000,   0.000,  0.000,  0.000,  0.000,  -0.125,  0.125,  0.000,
         -226.000,  206.000,   5.000,  3.000,  2.000,  1.429, -27.179,  1.750,  2.000,
          560.000, -520.000, -10.000, -6.000, -4.000, -2.857,  67.857, -5.000, -5.000,
         -325.000,  305.000,   5.000,  3.000,  2.000,  1.429, -39.554,  3.125,  3.000
    };
    
    MCMatrix *solution = [MCMatrix matrixWithValues:inverseValues rows:9 columns:9 leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 9; row += 1) {
        for (int col = 0; col < 9; col += 1) {
            double a = [inverse valueAtRow:row column:col];
            double b = [solution valueAtRow:row column:col];
            double accuracy = 1.0e-3;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"Value at (%u, %u) incorrect beyond accuracy=%f", row, col, accuracy);
        }
    }
}

- (void)testMatrixDefiniteness
{
    // ----- positive definite -----
    double positiveDefiniteValues[9] = {
        2.0, -1.0, 0.0,
        -1.0, 2.0, -1.0,
        0.0, -1.0, 2.0
    };
    MCMatrix *matrix = [MCMatrix matrixWithValues:positiveDefiniteValues rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MCMatrixDefinitenessPositiveDefinite, @"Positive definite matrix was not recognized.");
    
    // ----- positive semidefinite -----
    double positiveSemidefiniteValues[4] = {
        1, 1,
        1, 1
    };
    matrix = [MCMatrix matrixWithValues:positiveSemidefiniteValues rows:2 columns:2 leadingDimension:MCMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MCMatrixDefinitenessPositiveSemidefinite, @"Positive semidefinite matrix was not recognized.");
    
    // ----- indefinite -----
    double indefiniteValues[9] = {
        1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
        1.0, 1.0, 0.5
    };
    matrix = [MCMatrix matrixWithValues:indefiniteValues rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MCMatrixDefinitenessIndefinite, @"Indefinite matrix was not recognized.");
    
    // ----- negative semidefinite -----
    
    // test case from http://www.math.drexel.edu/~tolya/301_spd_cholesky.pdf
    double negativeSemidefiniteValues[4] = {
        0.0, 0.0,
        0.0, -1.0
    };
    matrix = [MCMatrix matrixWithValues:negativeSemidefiniteValues rows:2 columns:2 leadingDimension:MCMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MCMatrixDefinitenessNegativeSemidefinite, @"Negative semidefinite matrix was not recognized.");
    
    // ----- negative definite -----
    double negativeDefiniteValues[9] = {
        -1.0, 0.0, 0.0,
        0.0, -1.0, 0.0,
        0.0, 0.0, -1.0
    };
    matrix = [MCMatrix matrixWithValues:negativeDefiniteValues rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MCMatrixDefinitenessNegativeDefinite, @"Negative definite matrix was not recognized.");
}

// tests can be verified using http://comnuan.com/cmnn0100c/
- (void)testConditionNumber
{
    double values[81] = {
        7.0, 3.0,
        -9.0, 2.0
    };
    MCMatrix *matrix = [MCMatrix matrixWithValues:values rows:2 columns:2 leadingDimension:MCMatrixLeadingDimensionColumn];
    
    double conditionNumber = matrix.conditionNumber;
    
    XCTAssertEqualWithAccuracy(conditionNumber, 3.902, 0.001, @"condition number not calculated correctly.");
}

- (void)testSymmetricMatrixCreation
{
    // packed row-major
    double rowMajorPackedValues[6] = {
        1.0, 2.0, 3.0,
             5.0, 7.0,
                  12.0
    };
    MCMatrix *matrix = [MCMatrix symmetricMatrixWithPackedValues:rowMajorPackedValues
                                                leadingDimension:MCMatrixLeadingDimensionRow
                                             triangularComponent:MCMatrixTriangularComponentUpper
                                                         ofOrder:3];
    XCTAssert(matrix.isSymmetric, @"Packed row-major symmetric matrix constructed incorrectly.");
    
    // packed column-major
    double columnMajorPackedValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    matrix = [MCMatrix symmetricMatrixWithPackedValues:columnMajorPackedValues
                                      leadingDimension:MCMatrixLeadingDimensionColumn
                                   triangularComponent:MCMatrixTriangularComponentLower
                                               ofOrder:3];
    XCTAssert(matrix.isSymmetric, @"Packed column-major symmetric matrix constructed incorrectly.");
}

- (void)testTriangularMatrixCreation
{
    double upperSolutionValues[9] = {
        1.0,   2.0,   3.0,
        0.0,   5.0,   7.0,
        0.0,   0.0,   12.0
    };
    MCMatrix *upperSolution = [MCMatrix matrixWithValues:upperSolutionValues
                                                    rows:3
                                                 columns:3
                                        leadingDimension:MCMatrixLeadingDimensionRow];
    
    // upper row-major
    double rowMajorUpperValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    MCMatrix *matrix = [MCMatrix triangularMatrixWithPackedValues:rowMajorUpperValues
                                            ofTriangularComponent:MCMatrixTriangularComponentUpper
                                                 leadingDimension:MCMatrixLeadingDimensionRow
                                                          ofOrder:3];
    XCTAssert([matrix isEqualToMatrix:upperSolution], @"Upper triangular row major matrix incorrectly created.");
    
    // upper column-major
    double columnMajorUpperValues[6] = {
        1.0, 2.0, 5.0,
        3.0, 7.0,
        12.0
    };
    matrix = [MCMatrix triangularMatrixWithPackedValues:columnMajorUpperValues
                                            ofTriangularComponent:MCMatrixTriangularComponentUpper
                                                 leadingDimension:MCMatrixLeadingDimensionColumn
                                                          ofOrder:3];
    XCTAssert([matrix isEqualToMatrix:upperSolution], @"Upper triangular column major matrix incorrectly created.");
    
    double lowerSolutionValues[9] = {
        1.0,   0.0,   0.0,
        2.0,   5.0,   0.0,
        3.0,   7.0,   12.0
    };
    MCMatrix *lowerSolution = [MCMatrix matrixWithValues:lowerSolutionValues
                                                    rows:3
                                                 columns:3
                                        leadingDimension:MCMatrixLeadingDimensionRow];
    
    // lower row-major
    double rowMajorLowerValues[6] = {
        1.0, 2.0, 5.0,
        3.0, 7.0,
        12.0
    };
    matrix = [MCMatrix triangularMatrixWithPackedValues:rowMajorLowerValues
                                  ofTriangularComponent:MCMatrixTriangularComponentLower
                                       leadingDimension:MCMatrixLeadingDimensionRow
                                                ofOrder:3];
    XCTAssert([matrix isEqualToMatrix:lowerSolution], @"Lower triangular row major matrix incorrectly created.");
    
    // lower column-major
    double columnMajorLowerValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    matrix = [MCMatrix triangularMatrixWithPackedValues:columnMajorLowerValues
                                  ofTriangularComponent:MCMatrixTriangularComponentLower
                                       leadingDimension:MCMatrixLeadingDimensionColumn
                                                ofOrder:3];
    XCTAssert([matrix isEqualToMatrix:lowerSolution], @"Lower triangular column major matrix incorrectly created.");
}

@end

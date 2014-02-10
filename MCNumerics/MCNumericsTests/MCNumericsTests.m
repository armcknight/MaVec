//
//  MCNumericsTests.m
//  MCNumericsTests
//
//  Created by andrew mcknight on 12/2/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Accelerate/Accelerate.h>
#import "MCMatrix.h"
#import "MCVector.h"
#import "MCSingularValueDecomposition.h"
#import "MCLUFactorization.h"
#import "MCTribool.h"
#import "MCEigendecomposition.h"

@interface MCNumericsTests : XCTestCase

@end

@implementation MCNumericsTests

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

#pragma mark - Matrices

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
    cr.valueStorageFormat = MCMatrixValueStorageFormatRowMajor;
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
    r.valueStorageFormat = MCMatrixValueStorageFormatRowMajor;
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
    b.valueStorageFormat = MCMatrixValueStorageFormatRowMajor;
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

- (void)testMinorComposition
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
    
    MCMatrix *m = [MCMatrix matrixWithValues:values rows:3 columns:3];
    MCMatrix *minor = [m minorByRemovingRow:0 column:0];
    
    // create mcmatrix corresponding to minor of m with 1st row and 1st column removed
    double *mValues = malloc(4 * sizeof(double));
    mValues[0] = 5.0;
    mValues[1] = 6.0;
    mValues[2] = 8.0;
    mValues[3] = 9.0;
    MCMatrix *minorSolution = [MCMatrix matrixWithValues:mValues rows:2 columns:2];
    
    XCTAssertEqual(minor.rows, minorSolution.rows, @"Minor computed with incorrect amount of rows.");
    XCTAssertEqual(minor.columns, minorSolution.columns, @"Minor computed with incorrect amount of columns.");
    for (int i = 0; i < minorSolution.rows; i++) {
        for (int j = 0; j < minorSolution.columns; j++) {
            XCTAssertEqual([minor valueAtRow:i column:j], [minorSolution valueAtRow:i column:j], @"Minor contains incorrect value at %u, %u", i, j);
        }
    }
    
    // try to create a minor with an invalid row and column
    XCTAssertThrows([m minorByRemovingRow:3 column:1], @"Should throw an invalid row exception.");
    XCTAssertThrows([m minorByRemovingRow:1 column:3], @"Should throw an invalid column exception.");
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
    
    MCMatrix *o = [MCMatrix matrixWithValues:values rows:5 columns:5 valueStorageFormat:MCMatrixValueStorageFormatRowMajor];
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
    
    MCMatrix *source = [MCMatrix matrixWithValues:values rows:4 columns:4 valueStorageFormat:MCMatrixValueStorageFormatRowMajor];
    MCEigendecomposition *e = source.eigendecomposition;
    
    for (int i = 0; i < 4; i += 1) {
        MCVector *eigenvector = [e.eigenvectors columnVectorForColumn:i];
        double eigenvalue = [e.eigenvalues valueAtIndex:i];
        MCVector *left = [MCMatrix productOfMatrix:source andVector:eigenvector];
        MCVector *right = [eigenvector vectorByMultiplyingByScalar:eigenvalue];
        for (int j = 0; j < 4; j += 1) {
            double a = [left valueAtIndex:j];
            double b = [right valueAtIndex:j];
            double accuracy = 0.0000000001;
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
    
    MCMatrix *a = [MCMatrix matrixWithValues:values rows:3 columns:3 valueStorageFormat:MCMatrixValueStorageFormatColumnMajor];
    
    double *rowMajorValues = [a valuesInStorageFormat:MCMatrixValueStorageFormatRowMajor];
    
    XCTAssertEqual(values[0], rowMajorValues[0], @"Value at 0, 0 incorrect");
    XCTAssertEqual(values[1], rowMajorValues[3], @"Value at 1, 3 incorrect");
    XCTAssertEqual(values[2], rowMajorValues[6], @"Value at 2, 6 incorrect");
    XCTAssertEqual(values[3], rowMajorValues[1], @"Value at 3, 1 incorrect");
    XCTAssertEqual(values[4], rowMajorValues[4], @"Value at 4, 4 incorrect");
    XCTAssertEqual(values[5], rowMajorValues[7], @"Value at 5, 7 incorrect");
    XCTAssertEqual(values[6], rowMajorValues[2], @"Value at 6, 2 incorrect");
    XCTAssertEqual(values[7], rowMajorValues[5], @"Value at 7, 5 incorrect");
    XCTAssertEqual(values[8], rowMajorValues[8], @"Value at 8, 8 incorrect");
    
    MCMatrix *b = [MCMatrix matrixWithValues:values rows:3 columns:3 valueStorageFormat:MCMatrixValueStorageFormatRowMajor];
    
    double *columnMajorValues = [b valuesInStorageFormat:MCMatrixValueStorageFormatColumnMajor];
    
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
    
    MCMatrix *a = [MCMatrix matrixWithValues:values rows:3 columns:3 valueStorageFormat:MCMatrixValueStorageFormatRowMajor];
    
    /*
     0  1  2
     -  4  5
     -  -  8
     */
    double *packedUpperTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                             inStorageFormat:MCMatrixValueStorageFormatRowMajor
                                                                           withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedUpperTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], packedUpperTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[2], packedUpperTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[4], packedUpperTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[5], packedUpperTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedUpperTriangularValuesRowMajor[5], @"Value incorrect");
    free(packedUpperTriangularValuesRowMajor);
    
    double *packedUpperTriangularValuesColumnMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                                inStorageFormat:MCMatrixValueStorageFormatColumnMajor
                                                                              withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedUpperTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], packedUpperTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[4], packedUpperTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[2], packedUpperTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[5], packedUpperTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedUpperTriangularValuesColumnMajor[5], @"Value incorrect");
    free(packedUpperTriangularValuesColumnMajor);
    
    double *unpackedUpperTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                               inStorageFormat:MCMatrixValueStorageFormatRowMajor
                                                                             withPackingFormat:MCMatrixValuePackingFormatUnpacked];
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
                                                                                  inStorageFormat:MCMatrixValueStorageFormatColumnMajor
                                                                                withPackingFormat:MCMatrixValuePackingFormatUnpacked];
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
                                                                             inStorageFormat:MCMatrixValueStorageFormatRowMajor
                                                                           withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedLowerTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], packedLowerTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[4], packedLowerTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[6], packedLowerTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[7], packedLowerTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedLowerTriangularValuesRowMajor[5], @"Value incorrect");
    free(packedLowerTriangularValuesRowMajor);
    
    double *packedLowerTriangularValuesColumnMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                                inStorageFormat:MCMatrixValueStorageFormatColumnMajor
                                                                              withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedLowerTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], packedLowerTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[6], packedLowerTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[4], packedLowerTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[7], packedLowerTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedLowerTriangularValuesColumnMajor[5], @"Value incorrect");
    free(packedLowerTriangularValuesColumnMajor);
    
    double *unpackedLowerTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                               inStorageFormat:MCMatrixValueStorageFormatRowMajor
                                                                             withPackingFormat:MCMatrixValuePackingFormatUnpacked];
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
                                                                                  inStorageFormat:MCMatrixValueStorageFormatColumnMajor
                                                                                withPackingFormat:MCMatrixValuePackingFormatUnpacked];
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
    
    MCMatrix *a = [MCMatrix matrixWithValues:values rows:3 columns:3 valueStorageFormat:MCMatrixValueStorageFormatColumnMajor];
    
    /*
     0  3  6
     -  4  7
     -  -  8
     */
    double *packedUpperTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                             inStorageFormat:MCMatrixValueStorageFormatRowMajor
                                                                           withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedUpperTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], packedUpperTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[6], packedUpperTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[4], packedUpperTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[7], packedUpperTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedUpperTriangularValuesRowMajor[5], @"Value incorrect");
    free(packedUpperTriangularValuesRowMajor);
    
    double *packedUpperTriangularValuesColumnMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                                inStorageFormat:MCMatrixValueStorageFormatColumnMajor
                                                                              withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedUpperTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[3], packedUpperTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[4], packedUpperTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[6], packedUpperTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[7], packedUpperTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedUpperTriangularValuesColumnMajor[5], @"Value incorrect");
    free(packedUpperTriangularValuesColumnMajor);
    
    double *unpackedUpperTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentUpper
                                                                               inStorageFormat:MCMatrixValueStorageFormatRowMajor
                                                                             withPackingFormat:MCMatrixValuePackingFormatUnpacked];
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
                                                                                  inStorageFormat:MCMatrixValueStorageFormatColumnMajor
                                                                                withPackingFormat:MCMatrixValuePackingFormatUnpacked];
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
                                                                             inStorageFormat:MCMatrixValueStorageFormatRowMajor
                                                                           withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedLowerTriangularValuesRowMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], packedLowerTriangularValuesRowMajor[1], @"Value incorrect");
    XCTAssertEqual(values[4], packedLowerTriangularValuesRowMajor[2], @"Value incorrect");
    XCTAssertEqual(values[2], packedLowerTriangularValuesRowMajor[3], @"Value incorrect");
    XCTAssertEqual(values[5], packedLowerTriangularValuesRowMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedLowerTriangularValuesRowMajor[5], @"Value incorrect");
    free(packedLowerTriangularValuesRowMajor);
    
    double *packedLowerTriangularValuesColumnMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                                inStorageFormat:MCMatrixValueStorageFormatColumnMajor
                                                                              withPackingFormat:MCMatrixValuePackingFormatPacked];
    XCTAssertEqual(values[0], packedLowerTriangularValuesColumnMajor[0], @"Value incorrect");
    XCTAssertEqual(values[1], packedLowerTriangularValuesColumnMajor[1], @"Value incorrect");
    XCTAssertEqual(values[2], packedLowerTriangularValuesColumnMajor[2], @"Value incorrect");
    XCTAssertEqual(values[4], packedLowerTriangularValuesColumnMajor[3], @"Value incorrect");
    XCTAssertEqual(values[5], packedLowerTriangularValuesColumnMajor[4], @"Value incorrect");
    XCTAssertEqual(values[8], packedLowerTriangularValuesColumnMajor[5], @"Value incorrect");
    free(packedLowerTriangularValuesColumnMajor);
    
    double *unpackedLowerTriangularValuesRowMajor = [a triangularValuesFromTriangularComponent:MCMatrixTriangularComponentLower
                                                                               inStorageFormat:MCMatrixValueStorageFormatRowMajor
                                                                             withPackingFormat:MCMatrixValuePackingFormatUnpacked];
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
                                                                                  inStorageFormat:MCMatrixValueStorageFormatColumnMajor
                                                                                withPackingFormat:MCMatrixValuePackingFormatUnpacked];
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

#pragma mark - Vectors

- (void)testVectorDotProduct
{
    double dotProduct = [MCVector dotProductOfVectorA:[MCVector vectorWithValuesInArray:@[
                                                                                          @1,
                                                                                          @3,
                                                                                          @(-5)]]
                                           andVectorB:[MCVector vectorWithValuesInArray:@[
                                                                                           @4,
                                                                                           @(-2),
                                                                                           @(-1)]]];
    XCTAssertEqual(dotProduct, 3.0, @"Dot product not computed correctly");
    
    dotProduct = [MCVector dotProductOfVectorA:[MCVector vectorWithValuesInArray:@[
                                                                                   @0,
                                                                                   @0,
                                                                                   @1]]
                                    andVectorB:[MCVector vectorWithValuesInArray:@[
                                                                                   @0,
                                                                                   @1,
                                                                                   @0]]];
    XCTAssertEqual(dotProduct, 0.0, @"Dot product not computed correctly");
    
    @try {
        dotProduct = [MCVector dotProductOfVectorA:[MCVector vectorWithValuesInArray:@[
                                                                                       @0,
                                                                                       @0,
                                                                                       @1]]
                                        andVectorB:[MCVector vectorWithValuesInArray:@[
                                                                                       @0,
                                                                                       @1,
                                                                                       @0,
                                                                                       @1]]];
    }
    @catch (NSException *exception) {
        XCTAssert([exception.name isEqualToString:NSInvalidArgumentException], @"Did not detect dimension mismatch in MCVector dot product method");
    }
}

- (void)testVectorAddition
{
    MCVector *a = [MCVector vectorWithValuesInArray:@[@1, @2, @3, @4]];
    MCVector *b = [MCVector vectorWithValuesInArray:@[@5, @6, @7, @8]];
    MCVector *c = [MCVector vectorWithValuesInArray:@[@1, @2, @3]];
    
    MCVector *sum = [MCVector sumOfVectorA:a andVectorB:b];
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@6, @8, @10, @12]];
    for (int i = 0; i < 4; i++) {
        XCTAssertEqual([sum valueAtIndex:i], [solution valueAtIndex:i], @"Value at index %u not added correctly", i);
    }
    
    XCTAssertThrows([MCVector sumOfVectorA:a andVectorB:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorSubtraction
{
    MCVector *a = [MCVector vectorWithValuesInArray:@[@1, @2, @3, @4]];
    MCVector *b = [MCVector vectorWithValuesInArray:@[@5, @6, @7, @8]];
    MCVector *c = [MCVector vectorWithValuesInArray:@[@1, @2, @3]];
    
    MCVector *diff = [MCVector differenceOfVectorA:b andVectorB:a];
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@4, @4, @4, @4]];
    for (int i = 0; i < 4; i++) {
        XCTAssertEqual([diff valueAtIndex:i], [solution valueAtIndex:i], @"Value at index %u not subtracted correctly", i);
    }
    
    XCTAssertThrows([MCVector differenceOfVectorA:a andVectorB:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorMultiplication
{
    MCVector *a = [MCVector vectorWithValuesInArray:@[@1, @2, @3, @4]];
    MCVector *b = [MCVector vectorWithValuesInArray:@[@5, @6, @7, @8]];
    MCVector *c = [MCVector vectorWithValuesInArray:@[@1, @2, @3]];
    
    MCVector *prod = [MCVector productOfVectorA:a andVectorB:b];
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@5, @12, @21, @32]];
    for (int i = 0; i < 4; i++) {
        XCTAssertEqual([prod valueAtIndex:i], [solution valueAtIndex:i], @"Value at index %u not multiplied correctly", i);
    }
    
    XCTAssertThrows([MCVector productOfVectorA:a andVectorB:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorDivision
{
    MCVector *a = [MCVector vectorWithValuesInArray:@[@1, @2, @3, @4]];
    MCVector *b = [MCVector vectorWithValuesInArray:@[@5, @6, @9, @8]];
    MCVector *c = [MCVector vectorWithValuesInArray:@[@1, @2, @3]];
    
    MCVector *quotient = [MCVector quotientOfVectorA:b andVectorB:a];
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@5, @3, @3, @2]];
    for (int i = 0; i < 4; i++) {
        XCTAssertEqual([quotient valueAtIndex:i], [solution valueAtIndex:i], @"Value at index %u not divided correctly", i);
    }
    
    XCTAssertThrows([MCVector quotientOfVectorA:a andVectorB:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorCrossProduct
{
    MCVector *a = [MCVector vectorWithValuesInArray:@[@3, @(-3), @1]];
    MCVector *b = [MCVector vectorWithValuesInArray:@[@4, @9, @2]];
    MCVector *c = [MCVector crossProductOfVectorA:a andVectorB:b];
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@(-15), @(-2), @39]];
    XCTAssertTrue([c isEqualToVector:solution], @"Cross product not computed correctly.");
}

- (void)testVectorCopying
{
    MCVector *a = [MCVector vectorWithValuesInArray:@[@3, @(-3), @1]];
    MCVector *aCopy = a.copy;
    
    XCTAssertNotEqual(a.self, aCopy.self, @"The copied vector is the same instance as its source.");
    XCTAssertTrue([a isEqualToVector:aCopy], @"Vector copy is not equal to its source.");
}

#pragma mark - Mixed

- (void)testMultiplyingMatrixByVector
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
    
    bVals[0] = -1.95;
    bVals[1] = -0.7445;
    bVals[2] = -2.5594;
    bVals[3] = 1.125;
    MCMatrix *a = [MCMatrix matrixWithValues:aVals rows:4 columns:4];
    MCVector *b = [MCVector vectorWithValues:bVals length:4];
    
    MCVector *product = [MCMatrix productOfMatrix:a andVector:b];
    
    double *solution = malloc(4 * sizeof(double));
    solution[0] = -15.6;
    solution[1] = -2.9778;
    solution[2] = -10.2376;
    solution[3] = 4.5;
    MCVector *s = [MCVector vectorWithValues:solution length:4];
    
    for (int i = 0; i < 4; i++) {
        XCTAssertEqualWithAccuracy([s valueAtIndex:i], [product valueAtIndex:i], 0.0005, @"Coefficient %u incorrect", i);
    }
}

@end

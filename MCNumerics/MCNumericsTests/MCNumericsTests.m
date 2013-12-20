//
//  MCNumericsTests.m
//  MCNumericsTests
//
//  Created by andrew mcknight on 12/2/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import <Accelerate/Accelerate.h>
#import "MCMatrix.h"
#import "MCVector.h"
#import "MCSingularValueDecomposition.h"
#import "MCLUFactorization.h"

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
    MCMatrix *cr = [c matrixWithValuesStoredInFormat:MCMatrixValueStorageFormatRowMajor];
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
    
    MCMatrix *r = [b matrixWithValuesStoredInFormat:MCMatrixValueStorageFormatRowMajor];
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
    NSLog([a matrixWithValuesStoredInFormat:MCMatrixValueStorageFormatRowMajor].description);
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
    
    MCLUFactorization *f = [m luFactorization];
    
    MCMatrix *pl = [MCMatrix productOfMatrixA:f.p andMatrixB:f.l];
    MCMatrix *product = [MCMatrix productOfMatrixA:pl andMatrixB:f.u];
    
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
    
    MCLUFactorization *f = [m luFactorization];
    
    MCMatrix *pl = [MCMatrix productOfMatrixA:f.p andMatrixB:f.l];
    MCMatrix *product = [MCMatrix productOfMatrixA:pl andMatrixB:f.u];
    
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            double a = [m valueAtRow:i column:j];
            double b = [product valueAtRow:i column:j];
            XCTAssertEqualWithAccuracy(a, b, 0.0000000000000003, @"Value at row %i and column %i was not recomputed correctly", i, j);
        }
    }
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
    MCMatrix *t = [[MCMatrix matrixWithValues:tVals rows:3 columns:3] transpose];
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([a valueAtRow:i column:j], [t valueAtRow:i column:j], @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testMatrixCreationFromRowVectors
{
    MCVector *v1 = [MCVector vectorWithValues:@[@1, @2, @3]];
    MCVector *v2 = [MCVector vectorWithValues:@[@4, @5, @6]];
    MCVector *v3 = [MCVector vectorWithValues:@[@7, @8, @9]];
    
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
                                                       [MCVector vectorWithValues:@[
                                                                                    @(drand48()),
                                                                                    @(drand48()),
                                                                                    @(drand48())
                                                                                    ]],
                                                       [MCVector vectorWithValues:@[
                                                                                    @(drand48()),
                                                                                    @(drand48()),
                                                                                    @(drand48())
                                                                                    ]],
                                                       [MCVector vectorWithValues:@[
                                                                                    @(drand48()),
                                                                                    @(drand48()),
                                                                                    @(drand48())
                                                                                    ]]
                                                       ]];
        MCMatrix *b = [MCMatrix matrixWithRowVectors:@[
                                                       [MCVector vectorWithValues:@[
                                                                                    @(drand48()),
                                                                                    @(drand48()),
                                                                                    @(drand48())
                                                                                    ]],
                                                       [MCVector vectorWithValues:@[
                                                                                    @(drand48()),
                                                                                    @(drand48()),
                                                                                    @(drand48())
                                                                                    ]],
                                                       [MCVector vectorWithValues:@[
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

- (void)testVectorDotProduct
{
    double dotProduct = [MCVector dotProductOfVectorA:[MCVector vectorWithValues:@[
                                                                                   @1,
                                                                                   @3,
                                                                                   @(-5)]]
                                           andVectorB:[MCVector vectorWithValues:@[
                                                                                   @4,
                                                                                   @(-2),
                                                                                   @(-1)]]];
    XCTAssertEqual(dotProduct, 3.0, @"Dot product not computed correctly");
    
    dotProduct = [MCVector dotProductOfVectorA:[MCVector vectorWithValues:@[
                                                                            @0,
                                                                            @0,
                                                                            @1]]
                                    andVectorB:[MCVector vectorWithValues:@[
                                                                            @0,
                                                                            @1,
                                                                            @0]]];
    XCTAssertEqual(dotProduct, 0.0, @"Dot product not computed correctly");
    
    @try {
        dotProduct = [MCVector dotProductOfVectorA:[MCVector vectorWithValues:@[
                                                                                @0,
                                                                                @0,
                                                                                @1]]
                                        andVectorB:[MCVector vectorWithValues:@[
                                                                                @0,
                                                                                @1,
                                                                                @0,
                                                                                @1]]];
    }
    @catch (NSException *exception) {
        XCTAssert([exception.name isEqualToString:NSInvalidArgumentException], @"Did not detect dimension mismatch in MCVector dot product method");
    }
}

@end

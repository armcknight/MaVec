//
//  MCNumericsTests.m
//  MCNumericsTests
//
//  Created by andrew mcknight on 12/2/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCMatrix.h"

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
    
    for (int i = 0; i < 4; i++) {
        XCTAssertEqual(p.values[i], solution[i], @"Value at index %i incorrect", i);
    }
    
    free(aVals);
    free(bVals);
    free(solution);
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
    
    for (int i = 0; i < 6; i++) {
        XCTAssertEqual(p.values[i], solution[i], @"Value at index %i incorrect", i);
    }
    
    free(aVals);
    free(bVals);
    free(solution);
}

- (void)firstSVDTest
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
    
    for (int i = 0; i < 6; i++) {
        XCTAssertEqualWithAccuracy(values[i], original.values[i], __DBL_EPSILON__ * 10.0, @"Value at index %i incorrect", i);
    }
    
    free(values);
}

- (void)secondSVDTest
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
    
    for (int i = 0; i < 8; i++) {
        XCTAssertEqualWithAccuracy(values[i], original.values[i], __DBL_EPSILON__ * 10.0, @"Value at index %i incorrect", i);
    }
    
    free(values);
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
    
    for (int i = 0; i < 2; i++) {
        XCTAssertEqualWithAccuracy(solution[i], coefficients.values[i], __DBL_EPSILON__ * 10.0, @"Value at index %i incorrect", i);
    }
    
    free(aVals);
    free(bVals);
    free(solution);
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
    
    double *solution = malloc(2 * sizeof(double));
    solution[0] = -1.95;
    solution[1] = -0.7445;
    solution[2] = -2.5594;
    solution[3] = 1.125;
    
    for (int i = 0; i < 4; i++) {
        XCTAssertEqualWithAccuracy(solution[i], coefficients.values[i], 0.0005, @"Value at index %i incorrect", i);
    }
    
    free(aVals);
    free(bVals);
    free(solution);
}


@end

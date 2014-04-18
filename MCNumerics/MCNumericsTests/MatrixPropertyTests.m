//
//  MatrixPropertyTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/8/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"
#import "MCTribool.h"

@interface MatrixPropertyTests : XCTestCase

@end

@implementation MatrixPropertyTests

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

- (void)testDeterminantCalculation
{
    double values2x2[4] = {
        1.0, 2.0,
        3.0, 4.0
    };
    MCMatrix *matrix = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:values2x2 size:4]
                                             rows:2
                                          columns:2
                                 leadingDimension:MCMatrixLeadingDimensionRow];
    
    XCTAssertEqual(matrix.determinant, -2.0, @"Determinant not correct");
    
    double values3x3[9] = {
        6.0, 1.0, 1.0,
        4.0, -2.0, 5.0,
        2.0, 8.0, 7.0
    };
    matrix = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:values3x3 size:9]
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
    matrix = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:values4x4 size:16]
                                   rows:4
                                columns:4
                       leadingDimension:MCMatrixLeadingDimensionRow];
    
    XCTAssertEqual(matrix.determinant, 24.0, @"Determinant not correct");
}

- (void)testMatrixDefiniteness
{
    // ----- positive definite -----
    double positiveDefiniteValues[9] = {
        2.0, -1.0, 0.0,
        -1.0, 2.0, -1.0,
        0.0, -1.0, 2.0
    };
    MCMatrix *matrix = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:positiveDefiniteValues size:9] rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MCMatrixDefinitenessPositiveDefinite, @"Positive definite matrix was not recognized.");
    
    // ----- positive semidefinite -----
    double positiveSemidefiniteValues[4] = {
        1, 1,
        1, 1
    };
    matrix = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:positiveSemidefiniteValues size:4] rows:2 columns:2 leadingDimension:MCMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MCMatrixDefinitenessPositiveSemidefinite, @"Positive semidefinite matrix was not recognized.");
    
    // ----- indefinite -----
    double indefiniteValues[9] = {
        1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
        1.0, 1.0, 0.5
    };
    matrix = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:indefiniteValues size:9] rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MCMatrixDefinitenessIndefinite, @"Indefinite matrix was not recognized.");
    
    // ----- negative semidefinite -----
    
    // test case from http://www.math.drexel.edu/~tolya/301_spd_cholesky.pdf
    double negativeSemidefiniteValues[4] = {
        0.0, 0.0,
        0.0, -1.0
    };
    matrix = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:negativeSemidefiniteValues size:4] rows:2 columns:2 leadingDimension:MCMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MCMatrixDefinitenessNegativeSemidefinite, @"Negative semidefinite matrix was not recognized.");
    
    // ----- negative definite -----
    double negativeDefiniteValues[9] = {
        -1.0, 0.0, 0.0,
        0.0, -1.0, 0.0,
        0.0, 0.0, -1.0
    };
    matrix = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:negativeDefiniteValues size:9] rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MCMatrixDefinitenessNegativeDefinite, @"Negative definite matrix was not recognized.");
}

// tests can be verified using http://comnuan.com/cmnn0100c/
- (void)testConditionNumber
{
    double values[4] = {
        7.0, 3.0,
        -9.0, 2.0
    };
    MCMatrix *matrix = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:values size:4] rows:2 columns:2 leadingDimension:MCMatrixLeadingDimensionColumn];
    
    double conditionNumber = matrix.conditionNumber;
    
    XCTAssertEqualWithAccuracy(conditionNumber, 3.902, 0.001, @"condition number not calculated correctly.");
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
    
    aValues = malloc(9 * sizeof(double));
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

@end

//
//  MinorCofactorAdjugateTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/8/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"

#import "DynamicArrayUtility.h"

@interface MinorCofactorAdjugateTests : XCTestCase

@end

@implementation MinorCofactorAdjugateTests

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
    MCMatrix *minorSolutions = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:minorSolutionValues size:9]
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
    MCMatrix *cofactorSolutions = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:cofactorSolutionValues size:9]
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
    MCMatrix *original = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:values size:9]
                                               rows:3
                                            columns:3
                                   leadingDimension:MCMatrixLeadingDimensionRow];
    
    MCMatrix *adjugate = original.adjugate;
    
    double adjugateSolutionValues[9] = {
        -36.0, 77.0, -49.0,
        -0.0, 26.0, 26.0,
        108.0, -114.0, 30.0
    };
    MCMatrix *adjugateSolutions = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:adjugateSolutionValues size:9]
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

@end

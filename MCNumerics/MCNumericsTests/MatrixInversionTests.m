//
//  MatrixInversionTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/8/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"

@interface MatrixInversionTests : XCTestCase

@end

@implementation MatrixInversionTests

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
    
    MCMatrix *original = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:values size:81] rows:9 columns:9 leadingDimension:MCMatrixLeadingDimensionRow];
    
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
    
    MCMatrix *solution = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:inverseValues size:81] rows:9 columns:9 leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 9; row += 1) {
        for (int col = 0; col < 9; col += 1) {
            double a = [inverse valueAtRow:row column:col];
            double b = [solution valueAtRow:row column:col];
            double accuracy = 1.0e-3;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"Value at (%u, %u) incorrect beyond accuracy=%f", row, col, accuracy);
        }
    }
}

@end

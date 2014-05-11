//
//  MatrixInversionTests.m
//  MAVNumerics
//
//  Created by andrew mcknight on 3/8/14.
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

#import "MAVMatrix.h"

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
    
    MAVMatrix *original = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:81*sizeof(double)] rows:9 columns:9 leadingDimension:MAVMatrixLeadingDimensionRow];
    
    MAVMatrix *inverse = original.inverse;
    
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
    
    MAVMatrix *solution = [MAVMatrix matrixWithValues:[NSData dataWithBytes:inverseValues length:81*sizeof(double)] rows:9 columns:9 leadingDimension:MAVMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 9; row += 1) {
        for (int col = 0; col < 9; col += 1) {
            double a = [inverse valueAtRow:row column:col].doubleValue;
            double b = [solution valueAtRow:row column:col].doubleValue;
            double accuracy = 1.0e-3;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"Value at (%u, %u) incorrect beyond accuracy=%f", row, col, accuracy);
        }
    }
}

@end

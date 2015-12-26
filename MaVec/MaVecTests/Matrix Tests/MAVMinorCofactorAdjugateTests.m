//
//  MAVMinorCofactorAdjugateTests.m
//  MaVec
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

@interface MAVMinorCofactorAdjugateTests : XCTestCase

@end

@implementation MAVMinorCofactorAdjugateTests

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
    size_t size = 9 * sizeof(double);
    double *values = malloc(size);
    values[0] = 1.0;
    values[1] = 2.0;
    values[2] = 3.0;
    values[3] = 4.0;
    values[4] = 5.0;
    values[5] = 6.0;
    values[6] = 7.0;
    values[7] = 8.0;
    values[8] = 9.0;
    MAVMatrix *original = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:size]
                                               rows:3
                                            columns:3
                                   leadingDimension:MAVMatrixLeadingDimensionRow];
    
    MAVMatrix *minorMatrix = original.minorMatrix;
    
    double minorSolutionValues[9] = {
        -3.0, -6.0, -3.0,
        -6.0, -12.0, -6.0,
        -3.0, -6.0, -3.0
    };
    MAVMatrix *minorSolutions = [MAVMatrix matrixWithValues:[NSData dataWithBytes:minorSolutionValues length:9*sizeof(double)]
                                                     rows:3
                                                  columns:3
                                         leadingDimension:MAVMatrixLeadingDimensionRow];
    
    for (unsigned int row = 0; row < 3; row += 1) {
        for (unsigned int col = 0; col < 3; col += 1) {
            double a = [minorMatrix valueAtRow:row column:col].doubleValue;
            double b = [minorSolutions valueAtRow:row column:col].doubleValue;
            XCTAssertEqual(a, b, @"Minor at (%u, %u) calculated incorrectly", row, col);
        }
    }
}

- (void)testCofactorCalculation
{
    size_t size = 9 * sizeof(double);
    double *values = malloc(size);
    values[0] = 1.0;
    values[1] = 2.0;
    values[2] = 3.0;
    values[3] = 4.0;
    values[4] = 5.0;
    values[5] = 6.0;
    values[6] = 7.0;
    values[7] = 8.0;
    values[8] = 9.0;
    MAVMatrix *original = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:size]
                                               rows:3
                                            columns:3
                                   leadingDimension:MAVMatrixLeadingDimensionRow];
    
    MAVMatrix *cofactorMatrix = original.cofactorMatrix;
    
    double cofactorSolutionValues[9] = {
        -3.0, 6.0, -3.0,
        6.0, -12.0, 6.0,
        -3.0, 6.0, -3.0
    };
    MAVMatrix *cofactorSolutions = [MAVMatrix matrixWithValues:[NSData dataWithBytes:cofactorSolutionValues length:9*sizeof(double)]
                                                        rows:3
                                                     columns:3
                                            leadingDimension:MAVMatrixLeadingDimensionRow];
    
    for (unsigned int row = 0; row < 3; row += 1) {
        for (unsigned int col = 0; col < 3; col += 1) {
            double a = [cofactorMatrix valueAtRow:row column:col].doubleValue;
            double b = [cofactorSolutions valueAtRow:row column:col].doubleValue;
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
    MAVMatrix *original = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:9*sizeof(double)]
                                               rows:3
                                            columns:3
                                   leadingDimension:MAVMatrixLeadingDimensionRow];
    
    MAVMatrix *adjugate = original.adjugate;
    
    double adjugateSolutionValues[9] = {
        -36.0, 77.0, -49.0,
        -0.0, 26.0, 26.0,
        108.0, -114.0, 30.0
    };
    MAVMatrix *adjugateSolutions = [MAVMatrix matrixWithValues:[NSData dataWithBytes:adjugateSolutionValues length:9*sizeof(double)]
                                                        rows:3
                                                     columns:3
                                            leadingDimension:MAVMatrixLeadingDimensionRow];
    
    for (unsigned int row = 0; row < 3; row += 1) {
        for (unsigned int col = 0; col < 3; col += 1) {
            double a = [adjugate valueAtRow:row column:col].doubleValue;
            double b = [adjugateSolutions valueAtRow:row column:col].doubleValue;
            XCTAssertEqual(a, b, @"Adjugate value at (%u, %u) calculated incorrectly", row, col);
        }
    }
}

@end

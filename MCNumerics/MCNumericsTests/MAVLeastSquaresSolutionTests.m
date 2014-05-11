//
//  MAVLeastSquaresSolutionTests.m
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

#import "MAVMatrix.h"

@interface MAVLeastSquaresSolutionTests : XCTestCase

@end

@implementation MAVLeastSquaresSolutionTests

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

- (void)testOverdeterminedSystem
{
    size_t aSize = 6 * sizeof(double);
    size_t bSize = 3 * sizeof(double);
    double *aVals = malloc(aSize);
    double *bVals = malloc(bSize);
    aVals[0] = 1.0;
    aVals[1] = 1.0;
    aVals[2] = 1.0;
    aVals[3] = 1.0;
    aVals[4] = -1.0;
    aVals[5] = 1.0;
    
    bVals[0] = 2.0;
    bVals[1] = 1.0;
    bVals[2] = 3.0;
    MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:aVals length:aSize] rows:3 columns:2];
    MAVMatrix *b = [MAVMatrix matrixWithValues:[NSData dataWithBytes:bVals length:bSize] rows:3 columns:1];
    
    MAVMatrix *coefficients = [MAVMatrix solveLinearSystemWithMatrixA:a valuesB:b];
    
    size_t solutionSize = 2 * sizeof(double);
    double *solution = malloc(solutionSize);
    solution[0] = 7.0 / 4.0;
    solution[1] = 3.0 / 4.0;
    MAVMatrix *s = [MAVMatrix matrixWithValues:[NSData dataWithBytes:solution length:solutionSize] rows:2 columns:1];
    
    for (int i = 0; i < 2; i++) {
        XCTAssertEqualWithAccuracy([s valueAtRow:i column:0].doubleValue, [coefficients valueAtRow:i column:0].doubleValue, __DBL_EPSILON__ * 10.0, @"Coefficient %u incorrect", i);
    }
}

- (void)testNormalSystemOfEquations
{
    size_t aSize = 16 * sizeof(double);
    size_t bSize = 4 * sizeof(double);
    double *aVals = malloc(aSize);
    double *bVals = malloc(bSize);
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
    MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:aVals length:aSize] rows:4 columns:4];
    MAVMatrix *b = [MAVMatrix matrixWithValues:[NSData dataWithBytes:bVals length:bSize] rows:4 columns:1];
    
    MAVMatrix *coefficients = [MAVMatrix solveLinearSystemWithMatrixA:a valuesB:b];
    
    size_t solutionSize = 4 * sizeof(double);
    double *solution = malloc(solutionSize);
    solution[0] = -1.95;
    solution[1] = -0.7445;
    solution[2] = -2.5594;
    solution[3] = 1.125;
    MAVMatrix *s = [MAVMatrix matrixWithValues:[NSData dataWithBytes:solution length:solutionSize] rows:4 columns:1];
    
    for (int i = 0; i < 4; i++) {
        XCTAssertEqualWithAccuracy([s valueAtRow:i column:0].doubleValue, [coefficients valueAtRow:i column:0].doubleValue, 0.0005, @"Coefficient %u incorrect", i);
    }
}

@end

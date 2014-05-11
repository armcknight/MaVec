//
//  SingularValueDecompositionTests.m
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
#import "MAVSingularValueDecomposition.h"

@interface SingularValueDecompositionTests : XCTestCase

@end

@implementation SingularValueDecompositionTests

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

- (void)testFirstSVDTest
{
    // page 568 example 12.5 from Sauer
    size_t size = 6 * sizeof(double);
    double *values = malloc(size);
    values[0] = 0.0;
    values[1] = 3.0;
    values[2] = 0.0;
    values[3] = -0.5;
    values[4] = 0.0;
    values[5] = 0.0;
    MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:size] rows:3 columns:2];
    
    MAVSingularValueDecomposition *svd = a.singularValueDecomposition;
    
    MAVMatrix *intermediate = [MAVMatrix productOfMatrixA:svd.u andMatrixB:svd.s];
    MAVMatrix *original = [MAVMatrix productOfMatrixA:intermediate andMatrixB:svd.vT];
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 2; j++) {
            XCTAssertEqualWithAccuracy([a valueAtRow:i column:j].doubleValue, [original valueAtRow:i column:j].doubleValue, __DBL_EPSILON__ * 10.0, @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testSecondSVDTest
{
    // page 574 example 12.9 from Sauer
    size_t size = 8 * sizeof(double);
    double *values = malloc(size);
    values[0] = 3.0;
    values[1] = 2.0;
    values[2] = 2.0;
    values[3] = 4.0;
    values[4] = -2.0;
    values[5] = -1.0;
    values[6] = -3.0;
    values[7] = -5.0;
    MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:size] rows:2 columns:4];
    
    MAVSingularValueDecomposition *svd = a.singularValueDecomposition;
    
    MAVMatrix *intermediate = [MAVMatrix productOfMatrixA:svd.u andMatrixB:svd.s];
    MAVMatrix *original = [MAVMatrix productOfMatrixA:intermediate andMatrixB:svd.vT];
    
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 4; j++) {
            XCTAssertEqualWithAccuracy([a valueAtRow:i column:j].doubleValue, [original valueAtRow:i column:j].doubleValue, __DBL_EPSILON__ * 10.0, @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

@end

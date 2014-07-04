//
//  MAVLUDecompositionTests.m
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
#import "MAVMutableMatrix.h"
#import "MAVLUFactorization.h"

@interface MAVLUDecompositionTests : XCTestCase

@end

@implementation MAVLUDecompositionTests

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

- (void)testLUDecompositionOfSquareMatrix1
{
    // pg 85 of Sauer
    size_t size = 9 * sizeof(double);
    double *values = malloc(size);
    values[0] = 1.0;
    values[1] = 2.0;
    values[2] = -3.0;
    values[3] = 2.0;
    values[4] = 1.0;
    values[5] = 1.0;
    values[6] = -1.0;
    values[7] = -2.0;
    values[8] = 1.0;
    
    MAVMatrix *m = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:size] rows:3 columns:3];
    
    MAVLUFactorization *f = m.luFactorization;
    
    MAVMatrix *product = [[[f.permutationMatrix mutableCopy] multiplyByMatrix:f.lowerTriangularMatrix] multiplyByMatrix:f.upperTriangularMatrix];
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            double a = [m valueAtRow:i column:j].doubleValue;
            double b = [product valueAtRow:i column:j].doubleValue;
            XCTAssertEqualWithAccuracy(a, b, 0.0000000000000003, @"Value at row %i and column %i was not recomputed correctly", i, j);
        }
    }
}

- (void)testLUDecompositionOfSquareMatrix2
{
    // pg 85 of Sauer
    size_t size = 4 * sizeof(double);
    double *values = malloc(size);
    values[0] = 1.0;
    values[1] = 3.0;
    values[2] = 1.0;
    values[3] = -4.0;
    
    MAVMatrix *m = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:size] rows:2 columns:2];
    
    MAVLUFactorization *f = m.luFactorization;
    
    MAVMatrix *product = [[[f.permutationMatrix mutableCopy] multiplyByMatrix:f.lowerTriangularMatrix] multiplyByMatrix:f.upperTriangularMatrix];
    
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            double a = [m valueAtRow:i column:j].doubleValue;
            double b = [product valueAtRow:i column:j].doubleValue;
            XCTAssertEqualWithAccuracy(a, b, 0.0000000000000003, @"Value at row %i and column %i was not recomputed correctly", i, j);
        }
    }
}

@end

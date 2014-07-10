//
//  MAVMAVMatrixMultiplicationTests.m
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
#import "MAVVector.h"

@interface MAVMatrixMultiplicationTests : XCTestCase

@end

@implementation MAVMatrixMultiplicationTests

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

- (void)testMultiplySquareMatrices
{
    size_t size = 4 * sizeof(double);
    double *aVals = malloc(size);
    double *bVals = malloc(size);
    aVals[0] = 1.0;
    aVals[1] = 3.0;
    aVals[2] = 2.0;
    aVals[3] = 5.0;
    
    bVals[0] = 6.0;
    bVals[1] = 8.0;
    bVals[2] = 7.0;
    bVals[3] = 9.0;
    MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:aVals length:size] rows:2 columns:2];
    MAVMatrix *b = [MAVMatrix matrixWithValues:[NSData dataWithBytes:bVals length:size] rows:2 columns:2];
    
    MAVMatrix *p = [[a mutableCopy] multiplyByMatrix:b];
    
    double *solution = malloc(size);
    solution[0] = 22.0;
    solution[1] = 58.0;
    solution[2] = 25.0;
    solution[3] = 66.0;
    
    MAVMatrix *s = [MAVMatrix matrixWithValues:[NSData dataWithBytes:solution length:size] rows:2 columns:2];
    
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            XCTAssertEqual([p valueAtRow:i column:j].doubleValue, [s valueAtRow:i column:j].doubleValue, @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testMultiplyRectangularMatrices
{
    size_t aSize = 6 * sizeof(double);
    size_t bSize = 9 * sizeof(double);
    double *aVals = malloc(aSize);
    double *bVals = malloc(bSize);
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
    MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:aVals length:aSize] rows:2 columns:3];
    MAVMatrix *b = [MAVMatrix matrixWithValues:[NSData dataWithBytes:bVals length:bSize] rows:3 columns:3];
    
    MAVMatrix *p = [[a mutableCopy] multiplyByMatrix:b];
    
    double *solution = malloc(aSize);
    solution[0] = -3.0;
    solution[1] = 8.0;
    solution[2] = -3.0;
    solution[3] = 10.0;
    solution[4] = -3.0;
    solution[5] = 12.0;
    MAVMatrix *s = [MAVMatrix matrixWithValues:[NSData dataWithBytes:solution length:aSize] rows:2 columns:3];
    
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([p valueAtRow:i column:j].doubleValue, [s valueAtRow:i column:j].doubleValue, @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testMatrixVectorMultiplication
{
    double matrixValues[9] = {
        -9.0, 4.0, -9.0,
        -7.0, -4.0, -4.0,
        9.0, 7.0, 1.0
    };
    MAVMatrix *matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:matrixValues length:9*sizeof(double)]
                                             rows:3
                                          columns:3
                                 leadingDimension:MAVMatrixLeadingDimensionRow];
    
    double vectorValues[3] = {
        9.0, -8.0, -4.0
    };
    MAVVector *vector = [MAVVector vectorWithValues:[NSData dataWithBytes:vectorValues length:3*sizeof(double)] length:3];
    
    MAVVector *product = [[[matrix mutableCopy] multiplyByVector:vector] columnVectorForColumn:0];
    double productSolution[3] = {
        -77.0, -15.0, 21.0
    };
    MAVVector *solutionVector = [MAVVector vectorWithValues:[NSData dataWithBytes:productSolution length:3*sizeof(double)] length:3];
    
    XCTAssert([product isEqualToVector:solutionVector], @"Product of matrix and vector incorrectly calculated.");
}

- (void)testMatrixScalarMultiplication
{
    double matrixValues[9] = {
        -9.0, 4.0, -9.0,
        -7.0, -4.0, -4.0,
        9.0, 7.0, 1.0
    };
    MAVMatrix *matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:matrixValues length:9*sizeof(double)]
                                             rows:3
                                          columns:3
                                 leadingDimension:MAVMatrixLeadingDimensionRow];
    
    MAVMatrix *product = [[matrix mutableCopy] multiplyByScalar:@7.2];
    
    double solutionValues[9] = {
        -64.8, 28.8, -64.8,
        -50.4, -28.8, -28.8,
        64.8, 50.4, 7.2
    };
    MAVMatrix *solution = [MAVMatrix matrixWithValues:[NSData dataWithBytes:solutionValues length:9*sizeof(double)]
                                               rows:3
                                            columns:3
                                   leadingDimension:MAVMatrixLeadingDimensionRow];
    
    XCTAssert([product isEqualToMatrix:solution], @"Product of matrix and scalar incorrectly calculated.");
}

- (void)testMatrixPower
{
    double matrixValues[9] = {
        -9.0, 4.0, -9.0,
        -7.0, -4.0, -4.0,
        9.0, 7.0, 1.0
    };
    MAVMatrix *matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:matrixValues length:9*sizeof(double)]
                                             rows:3
                                          columns:3
                                 leadingDimension:MAVMatrixLeadingDimensionRow];
    
    MAVMatrix *power = [[matrix mutableCopy] raiseToPower:4];
    
    double solutionValues[9] = {
        -12317.0, 8660.0, -16241.0,
        -12815.0, -3600.0, -8020.0,
        17281.0, 11695.0, 6013.0
    };
    MAVMatrix *solution = [MAVMatrix matrixWithValues:[NSData dataWithBytes:solutionValues length:9*sizeof(double)]
                                               rows:3
                                            columns:3
                                   leadingDimension:MAVMatrixLeadingDimensionRow];
    
    XCTAssert([power isEqualToMatrix:solution], @"Power of matrix incorrectly calculated.");
}

@end

//
//  MAVQRDecompositionTests.m
//  MaVec
//
//  Created by Andrew McKnight on 3/8/14.
//
//  Copyright © 2015 AMProductions
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

@interface MAVQRDecompositionTests : XCTestCase

@end

@implementation MAVQRDecompositionTests

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

- (void)testQRDecompositionOfSquareMatrix
{
    // example from wikipedia: http://en.wikipedia.org/wiki/QR_decomposition#Example
    MAVMatrix *source = [MAVMatrix matrixWithColumnVectors:@[
                                                           [MAVVector vectorWithValuesInArray:@[@12.0, @6.0, @(-4.0)]],
                                                           [MAVVector vectorWithValuesInArray:@[@(-51.0), @167.0, @24.0]],
                                                           [MAVVector vectorWithValuesInArray:@[@4.0, @(-68.0), @(-41.0)]],
                                                           ]];
    
    MAVQRFactorization *qrFactorization = source.qrFactorization;
    
    MAVMatrix *qrProduct = [[qrFactorization.q mutableCopy] multiplyByMatrix:qrFactorization.r];
    
    for (unsigned int row = 0; row < qrProduct.rows; row += 1) {
        for (unsigned int col = 0; col < qrProduct.columns; col += 1) {
            double a = [source valueAtRow:row column:col].doubleValue;
            double b = [qrProduct valueAtRow:row column:col].doubleValue;
            double accuracy = 1.0e-10;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"value at (%u, %u) incorrect beyond accuracy = %f", row, col, accuracy);
        }
    }
}

- (void)testQRDecompositionOfGeneralMatrix
{
    double values[12] = {
        0.0, 2.0, 2.0, 0.0, 2.0, 2.0,
        2.0, -1.0, -1.0, 1.5, -1.0, -1.0
    };
    MAVMatrix *source = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:12*sizeof(double)]
                                             rows:6
                                          columns:2
                                 leadingDimension:MAVMatrixLeadingDimensionColumn];
    
    MAVQRFactorization *qrFactorization = source.qrFactorization.thinFactorization;
    
    // need to take the 'thin QR factorization' of the general rectangular matrix
    MAVMatrix *qrProduct = [[qrFactorization.q mutableCopy] multiplyByMatrix:qrFactorization.r];
    
    for (unsigned int row = 0; row < qrProduct.rows; row += 1) {
        for (unsigned int col = 0; col < qrProduct.columns; col += 1) {
            double a = [source valueAtRow:row column:col].doubleValue;
            double b = [qrProduct valueAtRow:row column:col].doubleValue;
            double accuracy = 1.0e-10;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"value at (%u, %u) incorrect beyond accuracy = %f", row, col, accuracy);
        }
    }
}

@end

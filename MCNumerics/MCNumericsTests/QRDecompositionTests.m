//
//  QRDecompositionTests.m
//  MCNumerics
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

#import "MCMatrix.h"
#import "MCQRFactorization.h"
#import "MCVector.h"

@interface QRDecompositionTests : XCTestCase

@end

@implementation QRDecompositionTests

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
    MCMatrix *source = [MCMatrix matrixWithColumnVectors:@[
                                                           [MCVector vectorWithValuesInArray:@[@12, @6, @(-4)]],
                                                           [MCVector vectorWithValuesInArray:@[@(-51), @167, @24]],
                                                           [MCVector vectorWithValuesInArray:@[@4, @(-68), @(-41)]],
                                                           ]];
    
    MCQRFactorization *qrFactorization = source.qrFactorization;
    
    MCMatrix *qrProduct = [MCMatrix productOfMatrixA:qrFactorization.q andMatrixB:qrFactorization.r];
    
    for(int row = 0; row < qrProduct.rows; row += 1) {
        for(int col = 0; col < qrProduct.columns; col += 1) {
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
    MCMatrix *source = [MCMatrix matrixWithValues:[NSData dataWithBytes:values length:12*sizeof(double)]
                                             rows:6
                                          columns:2
                                 leadingDimension:MCMatrixLeadingDimensionColumn];
    
    MCQRFactorization *qrFactorization = source.qrFactorization.thinFactorization;
    
    // need to take the 'thin QR factorization' of the general rectangular matrix
    MCMatrix *qrProduct = [MCMatrix productOfMatrixA:qrFactorization.q andMatrixB:qrFactorization.r];
    
    for(int row = 0; row < qrProduct.rows; row += 1) {
        for(int col = 0; col < qrProduct.columns; col += 1) {
            double a = [source valueAtRow:row column:col].doubleValue;
            double b = [qrProduct valueAtRow:row column:col].doubleValue;
            double accuracy = 1.0e-10;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"value at (%u, %u) incorrect beyond accuracy = %f", row, col, accuracy);
        }
    }
}

@end

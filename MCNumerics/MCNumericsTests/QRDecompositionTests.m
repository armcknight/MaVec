//
//  QRDecompositionTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/8/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
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
    
    for(NSUInteger row = 0; row < qrProduct.rows; row += 1) {
        for(NSUInteger col = 0; col < qrProduct.columns; col += 1) {
            double a = [source valueAtRow:row column:col];
            double b = [qrProduct valueAtRow:row column:col];
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
    MCMatrix *source = [MCMatrix matrixWithValues:values
                                             rows:6
                                          columns:2
                                 leadingDimension:MCMatrixLeadingDimensionColumn];
    
    MCQRFactorization *qrFactorization = source.qrFactorization.thinFactorization;
    
    // need to take the 'thin QR factorization' of the general rectangular matrix
    MCMatrix *qrProduct = [MCMatrix productOfMatrixA:qrFactorization.q andMatrixB:qrFactorization.r];
    
    for(NSUInteger row = 0; row < qrProduct.rows; row += 1) {
        for(NSUInteger col = 0; col < qrProduct.columns; col += 1) {
            double a = [source valueAtRow:row column:col];
            double b = [qrProduct valueAtRow:row column:col];
            double accuracy = 1.0e-10;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"value at (%u, %u) incorrect beyond accuracy = %f", row, col, accuracy);
        }
    }
}

@end

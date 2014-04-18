//
//  MatrixArithmeticTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/8/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"

@interface MatrixArithmeticTests : XCTestCase

@end

@implementation MatrixArithmeticTests

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

- (void)testMatrixAddition
{
    size_t size = 9 * sizeof(double);
    double *aValues = malloc(size);
    aValues[0] = 1.0;
    aValues[1] = 2.0;
    aValues[2] = 3.0;
    aValues[3] = 4.0;
    aValues[4] = 5.0;
    aValues[5] = 6.0;
    aValues[6] = 7.0;
    aValues[7] = 8.0;
    aValues[8] = 9.0;
    MCMatrix *a = [MCMatrix matrixWithValues:[NSData dataWithBytes:aValues length:size] rows:3 columns:3];
    
    size = 9 * sizeof(double);
    double *bValues = malloc(size);
    bValues[0] = 9.0;
    bValues[1] = 8.0;
    bValues[2] = 7.0;
    bValues[3] = 6.0;
    bValues[4] = 5.0;
    bValues[5] = 4.0;
    bValues[6] = 3.0;
    bValues[7] = 2.0;
    bValues[8] = 1.0;
    MCMatrix *b = [MCMatrix matrixWithValues:[NSData dataWithBytes:bValues length:size] rows:3 columns:3];
    
    MCMatrix *sum = [MCMatrix sumOfMatrixA:a andMatrixB:b];
    
    for (int i = 0; i < 3; i++) {
        for (int j; j < 3; j++) {
            XCTAssertEqual(10.0, [sum valueAtRow:i column:j].doubleValue, @"Value at %u,%u incorrectly added", i, j);
        }
    }
    
    XCTAssertThrows([MCMatrix sumOfMatrixA:[MCMatrix matrixWithRows:4 columns:5 precision:MCValuePrecisionDouble]
                                andMatrixB:[MCMatrix matrixWithRows:5 columns:5 precision:MCValuePrecisionDouble]], @"Should throw an exception for mismatched row amount");
    XCTAssertThrows([MCMatrix sumOfMatrixA:[MCMatrix matrixWithRows:5 columns:4 precision:MCValuePrecisionDouble]
                                andMatrixB:[MCMatrix matrixWithRows:5 columns:5 precision:MCValuePrecisionDouble]], @"Should throw an exception for mismatched column amount");
}

- (void)testMatrixSubtraction
{
    size_t size = 9 * sizeof(double);
    double *aValues = malloc(size);
    aValues[0] = 10.0;
    aValues[1] = 10.0;
    aValues[2] = 10.0;
    aValues[3] = 10.0;
    aValues[4] = 10.0;
    aValues[5] = 10.0;
    aValues[6] = 10.0;
    aValues[7] = 10.0;
    aValues[8] = 10.0;
    MCMatrix *a = [MCMatrix matrixWithValues:[NSData dataWithBytes:aValues length:size] rows:3 columns:3];
    
    double *bValues = malloc(size);
    bValues[0] = 9.0;
    bValues[1] = 8.0;
    bValues[2] = 7.0;
    bValues[3] = 6.0;
    bValues[4] = 5.0;
    bValues[5] = 4.0;
    bValues[6] = 3.0;
    bValues[7] = 2.0;
    bValues[8] = 1.0;
    MCMatrix *b = [MCMatrix matrixWithValues:[NSData dataWithBytes:bValues length:size] rows:3 columns:3];
    
    double *sValues = malloc(size);
    sValues[0] = 1.0;
    sValues[1] = 2.0;
    sValues[2] = 3.0;
    sValues[3] = 4.0;
    sValues[4] = 5.0;
    sValues[5] = 6.0;
    sValues[6] = 7.0;
    sValues[7] = 8.0;
    sValues[8] = 9.0;
    MCMatrix *solution = [MCMatrix matrixWithValues:[NSData dataWithBytes:sValues length:size] rows:3 columns:3];
    
    MCMatrix *difference = [MCMatrix differenceOfMatrixA:a andMatrixB:b];
    
    for (int i = 0; i < 3; i++) {
        for (int j; j < 3; j++) {
            XCTAssertEqual([solution valueAtRow:i column:j].doubleValue, [difference valueAtRow:i column:j].doubleValue, @"Value at %u,%u incorrectly subtracted", i, j);
        }
    }
    
    XCTAssertThrows([MCMatrix sumOfMatrixA:[MCMatrix matrixWithRows:4 columns:5 precision:MCValuePrecisionDouble]
                                andMatrixB:[MCMatrix matrixWithRows:5 columns:5 precision:MCValuePrecisionDouble]], @"Should throw an exception for mismatched row amount");
    XCTAssertThrows([MCMatrix sumOfMatrixA:[MCMatrix matrixWithRows:5 columns:4 precision:MCValuePrecisionDouble]
                                andMatrixB:[MCMatrix matrixWithRows:5 columns:5 precision:MCValuePrecisionDouble]], @"Should throw an exception for mismatched column amount");
}

@end

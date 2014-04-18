//
//  LUDecompositionTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/8/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"
#import "MCLUFactorization.h"

@interface LUDecompositionTests : XCTestCase

@end

@implementation LUDecompositionTests

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
    
    MCMatrix *m = [MCMatrix matrixWithValues:[NSData dataWithBytes:values length:size] rows:3 columns:3];
    
    MCLUFactorization *f = m.luFactorization;
    
    //    MCMatrix *i = [MCMatrix productOfMatrixA:f.lowerTriangularMatrix andMatrixB:f.upperTriangularMatrix];
    //    MCMatrix *product = [MCMatrix productOfMatrixA:i andMatrixB:f.permutationMatrix];
    MCMatrix *pl = [MCMatrix productOfMatrixA:f.permutationMatrix andMatrixB:f.lowerTriangularMatrix];
    MCMatrix *product = [MCMatrix productOfMatrixA:pl andMatrixB:f.upperTriangularMatrix];
    
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
    
    MCMatrix *m = [MCMatrix matrixWithValues:[NSData dataWithBytes:values length:size] rows:2 columns:2];
    
    MCLUFactorization *f = m.luFactorization;
    
    MCMatrix *pl = [MCMatrix productOfMatrixA:f.permutationMatrix andMatrixB:f.lowerTriangularMatrix];
    MCMatrix *product = [MCMatrix productOfMatrixA:pl andMatrixB:f.upperTriangularMatrix];
    
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            double a = [m valueAtRow:i column:j].doubleValue;
            double b = [product valueAtRow:i column:j].doubleValue;
            XCTAssertEqualWithAccuracy(a, b, 0.0000000000000003, @"Value at row %i and column %i was not recomputed correctly", i, j);
        }
    }
}

@end

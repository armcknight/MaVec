//
//  MatrixOperationTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/8/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"

@interface MatrixOperationTests : XCTestCase

@end

@implementation MatrixOperationTests

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

- (void)testTransposition
{
    size_t size = 9 * sizeof(double);
    double *aVals= malloc(size);
    aVals[0] = 1.0;
    aVals[1] = 2.0;
    aVals[2] = 3.0;
    aVals[3] = 4.0;
    aVals[4] = 5.0;
    aVals[5] = 6.0;
    aVals[6] = 7.0;
    aVals[7] = 8.0;
    aVals[8] = 9.0;
    MCMatrix *a = [MCMatrix matrixWithValues:[NSData dataWithBytes:aVals length:size] rows:3 columns:3];
    
    double *tVals= malloc(size);
    tVals[0] = 1.0;
    tVals[1] = 4.0;
    tVals[2] = 7.0;
    tVals[3] = 2.0;
    tVals[4] = 5.0;
    tVals[5] = 8.0;
    tVals[6] = 3.0;
    tVals[7] = 6.0;
    tVals[8] = 9.0;
    MCMatrix *t = [MCMatrix matrixWithValues:[NSData dataWithBytes:tVals length:size] rows:3 columns:3].transpose;
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([a valueAtRow:i column:j], [t valueAtRow:i column:j], @"Value at row %u and column %u incorrect", i, j);
        }
    }
    
    aVals= malloc(size);
    aVals[0] = 1.0;
    aVals[1] = 2.0;
    aVals[2] = 3.0;
    aVals[3] = 4.0;
    aVals[4] = 5.0;
    aVals[5] = 6.0;
    aVals[6] = 7.0;
    aVals[7] = 8.0;
    aVals[8] = 9.0;
    a = [MCMatrix matrixWithValues:[NSData dataWithBytes:tVals length:size] rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow];
    
    tVals= malloc(size);
    tVals[0] = 1.0;
    tVals[1] = 4.0;
    tVals[2] = 7.0;
    tVals[3] = 2.0;
    tVals[4] = 5.0;
    tVals[5] = 8.0;
    tVals[6] = 3.0;
    tVals[7] = 6.0;
    tVals[8] = 9.0;
    t = [MCMatrix matrixWithValues:[NSData dataWithBytes:tVals length:size] rows:3 columns:3 leadingDimension:MCMatrixLeadingDimensionRow].transpose;
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([a valueAtRow:i column:j], [t valueAtRow:i column:j], @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

@end

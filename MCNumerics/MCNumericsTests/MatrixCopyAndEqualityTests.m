//
//  MatrixCopyAndEqualityTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/8/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"

@interface MatrixCopyAndEqualityTests : XCTestCase

@end

@implementation MatrixCopyAndEqualityTests

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

- (void)testMatrixEqualityComparison
{
    int size = 16;
    double *aValues = malloc(size * sizeof(double));
    for (int i = 0; i < size; i++) {
        aValues[i] = i;
    }
    double *bValues = malloc(size * sizeof(double));
    for (int i = 0; i < size; i++) {
        bValues[i] = i;
    }
    
    MCMatrix *a = [MCMatrix matrixWithValues:[NSData dataWithBytes:aValues length:16*sizeof(double)] rows:4 columns:4];
    MCMatrix *b = [MCMatrix matrixWithValues:[NSData dataWithBytes:bValues length:16*sizeof(double)] rows:4 columns:4];
    
    XCTAssertEqual([a isEqual:[NSArray array]], NO, @"Thought an MCMatrix was equal to an NSArray using isEqual:");
    XCTAssertEqual([a isEqual:a], YES, @"Couldn't tell an MCMatrix was equal to itself (same instance object) using isEqual:");
    XCTAssertEqual([a isEqual:b], YES, @"Couldn't tell different MCMatrix instances with identical values were equal using isEqual:");
    XCTAssertEqual([a isEqualToMatrix:(MCMatrix *)[NSArray array]], NO, @"Thought an MCMatrix was equal to an NSArray using isEqualToMatrix:");
    XCTAssertEqual([a isEqualToMatrix:a], YES, @"Couldn't tell an MCMatrix was equal to itself (same instance object) using isEqualToMatrix:");
    XCTAssertEqual([a isEqualToMatrix:b], YES, @"Couldn't tell different MCMatrix instances with identical values were equal using isEqualToMatrix:");
    
    double *cValues = malloc(size * sizeof(double));
    for (int i = 0; i < size; i++) {
        cValues[i] = i;
    }
    MCMatrix *c = [MCMatrix matrixWithValues:[NSData dataWithBytes:cValues length:16*sizeof(double)] rows:4 columns:4];
    MCMatrix *cr = [MCMatrix matrixWithValues:[c valuesWithLeadingDimension:MCMatrixLeadingDimensionRow] rows:c.rows columns:c.columns leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            NSNumber *oldCValue = [c valueAtRow:i column:j];
            [c setEntryAtRow:i column:j toValue:@(-1.0)];
            NSNumber *oldCRValue = [cr valueAtRow:i column:j];
            [cr setEntryAtRow:i column:j toValue:@(-1.0)];
            XCTAssertEqual([a isEqual:c], NO, @"Couldn't tell two MCMatrix objects differing at value %u are unequal using isEqual:", i);
            XCTAssertEqual([a isEqualToMatrix:c], NO, @"Couldn't tell two MCMatrix objects differing at value %u are unequal using isEqualToMatrix:", i);
            XCTAssertEqual([a isEqual:cr], NO, @"Couldn't tell two MCMatrix objects with different value storage formats differing at value %u are unequal using isEqual:", i);
            XCTAssertEqual([a isEqualToMatrix:cr], NO, @"Couldn't tell two MCMatrix objects with different value storage formats  differing at value %u are unequal using isEqualToMatrix:", i);
            [c setEntryAtRow:i column:j toValue:oldCValue];
            [cr setEntryAtRow:i column:j toValue:oldCRValue];
        }
    }
    
    int smallerSize = 12;
    double *dValues = malloc(smallerSize * sizeof(double));
    for (int i = 0; i < smallerSize; i++) {
        dValues[i] = i;
    }
    MCMatrix *d = [MCMatrix matrixWithValues:[NSData dataWithBytes:dValues length:12*sizeof(double)] rows:4 columns:3];
    XCTAssert([a isEqual:d], @"Couldn't tell two MCMatrix objects with different amounts of columns are unequal using isEqual:");
    XCTAssert([a isEqualToMatrix:d], @"Couldn't tell two MCMatrix objects with different amounts of columns are unequal using isEqualToMatrix:");
    dValues = malloc(smallerSize * sizeof(double));
    for (int i = 0; i < smallerSize; i++) {
        dValues[i] = i;
    }
    d = [MCMatrix matrixWithValues:[NSData dataWithBytes:dValues length:12*sizeof(double)] rows:3 columns:4];
    XCTAssert([a isEqual:d], @"Couldn't tell two MCMatrix objects with different amounts of rows are unequal using isEqual:");
    XCTAssert([a isEqualToMatrix:d], @"Couldn't tell two MCMatrix objects with different amounts of rows are unequal using isEqualToMatrix:");
    
    smallerSize = 9;
    dValues = malloc(smallerSize * sizeof(double));
    for (int i = 0; i < smallerSize; i++) {
        dValues[i] = i;
    }
    d = [MCMatrix matrixWithValues:[NSData dataWithBytes:dValues length:9*sizeof(double)] rows:3 columns:3];
    XCTAssert(![a isEqual:d], @"Couldn't tell two MCMatrix objects with different amounts of rows and columns are unequal using isEqual:");
    XCTAssert(![a isEqualToMatrix:d], @"Couldn't tell two MCMatrix objects with different amounts of rows and  columns are unequal using isEqualToMatrix:");
    
    MCMatrix *r = [MCMatrix matrixWithValues:[b valuesWithLeadingDimension:MCMatrixLeadingDimensionRow] rows:b.rows columns:b.columns leadingDimension:MCMatrixLeadingDimensionRow];
    r.leadingDimension = MCMatrixLeadingDimensionRow;
    XCTAssert([a isEqual:r], @"Couldn't tell two MCMatrix objects with identical values but different storage formats were equal using isEqual:");
    XCTAssert([a isEqualToMatrix:r], @"Couldn't tell two MCMatrix objects with identical values but different storage formats were equal using isEqualToMatrix:");
}

- (void)testMatrixCopy
{
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
    
    MCMatrix *a = [MCMatrix matrixWithValues:[NSData dataWithBytes:values length:size] rows:3 columns:3];
    a.luFactorization;
    a.singularValueDecomposition;
    a.transpose;
    
    MCMatrix *b = a.copy;
    
    XCTAssertNotEqual(a.self, b.self, @"The copied matrix is the same instance as its source.");
    XCTAssertTrue([a isEqualToMatrix:b], @"Matrix copy is not equal to its source.");
}

@end

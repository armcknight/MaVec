//
//  MAVMatrixCopyAndEqualityTests.m
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

@interface MAVMatrixCopyAndEqualityTests : XCTestCase

@end

@implementation MAVMatrixCopyAndEqualityTests

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
    
    MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:aValues length:16*sizeof(double)] rows:4 columns:4];
    MAVMatrix *b = [MAVMatrix matrixWithValues:[NSData dataWithBytes:bValues length:16*sizeof(double)] rows:4 columns:4];
    
    XCTAssertEqual([a isEqual:[NSArray array]], NO, @"Thought an MAVMatrix was equal to an NSArray using isEqual:");
    XCTAssertEqual([a isEqual:a], YES, @"Couldn't tell an MAVMatrix was equal to itself (same instance object) using isEqual:");
    XCTAssertEqual([a isEqual:b], YES, @"Couldn't tell different MAVMatrix instances with identical values were equal using isEqual:");
    XCTAssertEqual([a isEqualToMatrix:(MAVMatrix *)[NSArray array]], NO, @"Thought an MAVMatrix was equal to an NSArray using isEqualToMatrix:");
    XCTAssertEqual([a isEqualToMatrix:a], YES, @"Couldn't tell an MAVMatrix was equal to itself (same instance object) using isEqualToMatrix:");
    XCTAssertEqual([a isEqualToMatrix:b], YES, @"Couldn't tell different MAVMatrix instances with identical values were equal using isEqualToMatrix:");
    
    double *cValues = malloc(size * sizeof(double));
    for (int i = 0; i < size; i++) {
        cValues[i] = i;
    }
    MAVMatrix *c = [MAVMatrix matrixWithValues:[NSData dataWithBytes:cValues length:16*sizeof(double)] rows:4 columns:4];
    MAVMatrix *cr = [MAVMatrix matrixWithValues:[c valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow] rows:c.rows columns:c.columns leadingDimension:MAVMatrixLeadingDimensionRow];
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            NSNumber *oldCValue = [c valueAtRow:i column:j];
            [c setEntryAtRow:i column:j toValue:@(-1.0)];
            NSNumber *oldCRValue = [cr valueAtRow:i column:j];
            [cr setEntryAtRow:i column:j toValue:@(-1.0)];
            XCTAssertEqual([a isEqual:c], NO, @"Couldn't tell two MAVMatrix objects differing at value %u are unequal using isEqual:", i);
            XCTAssertEqual([a isEqualToMatrix:c], NO, @"Couldn't tell two MAVMatrix objects differing at value %u are unequal using isEqualToMatrix:", i);
            XCTAssertEqual([a isEqual:cr], NO, @"Couldn't tell two MAVMatrix objects with different value storage formats differing at value %u are unequal using isEqual:", i);
            XCTAssertEqual([a isEqualToMatrix:cr], NO, @"Couldn't tell two MAVMatrix objects with different value storage formats  differing at value %u are unequal using isEqualToMatrix:", i);
            [c setEntryAtRow:i column:j toValue:oldCValue];
            [cr setEntryAtRow:i column:j toValue:oldCRValue];
        }
    }
    
    int smallerSize = 12;
    double *dValues = malloc(smallerSize * sizeof(double));
    for (int i = 0; i < smallerSize; i++) {
        dValues[i] = i;
    }
    MAVMatrix *d = [MAVMatrix matrixWithValues:[NSData dataWithBytes:dValues length:12*sizeof(double)] rows:4 columns:3];
    XCTAssert(![a isEqual:d], @"Couldn't tell two MAVMatrix objects with different amounts of columns are unequal using isEqual:");
    XCTAssert(![a isEqualToMatrix:d], @"Couldn't tell two MAVMatrix objects with different amounts of columns are unequal using isEqualToMatrix:");
    dValues = malloc(smallerSize * sizeof(double));
    for (int i = 0; i < smallerSize; i++) {
        dValues[i] = i;
    }
    d = [MAVMatrix matrixWithValues:[NSData dataWithBytes:dValues length:12*sizeof(double)] rows:3 columns:4];
    XCTAssert(![a isEqual:d], @"Couldn't tell two MAVMatrix objects with different amounts of rows are unequal using isEqual:");
    XCTAssert(![a isEqualToMatrix:d], @"Couldn't tell two MAVMatrix objects with different amounts of rows are unequal using isEqualToMatrix:");
    
    smallerSize = 9;
    dValues = malloc(smallerSize * sizeof(double));
    for (int i = 0; i < smallerSize; i++) {
        dValues[i] = i;
    }
    d = [MAVMatrix matrixWithValues:[NSData dataWithBytes:dValues length:9*sizeof(double)] rows:3 columns:3];
    XCTAssert(![a isEqual:d], @"Couldn't tell two MAVMatrix objects with different amounts of rows and columns are unequal using isEqual:");
    XCTAssert(![a isEqualToMatrix:d], @"Couldn't tell two MAVMatrix objects with different amounts of rows and  columns are unequal using isEqualToMatrix:");
    
    MAVMatrix *r = [MAVMatrix matrixWithValues:[b valuesWithLeadingDimension:MAVMatrixLeadingDimensionRow] rows:b.rows columns:b.columns leadingDimension:MAVMatrixLeadingDimensionRow];
    r.leadingDimension = MAVMatrixLeadingDimensionRow;
    XCTAssert([a isEqual:r], @"Couldn't tell two MAVMatrix objects with identical values but different storage formats were equal using isEqual:");
    XCTAssert([a isEqualToMatrix:r], @"Couldn't tell two MAVMatrix objects with identical values but different storage formats were equal using isEqualToMatrix:");
}

- (void)testMatrixCopy
{
    MAVMatrix *a = [MAVMatrix randomMatrixWithRows:3 columns:3 precision:MCKValuePrecisionDouble];
    MAVMatrix *b = a.copy;
    
    XCTAssertNotEqual(a.self, b.self, @"The copied matrix is the same instance as its source.");
    XCTAssertTrue([a isEqualToMatrix:b], @"Matrix copy is not equal to its source.");
    
    a = [MAVMatrix randomSymmetricMatrixOfOrder:3 precision:MCKValuePrecisionDouble];
    b = a.copy;
    
    XCTAssertNotEqual(a.self, b.self, @"The copied matrix is the same instance as its source.");
    XCTAssertTrue([a isEqualToMatrix:b], @"Matrix copy is not equal to its source.");
    
    a = [MAVMatrix randomBandMatrixOfOrder:3 upperCodiagonals:2 lowerCodiagonals:1 precision:MCKValuePrecisionDouble];
    b = a.copy;
    
    XCTAssertNotEqual(a.self, b.self, @"The copied matrix is the same instance as its source.");
    XCTAssertTrue([a isEqualToMatrix:b], @"Matrix copy is not equal to its source.");
    
    a = [MAVMatrix randomDiagonalMatrixOfOrder:3 precision:MCKValuePrecisionDouble];
    b = a.copy;
    
    XCTAssertNotEqual(a.self, b.self, @"The copied matrix is the same instance as its source.");
    XCTAssertTrue([a isEqualToMatrix:b], @"Matrix copy is not equal to its source.");
    
    a = [MAVMatrix randomMatrixOfOrder:3 definiteness:MAVMatrixDefinitenessIndefinite precision:MCKValuePrecisionDouble];
    b = a.copy;
    
    XCTAssertNotEqual(a.self, b.self, @"The copied matrix is the same instance as its source.");
    XCTAssertTrue([a isEqualToMatrix:b], @"Matrix copy is not equal to its source.");
    
    a = [MAVMatrix randomTriangularMatrixOfOrder:3 triangularComponent:MAVMatrixTriangularComponentLower precision:MCKValuePrecisionDouble];
    b = a.copy;
    
    XCTAssertNotEqual(a.self, b.self, @"The copied matrix is the same instance as its source.");
    XCTAssertTrue([a isEqualToMatrix:b], @"Matrix copy is not equal to its source.");
}

@end

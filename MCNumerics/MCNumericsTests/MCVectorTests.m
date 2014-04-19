//
//  MCVectorTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 2/16/14.
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

#import "MCVector.h"

@interface MCVectorTests : XCTestCase

@end

@implementation MCVectorTests

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

- (void)testVectorDotProduct
{
    NSNumber *dotProduct = [MCVector dotProductOfVectorA:[MCVector vectorWithValuesInArray:@[
                                                                                          @1,
                                                                                          @3,
                                                                                          @(-5)]]
                                           vectorB:[MCVector vectorWithValuesInArray:@[
                                                                                          @4,
                                                                                          @(-2),
                                                                                          @(-1)]]];
    XCTAssertEqual(dotProduct.doubleValue, 3.0, @"Dot product not computed correctly");
    
    dotProduct = [MCVector dotProductOfVectorA:[MCVector vectorWithValuesInArray:@[
                                                                                   @0,
                                                                                   @0,
                                                                                   @1]]
                                    vectorB:[MCVector vectorWithValuesInArray:@[
                                                                                   @0,
                                                                                   @1,
                                                                                   @0]]];
    XCTAssertEqual(dotProduct.doubleValue, 0.0, @"Dot product not computed correctly");
    
    @try {
        dotProduct = [MCVector dotProductOfVectorA:[MCVector vectorWithValuesInArray:@[
                                                                                       @0,
                                                                                       @0,
                                                                                       @1]]
                                        vectorB:[MCVector vectorWithValuesInArray:@[
                                                                                       @0,
                                                                                       @1,
                                                                                       @0,
                                                                                       @1]]];
    }
    @catch (NSException *exception) {
        XCTAssert([exception.name isEqualToString:NSInternalInconsistencyException], @"Did not detect dimension mismatch in MCVector dot product method");
    }
}

- (void)testVectorAddition
{
    MCVector *a = [MCVector vectorWithValuesInArray:@[@1, @2, @3, @4]];
    MCVector *b = [MCVector vectorWithValuesInArray:@[@5, @6, @7, @8]];
    MCVector *c = [MCVector vectorWithValuesInArray:@[@1, @2, @3]];
    
    MCVector *sum = [MCVector sumOfVectorA:a vectorB:b];
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@6, @8, @10, @12]];
    for (int i = 0; i < 4; i++) {
        XCTAssertEqual([sum valueAtIndex:i], [solution valueAtIndex:i], @"Value at index %u not added correctly", i);
    }
    
    XCTAssertThrows([MCVector sumOfVectorA:a vectorB:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorSubtraction
{
    MCVector *a = [MCVector vectorWithValuesInArray:@[@1, @2, @3, @4]];
    MCVector *b = [MCVector vectorWithValuesInArray:@[@5, @6, @7, @8]];
    MCVector *c = [MCVector vectorWithValuesInArray:@[@1, @2, @3]];
    
    MCVector *diff = [MCVector differenceOfVectorMinuend:b vectorSubtrahend:a];
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@4, @4, @4, @4]];
    for (int i = 0; i < 4; i++) {
        XCTAssertEqual([diff valueAtIndex:i], [solution valueAtIndex:i], @"Value at index %u not subtracted correctly", i);
    }
    
    XCTAssertThrows([MCVector differenceOfVectorMinuend:a vectorSubtrahend:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorMultiplication
{
    MCVector *a = [MCVector vectorWithValuesInArray:@[@1, @2, @3, @4]];
    MCVector *b = [MCVector vectorWithValuesInArray:@[@5, @6, @7, @8]];
    MCVector *c = [MCVector vectorWithValuesInArray:@[@1, @2, @3]];
    
    MCVector *prod = [MCVector productOfVectorA:a vectorB:b];
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@5, @12, @21, @32]];
    for (int i = 0; i < 4; i++) {
        XCTAssertEqual([prod valueAtIndex:i], [solution valueAtIndex:i], @"Value at index %u not multiplied correctly", i);
    }
    
    XCTAssertThrows([MCVector productOfVectorA:a vectorB:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorDivision
{
    MCVector *a = [MCVector vectorWithValuesInArray:@[@1, @2, @3, @4]];
    MCVector *b = [MCVector vectorWithValuesInArray:@[@5, @6, @9, @8]];
    MCVector *c = [MCVector vectorWithValuesInArray:@[@1, @2, @3]];
    
    MCVector *quotient = [MCVector quotientOfVectorDividend:b vectorDivisor:a];
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@5, @3, @3, @2]];
    for (int i = 0; i < 4; i++) {
        XCTAssertEqual([quotient valueAtIndex:i], [solution valueAtIndex:i], @"Value at index %u not divided correctly", i);
    }
    
    XCTAssertThrows([MCVector quotientOfVectorDividend:a vectorDivisor:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorCrossProduct
{
    MCVector *a = [MCVector vectorWithValuesInArray:@[@3, @(-3), @1]];
    MCVector *b = [MCVector vectorWithValuesInArray:@[@4, @9, @2]];
    MCVector *c = [MCVector crossProductOfVectorA:a vectorB:b];
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@(-15), @(-2), @39]];
    XCTAssertTrue([c isEqualToVector:solution], @"Cross product not computed correctly.");
}

- (void)testVectorCopying
{
    MCVector *a = [MCVector vectorWithValuesInArray:@[@3, @(-3), @1]];
    MCVector *aCopy = a.copy;
    
    XCTAssertNotEqual(a.self, aCopy.self, @"The copied vector is the same instance as its source.");
    XCTAssertTrue([a isEqualToVector:aCopy], @"Vector copy is not equal to its source.");
}

- (void)testVectorNorms
{
    MCVector *vector = [MCVector vectorWithValuesInArray:@[@1, @2, @3]];
    
    double l1NormSolution = 6.0;
    double l2NormSolution = 3.74165738677;
    double l3NormSolution = 3.30192724889;
    double infinityNormSolution = 3.0;
    
    XCTAssertEqual(vector.l1Norm.doubleValue, l1NormSolution, @"L1 norm incorrect.");
    XCTAssertEqualWithAccuracy(vector.l2Norm.doubleValue, l2NormSolution, 1e-10, @"L2 norm incorrect.");
    XCTAssertEqualWithAccuracy(vector.l3Norm.doubleValue, l3NormSolution, 1e-10, @"L3 norm incorrect.");
    XCTAssertEqual(vector.infinityNorm.doubleValue, infinityNormSolution, @"Infinity norm incorrect.");
}

@end

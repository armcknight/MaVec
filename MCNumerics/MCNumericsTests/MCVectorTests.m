//
//  MAVVectorTests.m
//  MAVNumerics
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

#import "MAVVector.h"

@interface MAVVectorTests : XCTestCase

@end

@implementation MAVVectorTests

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
    NSNumber *dotProduct = [MAVVector dotProductOfVectorA:[MAVVector vectorWithValuesInArray:@[
                                                                                          @1.0,
                                                                                          @3.0,
                                                                                          @(-5.0)]]
                                           vectorB:[MAVVector vectorWithValuesInArray:@[
                                                                                          @4.0,
                                                                                          @(-2.0),
                                                                                          @(-1.0)]]];
    XCTAssertEqual(dotProduct.doubleValue, 3.0, @"Dot product not computed correctly");
    
    dotProduct = [MAVVector dotProductOfVectorA:[MAVVector vectorWithValuesInArray:@[
                                                                                   @0.0,
                                                                                   @0.0,
                                                                                   @1.0]]
                                    vectorB:[MAVVector vectorWithValuesInArray:@[
                                                                                   @0.0,
                                                                                   @1.0,
                                                                                   @0.0]]];
    XCTAssertEqual(dotProduct.doubleValue, 0.0, @"Dot product not computed correctly");
    
    @try {
        dotProduct = [MAVVector dotProductOfVectorA:[MAVVector vectorWithValuesInArray:@[
                                                                                       @0.0,
                                                                                       @0.0,
                                                                                       @1.0]]
                                        vectorB:[MAVVector vectorWithValuesInArray:@[
                                                                                       @0.0,
                                                                                       @1.0,
                                                                                       @0.0,
                                                                                       @1.0]]];
    }
    @catch (NSException *exception) {
        XCTAssert([exception.name isEqualToString:NSInternalInconsistencyException], @"Did not detect dimension mismatch in MAVVector dot product method");
    }
}

- (void)testVectorAddition
{
    MAVVector *a = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0, @4.0]];
    MAVVector *b = [MAVVector vectorWithValuesInArray:@[@5.0, @6.0, @7.0, @8.0]];
    MAVVector *c = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0]];
    
    MAVVector *sum = [MAVVector sumOfVectorA:a vectorB:b];
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@6.0, @8.0, @10.0, @12.0]];
    for (int i = 0; i < 4; i++) {
        XCTAssertEqual([sum valueAtIndex:i].doubleValue, [solution valueAtIndex:i].doubleValue, @"Value at index %u not added correctly", i);
    }
    
    XCTAssertThrows([MAVVector sumOfVectorA:a vectorB:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorSubtraction
{
    MAVVector *a = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0, @4.0]];
    MAVVector *b = [MAVVector vectorWithValuesInArray:@[@5.0, @6.0, @7.0, @8.0]];
    MAVVector *c = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0]];
    
    MAVVector *diff = [MAVVector differenceOfVectorMinuend:b vectorSubtrahend:a];
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@4.0, @4.0, @4.0, @4.0]];
    for (int i = 0; i < 4; i++) {
        XCTAssertEqual([diff valueAtIndex:i].doubleValue, [solution valueAtIndex:i].doubleValue, @"Value at index %u not subtracted correctly", i);
    }
    
    XCTAssertThrows([MAVVector differenceOfVectorMinuend:a vectorSubtrahend:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorMultiplication
{
    MAVVector *a = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0, @4.0]];
    MAVVector *b = [MAVVector vectorWithValuesInArray:@[@5.0, @6.0, @7.0, @8.0]];
    MAVVector *c = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0]];
    
    MAVVector *prod = [MAVVector productOfVectorA:a vectorB:b];
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@5.0, @12.0, @21.0, @32.0]];
    for (int i = 0; i < 4; i++) {
        XCTAssertEqual([prod valueAtIndex:i].doubleValue, [solution valueAtIndex:i].doubleValue, @"Value at index %u not multiplied correctly", i);
    }
    
    XCTAssertThrows([MAVVector productOfVectorA:a vectorB:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorDivision
{
    MAVVector *a = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0, @4.0]];
    MAVVector *b = [MAVVector vectorWithValuesInArray:@[@5.0, @6.0, @9.0, @8.0]];
    MAVVector *c = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0]];
    
    MAVVector *quotient = [MAVVector quotientOfVectorDividend:b vectorDivisor:a];
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@5.0, @3.0, @3.0, @2.0]];
    for (int i = 0; i < 4; i++) {
        XCTAssertEqual([quotient valueAtIndex:i].doubleValue, [solution valueAtIndex:i].doubleValue, @"Value at index %u not divided correctly", i);
    }
    
    XCTAssertThrows([MAVVector quotientOfVectorDividend:a vectorDivisor:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorCrossProduct
{
    MAVVector *a = [MAVVector vectorWithValuesInArray:@[@3.0, @(-3.0), @1.0]];
    MAVVector *b = [MAVVector vectorWithValuesInArray:@[@4.0, @9.0, @2.0]];
    MAVVector *c = [MAVVector crossProductOfVectorA:a vectorB:b];
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@(-15.0), @(-2.0), @39.0]];
    XCTAssertTrue([c isEqualToVector:solution], @"Cross product not computed correctly.");
}

- (void)testVectorCopying
{
    MAVVector *a = [MAVVector vectorWithValuesInArray:@[@3.0, @(-3.0), @1.0]];
    MAVVector *aCopy = a.copy;
    
    XCTAssertNotEqual(a.self, aCopy.self, @"The copied vector is the same instance as its source.");
    XCTAssertTrue([a isEqualToVector:aCopy], @"Vector copy is not equal to its source.");
}

- (void)testVectorNorms
{
    MAVVector *vector = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0]];
    
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

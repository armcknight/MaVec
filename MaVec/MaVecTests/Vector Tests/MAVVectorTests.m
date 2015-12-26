//
//  MAVVectorTests.m
//  MaVec
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
    NSNumber *dotProduct = [[MAVMutableVector vectorWithValuesInArray:@[
                                                                        @1.0,
                                                                        @3.0,
                                                                        @(-5.0)]]
                            dotProductWithVector:[MAVVector vectorWithValuesInArray:@[
                                                                                      @4.0,
                                                                                      @(-2.0),
                                                                                      @(-1.0)]]];
    XCTAssertEqual(dotProduct.doubleValue, 3.0, @"Dot product not computed correctly");
    
    dotProduct = [[MAVMutableVector vectorWithValuesInArray:@[
                                                              @0.0,
                                                              @0.0,
                                                              @1.0]]
                  dotProductWithVector:[MAVVector vectorWithValuesInArray:@[
                                                                            @0.0,
                                                                            @1.0,
                                                                            @0.0]]];
    XCTAssertEqual(dotProduct.doubleValue, 0.0, @"Dot product not computed correctly");
    
    @try {
        dotProduct = [[MAVMutableVector vectorWithValuesInArray:@[
                                                                  @0.0,
                                                                  @0.0,
                                                                  @1.0]]
                      dotProductWithVector:[MAVVector vectorWithValuesInArray:@[
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
    MAVMutableVector *a = [MAVMutableVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0, @4.0]];
    MAVVector *b = [MAVVector vectorWithValuesInArray:@[@5.0, @6.0, @7.0, @8.0]];
    MAVVector *c = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0]];
    
    [a addVector:b];
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@6.0, @8.0, @10.0, @12.0]];
    for (unsigned int i = 0; i < 4; i++) {
        XCTAssertEqual([a valueAtIndex:i].doubleValue, [solution valueAtIndex:i].doubleValue, @"Value at index %u not added correctly", i);
    }
    
    XCTAssertThrows([a addVector:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorSubtraction
{
    MAVMutableVector *a = [MAVMutableVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0, @4.0]];
    MAVMutableVector *b = [MAVMutableVector vectorWithValuesInArray:@[@5.0, @6.0, @7.0, @8.0]];
    MAVVector *c = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0]];
    
    [b subtractVector:a];
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@4.0, @4.0, @4.0, @4.0]];
    for (unsigned int i = 0; i < 4; i++) {
        XCTAssertEqual([b valueAtIndex:i].doubleValue, [solution valueAtIndex:i].doubleValue, @"Value at index %u not subtracted correctly", i);
    }
    
    XCTAssertThrows([a subtractVector:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorMultiplication
{
    MAVMutableVector *a = [MAVMutableVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0, @4.0]];
    MAVVector *b = [MAVVector vectorWithValuesInArray:@[@5.0, @6.0, @7.0, @8.0]];
    MAVVector *c = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0]];
    
    [a multiplyByVector:b];
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@5.0, @12.0, @21.0, @32.0]];
    for (unsigned int i = 0; i < 4; i++) {
        XCTAssertEqual([a valueAtIndex:i].doubleValue, [solution valueAtIndex:i].doubleValue, @"Value at index %u not multiplied correctly", i);
    }
    
    XCTAssertThrows([a multiplyByVector:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorDivision
{
    MAVMutableVector *a = [MAVMutableVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0, @4.0]];
    MAVMutableVector *b = [MAVMutableVector vectorWithValuesInArray:@[@5.0, @6.0, @9.0, @8.0]];
    MAVVector *c = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0]];
    
    [b divideByVector:a];
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@5.0, @3.0, @3.0, @2.0]];
    for (unsigned int i = 0; i < 4; i++) {
        XCTAssertEqual([b valueAtIndex:i].doubleValue, [solution valueAtIndex:i].doubleValue, @"Value at index %u not divided correctly", i);
    }
    
    XCTAssertThrows([a divideByVector:c], @"Should throw a mismatched dimension exception");
}

- (void)testVectorPower
{
    MAVMutableVector *a = [MAVMutableVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0, @4.0, @5.0]];
    [a raiseToPower:3];
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@1.0, @8.0, @27.0, @64.0, @125.0]];
    for (unsigned int i = 0; i < 5; i++) {
        XCTAssertEqual(a[i].doubleValue, solution[i].doubleValue, @"element at index %u = %f but expected %f", i, a[i].doubleValue, solution[i].doubleValue);
    }
}

- (void)testVectorCrossProduct
{
    MAVMutableVector *a = [MAVMutableVector vectorWithValuesInArray:@[@3.0, @(-3.0), @1.0]];
    MAVVector *b = [MAVVector vectorWithValuesInArray:@[@4.0, @9.0, @2.0]];
    MAVVector *c = [a crossProductWithVector:b];
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

- (void)testIdentityVector
{
    MAVVector *doubleIdentityVector = [MAVVector vectorFilledWithValue:@1.0 length:4 vectorFormat:MAVVectorFormatRowVector];
    XCTAssert(doubleIdentityVector.isIdentity.isYes, @"Double precision identity vector not identified as identity.");
    
    MAVVector *singleIdentityVector = [MAVVector vectorFilledWithValue:@1.0f length:4 vectorFormat:MAVVectorFormatRowVector];
    XCTAssert(singleIdentityVector.isIdentity.isYes, @"Single precision identity vector not identified as identity.");
    
    MAVMutableVector *randomDoubleVector = [MAVMutableVector randomVectorOfLength:4 vectorFormat:MAVVectorFormatRowVector precision:MCKPrecisionDouble];
    [randomDoubleVector setValue:@2.0 atIndex:0];
    XCTAssert(randomDoubleVector.isIdentity.isNo, @"Non-identity double precision vector identified as identity.");
    
    MAVMutableVector *randomSingleVector = [MAVMutableVector randomVectorOfLength:4 vectorFormat:MAVVectorFormatRowVector precision:MCKPrecisionSingle];
    [randomSingleVector setValue:@2.0f atIndex:0];
    XCTAssert(randomSingleVector.isIdentity.isNo, @"Non-identity single precision vector identified as identity.");
}

- (void)testZeroVector
{
    MAVVector *doubleZeroVector = [MAVVector vectorFilledWithValue:@0.0 length:4 vectorFormat:MAVVectorFormatRowVector];
    XCTAssert(doubleZeroVector.isZero.isYes, @"Double precision zero vector not identified as zero.");
    
    MAVVector *singleZeroVector = [MAVVector vectorFilledWithValue:@0.0f length:4 vectorFormat:MAVVectorFormatRowVector];
    XCTAssert(singleZeroVector.isZero.isYes, @"Single precision zero vector not identified as zero.");
    
    MAVMutableVector *randomDoubleVector = [MAVMutableVector randomVectorOfLength:4 vectorFormat:MAVVectorFormatRowVector precision:MCKPrecisionDouble];
    [randomDoubleVector setValue:@2.0 atIndex:0];
    XCTAssert(randomDoubleVector.isZero.isNo, @"Non-zero double precision vector identified as zero.");
    
    MAVMutableVector *randomSingleVector = [MAVMutableVector randomVectorOfLength:4 vectorFormat:MAVVectorFormatRowVector precision:MCKPrecisionSingle];
    [randomSingleVector setValue:@2.0f atIndex:0];
    XCTAssert(randomSingleVector.isZero.isNo, @"Non-zero single precision vector identified as zero.");
}

@end

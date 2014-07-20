//
//  MAVMutableVectorTests.m
//  MaVec
//
//  Created by Andrew McKnight on 7/19/14.
//  Copyright (c) 2014 AMProductions. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>

#import "MAVMutableVector.h"

@interface MAVMutableVectorTests : XCTestCase

@property (strong, nonatomic) MAVMutableVector *vector1;
@property (strong, nonatomic) NSNumber *sumOfValues;
@property (strong, nonatomic) NSNumber *productOfValues;
@property (strong, nonatomic) NSNumber *l1Norm;
@property (strong, nonatomic) NSNumber *l2Norm;
@property (strong, nonatomic) NSNumber *l3Norm;
@property (strong, nonatomic) NSNumber *infinityNorm;
@property (strong, nonatomic) NSNumber *minimumValue;
@property (strong, nonatomic) NSNumber *maximumValue;
@property (assign, nonatomic) int minimumValueIndex;
@property (assign, nonatomic) int maximumValueIndex;
@property (strong, nonatomic) MAVVector *absoluteVector;

@end

@implementation MAVMutableVectorTests

- (void)setUp
{
	self.vector1 = [MAVMutableVector randomVectorOfLength:5
	                                         vectorFormat:MAVVectorFormatColumnVector
	                                            precision:MCKPrecisionDouble];
    
    self.sumOfValues = self.vector1.sumOfValues;
    self.productOfValues = self.vector1.productOfValues;
    self.l1Norm = self.vector1.l1Norm;
    self.l2Norm = self.vector1.l2Norm;
    self.l3Norm = self.vector1.l3Norm;
    self.infinityNorm = self.vector1.infinityNorm;
    self.minimumValue = self.vector1.minimumValue;
    self.maximumValue = self.vector1.maximumValue;
    self.minimumValueIndex = self.vector1.minimumValueIndex;
    self.maximumValueIndex = self.vector1.maximumValueIndex;
    self.absoluteVector = self.vector1.absoluteVector;
}

- (void)testIdempotentOperationStateInvalidation
{
    MAVVector *zeroVector = [MAVVector vectorFilledWithValue:@0.0
                                                      length:self.vector1.length
                                                vectorFormat:self.vector1.vectorFormat];
    MAVVector *oneVector = [MAVVector vectorFilledWithValue:@1.0
                                                     length:self.vector1.length
                                               vectorFormat:self.vector1.vectorFormat];
    
    [self.vector1 addVector:zeroVector];
    [self checkThatPropertiesOnVector:self.vector1 areEqual:YES];
    
    [self.vector1 subtractVector:zeroVector];
    [self checkThatPropertiesOnVector:self.vector1 areEqual:YES];
    
    [self.vector1 multiplyByScalar:@1.0];
    [self checkThatPropertiesOnVector:self.vector1 areEqual:YES];
    
    [self.vector1 multiplyByVector:oneVector];
    [self checkThatPropertiesOnVector:self.vector1 areEqual:YES];
    
    [self.vector1 divideByVector:oneVector];
    [self checkThatPropertiesOnVector:self.vector1 areEqual:YES];
    
    [self.vector1 raiseToPower:1];
    [self checkThatPropertiesOnVector:self.vector1 areEqual:YES];
    
    self.vector1[0] = self.vector1[0];
    [self checkThatPropertiesOnVector:self.vector1 areEqual:YES];
    
    [self.vector1 setValues:@[self.vector1[0], self.vector1[1]] inRange:NSMakeRange(0, 2)];
    [self checkThatPropertiesOnVector:self.vector1 areEqual:YES];
}

- (void)testNonIdempotentOperationStateInvalidation
{
	MAVVector *nonIdempotentVector = [MAVVector vectorFilledWithValue:@2.0
	                                                           length:self.vector1.length
	                                                     vectorFormat:self.vector1.vectorFormat];
    
    MAVMutableVector *result;
    
    result = [self.vector1.mutableCopy addVector:nonIdempotentVector];
    [self checkThatPropertiesOnVector:result areEqual:NO];
    
    result = [self.vector1.mutableCopy subtractVector:nonIdempotentVector];
    [self checkThatPropertiesOnVector:result areEqual:NO];
    
    result = [self.vector1.mutableCopy multiplyByScalar:@2.0];
    [self checkThatPropertiesOnVector:result areEqual:NO];
    
    result = [self.vector1.mutableCopy multiplyByVector:nonIdempotentVector];
    [self checkThatPropertiesOnVector:result areEqual:NO];
    
    result = [self.vector1.mutableCopy divideByVector:nonIdempotentVector];
    [self checkThatPropertiesOnVector:result areEqual:NO];
    
    result = [self.vector1.mutableCopy raiseToPower:2];
    [self checkThatPropertiesOnVector:result areEqual:NO];
    
    result = self.vector1.mutableCopy;
    result[0] = @(result[0].doubleValue + 1.0);
    [self checkThatPropertiesOnVector:result areEqual:NO];
    
    result = self.vector1.mutableCopy;
    [result setValues:@[@(result[0].doubleValue + 1.0), @(result[1].doubleValue + 1.0)] inRange:NSMakeRange(0, 2)];
    [self checkThatPropertiesOnVector:result areEqual:NO];
}

#pragma mark - Private

- (void)checkThatPropertiesOnVector:(MAVVector *)vector areEqual:(BOOL)equal
{
    NSNumber *sumOfValues;
    NSNumber *productOfValues;
    NSNumber *l1Norm;
    NSNumber *l2Norm;
    NSNumber *l3Norm;
    NSNumber *infinityNorm;
    NSNumber *minimumValue;
    NSNumber *maximumValue;
    int minimumValueIndex;
    int maximumValueIndex;
    MAVVector *absoluteVector;
    
    Ivar sumOfValuesIvar = class_getInstanceVariable([vector class], "_sumOfValues");
    sumOfValues = object_getIvar(vector, sumOfValuesIvar);
    
    Ivar productOfValuesIvar = class_getInstanceVariable([vector class], "_productOfValues");
    productOfValues = object_getIvar(vector, productOfValuesIvar);
    
    Ivar l1NormIvar = class_getInstanceVariable([vector class], "_l1Norm");
    l1Norm = object_getIvar(vector, l1NormIvar);
    
    Ivar l2NormIvar = class_getInstanceVariable([vector class], "_l2Norm");
    l2Norm = object_getIvar(vector, l2NormIvar);
    
    Ivar l3NormIvar = class_getInstanceVariable([vector class], "_l3Norm");
    l3Norm = object_getIvar(vector, l3NormIvar);
    
    Ivar infinityNormIvar = class_getInstanceVariable([vector class], "_infinityNorm");
    infinityNorm = object_getIvar(vector, infinityNormIvar);
    
    Ivar minimumValueIvar = class_getInstanceVariable([vector class], "_minimumValue");
    minimumValue = object_getIvar(vector, minimumValueIvar);
    
    Ivar maximumValueIvar = class_getInstanceVariable([vector class], "_maximumValue");
    maximumValue = object_getIvar(vector, maximumValueIvar);
    
    Ivar minimumValueIndexIvar = class_getInstanceVariable([vector class], "_minimumValueIndex");
    minimumValueIndex = ((int (*)(id, Ivar))object_getIvar)(vector, minimumValueIndexIvar);
    
    Ivar maximumValueIndexIvar = class_getInstanceVariable([vector class], "_maximumValueIndex");
    maximumValueIndex = ((int (*)(id, Ivar))object_getIvar)(vector, maximumValueIndexIvar);
    
    Ivar absoluteVectorIvar = class_getInstanceVariable([vector class], "_absoluteVector");
    absoluteVector = object_getIvar(vector, absoluteVectorIvar);
    
    if (equal) {
        XCTAssertEqualObjects(self.sumOfValues, sumOfValues, @"sumOfValues was incorrectly invalidated by an idempotent operation.");
        XCTAssertEqualObjects(self.productOfValues, productOfValues, @"productOfValues was incorrectly invalidated by an idempotent operation.");
        XCTAssertEqualObjects(self.l1Norm, l1Norm, @"l1Norm was incorrectly invalidated by an idempotent operation.");
        XCTAssertEqualObjects(self.l2Norm, l2Norm, @"l2Norm was incorrectly invalidated by an idempotent operation.");
        XCTAssertEqualObjects(self.l3Norm, l3Norm, @"l3Norm was incorrectly invalidated by an idempotent operation.");
        XCTAssertEqualObjects(self.infinityNorm, infinityNorm, @"infinityNorm was incorrectly invalidated by an idempotent operation.");
        XCTAssertEqualObjects(self.minimumValue, minimumValue, @"minimumValue was incorrectly invalidated by an idempotent operation.");
        XCTAssertEqualObjects(self.maximumValue, maximumValue, @"maximumValue was incorrectly invalidated by an idempotent operation.");
        XCTAssertEqual(self.minimumValueIndex, minimumValueIndex, @"minimumValueIndex was incorrectly invalidated by an idempotent operation.");
        XCTAssertEqual(self.maximumValueIndex, maximumValueIndex, @"maximumValueIndex was incorrectly invalidated by an idempotent operation.");
        XCTAssertEqualObjects(self.absoluteVector, absoluteVector, @"absoluteVector was incorrectly invalidated by an idempotent operation.");
    } else {
        XCTAssertNotEqualObjects(self.sumOfValues, sumOfValues, @"sumOfValues was not invalidated by a non-idempotent operation.");
        XCTAssertNotEqualObjects(self.productOfValues, productOfValues, @"productOfValues was not invalidated by a non-idempotent operation.");
        XCTAssertNotEqualObjects(self.l1Norm, l1Norm, @"l1Norm was not invalidated by a non-idempotent operation.");
        XCTAssertNotEqualObjects(self.l2Norm, l2Norm, @"l2Norm was not invalidated by a non-idempotent operation.");
        XCTAssertNotEqualObjects(self.l3Norm, l3Norm, @"l3Norm was not invalidated by a non-idempotent operation.");
        XCTAssertNotEqualObjects(self.infinityNorm, infinityNorm, @"infinityNorm was not invalidated by a non-idempotent operation.");
        XCTAssertNotEqualObjects(self.minimumValue, minimumValue, @"minimumValue was not invalidated by a non-idempotent operation.");
        XCTAssertNotEqualObjects(self.maximumValue, maximumValue, @"maximumValue was not invalidated by a non-idempotent operation.");
        XCTAssertNotEqual(self.minimumValueIndex, minimumValueIndex, @"minimumValueIndex was not invalidated by a non-idempotent operation.");
        XCTAssertNotEqual(self.maximumValueIndex, maximumValueIndex, @"maximumValueIndex was not invalidated by a non-idempotent operation.");
        XCTAssertNotEqualObjects(self.absoluteVector, absoluteVector, @"absoluteVector was not invalidated by a non-idempotent operation.");
    }
}

@end

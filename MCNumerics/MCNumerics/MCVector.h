//
//  MCVector.h
//  MCNumerics
//
//  Created by andrew mcknight on 12/8/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCVector : NSObject

#pragma mark - Constructors

- (id)initWithValues:(NSArray *)values;
+ (MCVector *)vectorWithValues:(NSArray *)values;

#pragma mark - NSObject overrides

- (BOOL)isEqualToVector:(MCVector *)otherVector;
- (NSUInteger)hash;

#pragma mark - Inspection

- (NSUInteger)length;
- (double)valueAtIndex:(NSUInteger)index;
- (double)maximumValue;
- (double)minimumValue;
- (NSUInteger)indexOfMaximumValue;
- (NSUInteger)indexOfMinimumValue;

#pragma mark - Instance Operations

- (MCVector *)vectorByMultiplyingByScalar:(double)scalar;

#pragma mark - Class Operations

+ (MCVector *)sumOfVectorA:(MCVector *)a andVectorB:(MCVector *)b;
+ (MCVector *)differenceOfVectorA:(MCVector *)a andVectorB:(MCVector *)b;
+ (MCVector *)productOfVectorA:(MCVector *)a andVectorB:(MCVector *)b;
+ (MCVector *)quotientOfVectorA:(MCVector *)a andVectorB:(MCVector *)b;
+ (double)dotProductOfVectorA:(MCVector *)a andVectorB:(MCVector *)b;
+ (MCVector *)crossProductOfVectorA:(MCVector *)a andVectorB:(MCVector *)b;

@end

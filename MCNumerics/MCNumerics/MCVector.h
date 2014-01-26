//
//  MCVector.h
//  MCNumerics
//
//  Created by andrew mcknight on 12/8/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MCVectorFormatRowVector,
    MCVectorFormatColumnVector
} MCVectorFormat;

@interface MCVector : NSObject

@property (assign, nonatomic) MCVectorFormat vectorFormat;
#pragma mark - Constructors

/**
 @description Initializes a new MCVector with supplied values in column format.
 */
- (id)initWithValues:(double *)values;
- (id)initWithValues:(double *)values inVectorFormat:(MCVectorFormat)vectorFormat;
+ (MCVector *)vectorWithValues:(double *)values;
+ (MCVector *)vectorWithValues:(double *)values inVectorFormat:(MCVectorFormat)vectorFormat;

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

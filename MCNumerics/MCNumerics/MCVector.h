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

@interface MCVector : NSObject<NSCopying>

@property (assign, readonly, nonatomic) MCVectorFormat vectorFormat;
@property (assign, readonly, nonatomic) NSUInteger length;
@property (assign, readonly, nonatomic) double *values;

@property (assign, readonly, nonatomic) double sumOfValues;
@property (assign, readonly, nonatomic) double productOfValues;

#pragma mark - Constructors

/**
 @description Initializes a new MCVector with supplied values in column format.
 */
- (instancetype)initWithValues:(double *)values length:(int)length;
- (instancetype)initWithValues:(double *)values length:(int)length inVectorFormat:(MCVectorFormat)vectorFormat;
+ (instancetype)vectorWithValues:(double *)values length:(int)length;
+ (instancetype)vectorWithValues:(double *)values length:(int)length inVectorFormat:(MCVectorFormat)vectorFormat;

- (instancetype)initWithValuesInArray:(NSArray *)values;
- (instancetype)initWithValuesInArray:(NSArray *)values inVectorFormat:(MCVectorFormat)vectorFormat;
+ (instancetype)vectorWithValuesInArray:(NSArray *)values;
+ (instancetype)vectorWithValuesInArray:(NSArray *)values inVectorFormat:(MCVectorFormat)vectorFormat;

#pragma mark - NSObject overrides

- (BOOL)isEqualToVector:(MCVector *)otherVector;
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;
- (NSString *)description;

#pragma mark - Inspection

- (NSUInteger)length;
- (double)valueAtIndex:(NSUInteger)index;
- (double)maximumValue;
- (double)minimumValue;
- (NSUInteger)indexOfMaximumValue;
- (NSUInteger)indexOfMinimumValue;

#pragma mark - Subscripting

- (NSNumber *)objectAtIndexedSubscript:(NSUInteger)idx;

#pragma mark - Instance Operations

- (MCVector *)vectorByMultiplyingByScalar:(double)scalar;
- (MCVector *)vectorByAddingVector:(MCVector *)addend;
- (MCVector *)vectorBySubtractingVector:(MCVector *)subtrahend;
- (MCVector *)vectorByMultiplyingByVector:(MCVector *)multiplier;
- (MCVector *)vectorByDividingByVector:(MCVector *)divisor;
- (double)dotProductWithVector:(MCVector *)otherVector;
- (MCVector *)crossProductWithVector:(MCVector *)otherVector;

#pragma mark - Class Operations

+ (MCVector *)sumOfVectorA:(MCVector *)a andVectorB:(MCVector *)b;
+ (MCVector *)differenceOfVectorA:(MCVector *)a andVectorB:(MCVector *)b;
+ (MCVector *)productOfVectorA:(MCVector *)a andVectorB:(MCVector *)b;
+ (MCVector *)quotientOfVectorA:(MCVector *)a andVectorB:(MCVector *)b;
+ (double)dotProductOfVectorA:(MCVector *)a andVectorB:(MCVector *)b;
+ (MCVector *)crossProductOfVectorA:(MCVector *)a andVectorB:(MCVector *)b;
+ (double)scalarTripleProductWithVectorA:(MCVector *)a vectorB:(MCVector *)b vectorC:(MCVector *)c;
+ (MCVector *)vectorTripleProductWithVectorA:(MCVector *)a vectorB:(MCVector *)b vectorC:(MCVector *)c;

@end

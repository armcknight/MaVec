//
//  MCVector.h
//  MCNumerics
//
//  Created by andrew mcknight on 12/8/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : UInt8 {
    /**
     Specifies that the values in the vector form a row with each value in its own column.
     */
    MCVectorFormatRowVector,
    
    /**
     Specifies that the values in the vector form a column with each value in its own row.
     */
    MCVectorFormatColumnVector
}
/**
 Constants specifying whether the vector is a row- or column- vector.
 */
MCVectorFormat;

@interface MCVector : NSObject<NSCopying>

@property (assign, readonly, nonatomic) MCVectorFormat vectorFormat;
@property (assign, readonly, nonatomic) int length;
@property (assign, readonly, nonatomic) double *values;

@property (assign, readonly, nonatomic) double sumOfValues;
@property (assign, readonly, nonatomic) double productOfValues;

#pragma mark - Constructors

/**
 @description Initializes a new MCVector with supplied values in column format.
- (instancetype)initWithValues:(double *)values length:(int)length vectorFormat:(MCVectorFormat)vectorFormat;
 */
+ (instancetype)vectorWithValues:(double *)values length:(int)length;

+ (instancetype)vectorWithValues:(double *)values length:(int)length vectorFormat:(MCVectorFormat)vectorFormat;
- (instancetype)initWithValuesInArray:(NSArray *)values vectorFormat:(MCVectorFormat)vectorFormat;
+ (instancetype)vectorWithValuesInArray:(NSArray *)values;

+ (instancetype)vectorWithValuesInArray:(NSArray *)values vectorFormat:(MCVectorFormat)vectorFormat;
#pragma mark - NSObject overrides

- (BOOL)isEqualToVector:(MCVector *)otherVector;
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;
- (NSString *)description;

#pragma mark - Inspection

- (double)valueAtIndex:(int)index;
- (double)maximumValue;
- (double)minimumValue;
- (int)indexOfMaximumValue;
- (int)indexOfMinimumValue;

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

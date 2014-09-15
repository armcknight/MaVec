//
//  MAVVector-Protected.h
//  MaVec
//
//  Created by Andrew McKnight on 7/16/14.
//  Copyright (c) 2014 AMProductions. All rights reserved.
//

#import "MAVVector.h"

@interface MAVVector()

@property (strong, readwrite, nonatomic) NSNumber *sumOfValues;
@property (strong, readwrite, nonatomic) NSNumber *productOfValues;
@property (strong, readwrite, nonatomic) NSNumber *l1Norm;
@property (strong, readwrite, nonatomic) NSNumber *l2Norm;
@property (strong, readwrite, nonatomic) NSNumber *l3Norm;
@property (strong, readwrite, nonatomic) NSNumber *infinityNorm;
@property (strong, readwrite, nonatomic) NSNumber *minimumValue;
@property (strong, readwrite, nonatomic) NSNumber *maximumValue;
@property (assign, readwrite, nonatomic) int minimumValueIndex;
@property (assign, readwrite, nonatomic) int maximumValueIndex;
@property (strong, readwrite, nonatomic) MAVVector *absoluteVector;
@property (assign, readwrite, nonatomic) MCKPrecision precision;
@property (strong, readwrite, nonatomic) MCKTribool *isIdentity;
@property (strong, readwrite, nonatomic) MCKTribool *isZero;

/**
 @brief Constructs new instance by calling [self init] and sets the supplied values and length.
 @param values C array of floating-point values.
 @param length The length of the C array.
 @return A new instance of MAVVector in a default state.
 */
- (instancetype)initWithValues:(NSData *)values length:(int)length;

/**
 @brief Constructs new instance by calling [self init] and sets the supplied values and inferred length.
 @param values An NSArray of NSNumbers.
 @return A new instance of MAVVector in a default state.
 */
- (instancetype)initWithValuesInArray:(NSArray *)values;

/**
 *  Sets any computed values or structures that may change with variation in 
 *  vector values to their default values (nil, -1, etc).
 */
- (void)resetToDefaultState;

@end

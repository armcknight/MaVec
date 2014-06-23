//
//  MAVMutableVector.h
//  MaVec
//
//  Created by Andrew McKnight on 6/1/14.
//  Copyright (c) 2014 AMProductions. All rights reserved.
//

#import "MAVVector.h"

@interface MAVMutableVector : MAVVector

/**
 *  Sets the value of the entry at the specified location.
 *
 *  @param value The value to set in this vector.
 *  @param index The position at which to set the supplied value.
 */
- (void)setValue:(NSNumber *)value atIndex:(NSUInteger)index;

/**
 *  Enable bracketed subscripting to values into this vector.
 *
 *  @param obj The value to insert.
 *  @param idx The position in the vector to place the value. Must be lesser than the vector's length.
 */
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

/**
 *  Set a contiguous range of values at the specified range.
 *
 *  @param values The values to set in this vector.
 *  @param range  The chunk of positions whose values are being set.
 */
- (void)setValues:(NSArray *)values inRange:(NSRange)range;

@end

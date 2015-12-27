//
//  MAVMutableVector.h
//  MaVec
//
//  Created by Andrew McKnight on 6/1/14.
//
//  Copyright © 2015 AMProductions
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

#import "MAVTypedefs.h"

#import "MAVVector.h"

@interface MAVMutableVector : MAVVector

/**
 *  Sets the value of the entry at the specified location.
 *
 *  @param value The value to set in this vector.
 *  @param index The position at which to set the supplied value.
 */
- (void)setValue:(NSNumber *)value atIndex:(MAVIndex)index;

/**
 *  Enable bracketed subscripting to values into this vector.
 *
 *  @param obj The value to insert.
 *  @param idx The position in the vector to place the value. Must be lesser than the vector's length.
 */
- (void)setObject:(id)obj atIndexedSubscript:(MAVIndex)idx;

/**
 *  Set a contiguous range of values at the specified range.
 *
 *  @param values The values to set in this vector.
 *  @param range  The chunk of positions whose values are being set.
 */
- (void)setValues:(NSArray *)values inRange:(NSRange)range;

#pragma mark - Arithmetic

/**
 *  Multiply each element in receiving vector by a scalar.
 *
 *  @param scalar Value to multiply each element of this vector by.
 *
 *  @return A reference to the receiving vector.
 */
- (MAVMutableVector *)multiplyByScalar:(NSNumber *)scalar;

/**
 *  Add each element in the receiving vector to each corresponding element in 
 *  another vector.
 *
 *  @param vector The vector to be added to the receiving vector.
 *  
 *  @return A reference to the receiving vector.
 */
- (MAVMutableVector *)addVector:(MAVVector *)vector;

/**
 *  Subtract each element in a supplied vector from each corresponding element 
 *  in the receiving vector.
 *
 *  @param vector The vector to subtract from the receiving vector.
 *
 *  @return A reference to the receiving vector.
 */
- (MAVMutableVector *)subtractVector:(MAVVector *)vector;

/**
 *  Multiply each element in the receiving vector by each corresponding element
 *  in another vector.
 *
 *  @param vector The vector by which to multiply the receiving vector.
 *
 *  @return A reference to the receiving vector.
 */
- (MAVMutableVector *)multiplyByVector:(MAVVector *)vector;

/**
 *  Divide the each element in the receiving vector by each corresponding 
 *  element in another vector.
 *
 *  @param vector The vectory by which to divide the receiving vector.
 *
 *  @return A reference to the receiving vector.
 */
- (MAVMutableVector *)divideByVector:(MAVVector *)vector;

/**
 @brief Raise a vector to an integer power. Effectively multiplies a vector by itself power number of times.
 @param vector The vector to raise to the power.
 @param power An integer value for the exponent of the vector.
 @return A new instance of MAVVector holding the result of the power computation.
 */
- (MAVMutableVector *)raiseToPower:(NSUInteger)power;

@end

//
//  MAVMutableMatrix.h
//  MaVec
//
//  Created by Andrew McKnight on 6/1/14.
//  Copyright (c) 2014 AMProductions. All rights reserved.
//

#import "MAVMatrix.h"

@interface MAVMutableMatrix : MAVMatrix

/**
 @brief Exchanges the values in the specified rows.
 @param rowA The index of the first row to exchange.
 @param rowB The index of the first second to exchange.
 */
- (void)swapRowA:(int)rowA withRowB:(int)rowB;

/**
 @brief Exchanges the values in the specified columns.
 @param columnA  The index of the first column to exchange.
 @param columnB  The index of the second column to exchange.
 */
- (void)swapColumnA:(int)columnA withColumnB:(int)columnB;

/**
 @description Set the value at a position specified by row and column. Raises an NSRangeException if the position does not exist in the matrix.
 @param row The row in which the value will be set.
 @param column The column in which the value will be set.
 @param value The value to set at the specified position.
 */
- (void)setEntryAtRow:(int)row column:(int)column toValue:(NSNumber *)value;

/**
 *  Insert a column vector at the specified position.
 *
 *  @param vector The column vector of values to insert into this matrix.
 *  @param column The position at which to insert the column vector.
 */
- (void)setColumnVector:(MAVVector *)vector atColumn:(NSUInteger)column;

/**
 *  Insert a row vector at the specified position.
 *
 *  @param vector The row vector of values to insert into this matrix.
 *  @param row The position at which to insert the row vector.
 */
- (void)setRowVector:(MAVVector *)vector atRow:(NSUInteger)row;

/**
 *  Enable bracket operators to set row vectors of this matrix.
 *
 *  @param obj The row vector of values to insert.
 *  @param idx The row position at which to insert the values.
 */
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

@end

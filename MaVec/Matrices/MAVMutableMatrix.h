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

#pragma mark - Mathematical operations

/**
 @brief Performs a multiplication with the supplied matrix and vector, whose dimensions must agree according to the rules of matrix-vector multiplication: for A * b = c, A: m x p, b: p x 1 and C: m x 1.
 @param matrix The matrix to multiply with the vector.
 @param vector The vector to multiply with the matrix.
 @return A new MAVVector object representing the product of the matrix-vector multiplication.
 */
- (MAVMutableMatrix *)multiplyByVector:(MAVVector *)vector;

/**
 @brief Multiplies each value in a matrix by a scalar value.
 @param matrix The matrix whose values are to be multiplied.
 @param scalar The scalar to multiply each value in the matrix by.
 @return A new MAVMatrix object containing the results of the multiplication.
 */
- (MAVMutableMatrix *)multiplyByScalar:(NSNumber *)scalar;

/**
 @brief Raises a given matrix to specified power. If power = 0, returns the identity matrix of the same dimension; otherwise, the matrix is multiplied by itself power number of times, and must therefore be a square matrix. Throws an exception if this requirement is not met.
 @param matrix The matrix to raise to the specified power.
 @param power The power to raise the input matrix. Essentially the number of times the matrix will be multiplied by itself.
 @return A matrix of same dimension as input matrix, representing the product of the matrix multiplied by itself power number of times.
 */
- (MAVMutableMatrix *)raiseToPower:(NSUInteger)power;

/**
 @description Performs matrix multiplication on matrices A and B. Note that matrix multiplication is not commutative--in general, A x B ¬= B x A. Raises an NSInvalidArgumentException if A and B are not of compatible dimensions for matrix multiplication.
 @return A new MAVMatrix object representing the product of the expression A x B.
 */
- (MAVMutableMatrix *)multiplyByMatrix:(MAVMatrix *)matrix;

/**
 @description Raises an NSInvalidArgumentException if A and B are not of equal dimension.
 @return A new MAVMatrix object representing the sum (A + B) of the supplied matrices.
 */
- (MAVMutableMatrix *)addMatrix:(MAVMatrix *)matrix;

/**
 @description Raises an NSInvalidArgumentException if A and B are not of equal dimension.
 @return A new MAVMatrix object representing the difference (A - B) of the supplied matrices.
 */
- (MAVMutableMatrix *)subtractMatrix:(MAVMatrix *)matrix;

@end

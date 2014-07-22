/*
 *  MAVMutableMatrix.h
 *  MaVec
 *
 *  Created by Andrew McKnight on 6/1/14.
 *
 *  Copyright (c) 2014 Andrew Robert McKnight
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to 
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 */

#import "MAVMatrix.h"

@interface MAVMutableMatrix : MAVMatrix

/**
 *  Exchanges the values in the specified rows.
 *
 *  @param rowA The index of the first row to exchange.
 *  @param rowB The index of the first second to exchange.
 */
- (void)swapRowA:(__CLPK_integer)rowA withRowB:(__CLPK_integer)rowB;

/**
 *  Exchanges the values in the specified columns.
 *
 *  @param columnA  The index of the first column to exchange.
 *  @param columnB  The index of the second column to exchange.
 */
- (void)swapColumnA:(__CLPK_integer)columnA withColumnB:(__CLPK_integer)columnB;

/**
 *  Set the value at a position specified by row and column. Raises an 
 *  NSRangeException if the position does not exist in the matrix.
 *
 *  @param row The row in which the value will be set.
 *  @param column The column in which the value will be set.
 *  @param value The value to set at the specified position.
 */
- (void)setEntryAtRow:(__CLPK_integer)row column:(__CLPK_integer)column toValue:(NSNumber *)value;

/**
 *  Insert a column vector at the specified position.
 *
 *  @param vector The column vector of values to insert into this matrix.
 *  @param column The position at which to insert the column vector.
 */
- (void)setColumnVector:(MAVVector *)vector atColumn:(__CLPK_integer)column;

/**
 *  Insert a row vector at the specified position.
 *
 *  @param vector The row vector of values to insert into this matrix.
 *  @param row The position at which to insert the row vector.
 */
- (void)setRowVector:(MAVVector *)vector atRow:(__CLPK_integer)row;

/**
 *  Enable bracket operators to set row vectors of this matrix.
 *
 *  @param obj The row vector of values to insert.
 *  @param idx The row position at which to insert the values.
 */
- (void)setObject:(id)obj atIndexedSubscript:(__CLPK_integer)idx;

#pragma mark - Mathematical operations

/**
 *  Multiplies the recieving matrix by the supplied vector in place, whose
 *  dimensions must agree according to the rules of matrix-vector 
 *  multiplication: for A * b = c, A: m x p, b: p x 1 and C: m x 1.
 *
 *  @param vector The vector to multiply this matrix by.
 *
 *  @return A reference to the receiving matrix.
 */
- (MAVMutableMatrix *)multiplyByVector:(MAVVector *)vector;

/**
 *  Multiplies each value in the receiving matrix by a scalar value in place.
 *
 *  @param scalar The scalar to multiply each value in this matrix by.
 *
 *  @return A reference to the receiving matrix.
 */
- (MAVMutableMatrix *)multiplyByScalar:(NSNumber *)scalar;

/**
 *  Raises the receiving matrix to specified power. If power = 0, returns the 
 *  identity matrix of the same dimension; otherwise, the matrix is multiplied 
 *  by itself power number of times.
 *
 *  @param power The power to raise this matrix to. Essentially the number of
 *  times the matrix will be multiplied by itself.
 * 
 *  @warning Throws an exception if the receiving matrix is not square.
 *
 *  @return A reference to the receiving matrix.
 */
- (MAVMutableMatrix *)raiseToPower:(NSUInteger)power;

/**
 *  Multiplies receiving matrix by another matrix in place (self x matrix).
 *
 *  @param matrix The matrix to multiply the receiving matrix by.
 * 
 *  @note Matrix multiplication is not commutative: A x B ≠ B x A in general.
 *
 *  @warning Raises an NSInvalidArgumentException if A and B are not of 
 *  compatible dimensions for matrix multiplication (A.cols ≠ B.rows).
 *
 *  @return A reference to the receiving matrix.
 */
- (MAVMutableMatrix *)multiplyByMatrix:(MAVMatrix *)matrix;

/**
 *  Adds a matrix to the receiving matrix.
 * 
 *  @param matrix The matrix to add to the receiving matrix.
 *
 *  @warning Raises an NSInvalidArgumentException if A and B are not of equal
 *  dimension.
 *
 *  @return A reference to the receiving matrix.
 */
- (MAVMutableMatrix *)addMatrix:(MAVMatrix *)matrix;

/**
 *  Substracts a matrix from the receiving matrix.
 * 
 *  @param matrix The matrix to subtract from the receiving matrix.
 *
 *  @warning Raises an NSInvalidArgumentException if A and B are not of equal 
 *  dimension.
 *
 *  @return A reference to the receiving matrix.
 */
- (MAVMutableMatrix *)subtractMatrix:(MAVMatrix *)matrix;

@end

//
//  MAVMatrix+MAVMatrixFactory.h
//  MaVec
//
//  Created by Andrew McKnight on 12/26/15.
//
//  Copyright (c) 2014 Andrew Robert McKnight
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

#import "MAVMatrix.h"

@interface MAVMatrix (MAVMatrixFactory)

/**
 @brief Class convenience method to create a matrix with the specified number of rows and columns but without supplying values.
 @description  Instantiates a new object of type MAVMatrix with the specified number of rows and columns, with no supplied values, but with an initialized array to hold those values stored in column-major format and in the specified floating-point precision.
 @param rows The number of rows.
 @param columns The number of columns.
 @param precision The precision the matrix values will be stored in.
 @return New instance of MAVMatrix.
 */
+ (instancetype)matrixWithRows:(MAVIndex)rows
                       columns:(MAVIndex)columns
                     precision:(MCKPrecision)precision;

/**
 @brief Class convenience method to create a matrix with the specified number of rows and columns and storage format, but without supplying values.
 @description  Instantiates a new object of type MAVMatrix with the specified number of rows and columns, with no supplied values, but with an initialized array to hold those values stored in the specified format and specified floating-point precision..
 @param rows The number of rows.
 @param columns The number of columns.
 @param precision The precision the matrix values will be stored in.
 @param leadingDimension The format to store values in; either row- or column-major.
 @return New instance of MAVMatrix.
 */
+ (instancetype)matrixWithRows:(MAVIndex)rows
                       columns:(MAVIndex)columns
                     precision:(MCKPrecision)precision
              leadingDimension:(MAVMatrixLeadingDimension)leadingDimension;

/**
 @brief Class convenience method to create a matrix with the specified values and number of rows and columns.
 @description  Instantiates a new object of type MAVMatrix with the specified number of rows and columns and supplied values in column-major format.
 @param values The values to store in this matrix, supplied as a C array.
 @param rows The number of rows.
 @param columns The number of columns.
 @return New instance of MAVMatrix.
 */
+ (instancetype)matrixWithValues:(NSData *)values
                            rows:(MAVIndex)rows
                         columns:(MAVIndex)columns;

/**
 @brief Class convenience method to create a matrix with the specified values (in the specified storage format) and number of rows and columns.
 @description  Instantiates a new object of type MAVMatrix with the specified number of rows and columns and supplied values in the specified format.
 @param values The values to store in this matrix, supplied as a C array.
 @param rows The number of rows.
 @param columns The number of columns.
 @param leadingDimension The format to store values in; either row- or column-major.
 @return New instance of MAVMatrix.
 */
+ (instancetype)matrixWithValues:(NSData *)values
                            rows:(MAVIndex)rows
                         columns:(MAVIndex)columns
                leadingDimension:(MAVMatrixLeadingDimension)leadingDimension;

/**
 @brief Class convenience method to create a general matrix filled with a single supplied value.

 @param value   The value to fill the matrix with.
 @param rows    Amount of rows in the matrix.
 @param columns Amount of rows in the matrix.

 @return New instance of MAVMatrix filled with the supplied value.
 */
+ (instancetype)matrixFilledWithValue:(NSNumber *)value
                                 rows:(MAVIndex)rows
                              columns:(MAVIndex)columns;

/**
 @brief Class convenience method to create a triangular matrix filled with a single supplied value.

 @param value               The value to fill the matrix with.
 @param order               Amount of rows/columns in the square matrix.
 @param triangularComponent Either upper or lower, specifying the part of the matrix to fill with the supplied value.

 @return New triangular MAVMatrix with specified component filled with the supplied value.
 */
+ (instancetype)triangularMatrixFilledWithValue:(NSNumber *)value
                                          order:(MAVIndex)order
                            triangularComponent:(MAVMatrixTriangularComponent)triangularComponent;

/**
 @brief Class convenience method to create a band matrix filled with a single supplied value.

 @param value            The value to fill the matrix with.
 @param order            Amount of rows/columns in the square matrix.
 @param upperCodiagonals Amount of codiagonals above the diagonal to fill with the value.
 @param lowerCodiagonals Amount of codiagonals below the diagonal to fill with the value.

 @return New band MAVMatrix with band filled with the supplied value.
 */
+ (instancetype)bandMatrixFilledWithValue:(NSNumber *)value
                                    order:(MAVIndex)order
                         upperCodiagonals:(MAVIndex)upperCodiagonals
                         lowerCodiagonals:(MAVIndex)lowerCodiagonals;

/**
 @brief Class convenience method to create a square identity matrix with the specified size.
 @description  Instantiates a new object of type MAVMatrix with dimensions size x size whose diagonal values are 1.0 and all other values are 0.0, stored in column-major format.
 @param order The square dimension in which to create this identity matrix.
 @param precision The precision of the floating point values.
 @return New instance of MAVMatrix representing the identity matrix of dimension size x size.
 */
+ (instancetype)identityMatrixOfOrder:(MAVIndex)order
                            precision:(MCKPrecision)precision;

/**
 @brief Class convenience method to create a square matrix with the specified diagonal values.
 @description  Instantiates a new object of type MAVMatrix of dimension size x size with the specified diagonal values and other values as 0.0, stored in column-major format.
 @param values The values for the diagonal of the matrix, from the top-leftmost value to the bottom-rightmost value.
 @param order The square dimension inwhich to create this diagonal matrix.
 @return New instance of MAVMatrix representing the square matrix of dimension size x size with specified diagonal values.
 */
+ (instancetype)diagonalMatrixWithValues:(NSData *)values
                                   order:(MAVIndex)order;

/**
 @brief Class convenience method to create a matrix from an array of MAVVectors describing the matrix column vectors.
 @param columnVectors The array of MAVVector objects describing the columns of the matrix.
 @return A new instance of MAVMatrix.
 */
+ (instancetype)matrixWithColumnVectors:(NSArray *)columnVectors;

/**
 @brief Class convenience method to create a matrix from an array of MAVVectors describing the matrix row vectors.
 @param rowVectors The array of MAVVector objects describing the rows of the matrix.
 @return A new instance of MAVMatrix.
 */
+ (instancetype)matrixWithRowVectors:(NSArray *)rowVectors;

/**
 @brief Class convenience method to create a square matrix from an array of values describing a triangular component of a matrix, either upper or lower.
 @param values The array of values in the matrix.
 @param triangularComponent Which triangular component the provided values belong to. (Cannot be MAVMatrixTriangularComponentBoth)
 @param leadingDimension The leading dimension to use when accessing values in the provided one-dimensional array.
 @param order The number of rows/columns in the square triangular matrix.
 @return A new instance of MAVMatrix representing the desired triangular matrix.
 */
+ (instancetype)triangularMatrixWithPackedValues:(NSData *)values
                           ofTriangularComponent:(MAVMatrixTriangularComponent)triangularComponent
                                leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
                                           order:(MAVIndex)order;

/**
 @brief Class convenience method to create a square symmetric from an array of values describing a triangular component of a matrix, either upper or lower.
 @param values The array of values in the matrix.
 @param triangularComponent Which triangular component the provided values belong to. (Cannot be MAVMatrixTriangularComponentBoth)
 @param leadingDimension The leading dimension to use when accessing values in the provided one-dimensional array.
 @param order The number of rows/columns in the square triangular matrix.
 @return A new instance of MAVMatrix representing the desired triangular matrix.
 */
+ (instancetype)symmetricMatrixWithPackedValues:(NSData *)values
                            triangularComponent:(MAVMatrixTriangularComponent)triangularComponent
                               leadingDimension:(MAVMatrixLeadingDimension)leadingDimension
                                          order:(MAVIndex)order;

/**
 @brief Class convenience method to create a square band matrix with supplied (co)diagonal values in band matrix format (see http://www.roguewave.com/Portals/0/products/imsl-numerical-libraries/c-library/docs/6.0/math/default.htm?turl=matrixstoragemodes.htm for a good explanation).
 @param values Values in the bands of the matrix supplied in the band format.
 @param order Number of rows/columns in the matrix.
 @param bandwidth Number of diagonals and codiagonals in the band matrix.
 @param oddDiagonalLocation If there is an extra codiagonal, specifies whether it appears in the upper or lower triangular component of the matrix; disregarded otherwise. (Cannot be MAVMatrixTriangularComponentBoth if bandwidth is even).
 @return A new instance of MAVMatrix representing the band matrix.
 */
+ (instancetype)bandMatrixWithValues:(NSData *)values
                               order:(MAVIndex)order
                    upperCodiagonals:(MAVIndex)upperCodiagonals
                    lowerCodiagonals:(MAVIndex)lowerCodiagonals;

/**
 @brief Class convenience method to create a matrix describing the rotation of a vector through a fixed two dimensional Cartesian space.
 @param angle The magnitude of the angle.
 @param direction The direction of the angle, either clockwise or counterclockwise.
 @return A new instance of MAVMatrix representing the rotation matrix.
 */
+ (instancetype)matrixForTwoDimensionalRotationWithAngle:(NSNumber *)angle direction:(MAVAngleDirection)direction;

/**
 @brief Class convenience method to create a matrix describing the rotation of a vector about a single axis of a fixed three dimensional Cartesian space.
 @param angle The magnitude of the angle.
 @param axis The three dimensional Cartesian axis to rotate about, either X, Y or Z.
 @param direction The direction of the angle, either clockwise or counterclockwise, when the positive end of the axis faces the observer.
 @return A new instance of MAVMatrix representing the rotation matrix.
 */
+ (instancetype)matrixForThreeDimensionalRotationWithAngle:(NSNumber *)angle
                                                 aboutAxis:(MAVCoordinateAxis)axis
                                                 direction:(MAVAngleDirection)direction;

/**
 @brief Class convenience method to create a matrix with the specified size containing random double-precision floating-point values.
 @param rows The number of rows desired in the random matrix.
 @param columns The number of columns desired in the random matrix.
 @param precision The precision of the floating point values.
 @return A new instance of MAVMatrix containing rows * columns random values.
 */
+ (instancetype)randomMatrixWithRows:(MAVIndex)rows
                             columns:(MAVIndex)columns
                           precision:(MCKPrecision)precision;

/**
 @brief Class convenience method to create a square symmetric matrix with the specified order containing random double-precision floating-point values.
 @param order The amount of rows/columns desired in the matrix.
 @param precision The precision of the floating point values.
 @return A new square symmetric instance of MAVMatrix containing random values.
 */
+ (instancetype)randomSymmetricMatrixOfOrder:(MAVIndex)order
                                   precision:(MCKPrecision)precision;

/**
 @brief Class convenience method to create a square diagonal matrix with the specified order containing random double-precision floating-point values.
 @param order The amount of rows/columns desired in the matrix.
 @param precision The precision of the floating point values.
 @return A new square diagonal instance of MAVMatrix containing random values.
 */
+ (instancetype)randomDiagonalMatrixOfOrder:(MAVIndex)order
                                  precision:(MCKPrecision)precision;

/**
 @brief Class convenience method to create a square triangular matrix with the specified order containing random double-precision floating-point values.
 @param order The amount of rows/columns desired in the matrix.
 @param triangularComponent The triangular component the values should reside in, either upper or lower (cannot be MAVMatrixTriangularComponentBoth).
 @param precision The precision of the floating point values.
 @return A new square triangular instance of MAVMatrix containing random values.
 */
+ (instancetype)randomTriangularMatrixOfOrder:(MAVIndex)order
                          triangularComponent:(MAVMatrixTriangularComponent)triangularComponent
                                    precision:(MCKPrecision)precision;

/**
 @brief Class convenience method to create a square band matrix with the specified order containing random double-precision floating-point values.
 @param order The amount of rows/columns desired in the matrix.
 @param bandwidth Number of diagonals and codiagonals in the band matrix.
 @param oddDiagonalLocation If there is an extra codiagonal, specifies whether it appears in the upper or lower triangular component of the matrix; disregarded otherwise. (Cannot be MAVMatrixTriangularComponentBoth if bandwidth is even).
 @param precision The precision of the floating point values.
 @return A new square band instance of MAVMatrix containing random values.
 */
+ (instancetype)randomBandMatrixOfOrder:(MAVIndex)order
                       upperCodiagonals:(MAVIndex)upperCodiagonals
                       lowerCodiagonals:(MAVIndex)lowerCodiagonals
                              precision:(MCKPrecision)precision;

/**
 @brief Generate a square matrix of random values with the specified definiteness and precision. Random semidefinite matrices are currently generated as diagonal matrices, the others have random values throughout.
 @param order The square dimension of the matrix to be generated.
 @param definiteness The definiteness of the matrix to generate, either positive defininte, positivie semidefinite, negative definite, negative semidefinite, or indefinite. (Passing MAVMatrixDefinitenessUnknown will simply return a random matrix generated by randomMatrixWithRows:columns:precision:)
 @param precision The precision of the random floating point values to generate, either single- or double-precision.
 @return A square MAVMatrix object containing random floating point values of desired precision that satisfies the specified definiteness criteria.
 */
+ (instancetype)randomMatrixOfOrder:(MAVIndex)order
                       definiteness:(MAVMatrixDefiniteness)definiteness
                          precision:(MCKPrecision)precision;

/**
 @brief Generate a square matrix of random values with a determinant of 0, accomplished by making an entire row or column (randomly chosen) with 0 values.
 @param order The square dimension of the matrix.
 @param precision Either single- or double-precision floating point values.
 @return New instance of MAVMatrix with random values and determinant == 0.
 */
+ (instancetype)randomSingularMatrixOfOrder:(MAVIndex)order precision:(MCKPrecision)precision;

/**
 @brief Generate a square matrix of random values with a determinant not equal to 0.
 @param order The square dimension of the matrix.
 @param precision Either single- or double-precision floating point values.
 @return New instance of MAVMatrix with random values and determinant != 0.
 */
+ (instancetype)randomNonsigularMatrixOfOrder:(MAVIndex)order precision:(MCKPrecision)precision;

@end

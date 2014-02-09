//
//  Matrix.h
//  AccelerometerPlot
//
//  Created by andrew mcknight on 11/30/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCSingularValueDecomposition;
@class MCLUFactorization;
@class MCQRFactorization;
@class MCEigendecomposition;
@class MCVector;
@class MCTribool;

/**
 @brief Constants specifying the logical storage type for this matrix' values.
 @constant MCMatrixValueStorageFormatRowMajor Specifies that this matrix' values are stored in row-major order.
 @constant MCMatrixValueStorageFormatColumnMajor Specifies that this matrix' values are stored in column-major order.
 */
typedef enum {
    MCMatrixValueStorageFormatRowMajor,
    MCMatrixValueStorageFormatColumnMajor
} MCMatrixValueStorageFormat;

typedef enum {
    MCMatrixTriangularComponentLower,
    MCMatrixTriangularComponentUpper
} MCMatrixTriangularComponent;

typedef enum {
    MCMatrixValuePackingFormatPacked,
    MCMatrixValuePackingFormatUnpacked
} MCMatrixValuePackingFormat;

/**
 @brief A class providing storage and operations for matrices of double-precision floating point numbers.
 @description By default (except for objects instantiated using initWithRows:columns:valueStorageFormat: or initWithValues:rows:columns:valueStorageFormat:) values must be supplied in column-major format, as this is the format in which the accelerate framework expects them. For example, the following matrix is written in a one-dimensional array with column-major format as 1, 4, 2, 5, 3, 6 and in row-major format as 1, 2, 3, 4, 5, 6.@code
 [ 1  2  3
 
   4  5  6 ]
 */
@interface MCMatrix : NSObject <NSCopying>

/**
 @property rows 
 @brief The number of rows in the matrix.
 */
@property (nonatomic, readonly, assign) NSUInteger rows;

/**
 @property columns
 @brief The number of columns in the matrix.
 */
@property (nonatomic, readonly, assign) NSUInteger columns;

/**
 @property values
 @brief A one-dimensional C array of floating point values.
 */
@property (nonatomic, readonly, assign) double *values;

/**
 @property valueStorageFormat 
 @brief The logical storage format for the matrix' values in the one-dimensional array.
 */
@property (nonatomic, assign) MCMatrixValueStorageFormat valueStorageFormat;

/**
 @property transpose
 @brief Transpose of this matrix. (Lazy-loaded)
 */
@property (nonatomic, readonly, strong) MCMatrix *transpose;

/**
 @property determinant
 @brief The determinant of this matrix. (Lazy-loaded)
 */
@property (nonatomic, readonly, strong) NSNumber *determinant;

/**
 @property inverse
 @brief The (pseudo)inverse of this matrix in a new MCMatrix object. (Lazy-loaded)
 */

@property (nonatomic, readonly, strong) MCMatrix *inverse;

/**
 @property conditionNumber
 @brief The condition number of this matrix. (Lazy-loaded)
 */
@property (nonatomic, readonly, strong) NSNumber *conditionNumber;

/**
 @property qrFactorization
 @brief An MCQRFactorization object containing matrices representing the QR factorization of this matrix. (Lazy-loaded)
 */
@property (nonatomic, readonly, strong) MCQRFactorization *qrFactorization;

/**
 @property luFactorization
 @description Helpful documentation at http://www.netlib.no/netlib/lapack/double/dgetrf.f and https://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.essl.v5r2.essl100.doc%2Fam5gr_hsgetrf.htm
 @brief An MCLUFactorization object contatining matrices representing the LU factorization of this matrix. (Lazy-loaded)
 */
@property (nonatomic, readonly, strong) MCLUFactorization *luFactorization;

/**
 @property singularValueDecomposition
 @description Uses the Accelerate framework function dgesdd_. Examples of dgesdd_(...) usage found at http://software.intel.com/sites/products/documentation/doclib/mkl_sa/11/mkl_lapack_examples/lapacke_dgesdd_row.c.htm and http://stackoverflow.com/questions/5047503/lapack-svd-singular-value-decomposition Good documentation exists at http://www.netlib.org/lapack/lug/node53.html and http://www.nag.com/numeric/FL/nagdoc_fl22/xhtml/F08/f08kdf.xml. See http://www.netlib.org/lapack/lug/node38.html for general documentation.
 @brief An MCSingularValueDecomposition object containing matrices representing the singular value decomposition of this matrix, or nil if no such decomposition exists. (Lazy-loaded)
 */
@property (nonatomic, readonly, strong) MCSingularValueDecomposition *singularValueDecomposition;

/**
 @property eigendecomposition
 @brief Computes the eigendecomposition (spectral factorization) of this matrix. Documentation found at ... . (Lazy-loaded)
 */
@property (nonatomic, readonly, strong) MCEigendecomposition *eigendecomposition;

/**
 @property isSymmetric
 @brief YES if this matrix is symmetric, NO otherwise. (Lazy-loaded)
 */
@property (nonatomic, readonly, strong) MCTribool *isSymmetric;

/**
 @property isPositiveDefinite
 @brief YES if this matrix is positive definite, NO otherwise. (Lazy-loaded)
 */
@property (nonatomic, readonly, strong) MCTribool *isPositiveDefinite;

#pragma mark - Constructors

/**
 @brief Creates a column-major matrix with the specified number of rows and columns but without supplying values.
 @description  Instantiates a new object of type MCMatrix with the specified number of rows and columns, with no supplied values, but with an initialized array to hold those values stored in column-major format.
 @param rows The number of rows.
 @param columns The number of columns.
 @return New instance of MCMatrix.
 */
- (instancetype)initWithRows:(NSUInteger)rows
           columns:(NSUInteger)columns;

/**
 @brief Creates a matrix with the specified number of rows and columns and storage format, but without supplying values.
 @description  Instantiates a new object of type MCMatrix with the specified number of rows and columns, with no supplied values, but with an initialized array to hold those values stored in the specified format.
 @param rows The number of rows.
 @param columns The number of columns.
 @param valueStorageFormat The format to store values in; either row- or column-major.
 @return New instance of MCMatrix.
 */
- (instancetype)initWithRows:(NSUInteger)rows
           columns:(NSUInteger)columns
valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat;

/**
 @brief Creates a matrix with the specified values and number of rows and columns.
 @description  Instantiates a new object of type MCMatrix with the specified number of rows and columns and supplied values in column-major format.
 @param values The values to store in this matrix, supplied as a C array.
 @param rows The number of rows.
 @param columns The number of columns.
 @return New instance of MCMatrix.
 */
- (instancetype)initWithValues:(double *)values
                rows:(NSUInteger)rows
             columns:(NSUInteger)columns;

/**
 @brief Creates a matrix with the specified values (in the specified storage format) and number of rows and columns.
 @description  Instantiates a new object of type MCMatrix with the specified number of rows and columns and supplied values in the specified format.
 @param values The values to store in this matrix, supplied as a C array.
 @param rows The number of rows.
 @param columns The number of columns.
 @param valueStorageFormat The format to store values in; either row- or column-major.
 @return New instance of MCMatrix.
 */
- (instancetype)initWithValues:(double *)values
                rows:(NSUInteger)rows
             columns:(NSUInteger)columns
  valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat;

- (instancetype)initWithColumnVectors:(NSArray *)columnVectors;
- (instancetype)initWithRowVectors:(NSArray *)rowVectors;

/**
 @brief Class convenience method to create a matrix with the specified number of rows and columns but without supplying values.
 @description  Instantiates a new object of type MCMatrix with the specified number of rows and columns, with no supplied values, but with an initialized array to hold those values stored in column-major format.
 @param rows The number of rows.
 @param columns The number of columns.
 @return New instance of MCMatrix.
 */
+ (instancetype)matrixWithRows:(NSUInteger)rows
             columns:(NSUInteger)columns;

/**
 @brief Class convenience method to create a matrix with the specified number of rows and columns and storage format, but without supplying values.
 @description  Instantiates a new object of type MCMatrix with the specified number of rows and columns, with no supplied values, but with an initialized array to hold those values stored in the specified format.
 @param rows The number of rows.
 @param columns The number of columns.
 @param valueStorageFormat The format to store values in; either row- or column-major.
 @return New instance of MCMatrix.
 */
+ (instancetype)matrixWithRows:(NSUInteger)rows
             columns:(NSUInteger)columns
  valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat;

/**
 @brief Class convenience method to create a matrix with the specified values and number of rows and columns.
 @description  Instantiates a new object of type MCMatrix with the specified number of rows and columns and supplied values in column-major format.
 @param values The values to store in this matrix, supplied as a C array.
 @param rows The number of rows.
 @param columns The number of columns.
 @return New instance of MCMatrix.
 */
+ (instancetype)matrixWithValues:(double *)values
                  rows:(NSUInteger)rows
               columns:(NSUInteger)columns;

/**
 @brief Class convenience method to create a matrix with the specified values (in the specified storage format) and number of rows and columns.
 @description  Instantiates a new object of type MCMatrix with the specified number of rows and columns and supplied values in the specified format.
 @param values The values to store in this matrix, supplied as a C array.
 @param rows The number of rows.
 @param columns The number of columns.
 @param valueStorageFormat The format to store values in; either row- or column-major.
 @return New instance of MCMatrix.
 */
+ (instancetype)matrixWithValues:(double *)values
                  rows:(NSUInteger)rows
               columns:(NSUInteger)columns
    valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat;

/**
 @brief Class convenience method to create a square identity matrix with the specified size.
 @description  Instantiates a new object of type MCMatrix with dimensions size x size whose diagonal values are 1.0 and all other values are 0.0, stored in column-major format.
 @param size The square dimension in which to create this identity matrix.
 @return New instance of MCMatrix representing the identity matrix of dimension size x size.
 */
+ (instancetype)identityMatrixWithSize:(NSUInteger)size;

/**
 @brief Class convenience method to create a square matrix with the specified diagonal values.
 @description  Instantiates a new object of type MCMatrix of dimension size x size with the specified diagonal values and other values as 0.0, stored in column-major format.
 @param values The values for the diagonal of the matrix, from the top-leftmost value to the bottom-rightmost value.
 @return New instance of MCMatrix representing the square matrix of dimension size x size with specified diagonal values.
 */
+ (instancetype)diagonalMatrixWithValues:(double *)values size:(NSUInteger)size;

+ (instancetype)matrixWithColumnVectors:(NSArray *)columnVectors;
+ (instancetype)matrixWithRowVectors:(NSArray *)rowVectors;

#pragma mark - Operations

/**
 @return A new MCMatrix object with the values from this matrix (in the same valueStorageFormat), excluding the specified row and index values. 
 */
- (MCMatrix *)minorByRemovingRow:(NSUInteger)row column:(NSUInteger)column;

/**
 @return The (pseudo)inverse of this matrix in a new MCMatrix object.
 */
- (MCMatrix *)inverse;

- (void)swapRowA:(NSUInteger)rowA withRowB:(NSUInteger)rowB;

- (void)swapColumnA:(NSUInteger)columnA withColumnB:(NSUInteger)columnB;

/**
 @return An MCQRFactorization object containing matrices representing the QR factorization of this matrix.
 */
- (MCQRFactorization *)qrFactorization;

/**
 @description Helpful documentation at http://www.netlib.no/netlib/lapack/double/dgetrf.f and https://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.essl.v5r2.essl100.doc%2Fam5gr_hsgetrf.htm
 @return An MCLUFactorization object contatining matrices representing the LU factorization of this matrix.
 */
- (MCLUFactorization *)luFactorization;

/**
 @description Uses the Accelerate framework function dgesdd_. Examples of dgesdd_(...) usage found at http://software.intel.com/sites/products/documentation/doclib/mkl_sa/11/mkl_lapack_examples/lapacke_dgesdd_row.c.htm and http://stackoverflow.com/questions/5047503/lapack-svd-singular-value-decomposition Good documentation exists at http://www.netlib.org/lapack/lug/node53.html and http://www.nag.com/numeric/FL/nagdoc_fl22/xhtml/F08/f08kdf.xml. See http://www.netlib.org/lapack/lug/node38.html for general documentation.
 @return An MCSingularValueDecomposition object containing matrices representing the singular value decomposition of this matrix, or nil if no such decomposition exists.
 */
- (MCSingularValueDecomposition *)singularValueDecomposition;

/**
 @description Computes the eigendecomposition (spectral factorization) of this matrix. Documentation found at 
 */
- (MCEigendecomposition *)eigendecomposition;

#pragma mark - NSObject overrides

/**
 @return YES if object is either this MCMatrix instance or is identical in dimension and contains identical values at all positions, NO otherwise.
 */
- (BOOL)isEqualToMatrix:(MCMatrix *)otherMatrix;

/**
 @return YES if object is either this MCMatrix instance or is identical in dimension and contains identical values at all positions, NO otherwise.
 */
- (BOOL)isEqual:(id)object;

/**
 @return An NSString that can represent the values of this matrix in the usual two-dimensional human-readable format.
 */
- (NSString *)description;

#pragma mark - Inspection

/**
 @return A copy of this matrix' values stored in the specified format (row-major or column-major).
 */
- (double *)valuesInStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat;

- (double *)triangularValuesFromTriangularComponent:(MCMatrixTriangularComponent)triangularComponent
                                    inStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
                                  withPackingFormat:(MCMatrixValuePackingFormat)packingFormat;

/**
 @description Get the value at a position specified by row and column. Raises an NSRangeException if the position does not exist in the matrix.
 @param row The row in which the desired value resides.
 @param column The column in which the desired value resides.
 @return The value at the specified row and column.
 */
- (double)valueAtRow:(NSUInteger)row column:(NSUInteger)column;

- (MCVector *)columnVectorForColumn:(NSUInteger)column;
- (MCVector *)rowVectorForRow:(NSUInteger)row;

#pragma mark - Mutation

/**
 @description Set the value at a position specified by row and column. Raises an NSRangeException if the position does not exist in the matrix.
 @param row The row in which the value will be set.
 @param column The column in which the value will be set.
 @param value The value to set at the specified position.
 */
- (void)setEntryAtRow:(NSUInteger)row column:(NSUInteger)column toValue:(double)value;

#pragma mark - Class-level operations

/**
 @description Performs matrix multiplication on matrices A and B. Note that matrix multiplication is not commutative--in general, A x B ¬= B x A. Raises an NSInvalidArgumentException if A and B are not of compatible dimensions for matrix multiplication.
 @return A new MCMatrix object representing the product of the expression A x B.
 */
+ (MCMatrix *)productOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB;

/**
 @description Raises an NSInvalidArgumentException if A and B are not of equal dimension.
 @return A new MCMatrix object representing the sum (A + B) of the supplied matrices.
 */
+ (MCMatrix *)sumOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB;

/**
 @description Raises an NSInvalidArgumentException if A and B are not of equal dimension.
 @return A new MCMatrix object representing the difference (A - B) of the supplied matrices.
 */
+ (MCMatrix *)differenceOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB;

/**
 @description Good documentation for solving Ax=b where A is a square matrix located  at http://www.netlib.org/lapack/double/dgesv.f and example at http://software.intel.com/sites/products/documentation/doclib/mkl_sa/11/mkl_lapack_examples/dgesv_ex.c.htm. When A is a general m x n matrix, see documentation at http://www.netlib.org/lapack/double/dgels.f and example at http://software.intel.com/sites/products/documentation/doclib/mkl_sa/11/mkl_lapack_examples/dgels_ex.c.htm
 @return A column vector containing coefficients for unknows to solve a linear system Ax=B, or nil if the system cannot be solved. Raises an NSInvalidArgumentException if A and B are of incompatible dimension.
 */
+ (MCMatrix *)solveLinearSystemWithMatrixA:(MCMatrix *)A
                                 valuesB:(MCMatrix*)B;

@end

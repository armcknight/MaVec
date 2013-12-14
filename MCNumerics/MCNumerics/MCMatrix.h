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

@interface MCMatrix : NSObject

@property (nonatomic, assign) double *values;
@property (nonatomic, assign) NSUInteger rows;
@property (nonatomic, assign) NSUInteger columns;

#pragma mark - Constructors

/* 
 values arrays must be in column major format
 e.g.  [ 1  2  3
         4  5  6 ]
 
 is written as 1, 4, 2, 5, 3, 6
 */


- (id)initWithRows:(NSUInteger)rows
           columns:(NSUInteger)columns;

- (id)initWithValues:(double *)values
                rows:(NSUInteger)rows
             columns:(NSUInteger)columns;

+ (id)matrixWithRows:(NSUInteger)rows
             columns:(NSUInteger)columns;

+ (id)matrixWithValues:(double *)values
                  rows:(NSUInteger)rows
               columns:(NSUInteger)columns;

//+ (id)identityMatrixWithSize:(NSUInteger)size;
//+ (id)diagonalMatrixWithValues:(double *)values size:(NSUInteger)size;

#pragma mark - Operations

// compute and return the transpose of this matrix in a new object
- (MCMatrix *)transpose;

// return a matrix object with this matrix' values (stored in column-major order) with values in row-major order
- (MCMatrix *)rowMajor;

// return a matrix object with this matrix' values (stored in row-major order) with values in column-major order
- (MCMatrix *)columnMajor;
- (MCMatrix *)minorByRemovingRow:(NSUInteger)row column:(NSUInteger)column;
- (double)determinant;
//- (Matrix *)inverse;
//- (double)conditionNumber;
//- (QRFactorization *)qrFactorization;
//- (LUFactorization *)luFactorization;

// compute the singular value decomposition and return a container object with the component matrices, or nil if no decomposition exists
- (MCSingularValueDecomposition *)singularValueDecomposition;

#pragma mark - Inspection

// print the matrix in standard form by implicitly transposing from column-major to row-major ordering
- (NSString *)description;
- (double)valueAtRow:(NSUInteger)row column:(NSUInteger)column;
- (BOOL)isSymmetric;
- (BOOL)isPositiveDefinite;

#pragma mark - Class-level operations

// returns a column vector containing coefficients for unknows to solve a linear system Ax=B, or nil if the system cannot be solved
+ (MCMatrix *)productOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB;
//+ (Matrix *)sumOfMatrixA:(Matrix *)matrixA andMatrixB:(Matrix *)matrixB;
//+ (Matrix *)differenceOfMatrixA:(Matrix *)matrixA andMatrixB:(Matrix *)matrixB;
+ (MCMatrix *)solveLinearSystemWithMatrixA:(MCMatrix *)A
                                 valuesB:(MCMatrix*)B;

@end

@interface MCQRFactorization : NSObject

@property (nonatomic, strong) MCMatrix *q;
@property (nonatomic, strong) MCMatrix *r;

@end

@interface MCLUFactorization : NSObject

@property (nonatomic, strong) MCMatrix *l;
@property (nonatomic, strong) MCMatrix *u;

@end

@interface MCSingularValueDecomposition : NSObject

@property (nonatomic, strong) MCMatrix *u;
@property (nonatomic, strong) MCMatrix *s;
@property (nonatomic, strong) MCMatrix *vT;

- (id)initWithM:(NSUInteger)m n:(NSUInteger)n numberOfSingularValues:(NSUInteger)s;
+ (id)SingularValueDecompositionWithM:(NSUInteger)m n:(NSUInteger)n numberOfSingularValues:(NSUInteger)s;

@end

//
//  Matrix.h
//  AccelerometerPlot
//
//  Created by andrew mcknight on 11/30/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SingularValueDecomposition;
@class LUFactorization;
@class QRFactorization;

@interface Matrix : NSObject

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
- (Matrix *)transpose;

// return a matrix object with this matrix' values (stored in column-major order) with values in row-major order
- (Matrix *)rowMajor;

// return a matrix object with this matrix' values (stored in row-major order) with values in column-major order
- (Matrix *)columnMajor;
- (Matrix *)minorByRemovingRow:(NSUInteger)row column:(NSUInteger)column;
- (double)determinant;
//- (Matrix *)inverse;
//- (double)conditionNumber;
//- (QRFactorization *)qrFactorization;
//- (LUFactorization *)luFactorization;

// compute the singular value decomposition and return a container object with the component matrices, or nil if no decomposition exists
- (SingularValueDecomposition *)singularValueDecomposition;

#pragma mark - Inspection

// print the matrix in standard form by implicitly transposing from column-major to row-major ordering
- (NSString *)description;

#pragma mark - Class-level operations

// returns a column vector containing coefficients for unknows to solve a linear system Ax=B, or nil if the system cannot be solved
+ (Matrix *)productOfMatrixA:(Matrix *)matrixA andMatrixB:(Matrix *)matrixB;
//+ (Matrix *)sumOfMatrixA:(Matrix *)matrixA andMatrixB:(Matrix *)matrixB;
//+ (Matrix *)differenceOfMatrixA:(Matrix *)matrixA andMatrixB:(Matrix *)matrixB;
+ (Matrix *)solveLinearSystemWithMatrixA:(Matrix *)A
                                 valuesB:(Matrix*)B;

@end

@interface QRFactorization : NSObject

@property (nonatomic, strong) Matrix *q;
@property (nonatomic, strong) Matrix *r;

@end

@interface LUFactorization : NSObject

@property (nonatomic, strong) Matrix *l;
@property (nonatomic, strong) Matrix *u;

@end

@interface SingularValueDecomposition : NSObject

@property (nonatomic, strong) Matrix *u;
@property (nonatomic, strong) Matrix *s;
@property (nonatomic, strong) Matrix *vT;

- (id)initWithM:(NSUInteger)m n:(NSUInteger)n numberOfSingularValues:(NSUInteger)s;
+ (id)SingularValueDecompositionWithM:(NSUInteger)m n:(NSUInteger)n numberOfSingularValues:(NSUInteger)s;

@end

//
//  MCSingularValueDecomposition.h
//  MCNumerics
//
//  Created by andrew mcknight on 12/15/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCMatrix;

/**
 @brief Container class to hold the results of a singular value decomposition in MCMatrix objects.
 @description The singular value decomposition factors an m x m matrix M into the product UΣV^T (V^T = transpose of V), where U is an m x m unitary matrix, Σ is an m x n diagonal matrix and V^T is the transpose of an n x n unitary matrix. The values on Σ's diagonal are nonnegative real numbers, called the singular values of M.
 */
@interface MCSingularValueDecomposition : NSObject

/**
 @property u
 @brief An MCMatrix holding the upper triangular matrix U of the LU factorization.
 */
@property (nonatomic, strong) MCMatrix *u;

/**
 @property u
 @brief An MCMatrix holding the upper triangular matrix U of the LU factorization.
 */
@property (nonatomic, strong) MCMatrix *s;

/**
 @property u
 @brief An MCMatrix holding the upper triangular matrix U of the LU factorization.
 */
@property (nonatomic, strong) MCMatrix *vT;

/**
 @brief Instantiates a new MCSingularValueDecomposition object.
 @description Instantiates a new MCMatrix object each for u, s and vT.
 @param m The number of rows=columns in u, and number of rows in s.
 @param n The number of rows=columns in vT, and number of columns in s.
 @param s The number of singular values in s.
 @return A new MCSingularValueDecomposition object.
 */
- (id)initWithM:(NSUInteger)m n:(NSUInteger)n numberOfSingularValues:(NSUInteger)s;

/**
 @brief Class convenience method for initWithM:n:numberOfSingularValues:.
 */
+ (id)SingularValueDecompositionWithM:(NSUInteger)m n:(NSUInteger)n numberOfSingularValues:(NSUInteger)s;

@end

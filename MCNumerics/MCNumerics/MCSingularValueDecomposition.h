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
@interface MCSingularValueDecomposition : NSObject <NSCopying>

/**
 @property u
 @brief An MCMatrix holding the upper triangular matrix U of the SVD.
 */
@property (nonatomic, strong, readonly) MCMatrix *u;

/**
 @property u
 @brief An MCMatrix holding the sigma matrix of the SVD.
 */
@property (nonatomic, strong, readonly) MCMatrix *s;

/**
 @property u
 @brief An MCMatrix holding the v transpose matrix of the SVD.
 */
@property (nonatomic, strong, readonly) MCMatrix *vT;

/**
 @brief Instantiates a new MCSingularValueDecomposition object as computed from a supplied matrix.
 @param matrix The matrix used to compute the SVD.
 @return A new MCSingularValueDecomposition object containing the U, sigma, and V transpose matrices of the decomposition.
 */
- (instancetype)initWithMatrix:(MCMatrix *)matrix;

/**
 @brief Class convenience method for singularValueDecompositionWithMatrix:
 @param matrix The matrix used to compute the SVD.
 @return A new MCSingularValueDecomposition object object containing the U, sigma, and V transpose matrices of the decomposition.
 */
+ (instancetype)singularValueDecompositionWithMatrix:(MCMatrix *)matrix;

@end

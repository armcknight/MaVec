//
//  MCLUFactorization.h
//  MCNumerics
//
//  Created by andrew mcknight on 12/15/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCMatrix;

/**
 @brief Container class to hold the results of a LU factorization in MCMatrix objects.
 @description The LU factorization decomposes a matrix A into the product LU, where L is a lower triangular matrix and U is an upper triangular matrix.
 */
@interface MCLUFactorization : NSObject

/**
 @property l
 @brief An MCMatrix holding the lower triangular matrix L of the LU factorization.
 */
@property (nonatomic, readonly, strong) MCMatrix *lowerTriangularMatrix;

/**
 @property u
 @brief An MCMatrix holding the upper triangular matrix U of the LU factorization.
 */
@property (nonatomic, readonly, strong) MCMatrix *upperTriangularMatrix;

/**
 @property p
 @brief The permutation matrix of the LU factorization. See see http://www.math.drexel.edu/~tolya/permutations.pdf for explanation of permutation matrices.
 */
@property (nonatomic, readonly, strong) MCMatrix *permutationMatrix;

#pragma mark - Init

- (instancetype)initWithMatrix:(MCMatrix *)matrix;
+ (instancetype)luFactorizationOfMatrix:(MCMatrix *)matrix;

@end


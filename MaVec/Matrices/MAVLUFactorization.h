//
//  MAVLUFactorization.h
//  MaVec
//
//  Created by andrew mcknight on 12/15/13.
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

#import <Foundation/Foundation.h>

@class MAVMatrix;

/**
 @brief Container class to hold the results of a LU factorization in MAVMatrix objects.
 @description The LU factorization decomposes a matrix A into the product LU, where L is a lower triangular matrix and U is an upper triangular matrix.
 */
@interface MAVLUFactorization : NSObject <NSCopying>

/**
 @property l
 @brief An MAVMatrix holding the lower triangular matrix L of the LU factorization.
 */
@property (nonatomic, readonly, strong) MAVMatrix *lowerTriangularMatrix;

/**
 @property u
 @brief An MAVMatrix holding the upper triangular matrix U of the LU factorization.
 */
@property (nonatomic, readonly, strong) MAVMatrix *upperTriangularMatrix;

/**
 @property p
 @brief The permutation matrix of the LU factorization. See see http://www.math.drexel.edu/~tolya/permutations.pdf for explanation of permutation matrices.
 */
@property (nonatomic, readonly, strong) MAVMatrix *permutationMatrix;

/**
 @brief The number of row swaps induced by the permutation matrix.
 */
@property (nonatomic, readonly, assign) NSUInteger numberOfPermutations;

#pragma mark - Init

/**
 @brief Create a new MAVLUFactorization object by calculating the factorization of the provided matrix.
 @param matrix The matrix to factorize.
 @return A new instance of MAVLUFactorization containing the resulting L and U matrices of the factorization.
 */
- (instancetype)initWithMatrix:(MAVMatrix *)matrix;

/**
 @brief Class convenience method for initWithMatrix:
 @param matrix The matrix to factorize.
 @return A new instance of MAVLUFactorization containing the resulting L and U matrices of the factorization.
 */
+ (instancetype)luFactorizationOfMatrix:(MAVMatrix *)matrix;

@end


//
//  MAVSingularValueDecomposition.h
//  MaVec
//
//  Created by Andrew McKnight on 12/15/13.
//
//  Copyright © 2015 AMProductions
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
 @brief Container class to hold the results of a singular value decomposition in MAVMatrix objects.
 @description The singular value decomposition factors an m x m matrix M into the product UΣV^T (V^T = transpose of V), where U is an m x m unitary matrix, Σ is an m x n diagonal matrix and V^T is the transpose of an n x n unitary matrix. The values on Σ's diagonal are nonnegative real numbers, called the singular values of M.
 */
@interface MAVSingularValueDecomposition : NSObject <NSCopying>

/**
 @property u
 @brief An MAVMatrix holding the upper triangular matrix U of the SVD.
 */
@property (nonatomic, strong, readonly) MAVMatrix *u;

/**
 @property u
 @brief An MAVMatrix holding the sigma matrix of the SVD.
 */
@property (nonatomic, strong, readonly) MAVMatrix *s;

/**
 @property u
 @brief An MAVMatrix holding the v transpose matrix of the SVD.
 */
@property (nonatomic, strong, readonly) MAVMatrix *vT;

/**
 @brief Instantiates a new MAVSingularValueDecomposition object as computed from a supplied matrix.
 @param matrix The matrix used to compute the SVD.
 @return A new MAVSingularValueDecomposition object containing the U, sigma, and V transpose matrices of the decomposition.
 */
- (instancetype)initWithMatrix:(MAVMatrix *)matrix;

/**
 @brief Class convenience method for singularValueDecompositionWithMatrix:
 @param matrix The matrix used to compute the SVD.
 @return A new MAVSingularValueDecomposition object object containing the U, sigma, and V transpose matrices of the decomposition.
 */
+ (instancetype)singularValueDecompositionWithMatrix:(MAVMatrix *)matrix;

@end

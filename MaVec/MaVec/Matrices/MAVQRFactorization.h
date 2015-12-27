//
//  MAVQRFactorization.h
//  MaVec
//
//  Created by Andrew McKnight on 1/14/14.
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
 @brief Container class to hold the results of a QR factorization in MAVMatrix objects.
 @description The QR factorization decomposes a matrix A into the product QR, where Q is an orthogonal matrix and R is an upper triangular matrix.
 */
@interface MAVQRFactorization : NSObject <NSCopying>

/**
 @property q
 @brief An MAVMatrix holding the orthogonal matrix Q of the QR factorization.
 */
@property (nonatomic, strong) MAVMatrix *q;

/**
 @property r
 @brief An MAVMatrix holding the upper triangular matrix R of the QR factorization.
 */
@property (nonatomic, strong) MAVMatrix *r;

#pragma mark - Init

/**
 @brief Create a new instance of MAVQRFactorization by computing the factorization of the provided matrix.
 @param matrix The MAVMatrix object to compute the factorization from.
 @return A new MAVQRFactorization object containing the results of factorizing the provided matrix.
 */
- (instancetype)initWithMatrix:(MAVMatrix *)matrix;

/**
 @brief Convenience class method to create a new instance of MAVQRFactorization by computing the factorization of the provided matrix.
 @param matrix The MAVMatrix object to compute the factorization from.
 @return A new MAVQRFactorization object containing the results of factorizing the provided matrix.
 */
+ (instancetype)qrFactorizationOfMatrix:(MAVMatrix *)matrix;

#pragma mark - Operations

/**
 @brief When factorizing a general m x n matrix (m ≥ n), the resulting Q matrix is m x m and R is m x n upper triangular. The thin factorization takes the first n rows of R and n columns of Q.
 @code 
                  [ R1                 [ R1
 A = Q * R = Q *    0  ] = [Q1, Q2] *    0  ]
 
 A = Q1 * R1 is the thin factorization
 */
- (MAVQRFactorization *)thinFactorization;

- (NSString *)description;

@end

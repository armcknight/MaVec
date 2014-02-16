//
//  MCQRFactorization.h
//  MCNumerics
//
//  Created by andrew mcknight on 1/14/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCMatrix;

/**
 @brief Container class to hold the results of a QR factorization in MCMatrix objects.
 @description The QR factorization decomposes a matrix A into the product QR, where Q is an orthogonal matrix and R is an upper triangular matrix.
 */
@interface MCQRFactorization : NSObject <NSCopying>

/**
 @property q
 @brief An MCMatrix holding the orthogonal matrix Q of the QR factorization.
 */
@property (nonatomic, strong) MCMatrix *q;

/**
 @property r
 @brief An MCMatrix holding the upper triangular matrix R of the QR factorization.
 */
@property (nonatomic, strong) MCMatrix *r;

#pragma mark - Init

- (instancetype)initWithMatrix:(MCMatrix *)matrix;
+ (instancetype)qrFactorizationOfMatrix:(MCMatrix *)matrix;

#pragma mark - Operations

- (MCQRFactorization *)thinFactorization;

@end

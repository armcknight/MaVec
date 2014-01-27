//
//  MCLUFactorization.m
//  MCNumerics
//
//  Created by andrew mcknight on 12/15/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Accelerate/Accelerate.h>

#import "MCLUFactorization.h"
#import "MCMatrix.h"

@implementation MCLUFactorization

#pragma mark - Init

- (instancetype)initWithMatrix:(MCMatrix *)matrix
{
    self = [super init];
    if (self) {
        double *columnMajorValues = [matrix valuesInStorageFormat:MCMatrixValueStorageFormatColumnMajor];
        
        long m = matrix.rows;
        long n = matrix.columns;
        
        long lda = m;
        
        long *ipiv = malloc(MIN(m, n) * sizeof(long));
        
        long info = 0;
        
        dgetrf_(&m, &n, columnMajorValues, &lda, ipiv, &info);
        
        // extract L from values array
        MCMatrix *l = [MCMatrix matrixWithRows:m columns:n];
        for (int i = 0; i < matrix.columns; i++) {
            for (int j = 0; j < matrix.rows; j++) {
                if (j > i) {
                    [l setEntryAtRow:j column:i toValue:columnMajorValues[i * matrix.columns + j]];
                } else if (j == i) {
                    [l setEntryAtRow:j column:i toValue:1.0];
                } else {
                    [l setEntryAtRow:j column:i toValue:0.0];
                }
            }
        }
        
        // extract U from values array
        MCMatrix *u = [MCMatrix matrixWithRows:n columns:m];
        for (int i = 0; i < matrix.columns; i++) {
            for (int j = 0; j < matrix.rows; j++) {
                if (j <= i) {
                    [u setEntryAtRow:j column:i toValue:columnMajorValues[i * matrix.columns + j]];
                } else {
                    [u setEntryAtRow:j column:i toValue:0.0];
                }
            }
        }
        
        // exchange rows as defined in ipiv to build permutation matrix
        MCMatrix *p = [MCMatrix identityMatrixWithSize:MIN(m, n)];
        for (int i = MIN(m, n) - 1; i >= 0 ; i--) {
            [p swapRowA:i withRowB:ipiv[i] - 1];
        }
        
        _lowerTriangularMatrix = l;
        _upperTriangularMatrix = u;
        _permutationMatrix = p;
    }
    return self;
}

+ (instancetype)luFactorizationOfMatrix:(MCMatrix *)matrix
{
    return [[MCLUFactorization alloc] initWithMatrix:matrix];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MCLUFactorization *luCopy = [[self class] allocWithZone:zone];
    
    luCopy->_lowerTriangularMatrix = _lowerTriangularMatrix.copy;
    luCopy->_upperTriangularMatrix = _upperTriangularMatrix.copy;
    luCopy->_permutationMatrix = _permutationMatrix.copy;
    
    return luCopy;
}

@end

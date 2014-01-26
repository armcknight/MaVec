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
        MCMatrix *columnMajorMatrix = [matrix matrixWithValuesStoredInFormat:MCMatrixValueStorageFormatColumnMajor];
        NSUInteger size = columnMajorMatrix.rows * columnMajorMatrix.columns;
        double *values = malloc(size * sizeof(double));
        values = columnMajorMatrix.values;
        
        long m = columnMajorMatrix.rows;
        long n = columnMajorMatrix.columns;
        
        long lda = m;
        
        long *ipiv = malloc(MIN(m, n) * sizeof(long));
        
        long info = 0;
        
        dgetrf_(&m, &n, values, &lda, ipiv, &info);
        
        // extract L from values array
        MCMatrix *l = [MCMatrix matrixWithRows:m columns:n];
        for (int i = 0; i < columnMajorMatrix.columns; i++) {
            for (int j = 0; j < columnMajorMatrix.rows; j++) {
                if (j > i) {
                    [l setEntryAtRow:j column:i toValue:values[i * columnMajorMatrix.columns + j]];
                } else if (j == i) {
                    [l setEntryAtRow:j column:i toValue:1.0];
                } else {
                    [l setEntryAtRow:j column:i toValue:0.0];
                }
            }
        }
        
        // extract U from values array
        MCMatrix *u = [MCMatrix matrixWithRows:n columns:m];
        for (int i = 0; i < columnMajorMatrix.columns; i++) {
            for (int j = 0; j < columnMajorMatrix.rows; j++) {
                if (j <= i) {
                    [u setEntryAtRow:j column:i toValue:values[i * columnMajorMatrix.columns + j]];
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

@end

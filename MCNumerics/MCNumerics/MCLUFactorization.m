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
#import "MCNumberFormats.h"

@implementation MCLUFactorization

@synthesize numberOfPermutations = _numberOfPermutations;

#pragma mark - Init

- (instancetype)initWithMatrix:(MCMatrix *)matrix
{
    self = [super init];
    if (self) {
        NSData *columnMajorValues = [matrix valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn];
        
        int m = matrix.rows;
        int n = matrix.columns;
        int lda = m;
        int *ipiv = malloc(MIN(m, n) * sizeof(int));
        int info = 0;
        MCMatrix *l = [MCMatrix matrixWithRows:m columns:n precision:matrix.precision];
        MCMatrix *u = [MCMatrix matrixWithRows:n columns:m precision:matrix.precision];
        MCMatrix *p = [MCMatrix identityMatrixOfOrder:MIN(m, n) precision:matrix.precision];
        
        if (matrix.precision == MCValuePrecisionDouble) {
            dgetrf_(&m, &n, (double *)columnMajorValues.bytes, &lda, ipiv, &info);
            
            // extract L from values array
            for (int i = 0; i < matrix.columns; i++) {
                for (int j = 0; j < matrix.rows; j++) {
                    if (j > i) {
                        [l setEntryAtRow:j column:i toValue:@(((double *)columnMajorValues.bytes)[i * matrix.columns + j])];
                    } else if (j == i) {
                        [l setEntryAtRow:j column:i toValue:@1.0];
                    } else {
                        [l setEntryAtRow:j column:i toValue:@0.0];
                    }
                }
            }
            
            // extract U from values array
            for (int i = 0; i < matrix.columns; i++) {
                for (int j = 0; j < matrix.rows; j++) {
                    if (j <= i) {
                        [u setEntryAtRow:j column:i toValue:@(((double *)columnMajorValues.bytes)[i * matrix.columns + j])];
                    } else {
                        [u setEntryAtRow:j column:i toValue:@0.0];
                    }
                }
            }
            
            // exchange rows as defined in ipiv to build permutation matrix
            _numberOfPermutations = 0;
            for (int i = MIN(m, n) - 1; i >= 0 ; i--) {
                int a = i;
                int b = ipiv[i] - 1;
                if (a != b) {
                    [p swapRowA:i withRowB:ipiv[i] - 1];
                    _numberOfPermutations += 1;
                }
            }
            
            free(ipiv);
        } else {
            sgetrf_(&m, &n, (float *)columnMajorValues.bytes, &lda, ipiv, &info);
            
            // extract L from values array
            for (int i = 0; i < matrix.columns; i++) {
                for (int j = 0; j < matrix.rows; j++) {
                    if (j > i) {
                        [l setEntryAtRow:j column:i toValue:@(((float *)columnMajorValues.bytes)[i * matrix.columns + j])];
                    } else if (j == i) {
                        [l setEntryAtRow:j column:i toValue:@1.0f];
                    } else {
                        [l setEntryAtRow:j column:i toValue:@0.0f];
                    }
                }
            }
            
            // extract U from values array
            for (int i = 0; i < matrix.columns; i++) {
                for (int j = 0; j < matrix.rows; j++) {
                    if (j <= i) {
                        [u setEntryAtRow:j column:i toValue:@(((float *)columnMajorValues.bytes)[i * matrix.columns + j])];
                    } else {
                        [u setEntryAtRow:j column:i toValue:@0.0f];
                    }
                }
            }
            
            // exchange rows as defined in ipiv to build permutation matrix
            _numberOfPermutations = 0;
            for (int i = MIN(m, n) - 1; i >= 0 ; i--) {
                int a = i;
                int b = ipiv[i] - 1;
                if (a != b) {
                    [p swapRowA:i withRowB:ipiv[i] - 1];
                    _numberOfPermutations += 1;
                }
            }
            
            free(ipiv);
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

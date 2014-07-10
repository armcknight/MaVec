//
//  MAVLUFactorization.m
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

#import <Accelerate/Accelerate.h>

#import "MAVLUFactorization.h"
#import "MAVMatrix.h"
#import "MAVMutableMatrix.h"
#import "MCKNumberFormats.h"

@implementation MAVLUFactorization

@synthesize numberOfPermutations = _numberOfPermutations;

#pragma mark - Init

- (instancetype)initWithMatrix:(MAVMatrix *)matrix
{
    self = [super init];
    if (self) {
        NSData *columnMajorValues = [matrix valuesWithLeadingDimension:MAVMatrixLeadingDimensionColumn];
        
        int m = matrix.rows;
        int n = matrix.columns;
        int lda = m;
        int *ipiv = malloc(MIN(m, n) * sizeof(int));
        int info = 0;
        MAVMutableMatrix *l = [MAVMutableMatrix matrixWithRows:m columns:n precision:matrix.precision];
        MAVMutableMatrix *u = [MAVMutableMatrix matrixWithRows:n columns:m precision:matrix.precision];
        MAVMutableMatrix *p = [MAVMutableMatrix identityMatrixOfOrder:MIN(m, n) precision:matrix.precision];
        
        if (matrix.precision == MCKValuePrecisionDouble) {
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

+ (instancetype)luFactorizationOfMatrix:(MAVMatrix *)matrix
{
    return [[MAVLUFactorization alloc] initWithMatrix:matrix];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\nL:%@\nU:%@\nP:%@", self.lowerTriangularMatrix.description, self.upperTriangularMatrix.description, self.permutationMatrix.description];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MAVLUFactorization *luCopy = [[self class] allocWithZone:zone];
    
    luCopy->_lowerTriangularMatrix = _lowerTriangularMatrix.copy;
    luCopy->_upperTriangularMatrix = _upperTriangularMatrix.copy;
    luCopy->_permutationMatrix = _permutationMatrix.copy;
    
    return luCopy;
}

@end

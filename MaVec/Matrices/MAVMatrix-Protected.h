//
//  MAVMatrix-Protected.h
//  MaVec
//
//  Created by Andrew McKnight on 6/22/14.
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

#import "MAVMatrix.h"

typedef enum : UInt8 {
    /**
     The maximum absolute column sum of the matrix.
     */
    MAVMatrixNormL1,
    
    /**
     The maximum absolute row sum of the matrix.
     */
    MAVMatrixNormInfinity,
    
    /**
     The maximum value of all entries in the matrix.
     */
    MAVMatrixNormMax,
    
    /**
     Square root of the sum of the squared values in the matrix.
     */
    MAVMatrixNormFroebenius
}
/**
 Constants describing types of matrix norms.
 */
MAVMatrixNorm;

@interface MAVMatrix ()

// public readonly properties redeclared as readwrite
@property (strong, readwrite, nonatomic) NSData *values;
@property (assign, readwrite, nonatomic) __CLPK_integer rows;
@property (assign, readwrite, nonatomic) __CLPK_integer columns;
@property (strong, readwrite, nonatomic) MAVMatrix *transpose;
@property (strong, readwrite, nonatomic) MAVQRFactorization *qrFactorization;
@property (strong, readwrite, nonatomic) MAVLUFactorization *luFactorization;
@property (strong, readwrite, nonatomic) MAVSingularValueDecomposition *singularValueDecomposition;
@property (strong, readwrite, nonatomic) MAVEigendecomposition *eigendecomposition;
@property (strong, readwrite, nonatomic) MAVMatrix *inverse;
@property (strong, readwrite, nonatomic) NSNumber *determinant;
@property (strong, readwrite, nonatomic) NSNumber *conditionNumber;
@property (assign, readwrite, nonatomic) MAVMatrixDefiniteness definiteness;
@property (strong, readwrite, nonatomic, getter=isSymmetric) MCKTribool *symmetric;
@property (strong, readwrite, nonatomic) MCKTribool *isIdentity;
@property (strong, readwrite, nonatomic) MCKTribool *isZero;
@property (strong, readwrite, nonatomic) MAVVector *diagonalValues;
@property (strong, readwrite, nonatomic) NSNumber *trace;
@property (strong, readwrite, nonatomic) MAVMatrix *adjugate;
@property (strong, readwrite, nonatomic) MAVMatrix *minorMatrix;
@property (strong, readwrite, nonatomic) MAVMatrix *cofactorMatrix;
@property (strong, readwrite, nonatomic) NSNumber *normL1;
@property (strong, readwrite, nonatomic) NSNumber *normInfinity;
@property (strong, readwrite, nonatomic) NSNumber *normFroebenius;
@property (strong, readwrite, nonatomic) NSNumber *normMax;
@property (assign, readwrite, nonatomic) MAVMatrixTriangularComponent triangularComponent;
@property (assign, readwrite, nonatomic) MCKPrecision precision;

// private properties for band matrices
@property (assign, nonatomic) __CLPK_integer bandwidth;
@property (assign, nonatomic) __CLPK_integer numberOfBandValues;
@property (assign, nonatomic) __CLPK_integer upperCodiagonals;

/**
 @brief Generates specified number of floating-point values.
 @param size Amount of random values to generate.
 @return C array point containing specified number of random values.
 */
+ (NSData *)randomArrayOfSize:(size_t)size
                    precision:(MCKPrecision)precision;

/**
 @brief Sets all calculated properties to default states.
 */
- (void)resetToDefaultState;

/**
 @description Documentation on usage and other details can be found at http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.essl.v5r2.essl100.doc%2Fam5gr_llange.htm. More information about different matrix norms can be found at http://en.wikipedia.org/wiki/Matrix_norm.
 @brief Compute the desired norm of this matrix.
 @param normType The type of norm to compute.
 @return The calculated norm of desired type of this matrix as a floating-point value.
 */
- (NSNumber *)normOfType:(MAVMatrixNorm)normType;

+ (NSData *)dataFromVectors:(NSArray *)vectors;

@end

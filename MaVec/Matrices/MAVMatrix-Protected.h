//
//  MAVMatrix-Protected.h
//  MaVec
//
//  Created by Andrew McKnight on 6/22/14.
//  Copyright (c) 2014 AMProductions. All rights reserved.
//

#import "MAVMatrix.h"

#define randomDouble drand48()
#define randomFloat rand() / RAND_MAX

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
@property (assign, readwrite, nonatomic) int rows;
@property (assign, readwrite, nonatomic) int columns;
@property (strong, readwrite, nonatomic) MAVMatrix *transpose;
@property (strong, readwrite, nonatomic) MAVQRFactorization *qrFactorization;
@property (strong, readwrite, nonatomic) MAVLUFactorization *luFactorization;
@property (strong, readwrite, nonatomic) MAVSingularValueDecomposition *singularValueDecomposition;
@property (strong, readwrite, nonatomic) MAVEigendecomposition *eigendecomposition;
@property (strong, readwrite, nonatomic) MAVMatrix *inverse;
@property (strong, readwrite, nonatomic) NSNumber *determinant;
@property (strong, readwrite, nonatomic) NSNumber *conditionNumber;
@property (assign, readwrite, nonatomic) MAVMatrixDefiniteness definiteness;
@property (strong, readwrite, nonatomic) MCKTribool *isSymmetric;
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
@property (assign, readwrite, nonatomic) MCKValuePrecision precision;

// private properties for band matrices
@property (assign, nonatomic) int bandwidth;
@property (assign, nonatomic) int numberOfBandValues;
@property (assign, nonatomic) int upperCodiagonals;

/**
 @brief Generates specified number of floating-point values.
 @param size Amount of random values to generate.
 @return C array point containing specified number of random values.
 */
+ (NSData *)randomArrayOfSize:(int)size
                    precision:(MCKValuePrecision)precision;

/**
 @brief Sets all properties to default states.
 @return A new instance of MAVMatrix in a default state with no values or row/column counts.
 */
- (instancetype)init;

/**
 @description Documentation on usage and other details can be found at http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.essl.v5r2.essl100.doc%2Fam5gr_llange.htm. More information about different matrix norms can be found at http://en.wikipedia.org/wiki/Matrix_norm.
 @brief Compute the desired norm of this matrix.
 @param normType The type of norm to compute.
 @return The calculated norm of desired type of this matrix as a floating-point value.
 */
- (NSNumber *)normOfType:(MAVMatrixNorm)normType;

+ (NSData *)dataFromVectors:(NSArray *)vectors;

@end

//
//  MAVMatrix_Private.h
//  MaVec
//
//  Created by Andrew McKnight on 6/22/14.
//  Copyright (c) 2014 AMProductions. All rights reserved.
//

#import "MAVMatrix.h"

@interface MAVMatrix ()

// public readonly properties redeclared as readwrite
@property (strong, readwrite, nonatomic) NSData *values;
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

@end

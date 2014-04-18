//
//  Demos.m
//  MCNumerics
//
//  Created by andrew mcknight on 4/2/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"
#import "MCVector.h"

#import "MCQRFactorization.h"
#import "MCEigenDecomposition.h"

@interface Demos : XCTestCase

@end

@implementation Demos

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDemos
{
    /*
     * Vectors
     */
    
    MCVector *vectorA, *vectorB, *vectorC;
    
    double vectorAValues[3] = { 1.0, 2.0, 3.0 };
    vectorA = [MCVector vectorWithValues:[NSData dataWithBytes:vectorAValues length:3*sizeof(double)] length:3]; // column vector from C array
    
    vectorB = [MCVector vectorWithValues:[NSData dataWithBytes:vectorAValues length:3*sizeof(double)] length:3 vectorFormat:MCVectorFormatRowVector]; // row vector from C array
    
    vectorC = [MCVector vectorWithValuesInArray:@[@1, @2, @3]]; // column vector from NSArray
    
    /*
     * Matrices
     */
    
    MCMatrix *matrixA, *matrixB, *matrixC, *matrixD;
    
    double matrixValues[9] = {
        1.0, 2.0, 3.0,
        4.0, 5.0, 6.0,
        7.0, 8.0, 9.0
    };
    
    // matrix from C array of column-major values
    matrixA = [MCMatrix matrixWithValues:[NSData dataWithBytes:matrixValues length:9*sizeof(double)]
                                    rows:3
                                 columns:3];
    
    // matrix from C array of row-major values
    matrixB = [MCMatrix matrixWithValues:[NSData dataWithBytes:matrixValues length:9*sizeof(double)]
                                    rows:3
                                 columns:3
                        leadingDimension:MCMatrixLeadingDimensionRow];
    
    matrixC = [MCMatrix matrixWithRowVectors:@[vectorA, vectorB, vectorC]]; // matrix from NSArray of row vectors
    
    matrixD = [MCMatrix matrixWithColumnVectors:@[vectorA, vectorB, vectorC]]; // matrix from NSArray of column vectors
    
    /*
     * Special matrices
     */
    
    MCMatrix *diagonal, *identity, *randomTriangular, *randomSymmetric, *randomTridiagonal;
    
    diagonal = [MCMatrix diagonalMatrixWithValues:[NSData dataWithBytes:vectorAValues length:3*sizeof(double)] order:3];
    
    identity = [MCMatrix identityMatrixOfOrder:3 precision:MCValuePrecisionDouble];
    
    randomTriangular = [MCMatrix randomTriangularMatrixOfOrder:3 triangularComponent:MCMatrixTriangularComponentUpper precision:MCValuePrecisionDouble];
    
    randomSymmetric = [MCMatrix randomSymmetricMatrixOfOrder:3 precision:MCValuePrecisionDouble];
    
    randomTridiagonal = [MCMatrix randomBandMatrixOfOrder:3 upperCodiagonals:1 lowerCodiagonals:1 precision:MCValuePrecisionDouble];
    
    NSLog(@"so far so good!");
    
    MCMatrix *product = [MCMatrix productOfMatrixA:matrixA andMatrixB:matrixB];
    
    MCQRFactorization *qrfactorization = [MCQRFactorization qrFactorizationOfMatrix:matrixA];
    
    MCEigendecomposition *eigenDecomposition = [MCEigendecomposition eigendecompositionOfMatrix:matrixA];
    
    NSLog(@"whew!");
}

@end

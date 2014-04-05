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

#import "DynamicArrayUtility.h"

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
    vectorA = [MCVector vectorWithValues:vectorAValues length:3]; // column vector from C array
    
    vectorB = [MCVector vectorWithValues:vectorAValues length:3 vectorFormat:MCVectorFormatRowVector]; // row vector from C array
    
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
    matrixA = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:matrixValues size:9]
                                    rows:3
                                 columns:3];
    
    // matrix from C array of row-major values
    matrixB = [MCMatrix matrixWithValues:[DynamicArrayUtility dynamicArrayForStaticArray:matrixValues size:9]
                                    rows:3
                                 columns:3
                        leadingDimension:MCMatrixLeadingDimensionRow];
    
    matrixC = [MCMatrix matrixWithRowVectors:@[vectorA, vectorB, vectorC]]; // matrix from NSArray of row vectors
    
    matrixD = [MCMatrix matrixWithColumnVectors:@[vectorA, vectorB, vectorC]]; // matrix from NSArray of column vectors
    
    /*
     * Special matrices
     */
    
    MCMatrix *diagonal, *identity, *randomTriangular, *randomSymmetric, *randomTridiagonal;
    
    diagonal = [MCMatrix diagonalMatrixWithValues:vectorAValues size:3];
    
    identity = [MCMatrix identityMatrixWithSize:3];
    
    randomTriangular = [MCMatrix randomTriangularMatrixOfOrder:3 triangularComponent:MCMatrixTriangularComponentUpper];
    
    randomSymmetric = [MCMatrix randomSymmetricMatrixOfOrder:3];
    
    randomTridiagonal = [MCMatrix randomBandMatrixOfOrder:3 bandwidth:3 oddDiagonalLocation:MCMatrixTriangularComponentBoth];
    
    NSLog(@"so far so good!");
    
    MCMatrix *product = [MCMatrix productOfMatrixA:matrixA andMatrixB:matrixB];
    
    MCQRFactorization *qrfactorization = [MCQRFactorization qrFactorizationOfMatrix:matrixA];
    
    MCEigendecomposition *eigenDecomposition = [MCEigendecomposition eigendecompositionOfMatrix:matrixA];
    
    NSLog(@"whew!");
}

@end

//
//  Demos.m
//  MaVec
//
//  Created by Andrew McKnight on 4/2/14.
//
//  Copyright © 2015 AMProductions
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

#import <XCTest/XCTest.h>

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

- (void)testReadmeDemos
{
    /* create some vectors and compare them */
    double vectorValues[3] = { 1.0, 2.0, 3.0 };
    MAVVector *vectorA = [MAVVector vectorWithValues:[NSData dataWithBytes:vectorValues length:3 * sizeof(double)]
                                              length:3];
    MAVVector *vectorB = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0]];
    BOOL equal = [vectorA isEqualToVector:vectorB]; // YES
    
    /* multiply the vectors together and do some more comparisons */
    MAVMutableVector *vectorC = vectorA.mutableCopy; // NSMutableCopying
    [vectorC multiplyByVector:vectorB];
    equal = [vectorA isEqualToVector:vectorC]; // NO
    
    /* vectors can be subscripted */
    equal = [vectorA[0] isEqualToNumber:vectorC[0]]; // YES
    equal = [vectorA[1] isEqualToNumber:vectorC[1]]; // NO
    
    /* create some matrices and compare them */
    MAVMatrix *matrix = [MAVMatrix randomSymmetricMatrixOfOrder:3 precision:MCKPrecisionDouble];
    MAVMatrix *transpose = matrix.transpose.copy; // NSCopying
    equal = [matrix isEqualToMatrix:transpose]; // YES
    
    /* matrices can also be subscripted */
    equal = [matrix[0][0] isEqualToNumber:transpose[0][0]]; // YES
    
    /* multiply matrix by another matrix and then by a vector */
    MAVMutableMatrix *mutableMatrix = matrix.mutableCopy; // NSMutableCopying
    [mutableMatrix multiplyByMatrix:transpose];
    [mutableMatrix multiplyByVector:vectorA];
}

- (void)testDemos
{
    /*
     * Vectors
     */
    
    MAVVector *vectorA, *vectorB, *vectorC;
    
    double vectorAValues[3] = { 1.0, 2.0, 3.0 };
    vectorA = [MAVVector vectorWithValues:[NSData dataWithBytes:vectorAValues length:3*sizeof(double)] length:3]; // column vector from C array
    
    vectorB = [MAVVector vectorWithValues:[NSData dataWithBytes:vectorAValues length:3*sizeof(double)] length:3 vectorFormat:MAVVectorFormatRowVector]; // row vector from C array
    
    vectorC = [MAVVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0]]; // column vector from NSArray
    
    /*
     * Matrices
     */
    
    MAVMatrix *matrixA, *matrixB, *matrixC, *matrixD;
    
    double matrixValues[9] = {
        1.0, 2.0, 3.0,
        4.0, 5.0, 6.0,
        7.0, 8.0, 9.0
    };
    
    // matrix from C array of column-major values
    matrixA = [MAVMatrix matrixWithValues:[NSData dataWithBytes:matrixValues length:9*sizeof(double)]
                                    rows:3
                                 columns:3];
    
    // matrix from C array of row-major values
    matrixB = [MAVMatrix matrixWithValues:[NSData dataWithBytes:matrixValues length:9*sizeof(double)]
                                    rows:3
                                 columns:3
                        leadingDimension:MAVMatrixLeadingDimensionRow];
    
    matrixC = [MAVMatrix matrixWithRowVectors:@[vectorA, vectorB, vectorC]]; // matrix from NSArray of row vectors
    
    matrixD = [MAVMatrix matrixWithColumnVectors:@[vectorA, vectorB, vectorC]]; // matrix from NSArray of column vectors
    
    /*
     * Special matrices
     */
    
    MAVMatrix *diagonal, *identity, *randomTriangular, *randomSymmetric, *randomTridiagonal;
    
    diagonal = [MAVMatrix diagonalMatrixWithValues:[NSData dataWithBytes:vectorAValues length:3*sizeof(double)] order:3];
    
    identity = [MAVMatrix identityMatrixOfOrder:3 precision:MCKPrecisionDouble];
    
    randomTriangular = [MAVMatrix randomTriangularMatrixOfOrder:3 triangularComponent:MAVMatrixTriangularComponentUpper precision:MCKPrecisionDouble];
    
    randomSymmetric = [MAVMatrix randomSymmetricMatrixOfOrder:3 precision:MCKPrecisionDouble];
    
    randomTridiagonal = [MAVMatrix randomBandMatrixOfOrder:3 upperCodiagonals:1 lowerCodiagonals:1 precision:MCKPrecisionDouble];
    
    NSLog(@"so far so good!");
    
    MAVMatrix *product = [[matrixA mutableCopy] multiplyByMatrix:matrixB];
    NSLog(@"%@", product.description);
    
    MAVQRFactorization *qrfactorization = [MAVQRFactorization qrFactorizationOfMatrix:matrixA];
    NSLog(@"%@", qrfactorization.description);
    
    MAVEigendecomposition *eigenDecomposition = [MAVEigendecomposition eigendecompositionOfMatrix:matrixA];
    NSLog(@"%@", eigenDecomposition.description);
    
    NSLog(@"whew!");
}

@end

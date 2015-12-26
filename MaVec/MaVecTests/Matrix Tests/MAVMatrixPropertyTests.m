//
//  MAVMatrixPropertyTests.m
//  MaVec
//
//  Created by andrew mcknight on 3/8/14.
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

#import <XCTest/XCTest.h>

@interface MAVMatrixPropertyTests : XCTestCase

@end

@implementation MAVMatrixPropertyTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testDeterminantCalculation
{
    double values2x2[4] = {
        1.0, 2.0,
        3.0, 4.0
    };
    MAVMatrix *matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values2x2 length:4*sizeof(double)]
                                             rows:2
                                          columns:2
                                 leadingDimension:MAVMatrixLeadingDimensionRow];
    
    XCTAssertEqual(matrix.determinant.doubleValue, -2.0, @"Determinant not correct");
    
    double values3x3[9] = {
        6.0, 1.0, 1.0,
        4.0, -2.0, 5.0,
        2.0, 8.0, 7.0
    };
    matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values3x3 length:9*sizeof(double)]
                                   rows:3
                                columns:3
                       leadingDimension:MAVMatrixLeadingDimensionRow];
    
    XCTAssertEqual(matrix.determinant.doubleValue, -306.0, @"Determinant not correct");
    
    double values4x4[16] = {
        3.0, 2.0, 0.0, 1.0,
        4.0, 0.0, 1.0, 2.0,
        3.0, 0.0, 2.0, 1.0,
        9.0, 2.0, 3.0, 1.0
    };
    matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values4x4 length:16*sizeof(double)]
                                   rows:4
                                columns:4
                       leadingDimension:MAVMatrixLeadingDimensionRow];
    
    XCTAssertEqual(matrix.determinant.doubleValue, 24.0, @"Determinant not correct");
}

- (void)testMatrixDefiniteness
{
    // ----- positive definite -----
    double positiveDefiniteValues[9] = {
        2.0, -1.0, 0.0,
        -1.0, 2.0, -1.0,
        0.0, -1.0, 2.0
    };
    MAVMatrix *matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:positiveDefiniteValues length:9*sizeof(double)] rows:3 columns:3 leadingDimension:MAVMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MAVMatrixDefinitenessPositiveDefinite, @"Positive definite matrix was not recognized.");
    
    // ----- positive semidefinite -----
    double positiveSemidefiniteValues[4] = {
        1, 1,
        1, 1
    };
    matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:positiveSemidefiniteValues length:4*sizeof(double)] rows:2 columns:2 leadingDimension:MAVMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MAVMatrixDefinitenessPositiveSemidefinite, @"Positive semidefinite matrix was not recognized.");
    
    // ----- indefinite -----
    double indefiniteValues[9] = {
        1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
        1.0, 1.0, 0.5
    };
    matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:indefiniteValues length:9*sizeof(double)] rows:3 columns:3 leadingDimension:MAVMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MAVMatrixDefinitenessIndefinite, @"Indefinite matrix was not recognized.");
    
    // ----- negative semidefinite -----
    
    // test case from http://www.math.drexel.edu/~tolya/301_spd_cholesky.pdf
    double negativeSemidefiniteValues[4] = {
        0.0, 0.0,
        0.0, -1.0
    };
    matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:negativeSemidefiniteValues length:4*sizeof(double)] rows:2 columns:2 leadingDimension:MAVMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MAVMatrixDefinitenessNegativeSemidefinite, @"Negative semidefinite matrix was not recognized.");
    
    // ----- negative definite -----
    double negativeDefiniteValues[9] = {
        -1.0, 0.0, 0.0,
        0.0, -1.0, 0.0,
        0.0, 0.0, -1.0
    };
    matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:negativeDefiniteValues length:9*sizeof(double)] rows:3 columns:3 leadingDimension:MAVMatrixLeadingDimensionRow];
    XCTAssertEqual(matrix.definiteness, MAVMatrixDefinitenessNegativeDefinite, @"Negative definite matrix was not recognized.");
}

// tests can be verified using http://comnuan.com/cmnn0100c/
- (void)testConditionNumber
{
    double values[4] = {
        7.0, 3.0,
        -9.0, 2.0
    };
    MAVMatrix *matrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:4*sizeof(double)] rows:2 columns:2 leadingDimension:MAVMatrixLeadingDimensionColumn];
    
    double conditionNumber = matrix.conditionNumber.doubleValue;
    
    XCTAssertEqualWithAccuracy(conditionNumber, 3.902, 0.001, @"condition number not calculated correctly.");
}

- (void)testMatrixSymmetryQuerying
{
    size_t size = 9 * sizeof(double);
    double *aValues = malloc(size);
    aValues[0] = 1.0;
    aValues[1] = 2.0;
    aValues[2] = 3.0;
    aValues[3] = 4.0;
    aValues[4] = 5.0;
    aValues[5] = 6.0;
    aValues[6] = 7.0;
    aValues[7] = 8.0;
    aValues[8] = 9.0;
    MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:aValues length:size] rows:3 columns:3];
    
    
    XCTAssertFalse(a.isSymmetric.isYes, @"Nonsymmetric matrix reported to be symmetric.");
    
    aValues = malloc(size);
    aValues[0] = 1.0;
    aValues[1] = 2.0;
    aValues[2] = 3.0;
    
    aValues[3] = 2.0;
    aValues[4] = 1.0;
    aValues[5] = 6.0;
    
    aValues[6] = 3.0;
    aValues[7] = 6.0;
    aValues[8] = 1.0;
    a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:aValues length:size] rows:3 columns:3];
    
    XCTAssertTrue(a.isSymmetric.isYes, @"Symmetric matrix not reported to be symmetric.");
    
    size = 12 * sizeof(double);
    double *bValues = malloc(size);
    bValues[0] = 1.0;
    bValues[1] = 2.0;
    bValues[2] = 3.0;
    bValues[3] = 4.0;
    bValues[4] = 5.0;
    bValues[5] = 6.0;
    bValues[6] = 7.0;
    bValues[7] = 8.0;
    bValues[8] = 9.0;
    bValues[9] = 9.0;
    bValues[10] = 9.0;
    bValues[11] = 9.0;
    a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:bValues length:size] rows:3 columns:4];
    
    XCTAssertFalse(a.isSymmetric.isYes, @"Nonsquare matrix reported to be symmetric.");
}

- (void)testIdentityMatrix
{
    // double precision
    MAVMatrix *doublePrecisionIdentity = [MAVMatrix identityMatrixOfOrder:5 precision:MCKPrecisionDouble];
    XCTAssertTrue(doublePrecisionIdentity.isIdentity.isYes, @"Double precision identity matrix constructed using identityMatrixOfOrder: not determined to be an identity matix.");
    
    double values[16] = {   1.0, 0.0, 0.0, 0.0,
                            0.0, 1.0, 0.0, 0.0,
                            0.0, 0.0, 1.0, 0.0,
                            0.0, 0.0, 0.0, 1.0 };
    doublePrecisionIdentity = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:16*sizeof(double)] rows:4 columns:4 leadingDimension:MAVMatrixLeadingDimensionRow];
    XCTAssertTrue(doublePrecisionIdentity.isIdentity.isYes, @"Double precision identity matrix constructed using matrixWithValues: not determined to be an identity matix.");
    
    double diagonalValues[4] = { 1.0, 1.0, 1.0, 1.0 };
    doublePrecisionIdentity = [MAVMatrix diagonalMatrixWithValues:[NSData dataWithBytes:diagonalValues length:4*sizeof(double)] order:4];
    XCTAssertTrue(doublePrecisionIdentity.isIdentity.isYes, @"Double precision identity matrix constructed using diagonalMatrixWithValues: not determined to be an identity matix.");
    
    MAVMatrix *nonIdentityDoubleMatrix = [MAVMatrix randomMatrixWithRows:3 columns:4 precision:MCKPrecisionDouble];
    XCTAssert(nonIdentityDoubleMatrix.isIdentity.isNo, @"Non-square double precision matrix identified as identity.");
    
    MAVMutableMatrix *nonIdentitySquareDoubleMatrix = [MAVMutableMatrix randomMatrixWithRows:4 columns:4 precision:MCKPrecisionDouble];
    [nonIdentitySquareDoubleMatrix setEntryAtRow:2 column:2 toValue:@2.0];
    XCTAssert(nonIdentitySquareDoubleMatrix.isIdentity.isNo, @"Square double precision matrix with diagonal value not equal to 1 identified as identity.");
    
    nonIdentitySquareDoubleMatrix = [MAVMutableMatrix identityMatrixOfOrder:4 precision:MCKPrecisionDouble];
    [nonIdentitySquareDoubleMatrix setEntryAtRow:0 column:1 toValue:@2.0];
    XCTAssert(nonIdentitySquareDoubleMatrix.isIdentity.isNo, @"Square double precision matrix with diagonal value not equal to 1 identified as identity.");
    
    // single precision
    MAVMatrix *singlePrecisionIdentity = [MAVMatrix identityMatrixOfOrder:5 precision:MCKPrecisionSingle];
    XCTAssertTrue(singlePrecisionIdentity.isIdentity.isYes, @"Single precision identity matrix constructed using identityMatrixOfOrder: not determined to be an identity matix.");
    
    float floatValues[16] = {   1.0f, 0.0f, 0.0f, 0.0f,
                                0.0f, 1.0f, 0.0f, 0.0f,
                                0.0f, 0.0f, 1.0f, 0.0f,
                                0.0f, 0.0f, 0.0f, 1.0f };
    singlePrecisionIdentity = [MAVMatrix matrixWithValues:[NSData dataWithBytes:floatValues length:16*sizeof(float)] rows:4 columns:4 leadingDimension:MAVMatrixLeadingDimensionRow];
    XCTAssertTrue(singlePrecisionIdentity.isIdentity.isYes, @"Single precision identity matrix constructed using matrixWithValues: not determined to be an identity matix.");
    
    float diagonalFloatValues[4] = { 1.0f, 1.0f, 1.0f, 1.0f };
    singlePrecisionIdentity = [MAVMatrix diagonalMatrixWithValues:[NSData dataWithBytes:diagonalFloatValues length:4*sizeof(float)] order:4];
    XCTAssertTrue(singlePrecisionIdentity.isIdentity.isYes, @"Single precision identity matrix constructed using diagonalMatrixWithValues: not determined to be an identity matix.");
    
    MAVMatrix *nonIdentitySingleMatrix = [MAVMatrix randomMatrixWithRows:3 columns:4 precision:MCKPrecisionSingle];
    XCTAssert(nonIdentitySingleMatrix.isIdentity.isNo, @"Non-square single precision matrix identified as identity.");
    
    MAVMutableMatrix *nonIdentitySquareSingleMatrix = [MAVMutableMatrix randomMatrixWithRows:4 columns:4 precision:MCKPrecisionSingle];
    [nonIdentitySquareSingleMatrix setEntryAtRow:2 column:2 toValue:@2.0f];
    XCTAssert(nonIdentitySquareSingleMatrix.isIdentity.isNo, @"Square single precision matrix with diagonal value not equal to 1 identified as identity.");
    
    nonIdentitySquareSingleMatrix = [MAVMutableMatrix identityMatrixOfOrder:4 precision:MCKPrecisionSingle];
    [nonIdentitySquareSingleMatrix setEntryAtRow:0 column:1 toValue:@2.0f];
    XCTAssert(nonIdentitySquareSingleMatrix.isIdentity.isNo, @"Square single precision matrix with diagonal value not equal to 1 identified as identity.");
}

- (void)testZeroMatrix
{
    double doubleValues[16] = { 0.0, 0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0, 0.0 };
    MAVMatrix *zeroMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:doubleValues length:16*sizeof(double)] rows:4 columns:4];
    XCTAssertTrue(zeroMatrix.isZero.isYes, @"Double precision zero matrix constructed using matrixWithValues: not determined to be a zero matix.");
    
    MAVMutableMatrix *nonzeroMatrix = zeroMatrix.mutableCopy;
    [nonzeroMatrix setEntryAtRow:0 column:0 toValue:@1.0];
    XCTAssert(nonzeroMatrix.isZero.isNo, @"Non zero double precision matrix identified as zero matrix.");
    
    float singleValues[16] = {  0.0f, 0.0f, 0.0f, 0.0f,
                                0.0f, 0.0f, 0.0f, 0.0f,
                                0.0f, 0.0f, 0.0f, 0.0f,
                                0.0f, 0.0f, 0.0f, 0.0f };
    zeroMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytes:singleValues length:16*sizeof(float)] rows:4 columns:4];
    XCTAssertTrue(zeroMatrix.isZero.isYes, @"Single precision zero matrix constructed using matrixWithValues: not determined to be a zero matix.");
    
    nonzeroMatrix = zeroMatrix.mutableCopy;
    [nonzeroMatrix setEntryAtRow:0 column:0 toValue:@1.0f];
    XCTAssert(nonzeroMatrix.isZero.isNo, @"Non zero single precision matrix identified as zero matrix.");
}

@end

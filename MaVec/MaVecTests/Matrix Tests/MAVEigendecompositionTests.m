//
//  MAVEigendecompositionTests.m
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

@interface MAVEigendecompositionTests : XCTestCase

@end

@implementation MAVEigendecompositionTests

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

- (void)testSymmetricMatrixEigendecomposition
{
    // example from http://software.intel.com/sites/products/documentation/doclib/mkl_sa/11/mkl_lapack_examples/dsyevd_ex.c.htm; more located at http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.essl.v5r2.essl100.doc%2Fam5gr_eigevd.htm
    double values[25] = {
        6.39,   0.13,  -8.23,   5.71,  -3.18,
        0.13,   8.37,  -4.46,  -6.10,   7.21,
        -8.23,  -4.46,  -9.58,  -9.25,  -7.42,
        5.71,  -6.10,  -9.25,   3.72,   8.54,
        -3.18,   7.21,  -7.42,   8.54,   2.51
    };
    
    MAVMatrix *o = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:25*sizeof(double)] rows:5 columns:5 leadingDimension:MAVMatrixLeadingDimensionRow];
    MAVEigendecomposition *e = o.eigendecomposition;
    
    for (unsigned int i = 0; i < 5; i += 1) {
        MAVVector *eigenvector = [e.eigenvectors columnVectorForColumn:i];
        NSNumber *eigenvalue = [e.eigenvalues valueAtIndex:i];
        MAVMutableMatrix *mutableCopy = o.mutableCopy;
        MAVVector *left = [[mutableCopy multiplyByVector:eigenvector] columnVectorForColumn:0];
        MAVVector *right = [(MAVMutableVector *)[eigenvector mutableCopy] multiplyByScalar:eigenvalue];
        for (unsigned int j = 0; j < 5; j += 1) {
            double a = [left valueAtIndex:j].doubleValue;
            double b = [right valueAtIndex:j].doubleValue;
            double accuracy = 0.0000000001;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"Values at index %u differ by more than %f", j, accuracy);
        }
    }
}

- (void)testNonsymmetricMatrixEigendecomposition
{
    // example from http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.essl.v5r2.essl100.doc%2Fam5gr_eigevd.htm
    double values[16] = {
        -2.0,  2.0,  2.0,  2.0,
        -3.0,  3.0,  2.0,  2.0,
        -2.0,  0.0,  4.0,  2.0,
        -1.0,  0.0,  0.0,  5.0
    };
    
    MAVMatrix *source = [MAVMatrix matrixWithValues:[NSData dataWithBytes:values length:16*sizeof(double)] rows:4 columns:4 leadingDimension:MAVMatrixLeadingDimensionRow];
    MAVEigendecomposition *e = source.eigendecomposition;
    
    for (unsigned int i = 0; i < 4; i += 1) {
        MAVVector *eigenvector = [e.eigenvectors columnVectorForColumn:i];
        NSNumber *eigenvalue = [e.eigenvalues valueAtIndex:i];
        MAVMutableMatrix *mutableCopy = source.mutableCopy;
        MAVVector *left = [[mutableCopy multiplyByVector:eigenvector] columnVectorForColumn:0];
        MAVVector *right = [(MAVMutableVector *)[eigenvector mutableCopy] multiplyByScalar:eigenvalue];
        for (unsigned int j = 0; j < 4; j += 1) {
            double a = [left valueAtIndex:j].doubleValue;
            double b = [right valueAtIndex:j].doubleValue;
            double accuracy = 1.0e-6;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"Values at index %u differ by more than %f", j, accuracy);
        }
    }
}

@end

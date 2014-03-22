//
//  EigendecompositionTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/8/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"
#import "MCEigendecomposition.h"
#import "MCVector.h"

@interface EigendecompositionTests : XCTestCase

@end

@implementation EigendecompositionTests

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
    
    MCMatrix *o = [MCMatrix matrixWithValues:values rows:5 columns:5 leadingDimension:MCMatrixLeadingDimensionRow];
    MCEigendecomposition *e = o.eigendecomposition;
    
    for (int i = 0; i < 5; i += 1) {
        MCVector *eigenvector = [e.eigenvectors columnVectorForColumn:i];
        double eigenvalue = [e.eigenvalues valueAtIndex:i];
        MCVector *left = [MCMatrix productOfMatrix:o andVector:eigenvector];
        MCVector *right = [MCVector productOfVector:eigenvector scalar:eigenvalue];
        for (int j = 0; j < 5; j += 1) {
            double a = [left valueAtIndex:j];
            double b = [right valueAtIndex:j];
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
    
    MCMatrix *source = [MCMatrix matrixWithValues:values rows:4 columns:4 leadingDimension:MCMatrixLeadingDimensionRow];
    MCEigendecomposition *e = source.eigendecomposition;
    
    for (int i = 0; i < 4; i += 1) {
        MCVector *eigenvector = [e.eigenvectors columnVectorForColumn:i];
        double eigenvalue = [e.eigenvalues valueAtIndex:i];
        MCVector *left = [MCMatrix productOfMatrix:source andVector:eigenvector];
        MCVector *right = [MCVector productOfVector:eigenvector scalar:eigenvalue];
        NSLog(left.description);
        NSLog(right.description);
        for (int j = 0; j < 4; j += 1) {
            double a = [left valueAtIndex:j];
            double b = [right valueAtIndex:j];
            double accuracy = 1.0e-6;
            XCTAssertEqualWithAccuracy(a, b, accuracy, @"Values at index %u differ by more than %f", j, accuracy);
        }
    }
}

@end

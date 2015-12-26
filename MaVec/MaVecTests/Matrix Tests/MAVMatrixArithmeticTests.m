//
//  MAVMatrixArithmeticTests.m
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

@interface MAVMatrixArithmeticTests : XCTestCase

@end

@implementation MAVMatrixArithmeticTests

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

- (void)testMatrixAddition
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
    MAVMutableMatrix *a = [MAVMutableMatrix matrixWithValues:[NSData dataWithBytes:aValues length:size]
                                                        rows:3
                                                     columns:3];
    
    size = 9 * sizeof(double);
    double *bValues = malloc(size);
    bValues[0] = 9.0;
    bValues[1] = 8.0;
    bValues[2] = 7.0;
    bValues[3] = 6.0;
    bValues[4] = 5.0;
    bValues[5] = 4.0;
    bValues[6] = 3.0;
    bValues[7] = 2.0;
    bValues[8] = 1.0;
    MAVMutableMatrix *b = [MAVMutableMatrix matrixWithValues:[NSData dataWithBytes:bValues length:size]
                                                        rows:3
                                                     columns:3];
    
    [a addMatrix:b];
    
    for (unsigned int i = 0; i < 3; i++) {
        for (unsigned int j; j < 3; j++) {
            XCTAssertEqual(10.0, [a valueAtRow:i column:j].doubleValue, @"Value at %u,%u incorrectly added", i, j);
        }
    }
    
    a = [MAVMutableMatrix matrixWithRows:4
                                 columns:5
                               precision:MCKPrecisionDouble];
    
	b = [MAVMutableMatrix matrixWithRows:5
	                             columns:5
	                           precision:MCKPrecisionDouble];
    
    XCTAssertThrows([a addMatrix:b], @"Should throw an exception for mismatched row amount");
    
    a = [MAVMutableMatrix matrixWithRows:5
                                 columns:4
                               precision:MCKPrecisionDouble];
    
    b = [MAVMutableMatrix matrixWithRows:5
                                 columns:5
                               precision:MCKPrecisionDouble];
    
    XCTAssertThrows([a addMatrix:b], @"Should throw an exception for mismatched column amount");
}

- (void)testMatrixSubtraction
{
    size_t size = 9 * sizeof(double);
    double *aValues = malloc(size);
    aValues[0] = 10.0;
    aValues[1] = 10.0;
    aValues[2] = 10.0;
    aValues[3] = 10.0;
    aValues[4] = 10.0;
    aValues[5] = 10.0;
    aValues[6] = 10.0;
    aValues[7] = 10.0;
    aValues[8] = 10.0;
    MAVMutableMatrix *a = [MAVMutableMatrix matrixWithValues:[NSData dataWithBytes:aValues length:size]
                                                        rows:3
                                                     columns:3];
    
    double *bValues = malloc(size);
    bValues[0] = 9.0;
    bValues[1] = 8.0;
    bValues[2] = 7.0;
    bValues[3] = 6.0;
    bValues[4] = 5.0;
    bValues[5] = 4.0;
    bValues[6] = 3.0;
    bValues[7] = 2.0;
    bValues[8] = 1.0;
    MAVMutableMatrix *b = [MAVMutableMatrix matrixWithValues:[NSData dataWithBytes:bValues length:size]
                                                        rows:3
                                                     columns:3];
    
    double *sValues = malloc(size);
    sValues[0] = 1.0;
    sValues[1] = 2.0;
    sValues[2] = 3.0;
    sValues[3] = 4.0;
    sValues[4] = 5.0;
    sValues[5] = 6.0;
    sValues[6] = 7.0;
    sValues[7] = 8.0;
    sValues[8] = 9.0;
    MAVMatrix *solution = [MAVMatrix matrixWithValues:[NSData dataWithBytes:sValues length:size]
                                                 rows:3
                                              columns:3];
    
    MAVMatrix *difference = [a subtractMatrix:b];
    
    for (unsigned int i = 0; i < 3; i++) {
        for (unsigned int j; j < 3; j++) {
            XCTAssertEqual([solution valueAtRow:i column:j].doubleValue, [difference valueAtRow:i column:j].doubleValue, @"Value at %u,%u incorrectly subtracted", i, j);
        }
    }
    
    a = [MAVMutableMatrix matrixWithRows:4
                                 columns:5
                               precision:MCKPrecisionDouble];
    
    b = [MAVMutableMatrix matrixWithRows:5
                                 columns:5
                               precision:MCKPrecisionDouble];
    
    XCTAssertThrows([a subtractMatrix:b], @"Should throw an exception for mismatched row amount");
    
    a = [MAVMutableMatrix matrixWithRows:5
                                 columns:4
                               precision:MCKPrecisionDouble];
    
    b = [MAVMutableMatrix matrixWithRows:5
                                 columns:5
                               precision:MCKPrecisionDouble];
    
    XCTAssertThrows([a subtractMatrix:b], @"Should throw an exception for mismatched column amount");
}

@end

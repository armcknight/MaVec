//
//  MAVMatrixOperationTests.m
//  MaVec
//
//  Created by Andrew McKnight on 3/8/14.
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

@interface MAVMatrixOperationTests : XCTestCase

@end

@implementation MAVMatrixOperationTests

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

- (void)testTransposition
{
    size_t size = 9 * sizeof(double);
    double *aVals= malloc(size);
    aVals[0] = 1.0;
    aVals[1] = 2.0;
    aVals[2] = 3.0;
    aVals[3] = 4.0;
    aVals[4] = 5.0;
    aVals[5] = 6.0;
    aVals[6] = 7.0;
    aVals[7] = 8.0;
    aVals[8] = 9.0;
    MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:aVals length:size] rows:3 columns:3];
    
    double *tVals= malloc(size);
    tVals[0] = 1.0;
    tVals[1] = 4.0;
    tVals[2] = 7.0;
    tVals[3] = 2.0;
    tVals[4] = 5.0;
    tVals[5] = 8.0;
    tVals[6] = 3.0;
    tVals[7] = 6.0;
    tVals[8] = 9.0;
    MAVMatrix *t = [MAVMatrix matrixWithValues:[NSData dataWithBytes:tVals length:size] rows:3 columns:3].transpose;
    
    for (unsigned int i = 0; i < 3; i++) {
        for (unsigned int j = 0; j < 3; j++) {
            XCTAssertEqual([a valueAtRow:i column:j].doubleValue, [t valueAtRow:i column:j].doubleValue, @"Value at row %u and column %u incorrect", i, j);
        }
    }
    
    aVals= malloc(size);
    aVals[0] = 1.0;
    aVals[1] = 2.0;
    aVals[2] = 3.0;
    aVals[3] = 4.0;
    aVals[4] = 5.0;
    aVals[5] = 6.0;
    aVals[6] = 7.0;
    aVals[7] = 8.0;
    aVals[8] = 9.0;
    a = [MAVMatrix matrixWithValues:[NSData dataWithBytes:aVals length:size] rows:3 columns:3 leadingDimension:MAVMatrixLeadingDimensionRow];
    
    tVals= malloc(size);
    tVals[0] = 1.0;
    tVals[1] = 4.0;
    tVals[2] = 7.0;
    tVals[3] = 2.0;
    tVals[4] = 5.0;
    tVals[5] = 8.0;
    tVals[6] = 3.0;
    tVals[7] = 6.0;
    tVals[8] = 9.0;
    t = [MAVMatrix matrixWithValues:[NSData dataWithBytes:tVals length:size] rows:3 columns:3 leadingDimension:MAVMatrixLeadingDimensionRow].transpose;
    
    for (unsigned int i = 0; i < 3; i++) {
        for (unsigned int j = 0; j < 3; j++) {
            XCTAssertEqual([a valueAtRow:i column:j].doubleValue, [t valueAtRow:i column:j].doubleValue, @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

@end

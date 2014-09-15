//
//  MAVRotationMatrixTests.m
//  MaVec
//
//  Created by Andrew McKnight on 5/9/14.
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

#import "MAVMatrix.h"
#import "MAVMutableMatrix.h"
#import "MAVVector.h"

@interface MAVRotationMatrixTests : XCTestCase

@end

@implementation MAVRotationMatrixTests

- (void)testTwoDimensionalRotations
{
    // 90 degrees clockwise
    MAVMutableMatrix *matrix = [MAVMutableMatrix matrixForTwoDimensionalRotationWithAngle:@(90.0)
                                                                                direction:MAVAngleDirectionClockwise];
    
    MAVVector *point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0]
                                           vectorFormat:MAVVectorFormatColumnVector];
    
    MAVVector *rotatedPoint = [[matrix multiplyByVector:point] columnVectorForColumn:0];
    
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@3.0, @(-2.0)] vectorFormat:MAVVectorFormatColumnVector];
    
    // 90 degrees counterclockwise
    matrix = [MAVMutableMatrix matrixForTwoDimensionalRotationWithAngle:@(90.0)
                                                              direction:MAVAngleDirectionCounterClockwise];
    
    point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0]
                                  vectorFormat:MAVVectorFormatColumnVector];
    
    rotatedPoint = [[matrix multiplyByVector:point] columnVectorForColumn:0];
    
    solution = [MAVVector vectorWithValuesInArray:@[@(-3.0), @2.0] vectorFormat:MAVVectorFormatColumnVector];
}

- (void)testThreeDimensionalRotationsAboutXAxis
{
    // 90 degrees clockwise
    MAVVector *point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                           vectorFormat:MAVVectorFormatColumnVector];
    
	MAVMutableMatrix *matrix = [MAVMutableMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
	                                                                              aboutAxis:MAVCoordinateAxisX
	                                                                              direction:MAVAngleDirectionClockwise];
    
    MAVVector *rotatedPoint = [[matrix multiplyByVector:point] columnVectorForColumn:0];
    
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@2.0, @(-5.0), @3.0]
                                              vectorFormat:MAVVectorFormatColumnVector];
    
    // 90 degrees counterclockwise
    point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                 vectorFormat:MAVVectorFormatColumnVector];
    
	matrix = [MAVMutableMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
	                                                            aboutAxis:MAVCoordinateAxisX
	                                                            direction:MAVAngleDirectionCounterClockwise];
    
    rotatedPoint = [[matrix multiplyByVector:point] columnVectorForColumn:0];
    
    solution = [MAVVector vectorWithValuesInArray:@[@2.0, @5.0, @(-3.0)]
                                    vectorFormat:MAVVectorFormatColumnVector];
}

- (void)testThreeDimensionalRotationsAboutYAxis
{
    // 90 degrees clockwise
    MAVVector *point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                           vectorFormat:MAVVectorFormatColumnVector];
    
	MAVMutableMatrix *matrix = [MAVMutableMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
	                                                                              aboutAxis:MAVCoordinateAxisY
	                                                                              direction:MAVAngleDirectionClockwise];
    
    MAVVector *rotatedPoint = [[matrix multiplyByVector:point] columnVectorForColumn:0];
    
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@5.0, @3.0, @(-2.0)]
                                              vectorFormat:MAVVectorFormatColumnVector];
    
    // 90 degrees counterclockwise
    point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                 vectorFormat:MAVVectorFormatColumnVector];
    
	matrix = [MAVMutableMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
	                                                            aboutAxis:MAVCoordinateAxisY
	                                                            direction:MAVAngleDirectionCounterClockwise];
    
    rotatedPoint = [[matrix multiplyByVector:point] columnVectorForColumn:0];
    
    solution = [MAVVector vectorWithValuesInArray:@[@(-5.0), @3.0, @2.0]
                                    vectorFormat:MAVVectorFormatColumnVector];
}

- (void)testThreeDimensionalRotationsAboutZAxis
{
    // 90 degrees clockwise
    MAVVector *point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                           vectorFormat:MAVVectorFormatColumnVector];
    
	MAVMutableMatrix *matrix = [MAVMutableMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
	                                                                              aboutAxis:MAVCoordinateAxisZ
	                                                                              direction:MAVAngleDirectionClockwise];
    
    MAVVector *rotatedPoint = [[matrix multiplyByVector:point] columnVectorForColumn:0];
    
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@(-3.0), @2.0, @5.0]
                                              vectorFormat:MAVVectorFormatColumnVector];
    
    // 90 degrees counterclockwise
    point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                 vectorFormat:MAVVectorFormatColumnVector];
    
	matrix = [MAVMutableMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
	                                                            aboutAxis:MAVCoordinateAxisZ
	                                                            direction:MAVAngleDirectionCounterClockwise];
    
    rotatedPoint = [[matrix multiplyByVector:point] columnVectorForColumn:0];
    
    solution = [MAVVector vectorWithValuesInArray:@[@3.0, @(-2.0), @5.0]
                                    vectorFormat:MAVVectorFormatColumnVector];
}

@end

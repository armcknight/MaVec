//
//  MAVRotationMatrixTests.m
//  MaVec
//
//  Created by Andrew McKnight on 5/9/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
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

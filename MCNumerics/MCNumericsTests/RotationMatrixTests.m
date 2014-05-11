//
//  RotationMatrixTests.m
//  MAVNumerics
//
//  Created by Andrew McKnight on 5/9/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MAVMatrix.h"
#import "MAVVector.h"

@interface RotationMatrixTests : XCTestCase

@end

@implementation RotationMatrixTests

- (void)testTwoDimensionalRotations
{
    // 90 degrees clockwise
    MAVMatrix *matrix = [MAVMatrix matrixForTwoDimensionalRotationWithAngle:@(90.0)
                                                                direction:MAVAngleDirectionClockwise];
    
    MAVVector *point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0]
                                           vectorFormat:MAVVectorFormatColumnVector];
    
    MAVVector *rotatedPoint = [MAVMatrix productOfMatrix:matrix andVector:point];
    
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@3.0, @(-2.0)] vectorFormat:MAVVectorFormatColumnVector];
    
    // 90 degrees counterclockwise
    matrix = [MAVMatrix matrixForTwoDimensionalRotationWithAngle:@(90.0)
                                                      direction:MAVAngleDirectionCounterClockwise];
    
    point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0]
                                 vectorFormat:MAVVectorFormatColumnVector];
    
    rotatedPoint = [MAVMatrix productOfMatrix:matrix andVector:point];
    
    solution = [MAVVector vectorWithValuesInArray:@[@(-3.0), @2.0] vectorFormat:MAVVectorFormatColumnVector];
}

- (void)testThreeDimensionalRotationsAboutXAxis
{
    // 90 degrees clockwise
    MAVVector *point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                           vectorFormat:MAVVectorFormatColumnVector];
    
    MAVMatrix *matrix = [MAVMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
                                                                  aboutAxis:MAVCoordinateAxisX
                                                                  direction:MAVAngleDirectionClockwise];
    
    MAVVector *rotatedPoint = [MAVMatrix productOfMatrix:matrix andVector:point];
    
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@2.0, @(-5.0), @3.0]
                                              vectorFormat:MAVVectorFormatColumnVector];
    
    // 90 degrees counterclockwise
    point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                 vectorFormat:MAVVectorFormatColumnVector];
    
    matrix = [MAVMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
                                                        aboutAxis:MAVCoordinateAxisX
                                                        direction:MAVAngleDirectionCounterClockwise];
    
    rotatedPoint = [MAVMatrix productOfMatrix:matrix andVector:point];
    
    solution = [MAVVector vectorWithValuesInArray:@[@2.0, @5.0, @(-3.0)]
                                    vectorFormat:MAVVectorFormatColumnVector];
}

- (void)testThreeDimensionalRotationsAboutYAxis
{
    // 90 degrees clockwise
    MAVVector *point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                           vectorFormat:MAVVectorFormatColumnVector];
    
    MAVMatrix *matrix = [MAVMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
                                                                  aboutAxis:MAVCoordinateAxisY
                                                                  direction:MAVAngleDirectionClockwise];
    
    MAVVector *rotatedPoint = [MAVMatrix productOfMatrix:matrix andVector:point];
    
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@5.0, @3.0, @(-2.0)]
                                              vectorFormat:MAVVectorFormatColumnVector];
    
    // 90 degrees counterclockwise
    point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                 vectorFormat:MAVVectorFormatColumnVector];
    
    matrix = [MAVMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
                                                        aboutAxis:MAVCoordinateAxisY
                                                        direction:MAVAngleDirectionCounterClockwise];
    
    rotatedPoint = [MAVMatrix productOfMatrix:matrix andVector:point];
    
    solution = [MAVVector vectorWithValuesInArray:@[@(-5.0), @3.0, @2.0]
                                    vectorFormat:MAVVectorFormatColumnVector];
}

- (void)testThreeDimensionalRotationsAboutZAxis
{
    // 90 degrees clockwise
    MAVVector *point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                           vectorFormat:MAVVectorFormatColumnVector];
    
    MAVMatrix *matrix = [MAVMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
                                                                  aboutAxis:MAVCoordinateAxisZ
                                                                  direction:MAVAngleDirectionClockwise];
    
    MAVVector *rotatedPoint = [MAVMatrix productOfMatrix:matrix andVector:point];
    
    MAVVector *solution = [MAVVector vectorWithValuesInArray:@[@(-3.0), @2.0, @5.0]
                                              vectorFormat:MAVVectorFormatColumnVector];
    
    // 90 degrees counterclockwise
    point = [MAVVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                 vectorFormat:MAVVectorFormatColumnVector];
    
    matrix = [MAVMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
                                                        aboutAxis:MAVCoordinateAxisZ
                                                        direction:MAVAngleDirectionCounterClockwise];
    
    rotatedPoint = [MAVMatrix productOfMatrix:matrix andVector:point];
    
    solution = [MAVVector vectorWithValuesInArray:@[@3.0, @(-2.0), @5.0]
                                    vectorFormat:MAVVectorFormatColumnVector];
}

@end

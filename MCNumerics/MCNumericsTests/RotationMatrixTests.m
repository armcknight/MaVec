//
//  RotationMatrixTests.m
//  MCNumerics
//
//  Created by Andrew McKnight on 5/9/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCMatrix.h"
#import "MCVector.h"

@interface RotationMatrixTests : XCTestCase

@end

@implementation RotationMatrixTests

- (void)testTwoDimensionalRotations
{
    // 90 degrees clockwise
    MCMatrix *matrix = [MCMatrix matrixForTwoDimensionalRotationWithAngle:@(90.0)
                                                                direction:MCAngleDirectionClockwise];
    
    MCVector *point = [MCVector vectorWithValuesInArray:@[@2.0, @3.0]
                                           vectorFormat:MCVectorFormatColumnVector];
    
    MCVector *rotatedPoint = [MCMatrix productOfMatrix:matrix andVector:point];
    
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@3.0, @(-2.0)] vectorFormat:MCVectorFormatColumnVector];
    
    // 90 degrees counterclockwise
    matrix = [MCMatrix matrixForTwoDimensionalRotationWithAngle:@(90.0)
                                                      direction:MCAngleDirectionCounterClockwise];
    
    point = [MCVector vectorWithValuesInArray:@[@2.0, @3.0]
                                 vectorFormat:MCVectorFormatColumnVector];
    
    rotatedPoint = [MCMatrix productOfMatrix:matrix andVector:point];
    
    solution = [MCVector vectorWithValuesInArray:@[@(-3.0), @2.0] vectorFormat:MCVectorFormatColumnVector];
}

- (void)testThreeDimensionalRotationsAboutXAxis
{
    // 90 degrees clockwise
    MCVector *point = [MCVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                           vectorFormat:MCVectorFormatColumnVector];
    
    MCMatrix *matrix = [MCMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
                                                                  aboutAxis:MCCoordinateAxisX
                                                                  direction:MCAngleDirectionClockwise];
    
    MCVector *rotatedPoint = [MCMatrix productOfMatrix:matrix andVector:point];
    
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@2.0, @(-5.0), @3.0]
                                              vectorFormat:MCVectorFormatColumnVector];
    
    // 90 degrees counterclockwise
    point = [MCVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                 vectorFormat:MCVectorFormatColumnVector];
    
    matrix = [MCMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
                                                        aboutAxis:MCCoordinateAxisX
                                                        direction:MCAngleDirectionCounterClockwise];
    
    rotatedPoint = [MCMatrix productOfMatrix:matrix andVector:point];
    
    solution = [MCVector vectorWithValuesInArray:@[@2.0, @5.0, @(-3.0)]
                                    vectorFormat:MCVectorFormatColumnVector];
}

- (void)testThreeDimensionalRotationsAboutYAxis
{
    // 90 degrees clockwise
    MCVector *point = [MCVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                           vectorFormat:MCVectorFormatColumnVector];
    
    MCMatrix *matrix = [MCMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
                                                                  aboutAxis:MCCoordinateAxisY
                                                                  direction:MCAngleDirectionClockwise];
    
    MCVector *rotatedPoint = [MCMatrix productOfMatrix:matrix andVector:point];
    
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@5.0, @3.0, @(-2.0)]
                                              vectorFormat:MCVectorFormatColumnVector];
    
    // 90 degrees counterclockwise
    point = [MCVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                 vectorFormat:MCVectorFormatColumnVector];
    
    matrix = [MCMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
                                                        aboutAxis:MCCoordinateAxisY
                                                        direction:MCAngleDirectionCounterClockwise];
    
    rotatedPoint = [MCMatrix productOfMatrix:matrix andVector:point];
    
    solution = [MCVector vectorWithValuesInArray:@[@(-5.0), @3.0, @2.0]
                                    vectorFormat:MCVectorFormatColumnVector];
}

- (void)testThreeDimensionalRotationsAboutZAxis
{
    // 90 degrees clockwise
    MCVector *point = [MCVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                           vectorFormat:MCVectorFormatColumnVector];
    
    MCMatrix *matrix = [MCMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
                                                                  aboutAxis:MCCoordinateAxisZ
                                                                  direction:MCAngleDirectionClockwise];
    
    MCVector *rotatedPoint = [MCMatrix productOfMatrix:matrix andVector:point];
    
    MCVector *solution = [MCVector vectorWithValuesInArray:@[@(-3.0), @2.0, @5.0]
                                              vectorFormat:MCVectorFormatColumnVector];
    
    // 90 degrees counterclockwise
    point = [MCVector vectorWithValuesInArray:@[@2.0, @3.0, @5.0]
                                 vectorFormat:MCVectorFormatColumnVector];
    
    matrix = [MCMatrix matrixForThreeDimensionalRotationWithAngle:@90.0
                                                        aboutAxis:MCCoordinateAxisZ
                                                        direction:MCAngleDirectionCounterClockwise];
    
    rotatedPoint = [MCMatrix productOfMatrix:matrix andVector:point];
    
    solution = [MCVector vectorWithValuesInArray:@[@3.0, @(-2.0), @5.0]
                                    vectorFormat:MCVectorFormatColumnVector];
}

@end

//
//  Benchmarks.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/8/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

@import Accelerate;

#import <XCTest/XCTest.h>

#import "MCMatrix.h"
#import "MCVector.h"

@interface Benchmarks : XCTestCase

@end

@implementation Benchmarks

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

- (void)test3x3MatrixMultiplicationRuntime
{
    double accelerateTime = 0;
    double mcTime = 0;
    
    for(int i = 0; i < 20000; i++) {
        
        // test plain accelerate function with c array of doubles
        double *aValues = malloc(9 * sizeof(double));
        aValues[0] = drand48();
        aValues[1] = drand48();
        aValues[2] = drand48();
        aValues[3] = drand48();
        aValues[4] = drand48();
        aValues[5] = drand48();
        aValues[6] = drand48();
        aValues[7] = drand48();
        aValues[8] = drand48();
        double *bValues = malloc(9 * sizeof(double));
        bValues[0] = drand48();
        bValues[1] = drand48();
        bValues[2] = drand48();
        bValues[3] = drand48();
        bValues[4] = drand48();
        bValues[5] = drand48();
        bValues[6] = drand48();
        bValues[7] = drand48();
        bValues[8] = drand48();
        double *cValues = malloc(9 * sizeof(double));
        
        NSDate *startTime = [NSDate date];
        vDSP_mmulD(aValues, 1, bValues, 1, cValues, 1, 3, 3, 3);
        NSDate *endTime = [NSDate date];
        accelerateTime += [endTime timeIntervalSinceDate:startTime];
        
        // test with MCMatrix objects constructed from MCVector objects
        MCMatrix *a = [MCMatrix matrixWithRowVectors:@[
                                                       [MCVector vectorWithValuesInArray:@[
                                                                                           @(drand48()),
                                                                                           @(drand48()),
                                                                                           @(drand48())
                                                                                           ]],
                                                       [MCVector vectorWithValuesInArray:@[
                                                                                           @(drand48()),
                                                                                           @(drand48()),
                                                                                           @(drand48())
                                                                                           ]],
                                                       [MCVector vectorWithValuesInArray:@[
                                                                                           @(drand48()),
                                                                                           @(drand48()),
                                                                                           @(drand48())
                                                                                           ]]
                                                       ]];
        MCMatrix *b = [MCMatrix matrixWithRowVectors:@[
                                                       [MCVector vectorWithValuesInArray:@[
                                                                                           @(drand48()),
                                                                                           @(drand48()),
                                                                                           @(drand48())
                                                                                           ]],
                                                       [MCVector vectorWithValuesInArray:@[
                                                                                           @(drand48()),
                                                                                           @(drand48()),
                                                                                           @(drand48())
                                                                                           ]],
                                                       [MCVector vectorWithValuesInArray:@[
                                                                                           @(drand48()),
                                                                                           @(drand48()),
                                                                                           @(drand48())
                                                                                           ]]
                                                       ]];
        
        startTime = [NSDate date];
        MCMatrix *c = [MCMatrix productOfMatrixA:a andMatrixB:b];
        
        endTime = [NSDate date];
        mcTime += [endTime timeIntervalSinceDate:startTime];
    }
    
    NSLog(@"plain accelerate runtime: %.2f\nMCMatrix runtime: %.2f", accelerateTime, mcTime);
}

@end

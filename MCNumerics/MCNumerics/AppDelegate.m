//
//  AppDelegate.m
//  McNumerics
//
//  Created by andrew mcknight on 12/1/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import "AppDelegate.h"
#import "Matrix.h"

@implementation AppDelegate

- (void)testMultiplySquareMatricesVerbose:(BOOL)verbose
{
    double *aVals = malloc(4 * sizeof(double));
    double *bVals = malloc(4 * sizeof(double));
    aVals[0] = 1.0;
    aVals[1] = 3.0;
    aVals[2] = 2.0;
    aVals[3] = 5.0;
    
    bVals[0] = 6.0;
    bVals[1] = 8.0;
    bVals[2] = 7.0;
    bVals[3] = 9.0;
    Matrix *a = [Matrix matrixWithValues:aVals rows:2 columns:2];
    Matrix *b = [Matrix matrixWithValues:bVals rows:2 columns:2];
    
    Matrix *p = [Matrix productOfMatrixA:a andMatrixB:b];
    if (verbose) NSLog(a.description);
    if (verbose) NSLog(b.description);
    if (verbose) NSLog(p.description);
    
    double *solution = malloc(4 * sizeof(double));
    solution[0] = 22.0;
    solution[1] = 58.0;
    solution[2] = 25.0;
    solution[3] = 66.0;
    
    BOOL passed = YES;
    for (int i = 0; i < 4; i++) {
        if (p.values[i] != solution[i]) {
            passed = NO;
            break;
        }
    }
    
    NSLog(passed ? @"PASSED" : @"FAILED");
}

- (void)testMultiplyRectangularMatricesVerbose:(BOOL)verbose
{
    double *aVals = malloc(6 * sizeof(double));
    double *bVals = malloc(9 * sizeof(double));
    aVals[0] = 0.0;
    aVals[1] = 1.0;
    aVals[2] = 1.0;
    aVals[3] = 0.0;
    aVals[4] = -1.0;
    aVals[5] = 1.0;
    
    bVals[0] = 1.0;
    bVals[1] = 4.0;
    bVals[2] = 7.0;
    bVals[3] = 2.0;
    bVals[4] = 5.0;
    bVals[5] = 8.0;
    bVals[6] = 3.0;
    bVals[7] = 6.0;
    bVals[8] = 9.0;
    Matrix *a = [Matrix matrixWithValues:aVals rows:2 columns:3];
    Matrix *b = [Matrix matrixWithValues:bVals rows:3 columns:3];
    
    Matrix *p = [Matrix productOfMatrixA:a andMatrixB:b];
    if (verbose) NSLog(a.description);
    if (verbose) NSLog(b.description);
    if (verbose) NSLog(p.description);
    
    double *solution = malloc(6 * sizeof(double));
    solution[0] = -3.0;
    solution[1] = 8.0;
    solution[2] = -3.0;
    solution[3] = 10.0;
    solution[4] = -3.0;
    solution[5] = 12.0;
    
    BOOL passed = YES;
    for (int i = 0; i < 6; i++) {
        if (p.values[i] != solution[i]) {
            passed = NO;
            break;
        }
    }
    
    NSLog(passed ? @"PASSED" : @"FAILED");
}

- (void)firstSVDTestVerbose:(BOOL)verbose
{
    // page 568 example 12.5 from Sauer
    double *values = malloc(6 * sizeof(double));
    values[0] = 0.0;
    values[1] = 3.0;
    values[2] = 0.0;
    values[3] = -0.5;
    values[4] = 0.0;
    values[5] = 0.0;
    Matrix *a = [Matrix matrixWithValues:values rows:3 columns:2];
    if (verbose) NSLog(a.description);
    
    SingularValueDecomposition *svd = a.singularValueDecomposition;
    if (verbose) NSLog(svd.u.description);
    if (verbose) NSLog(svd.s.description);
    if (verbose) NSLog(svd.vT.description);
    
    Matrix *intermediate = [Matrix productOfMatrixA:svd.u andMatrixB:svd.s];
    Matrix *original = [Matrix productOfMatrixA:intermediate andMatrixB:svd.vT];
    if (verbose) NSLog(original.description);
    
    BOOL passed = YES;
    for (int i = 0; i < 6; i++) {
        double a = values[i];
        double b = original.values[i];
        double eps = __DBL_EPSILON__ * 10.0;
        if (fabs(a - b) > eps) {
            passed = NO;
            break;
        }
    }
    
    NSLog(passed ? @"PASSED" : @"FAILED");
}

- (void)secondSVDTestVerbose:(BOOL)verbose
{
    // page 574 example 12.9 from Sauer
    double *values = malloc(8 * sizeof(double));
    values[0] = 3.0;
    values[1] = 2.0;
    values[2] = 2.0;
    values[3] = 4.0;
    values[4] = -2.0;
    values[5] = -1.0;
    values[6] = -3.0;
    values[7] = -5.0;
    Matrix *a = [Matrix matrixWithValues:values rows:2 columns:4];
    if (verbose) NSLog(a.description);
    
    SingularValueDecomposition *svd = a.singularValueDecomposition;
    if (verbose) NSLog(svd.u.description);
    if (verbose) NSLog(svd.s.description);
    if (verbose) NSLog(svd.vT.description);
    
    Matrix *intermediate = [Matrix productOfMatrixA:svd.u andMatrixB:svd.s];
    Matrix *original = [Matrix productOfMatrixA:intermediate andMatrixB:svd.vT];
    if (verbose) NSLog(original.description);
    
    BOOL passed = YES;
    for (int i = 0; i < 8; i++) {
        double a = values[i];
        double b = original.values[i];
        double eps = __DBL_EPSILON__ * 10.0;
        if (fabs(a - b) > eps) {
            passed = NO;
            break;
        }
    }
    
    NSLog(passed ? @"PASSED" : @"FAILED");
}

- (void)testSVDVerbose:(BOOL)verbose
{
    [self firstSVDTestVerbose:verbose];
    [self secondSVDTestVerbose:verbose];
}

- (void)testOverdeterminedSystemVerbose:(BOOL)verbose
{
    double *aVals = malloc(6 * sizeof(double));
    double *bVals = malloc(3 * sizeof(double));
    aVals[0] = 1.0;
    aVals[1] = 1.0;
    aVals[2] = 1.0;
    aVals[3] = 1.0;
    aVals[4] = -1.0;
    aVals[5] = 1.0;
    
    bVals[0] = 2.0;
    bVals[1] = 1.0;
    bVals[2] = 3.0;
    Matrix *a = [Matrix matrixWithValues:aVals rows:3 columns:2];
    Matrix *b = [Matrix matrixWithValues:bVals rows:3 columns:1];
    
    Matrix *coefficients = [Matrix solveLinearSystemWithMatrixA:a valuesB:b];
    
    if (verbose) {
        NSLog(a.description);
        NSLog(b.description);
        NSLog(coefficients.description);
    }
    
    double *solution = malloc(2 * sizeof(double));
    solution[0] = 7.0 / 4.0;
    solution[1] = 3.0 / 4.0;
    
    BOOL passed = YES;
    for (int i = 0; i < 2; i++) {
        double a = coefficients.values[i];
        double b = solution[i];
        double eps = __DBL_EPSILON__ * 10.0;
        if (fabs(a - b) > eps) {
            passed = NO;
            break;
        }
    }
    
    NSLog(passed ? @"PASSED" : @"FAILED");
}

- (void)testNormalSystemOfEquationsVerbose:(BOOL)verbose
{
    double *aVals = malloc(16 * sizeof(double));
    double *bVals = malloc(4 * sizeof(double));
    aVals[0] = 8.0;
    aVals[1] = 0.0;
    aVals[2] = 0.0;
    aVals[3] = 0.0;
    aVals[4] = 0.0;
    aVals[5] = 4.0;
    aVals[6] = 0.0;
    aVals[7] = 0.0;
    aVals[8] = 0.0;
    aVals[9] = 0.0;
    aVals[10] = 4.0;
    aVals[11] = 0.0;
    aVals[12] = 0.0;
    aVals[13] = 0.0;
    aVals[14] = 0.0;
    aVals[15] = 4.0;
    
    bVals[0] = -15.6;
    bVals[1] = -2.9778;
    bVals[2] = -10.2376;
    bVals[3] = 4.5;
    Matrix *a = [Matrix matrixWithValues:aVals rows:4 columns:4];
    Matrix *b = [Matrix matrixWithValues:bVals rows:4 columns:1];
    
    Matrix *coefficients = [Matrix solveLinearSystemWithMatrixA:a valuesB:b];
    
    if (verbose) {
        NSLog(a.description);
        NSLog(b.description);
        NSLog(coefficients.description);
    }
    
    double *solution = malloc(2 * sizeof(double));
    solution[0] = -1.95;
    solution[1] = -0.7445;
    solution[2] = -2.5594;
    solution[3] = 1.125;
    
    BOOL passed = YES;
    for (int i = 0; i < 4; i++) {
        double a = coefficients.values[i];
        double b = solution[i];
        double eps = 0.0005;
        double diff = fabs(a - b);
        if (diff > eps) {
            passed = NO;
            break;
        }
    }
    
    NSLog(passed ? @"PASSED" : @"FAILED");
}

- (void)testSolvingSystemOfEquationsVerbose:(BOOL)verbose
{
    [self testOverdeterminedSystemVerbose:verbose];
    [self testNormalSystemOfEquationsVerbose:verbose];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    [self testMultiplySquareMatricesVerbose:NO];
//    [self testMultiplyRectangularMatricesVerbose:NO];
//    [self testSVDVerbose:NO];
    [self testSolvingSystemOfEquationsVerbose:NO];
}

@end

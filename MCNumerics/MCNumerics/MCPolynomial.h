//
//  MCPolynomial.h
//  MCNumerics
//
//  Created by andrew mcknight on 12/13/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCPolynomial : NSObject

@property (strong, nonatomic) NSArray *coefficients;

#pragma mark - Init

- (id)initWithCoefficients:(NSArray *)coefficients;

+ (MCPolynomial *)polynomialWithCoefficients:(NSArray *)coefficients;

#pragma mark - Inspection

- (BOOL)isEqualToPolynomial:(MCPolynomial *)otherPolynomial;

#pragma mark - Operations

- (MCPolynomial *)derivativeOfDegree:(NSUInteger)degree;

- (NSNumber *)evaluateAtValue:(NSNumber *)value;
- (NSNumber *)evaluateDerivativeOfDegree:(NSUInteger)degree withValue:(NSNumber *)value;

- (NSNumber *)rootNearValue:(NSNumber *)value;
- (NSNumber *)localMaximumNearValue:(NSNumber *)value;
- (NSNumber *)localMinimumNearValue:(NSNumber *)value;
- (NSNumber *)inflectionPointNearValue:(NSNumber *)value;

- (NSNumber *)areaUnderCurveBetweenA:(NSNumber *)a b:(NSNumber *)b;
- (NSNumber *)arcLengthBetweenA:(NSNumber *)a b:(NSNumber *)b;

@end

//
//  MCPolynomial.h
//  MCNumerics
//
//  Created by andrew mcknight on 12/13/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCEquation.h"

@interface MCPolynomial : NSObject <MCEquation>

@property (strong, nonatomic) NSArray *coefficients;

#pragma mark - Init

- (id)initWithCoefficients:(NSArray *)coefficients;

+ (MCPolynomial *)polynomialWithCoefficients:(NSArray *)coefficients;

#pragma mark - Inspection

- (BOOL)isEqualToPolynomial:(MCPolynomial *)otherPolynomial;

#pragma mark - Operations

- (NSNumber *)rootNearValue:(NSNumber *)value;
- (NSNumber *)localMaximumNearValue:(NSNumber *)value;
- (NSNumber *)localMinimumNearValue:(NSNumber *)value;
- (NSNumber *)inflectionPointNearValue:(NSNumber *)value;

@end

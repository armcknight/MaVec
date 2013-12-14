//
//  NSNumber+MCArithmetic.h
//  MCNumerics
//
//  Created by andrew mcknight on 12/13/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Arithmetic)

#pragma mark - Basic operations

- (NSNumber *)sumByAdding:(NSNumber *)addend;
- (NSNumber *)differenceBySubtracting:(NSNumber *)subtrahend;
- (NSNumber *)productByMultiplying:(NSNumber *)multiplicand;
- (NSNumber *)quotientByDividingBy:(NSNumber *)divident;
- (NSNumber *)raiseToPower:(NSNumber *)exponend;

#pragma mark - Exponents and logarithms

- (NSNumber *)naturalLog;
- (NSNumber *)commonLog;
- (NSNumber *)binaryLog;
- (NSNumber *)logarithmWithBase:(NSNumber *)base;
- (NSNumber *)exponentiate;

#pragma mark - Trigonometric functions

- (NSNumber *)sin;
- (NSNumber *)cos;
- (NSNumber *)tan;
- (NSNumber *)sec;
- (NSNumber *)csc;
- (NSNumber *)cot;

- (NSNumber *)arcsin;
- (NSNumber *)arccos;
- (NSNumber *)arctan;
- (NSNumber *)arcsec;
- (NSNumber *)arccsc;
- (NSNumber *)arccot;

#pragma mark - Hyperbolic functions

- (NSNumber *)sinh;
- (NSNumber *)cosh;
- (NSNumber *)tanh;
- (NSNumber *)sech;
- (NSNumber *)csch;
- (NSNumber *)coth;

- (NSNumber *)arcsinh;
- (NSNumber *)arccosh;
- (NSNumber *)arctanh;
- (NSNumber *)arcsech;
- (NSNumber *)arccsch;
- (NSNumber *)arccoth;

@end

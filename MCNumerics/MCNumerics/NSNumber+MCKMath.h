//
//  NSNumber+MCKMath.h
//  MAVNumerics
//
//  Created by andrew mcknight on 12/13/13.
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

#import <Foundation/Foundation.h>

@interface NSNumber (MCKMath)

#pragma mark - Queries

- (BOOL)isPositive;
- (BOOL)isZero;

#pragma mark - Basic operations

- (NSNumber *)negative;
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

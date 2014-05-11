//
//  NSNumber+MCKMath.m
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

#import "NSNumber+MCKMath.h"

@implementation NSNumber (MCKMath)

#pragma mark - Queries

- (BOOL)isPositive
{
    return self.doubleValue > 0.0;
}

- (BOOL)isZero
{
    return self.doubleValue == 0.0;
}

#pragma mark - Basic operations

- (NSNumber *)negative
{
    return @(self.doubleValue * -1.0);
}

- (NSNumber *)sumByAdding:(NSNumber *)addend
{
    return @(self.doubleValue + addend.doubleValue);
}

- (NSNumber *)differenceBySubtracting:(NSNumber *)subtrahend
{
    return @(self.doubleValue - subtrahend.doubleValue);
}

- (NSNumber *)productByMultiplying:(NSNumber *)multiplicand
{
    return @(self.doubleValue * multiplicand.doubleValue);
}

- (NSNumber *)quotientByDividingBy:(NSNumber *)dividend
{
    return @(self.doubleValue / dividend.doubleValue);
}

- (NSNumber *)raiseToPower:(NSNumber *)exponent
{
    return @(pow(self.doubleValue, exponent.doubleValue));
}

#pragma mark - Exponents and logarithms

- (NSNumber *)naturalLog
{
    return @(log(self.doubleValue));
}

- (NSNumber *)commonLog
{
    return @(log10(self.doubleValue));
}

- (NSNumber *)binaryLog
{
    return @(logb(self.doubleValue));
}

- (NSNumber *)logarithmWithBase:(NSNumber *)base
{
    return @(logb(self.doubleValue) / logb(base.doubleValue));
}

- (NSNumber *)exponentiate
{
    return @(exp(self.doubleValue));
}

#pragma mark - Trigonometric functions

- (NSNumber *)sin
{
    return @(sin(self.doubleValue));
}

- (NSNumber *)cos
{
    return @(cos(self.doubleValue));
}

- (NSNumber *)tan
{
    return @(tan(self.doubleValue));
}

- (NSNumber *)sec
{
    return [@(1) quotientByDividingBy:[self cos]];
}

- (NSNumber *)csc
{
    return [@(1) quotientByDividingBy:[self sin]];
}

- (NSNumber *)cot
{
    return [@(1) quotientByDividingBy:[self tan]];
}

- (NSNumber *)arcsin
{
    return @(asin(self.doubleValue));
}

- (NSNumber *)arccos
{
    return @(acos(self.doubleValue));
}

- (NSNumber *)arctan
{
    return @(atan(self.doubleValue));
}

- (NSNumber *)arcsec
{
    return [[@(1) quotientByDividingBy:self] arccos];
}

- (NSNumber *)arccsc
{
    return [[@(1) quotientByDividingBy:self] arcsin];
}

- (NSNumber *)arccot
{
    return [@(M_PI_2) differenceBySubtracting:[self arctan]];
}

#pragma mark - Hyperbolic functions

- (NSNumber *)sinh
{
    return @(sinh(self.doubleValue));
}

- (NSNumber *)cosh
{
    return @(cosh(self.doubleValue));
}

- (NSNumber *)tanh
{
    return @(tanh(self.doubleValue));
}

- (NSNumber *)sech
{
    return [@(1) quotientByDividingBy:[self cosh]];
}

- (NSNumber *)csch
{
    return [@(1) quotientByDividingBy:[self sinh]];
}

- (NSNumber *)coth
{
    return [@(1) quotientByDividingBy:[self coth]];
}

- (NSNumber *)arcsinh
{
    return @(asinh(self.doubleValue));
}

- (NSNumber *)arccosh
{
    return @(acosh(self.doubleValue));
}

- (NSNumber *)arctanh
{
    return @(atanh(self.doubleValue));
}

- (NSNumber *)arcsech
{
    return [[@(1) quotientByDividingBy:self] arccosh];
}

- (NSNumber *)arccsch
{
    return [[@(1) quotientByDividingBy:self] arcsinh];
}

- (NSNumber *)arccoth
{
    return [[@(1) quotientByDividingBy:self] arccoth];
}

@end

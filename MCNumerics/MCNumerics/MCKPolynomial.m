//
//  MCKPolynomial.m
//  MCKMath
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

#import "MCKPolynomial.h"

#import "NSNumber+MCKMath.h"

@interface MCKPolynomial ()

@end

@implementation MCKPolynomial

#pragma mark - Init

- (id)initWithCoefficients:(NSArray *)coefficients
{
    self = [super init];
    if (self) {
        self.coefficients = coefficients;
    }
    return self;
}

+ (MCKPolynomial *)polynomialWithCoefficients:(NSArray *)coefficients
{
    return [[MCKPolynomial alloc] initWithCoefficients:coefficients];
}

#pragma mark - MAVEquation methods

- (MCKPolynomial *)derivativeOfDegree:(NSUInteger)degree
{
    NSMutableArray *derivativeCoefficients = [NSMutableArray array];
    NSIndexSet *coefficientsToEnumerate = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(degree, self.coefficients.count - degree)];
    [self.coefficients enumerateObjectsAtIndexes:coefficientsToEnumerate
                                         options:0
                                      usingBlock:^(NSNumber *coefficient, NSUInteger power, BOOL *stop) {
                                          NSNumber *derivativeCoefficient = coefficient;
                                          for (int i = 0; i < degree; i++) {
                                              derivativeCoefficient = [derivativeCoefficient productByMultiplying:@(power - i)];
                                          }
                                          [derivativeCoefficients addObject:derivativeCoefficient];
                                      }];
    return [MCKPolynomial polynomialWithCoefficients:derivativeCoefficients];
}

- (NSNumber *)evaluateAtValue:(NSNumber *)value
{
    NSNumber __block *sum = @0.0;
    [self.coefficients enumerateObjectsUsingBlock:^(NSNumber *coefficient, NSUInteger power, BOOL *stop) {
        sum = [sum sumByAdding:[coefficient productByMultiplying:[value raiseToPower:@(power)]]];
    }];
    return sum;
}

- (NSNumber *)evaluateDerivativeOfDegree:(NSUInteger)degree withValue:(NSNumber *)value
{
    MCKPolynomial *derivative = [self derivativeOfDegree:degree];
    return [derivative evaluateAtValue:value];
}

#pragma mark - NSObject overrides

- (BOOL)isEqualToPolynomial:(MCKPolynomial *)otherPolynomial
{
    return [self.coefficients isEqualToArray:otherPolynomial.coefficients];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[MCKPolynomial class]]) {
        return NO;
    }
    return [self isEqualToPolynomial:(MCKPolynomial *)object];
}

- (NSUInteger)hash
{
    return [self.coefficients hash];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];
    
    [self.coefficients enumerateObjectsUsingBlock:^(NSNumber *coefficient, NSUInteger power, BOOL *stop) {
        if (power == 0) {
            [description appendFormat:@"%.2f", coefficient.doubleValue];
        } else if (power == 1) {
            [description appendFormat:@"%.2f*x", coefficient.doubleValue];
        } else {
            [description appendFormat:@"%.2f*x^%lu", coefficient.doubleValue, (unsigned long)power];
        }
        
        if (power < self.coefficients.count) {
            [description appendString:@" + "];
        }
    }];
    
    return description;
}

@end

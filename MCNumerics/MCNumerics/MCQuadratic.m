//
//  MCQuadratic.m
//  MCNumerics
//
//  Created by andrew mcknight on 2/15/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import "MCQuadratic.h"
#import "MCPair.h"

#import "NSNumber+MCMath.h"

@interface MCQuadratic ()

@end

@implementation MCQuadratic

@synthesize roots = _roots;

- (instancetype)initWithA:(NSNumber *)a b:(NSNumber *)b c:(NSNumber *)c
{
    return [super initWithCoefficients:@[a, b, c]];
}

+ (instancetype)quadraticWithA:(NSNumber *)a b:(NSNumber *)b c:(NSNumber *)c
{
    return [[MCQuadratic alloc] initWithA:a b:b c:c];
}

- (MCPair *)roots
{
    if (!_roots) {
        double a = [self.coefficients.firstObject doubleValue];
        double b = [self.coefficients[1] doubleValue];
        double c = [self.coefficients.lastObject doubleValue] * -2.0;
        double firstRoot = ( -b + sqrt(b * b - 4.0 * a * c) ) / 2.0;
        double secondRoot = ( -b - sqrt(b * b - 4.0 * a * c) ) / 2.0;
        _roots = [MCPair pairWithFirst:@(firstRoot) second:@(secondRoot)];
    }
    return _roots;
}

@end

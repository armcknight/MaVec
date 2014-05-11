//
//  MCKQuadratic.m
//  MCKMath
//
//  Created by andrew mcknight on 2/15/14.
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

#import "MCKQuadratic.h"
#import "MCKPair.h"

#import "NSNumber+MCKMath.h"

@interface MCKQuadratic ()

@end

@implementation MCKQuadratic

@synthesize roots = _roots;

- (instancetype)initWithA:(NSNumber *)a b:(NSNumber *)b c:(NSNumber *)c
{
    return [super initWithCoefficients:@[a, b, c]];
}

+ (instancetype)quadraticWithA:(NSNumber *)a b:(NSNumber *)b c:(NSNumber *)c
{
    return [[MCKQuadratic alloc] initWithA:a b:b c:c];
}

- (MCKPair *)roots
{
    if (!_roots) {
        double a = [self.coefficients.firstObject doubleValue];
        double b = [self.coefficients[1] doubleValue];
        double c = [self.coefficients.lastObject doubleValue] * -2.0;
        double firstRoot = ( -b + sqrt(b * b - 4.0 * a * c) ) / 2.0;
        double secondRoot = ( -b - sqrt(b * b - 4.0 * a * c) ) / 2.0;
        _roots = [MCKPair pairWithFirst:@(firstRoot) second:@(secondRoot)];
    }
    return _roots;
}

@end

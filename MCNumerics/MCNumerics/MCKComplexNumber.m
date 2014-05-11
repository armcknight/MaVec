//
//  MCKComplexNumber.m
//  MCKMath
//
//  Created by andrew mcknight on 4/13/14.
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

#import "MCKComplexNumber.h"

@interface MCKComplexNumber ()

@property (strong, nonatomic, readwrite) NSValue *imaginaryValue;

@end

@implementation MCKComplexNumber

- (instancetype)initWithRealValue:(const void *)realValue imaginaryValue:(const void *)imaginaryValue precision:(MCKValuePrecision)precision
{
    self = [super initWithValue:(__bridge NSNumber *)(realValue) precision:precision];
    if (self != nil) {
        _imaginaryValue = [NSValue valueWithBytes:imaginaryValue objCType:precision == MCKValuePrecisionSingle ? @encode(float) : @encode(double)];
    }
    return self;
}

+ (instancetype)complexNumberWithRealValue:(const void *)realValue imaginaryValue:(const void *)imaginaryValue precision:(MCKValuePrecision)precision
{
    return [[self alloc] initWithRealValue:realValue imaginaryValue:imaginaryValue precision:precision];
}

@end

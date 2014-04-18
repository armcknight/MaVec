//
//  MCImaginaryNumber.m
//  MCNumerics
//
//  Created by andrew mcknight on 4/13/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import "MCComplexNumber.h"

@interface MCComplexNumber ()

@property (strong, nonatomic, readwrite) NSValue *imaginaryValue;

@end

@implementation MCComplexNumber

- (instancetype)initWithRealValue:(const void *)realValue imaginaryValue:(const void *)imaginaryValue precision:(MCValuePrecision)precision
{
    self = [super initWithValue:(__bridge NSNumber *)(realValue) precision:precision];
    if (self != nil) {
        _imaginaryValue = [NSValue valueWithBytes:imaginaryValue objCType:precision == MCValuePrecisionSingle ? @encode(float) : @encode(double)];
    }
    return self;
}

+ (instancetype)complexNumberWithRealValue:(const void *)realValue imaginaryValue:(const void *)imaginaryValue precision:(MCValuePrecision)precision
{
    return [[self alloc] initWithRealValue:realValue imaginaryValue:imaginaryValue precision:precision];
}

@end

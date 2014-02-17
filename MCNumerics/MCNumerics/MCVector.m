//
//  MCVector.m
//  MCNumerics
//
//  Created by andrew mcknight on 12/8/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import "MCVector.h"
#import <Accelerate/Accelerate.h>

@interface MCVector()

@end

@implementation MCVector

@synthesize sumOfValues = _sumOfValues;
@synthesize productOfValues = _productOfValues;

#pragma mark - Constructors

- (void)commonInit
{
    _sumOfValues = NAN;
    _productOfValues = NAN;
}

- (void)commonInitWithValues:(double *)values length:(int)length
{
    _values = values;
    _length = length;
}

- (instancetype)initWithValues:(double *)values length:(int)length
{
    self = [super init];
    if (self) {
        [self commonInitWithValues:values length:length];
        _vectorFormat = MCVectorFormatColumnVector;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithValues:(double *)values length:(int)length inVectorFormat:(MCVectorFormat)vectorFormat
{
    self = [super init];
    if (self) {
        [self commonInitWithValues:values length:length];
        _vectorFormat = vectorFormat;
        [self commonInit];
    }
    return self;
}

+ (instancetype)vectorWithValues:(double *)values length:(int)length
{
    return [[MCVector alloc] initWithValues:values length:length];
}

+ (instancetype)vectorWithValues:(double *)values length:(int)length inVectorFormat:(MCVectorFormat)vectorFormat
{
    return [[MCVector alloc] initWithValues:values length:length inVectorFormat:vectorFormat];
}

- (void)commonInitWithValuesInArray:(NSArray *)values
{
    _length = values.count;
    _values = malloc(values.count * sizeof(double));
    [values enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
        _values[idx] = value.doubleValue;
    }];
}

- (instancetype)initWithValuesInArray:(NSArray *)values
{
    self = [super init];
    if (self) {
        [self commonInitWithValuesInArray:values];
        _vectorFormat = MCVectorFormatColumnVector;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithValuesInArray:(NSArray *)values inVectorFormat:(MCVectorFormat)vectorFormat
{
    self = [super init];
    if (self) {
        [self commonInitWithValuesInArray:values];
        _vectorFormat = vectorFormat;
        [self commonInit];
    }
    return self;
}

+ (instancetype)vectorWithValuesInArray:(NSArray *)values
{
    return [[MCVector alloc] initWithValuesInArray:values];
}

+ (instancetype)vectorWithValuesInArray:(NSArray *)values inVectorFormat:(MCVectorFormat)vectorFormat
{
    return [[MCVector alloc] initWithValuesInArray:values inVectorFormat:vectorFormat];
}

#pragma mark - Lazy loaded properties

- (double)sumOfValues
{
    if (isnan(_sumOfValues)) {
        double sum = 0.0;
        for (int i = 0; i < self.length; i += 1) {
            sum += self.values[i];
        }
        _sumOfValues = sum;
    }
    return _sumOfValues;
}

- (double)productOfValues
{
    if (isnan(_productOfValues)) {
        double product = 1.0;
        for (int i = 0; i < self.length; i += 1) {
            product *= self.values[i];
        }
        _productOfValues = product;
    }
    return _productOfValues;
}

#pragma mark - NSObject overrides

- (BOOL)isEqualToVector:(MCVector *)otherVector
{
    if (self == otherVector.self) {
        return YES;
    } else {
        for (int i = 0; i < self.length; i++) {
            if (self.values[i] != [otherVector valueAtIndex:i]) {
                return NO;
            }
        }
        return YES;
    }
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    } else if (![object isKindOfClass:[MCVector class]]) {
        return NO;
    } else {
        return [self isEqualToVector:(MCVector *)object];
    }
}

- (NSUInteger)hash
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < self.length; i++) {
        [array addObject:@(self.values[i])];
    }
    
    return array.hash;
}

- (NSString *)description
{
    int padding;
    if (self.vectorFormat == MCVectorFormatColumnVector) {
        double max = DBL_MIN;
        for (int i = 0; i < self.length; i++) {
            max = MAX(max, fabs(self.values[i]));
        }
        padding = floor(log10(max)) + 5;
    }
    
    NSMutableString *description = [@"\n" mutableCopy];
    
    for (int j = 0; j < self.length; j++) {
        NSString *valueString = [NSString stringWithFormat:@"%.1f", self.values[j]];
        if (self.vectorFormat == MCVectorFormatColumnVector) {
            [description appendString:[valueString stringByPaddingToLength:padding withString:@" " startingAtIndex:0]];
            if (j < self.length - 1) {
                [description appendString:@"\n"];
            }
        } else {
            [description appendString:valueString];
            if (j < self.length - 1) {
                [description appendString:@" "];
            }
        }
    }
    
    return description;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MCVector *vectorCopy = [[self class] allocWithZone:zone];
    
    vectorCopy->_length = _length;
    vectorCopy->_vectorFormat = _vectorFormat;
    
    vectorCopy->_values = malloc(_length * sizeof(double));
    for (int i = 0; i < _length; i += 1) {
        vectorCopy->_values[i] = _values[i];
    }
    
    return vectorCopy;
}

#pragma mark - Inspection

- (double)valueAtIndex:(NSUInteger)index
{
    return self.values[index];
}

- (double)maximumValue
{
    double max = DBL_MIN;
    for (int i = 0; i < self.length; i++) {
        if (self.values[i] > max) {
            max = self.values[i];
        }
    }
    return max;
}

- (double)minimumValue
{
    double min = DBL_MAX;
    for (int i = 0; i < self.length; i++) {
        if (self.values[i] < min) {
            min = self.values[i];
        }
    }
    return min;
}

- (NSUInteger)indexOfMaximumValue
{
    double max = DBL_MIN;
    NSUInteger idx = -1;
    for (int i = 0; i < self.length; i++) {
        if (self.values[i] > max) {
            idx = i;
        }
    }
    return max;
}

- (NSUInteger)indexOfMinimumValue
{
    double min = DBL_MAX;
    NSUInteger idx = -1;
    for (int i = 0; i < self.length; i++) {
        if (self.values[i] < min) {
            idx = i;
        }
    }
    return min;
}

#pragma mark - Instance Operations

- (MCVector *)vectorByMultiplyingByScalar:(double)scalar
{
    double *newValues = malloc(self.length * sizeof(double));
    for (int i = 0; i < self.length; i++) {
        newValues[i] = scalar * self.values[i];
    }
    return [MCVector vectorWithValues:newValues length:self.length inVectorFormat:self.vectorFormat];
}

- (MCVector *)vectorByAddingVector:(MCVector *)addend
{
    return [MCVector sumOfVectorA:self andVectorB:addend];
}

- (MCVector *)vectorBySubtractingVector:(MCVector *)subtrahend
{
    return [MCVector differenceOfVectorA:self andVectorB:subtrahend];
}

- (MCVector *)vectorByMultiplyingByVector:(MCVector *)multiplier
{
    return [MCVector productOfVectorA:self andVectorB:multiplier];
}

- (MCVector *)vectorByDividingByVector:(MCVector *)divisor
{
    return [MCVector quotientOfVectorA:self andVectorB:divisor];
}

- (double)dotProductWithVector:(MCVector *)otherVector
{
    return [MCVector dotProductOfVectorA:self andVectorB:otherVector];
}

- (MCVector *)crossProductWithVector:(MCVector *)otherVector
{
    return [MCVector crossProductOfVectorA:self andVectorB:otherVector];
}

#pragma mark - Class Operations

+ (MCVector *)sumOfVectorA:(MCVector *)a andVectorB:(MCVector *)b
{
    if (a.length != b.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double *sum = malloc(a.length * sizeof(double));
    vDSP_vaddD(a.values, 1, b.values, 1, sum, 1, a.length);
    
    return [MCVector vectorWithValues:sum length:a.length];
}

+ (MCVector *)differenceOfVectorA:(MCVector *)a andVectorB:(MCVector *)b
{
    if (a.length != b.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double *diff = malloc(a.length * sizeof(double));
    vDSP_vsubD(b.values, 1, a.values, 1, diff, 1, a.length);
    
    return [MCVector vectorWithValues:diff length:a.length];
}

+ (MCVector *)productOfVectorA:(MCVector *)a andVectorB:(MCVector *)b
{
    if (a.length != b.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double *product = malloc(a.length * sizeof(double));
    vDSP_vmulD(a.values, 1, b.values, 1, product, 1, a.length);
    
    return [MCVector vectorWithValues:product length:a.length];
}

+ (MCVector *)quotientOfVectorA:(MCVector *)a andVectorB:(MCVector *)b
{
    if (a.length != b.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double *quotient = malloc(a.length * sizeof(double));
    vDSP_vdivD(b.values, 1, a.values, 1, quotient, 1, a.length);
    
    return [MCVector vectorWithValues:quotient length:a.length];
}

+ (double)dotProductOfVectorA:(MCVector *)a andVectorB:(MCVector *)b
{
    if (a.length != b.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double dotProduct;
    vDSP_dotprD(a.values, 1, b.values, 1, &dotProduct, a.length);
    
    return dotProduct;
}

+ (MCVector *)crossProductOfVectorA:(MCVector *)a andVectorB:(MCVector *)b
{
    if (!(a.length == 3 && b.length == 3)) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vectors must both be of length 3 to perform cross products" userInfo:nil];
    }
    
    double *values = malloc(a.length * sizeof(double));
    values[0] = [a valueAtIndex:1] * [b valueAtIndex:2] - [a valueAtIndex:2] * [b valueAtIndex:1];
    values[1] = [a valueAtIndex:2] * [b valueAtIndex:0] - [a valueAtIndex:0] * [b valueAtIndex:2];
    values[2] = [a valueAtIndex:0] * [b valueAtIndex:1] - [a valueAtIndex:1] * [b valueAtIndex:0];
    
    return [MCVector vectorWithValues:values length:a.length];
}

+ (double)scalarTripleProductWithVectorA:(MCVector *)a vectorB:(MCVector *)b vectorC:(MCVector *)c
{
    return [MCVector dotProductOfVectorA:[MCVector crossProductOfVectorA:a
                                                              andVectorB:b]
                              andVectorB:c];
}

+ (MCVector *)vectorTripleProductWithVectorA:(MCVector *)a vectorB:(MCVector *)b vectorC:(MCVector *)c
{
    return [MCVector crossProductOfVectorA:a
                                andVectorB:[MCVector crossProductOfVectorA:b
                                                                andVectorB:c]];
}

@end

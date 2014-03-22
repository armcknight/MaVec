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

- (void)commonInit;
- (void)commonInitWithValues:(double *)values length:(int)length;
- (void)commonInitWithValuesInArray:(NSArray *)values;

@end

@implementation MCVector

@synthesize sumOfValues = _sumOfValues;
@synthesize productOfValues = _productOfValues;
@synthesize l1Norm = _l1Norm;
@synthesize l2Norm = _l2Norm;
@synthesize l3Norm = _l3Norm;
@synthesize infinityNorm = _infinityNorm;
@synthesize minimumValue = _minimumValue;
@synthesize maximumValue = _maximumValue;
@synthesize minimumValueIndex = _minimumValueIndex;
@synthesize maximumValueIndex = _maximumValueIndex;
@synthesize absoluteVector = _absoluteVector;

#pragma mark - Private constructor helpers

- (void)commonInit
{
    _sumOfValues = NAN;
    _productOfValues = NAN;
    _l1Norm = NAN;
    _l2Norm = NAN;
    _l3Norm = NAN;
    _infinityNorm = NAN;
    _minimumValue = NAN;
    _maximumValue = NAN;
    _minimumValueIndex = -1;
    _maximumValueIndex = -1;
    _absoluteVector = nil;
}

- (void)commonInitWithValues:(double *)values length:(int)length
{
    _values = values;
    _length = length;
}

- (void)commonInitWithValuesInArray:(NSArray *)values
{
    _length = (int)values.count;
    _values = malloc(values.count * sizeof(double));
    [values enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
        _values[idx] = value.doubleValue;
    }];
}

#pragma mark - Constructors

- (instancetype)initWithValues:(double *)values length:(int)length vectorFormat:(MCVectorFormat)vectorFormat
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
    return [[MCVector alloc] initWithValues:values length:length vectorFormat:MCVectorFormatColumnVector];
}

+ (instancetype)vectorWithValues:(double *)values length:(int)length vectorFormat:(MCVectorFormat)vectorFormat
{
    return [[MCVector alloc] initWithValues:values length:length vectorFormat:vectorFormat];
}

- (instancetype)initWithValuesInArray:(NSArray *)values vectorFormat:(MCVectorFormat)vectorFormat
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
    return [[MCVector alloc] initWithValuesInArray:values vectorFormat:MCVectorFormatColumnVector];
}

+ (instancetype)vectorWithValuesInArray:(NSArray *)values vectorFormat:(MCVectorFormat)vectorFormat
{
    return [[MCVector alloc] initWithValuesInArray:values vectorFormat:vectorFormat];
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

- (double)l1Norm
{
    if (isnan(_l1Norm)) {
        vDSP_svemgD(self.values, 1, &_l1Norm, self.length);
    }
    return _l1Norm;
}

- (double)l2Norm
{
    if (isnan(_l2Norm)) {
        double squaredSum;
        vDSP_svesqD(self.values, 1, &squaredSum, self.length);
        _l2Norm = sqrt(squaredSum);
    }
    return _l2Norm;
}

- (double)l3Norm
{
    if (isnan(_l3Norm)) {
        MCVector *cubedVector = [MCVector vectorByRaisingVector:self power:3];
        double cubedSum;
        vDSP_svemgD(cubedVector.values, 1, &cubedSum, self.length);
        _l3Norm = cbrt(cubedSum);
    }
    return _l3Norm;
}

- (double)infinityNorm
{
    if (isnan(_infinityNorm)) {
        _infinityNorm = self.absoluteVector.maximumValue;
    }
    return _infinityNorm;
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

- (double)maximumValue
{
    if (isnan(_maximumValue)) {
        _maximumValue = DBL_MIN;
        for (int i = 0; i < self.length; i++) {
            if (self.values[i] > _maximumValue) {
                _maximumValue = self.values[i];
            }
        }
    }
    return _maximumValue;
}

- (double)minimumValue
{
    if (isnan(_minimumValue)) {
        _minimumValue = DBL_MAX;
        for (int i = 0; i < self.length; i++) {
            if (self.values[i] < _minimumValue) {
                _minimumValue = self.values[i];
            }
        }
    }
    return _minimumValue;
}

- (int)maximumValueIndex
{
    if (_maximumValueIndex == -1) {
        double max = DBL_MIN;
        for (int i = 0; i < self.length; i++) {
            if (self.values[i] > max) {
                _maximumValueIndex = i;
            }
        }
    }
    return _maximumValueIndex;
}

- (int)minimumValueIndex
{
    if (_minimumValueIndex == -1) {
        double min = DBL_MAX;
        for (int i = 0; i < self.length; i++) {
            if (self.values[i] < min) {
                _minimumValueIndex = i;
            }
        }
    }
    return _minimumValueIndex;
}

- (MCVector *)absoluteVector
{
    if (_absoluteVector == nil) {
        double *absoluteValues = malloc(self.length * sizeof(double));
        vDSP_vabsD(self.values, 1, absoluteValues, 1, self.length);
        _absoluteVector = [MCVector vectorWithValues:absoluteValues
                                              length:self.length
                                        vectorFormat:self.vectorFormat];
    }
    return _absoluteVector;
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
    
    vectorCopy->_l1Norm = _l1Norm;
    vectorCopy->_l2Norm = _l2Norm;
    vectorCopy->_l3Norm = _l3Norm;
    vectorCopy->_infinityNorm = _infinityNorm;
    vectorCopy->_minimumValue = _minimumValue;
    vectorCopy->_maximumValue = _maximumValue;
    vectorCopy->_minimumValueIndex = _minimumValueIndex;
    vectorCopy->_maximumValueIndex = _maximumValueIndex;
    vectorCopy->_absoluteVector = _absoluteVector;
    
    return vectorCopy;
}

#pragma mark - Inspection

- (double)valueAtIndex:(int)index
{
    return self.values[index];
}

#pragma mark - Subscripting

- (NSNumber *)objectAtIndexedSubscript:(NSUInteger)idx
{
    return @(self.values[idx]);
}

#pragma mark - Class Operations

+ (MCVector *)productOfVector:(MCVector *)vector scalar:(double)scalar
{
    double *newValues = malloc(vector.length * sizeof(double));
    for (int i = 0; i < vector.length; i++) {
        newValues[i] = scalar * vector.values[i];
    }
    return [MCVector vectorWithValues:newValues length:vector.length vectorFormat:vector.vectorFormat];
}

+ (MCVector *)sumOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB
{
    if (vectorA.length != vectorB.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double *sum = malloc(vectorA.length * sizeof(double));
    vDSP_vaddD(vectorA.values, 1, vectorB.values, 1, sum, 1, vectorA.length);
    
    return [MCVector vectorWithValues:sum length:vectorA.length];
}

+ (MCVector *)differenceOfVectorMinuend:(MCVector *)vectorMinuend vectorSubtrahend:(MCVector *)vectorSubtrahend
{
    if (vectorMinuend.length != vectorSubtrahend.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double *diff = malloc(vectorMinuend.length * sizeof(double));
    vDSP_vsubD(vectorSubtrahend.values, 1, vectorMinuend.values, 1, diff, 1, vectorMinuend.length);
    
    return [MCVector vectorWithValues:diff length:vectorMinuend.length];
}

+ (MCVector *)productOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB
{
    if (vectorA.length != vectorB.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double *product = malloc(vectorA.length * sizeof(double));
    vDSP_vmulD(vectorA.values, 1, vectorB.values, 1, product, 1, vectorA.length);
    
    return [MCVector vectorWithValues:product length:vectorA.length];
}

+ (MCVector *)quotientOfVectorDividend:(MCVector *)vectorDividend vectorDivisor:(MCVector *)vectorDivisor
{
    if (vectorDividend.length != vectorDivisor.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double *quotient = malloc(vectorDividend.length * sizeof(double));
    vDSP_vdivD(vectorDivisor.values, 1, vectorDividend.values, 1, quotient, 1, vectorDividend.length);
    
    return [MCVector vectorWithValues:quotient length:vectorDividend.length];
}

+ (double)dotProductOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB
{
    if (vectorA.length != vectorB.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double dotProduct;
    vDSP_dotprD(vectorA.values, 1,vectorB.values, 1, &dotProduct, vectorA.length);
    
    return dotProduct;
}

+ (MCVector *)crossProductOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB
{
    if (!(vectorA.length == 3 && vectorB.length == 3)) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vectors must both be of length 3 to perform cross products" userInfo:nil];
    }
    
    double *values = malloc(vectorA.length * sizeof(double));
    values[0] = [vectorA valueAtIndex:1] * [vectorB valueAtIndex:2] - [vectorA valueAtIndex:2] * [vectorB valueAtIndex:1];
    values[1] = [vectorA valueAtIndex:2] * [vectorB valueAtIndex:0] - [vectorA valueAtIndex:0] * [vectorB valueAtIndex:2];
    values[2] = [vectorA valueAtIndex:0] * [vectorB valueAtIndex:1] - [vectorA valueAtIndex:1] * [vectorB valueAtIndex:0];
    
    return [MCVector vectorWithValues:values length:vectorA.length];
}

+ (double)scalarTripleProductWithVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB vectorC:(MCVector *)vectorC
{
    MCVector *crossProduct = [MCVector crossProductOfVectorA:vectorA vectorB:vectorB];
    return [MCVector dotProductOfVectorA:crossProduct vectorB:vectorC];
}

+ (MCVector *)vectorTripleProductWithVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB vectorC:(MCVector *)vectorC
{
    MCVector *crossProduct = [MCVector crossProductOfVectorA:vectorB vectorB:vectorC];
    return [MCVector crossProductOfVectorA:vectorA vectorB:crossProduct];
}

+ (MCVector *)vectorByRaisingVector:(MCVector *)vector power:(NSUInteger)power
{
    double *powerValues = malloc(vector.length * sizeof(double));
    for (int i = 0; i < vector.length; i++) {
        powerValues[i] = pow([vector valueAtIndex:i], power);
    }
    return [MCVector vectorWithValues:powerValues
                               length:vector.length
                         vectorFormat:vector.vectorFormat];
}

@end

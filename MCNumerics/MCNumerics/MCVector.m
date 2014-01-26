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

@property (assign, nonatomic) double *values;

@end

@implementation MCVector

#pragma mark - Constructors

- (void)commonInitWithValues:(double *)values
{
    self.values = values;
    self.length = sizeof(values) / sizeof(double);
}

- (id)initWithValues:(double *)values
{
    self = [super init];
    if (self) {
        [self commonInitWithValues:values];
        self.vectorFormat = MCVectorFormatColumnVector;
    }
    return self;
}

- (id)initWithValues:(double *)values inVectorFormat:(MCVectorFormat)vectorFormat
{
    self = [super init];
    if (self) {
        [self commonInitWithValues:values];
        self.vectorFormat = vectorFormat;
    }
    return self;
}

+ (MCVector *)vectorWithValues:(double *)values
{
    return [[MCVector alloc] initWithValues:values];
}

+ (MCVector *)vectorWithValues:(double *)values inVectorFormat:(MCVectorFormat)vectorFormat
{
    return [[MCVector alloc] initWithValues:values inVectorFormat:vectorFormat];
}

#pragma mark - NSObject overrides

- (BOOL)isEqualToVector:(MCVector *)otherVector
{
    BOOL __block equal = self == otherVector.self;
    
    if (equal) {
        return equal;
    } else {
        equal = YES;
        for (int i = 0; i < self.length; i++) {
            if (self.valuesCArray[i] != [otherVector valueAtIndex:i]) {
                equal = NO;
                break;
            }
        }
        return equal;
    }
}

- (NSUInteger)hash
{
    return self.values.hash;
}

#pragma mark - Inspection

{
}

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

#pragma mark - Operations

+ (MCVector *)sumOfVectorA:(MCVector *)a andVectorB:(MCVector *)b
{
    if (a.length != b.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double *sum = malloc(a.length * sizeof(double));
    vDSP_vaddD(a.valuesCArray, 1, b.valuesCArray, 1, sum, 1, a.length);
    
    NSMutableArray *values = [NSMutableArray array];
    for (int i = 0; i < a.length; i++) {
        [values addObject:@(sum[i])];
    }
    
    return [MCVector vectorWithValues:values];
}

+ (MCVector *)differenceOfVectorA:(MCVector *)a andVectorB:(MCVector *)b
{
    if (a.length != b.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double *diff = malloc(a.length * sizeof(double));
    vDSP_vsubD(b.valuesCArray, 1, a.valuesCArray, 1, diff, 1, a.length);
    
    NSMutableArray *values = [NSMutableArray array];
    for (int i = 0; i < a.length; i++) {
        [values addObject:@(diff[i])];
    }
    
    return [MCVector vectorWithValues:values];
}

+ (MCVector *)productOfVectorA:(MCVector *)a andVectorB:(MCVector *)b
{
    if (a.length != b.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double *product = malloc(a.length * sizeof(double));
    vDSP_vmulD(a.values, 1, b.values, 1, product, 1, a.length);
    
    NSMutableArray *values = [NSMutableArray array];
    for (int i = 0; i < a.length; i++) {
        [values addObject:@(product[i])];
    }
    
    return [MCVector vectorWithValues:values];
}

+ (MCVector *)quotientOfVectorA:(MCVector *)a andVectorB:(MCVector *)b
{
    if (a.length != b.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double *quotient = malloc(a.length * sizeof(double));
    vDSP_vdivD(b.valuesCArray, 1, a.valuesCArray, 1, quotient, 1, a.length);
    
    NSMutableArray *values = [NSMutableArray array];
    for (int i = 0; i < a.length; i++) {
        [values addObject:@(quotient[i])];
    }
    
    return [MCVector vectorWithValues:values];
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

@end

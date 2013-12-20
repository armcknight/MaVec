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

@property (strong, nonatomic) NSArray *values;
@property (assign, nonatomic) double *valuesCArray;
@property (assign, nonatomic) NSUInteger length;

@end

@implementation MCVector

#pragma mark - Constructors

- (id)initWithValues:(NSArray *)values
{
    self = [super init];
    if (self) {
        self.values = values;
        self.valuesCArray = malloc(values.count * sizeof(double));
        self.length = values.count;
        [values enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
            self.valuesCArray[idx] = value.doubleValue;
        }];
    }
    return self;
}

+ (MCVector *)vectorWithValues:(NSArray *)values
{
    return [[MCVector alloc] initWithValues:values];
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

- (NSUInteger)length
{
    return self.values.count;
}

- (double)valueAtIndex:(NSUInteger)index
{
    return self.valuesCArray[index];
}

- (double)maximumValue
{
    double max = DBL_MIN;
    for (int i = 0; i < self.length; i++) {
        if (self.valuesCArray[i] > max) {
            max = self.valuesCArray[i];
        }
    }
    return max;
}

- (double)minimumValue
{
    double min = DBL_MAX;
    for (int i = 0; i < self.length; i++) {
        if (self.valuesCArray[i] < min) {
            min = self.valuesCArray[i];
        }
    }
    return min;
}

- (NSUInteger)indexOfMaximumValue
{
    double max = DBL_MIN;
    NSUInteger idx = -1;
    for (int i = 0; i < self.length; i++) {
        if (self.valuesCArray[i] > max) {
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
        if (self.valuesCArray[i] < min) {
            idx = i;
        }
    }
    return min;
}

#pragma mark - Operations

+ (double)dotProductOfVectorA:(MCVector *)a andVectorB:(MCVector *)b
{
    if (a.length != b.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Vector dimensions do not match" userInfo:nil];
    }
    
    double dotProduct;
    vDSP_dotprD(a.valuesCArray, 1, b.valuesCArray, 1, &dotProduct, a.length);
    
    return dotProduct;
}

@end

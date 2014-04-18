//
//  MCValue.m
//  MCNumerics
//
//  Created by andrew mcknight on 4/12/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import "MCRealNumber.h"

@interface MCRealNumber ()

@property (assign, nonatomic, readwrite) MCValuePrecision precision;
@property (strong, nonatomic, readwrite) NSNumber *realValue;

@end

@implementation MCRealNumber

- (instancetype)initWithValue:(NSNumber *)value precision:(MCValuePrecision)precision
{
    self = [super init];
    if (self != nil) {
        _precision = precision;
        _realValue = value;
    }
    return self;
}

+ (instancetype)realNumberWithValue:(NSNumber *)value precision:(MCValuePrecision)precision
{
    return [[self alloc] initWithValue:value precision:precision];
}

@end

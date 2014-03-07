//
//  MCPair.m
//  MCNumerics
//
//  Created by andrew mcknight on 2/15/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import "MCPair.h"

@implementation MCPair

- (instancetype)initWithFirst:(NSNumber *)first second:(NSNumber *)second
{
    self = [super init];
    if (self) {
        _first = first;
        _second = second;
    }
    return self;
}

+ (instancetype)pairWithFirst:(NSNumber *)first second:(NSNumber *)second
{
    return [[MCPair alloc] initWithFirst:first second:second];
}

@end

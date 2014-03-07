//
//  MCTribool.m
//  MCNumerics
//
//  Created by andrew mcknight on 1/4/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import "MCTribool.h"

@interface MCTribool ()

@end

@implementation MCTribool

@synthesize triboolValue = _triboolValue;

#pragma mark - Init

- (id)initWithTriboolValue:(MCTriboolValue)triboolValue
{
    self = [super init];
    if (self) {
        _triboolValue = triboolValue;
    }
    return self;
}

+ (MCTribool *)triboolWithValue:(MCTriboolValue)triboolValue
{
    return [[MCTribool alloc] initWithTriboolValue:triboolValue];
}

#pragma mark - Inspection

- (BOOL)isYes
{
    return _triboolValue == MCTriboolIndeterminate ? NO : _triboolValue == MCTriboolYes ? YES : NO;
}

#pragma mark - Logical operations

- (MCTribool *)andTribool:(MCTribool *)tribool
{
    // TODO: implement based on triboolean logic
    return nil;
}

- (MCTribool *)orTribool:(MCTribool *)tribool
{
    // TODO: implement based on triboolean logic
    return nil;
}

- (MCTribool *)negate
{
    // TODO: implement
    return nil;
}

- (MCTribool *)kleeneImplication:(MCTribool *)tribool
{
    // TODO: implement
    return nil;
}

- (MCTribool *)lukasiewiczImplication:(MCTribool *)tribool
{
    // TODO: implement
    return nil;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MCTribool *triboolCopy = [[self class] allocWithZone:zone];
    
    triboolCopy->_triboolValue = _triboolValue;
    
    return triboolCopy;
}

@end

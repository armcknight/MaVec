//
//  MCTribool.m
//  MCNumerics
//
//  Created by andrew mcknight on 1/4/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import "MCTribool.h"

@interface MCTribool ()

@property (nonatomic, assign) BOOL isIndeterminate;
@property (nonatomic, assign) BOOL boolValue;

@end

@implementation MCTribool

#pragma mark - Init

- (id)initWithTriboolValue:(MCTriboolValue)triboolValue
{
    self = [super init];
    if (self) {
        switch (triboolValue) {
            default: case MCTriboolIndeterminate:
                _isIndeterminate = YES;
                break;
            case MCTriboolNo:
                _isIndeterminate = NO;
                _boolValue = NO;
                break;
            case MCTriboolYes:
                _isIndeterminate = NO;
                _boolValue = YES;
                break;
        }
    }
    return self;
}

+ (MCTribool *)triboolWithValue:(MCTriboolValue)triboolValue
{
    return [[MCTribool alloc] initWithTriboolValue:triboolValue];
}

#pragma mark - Inspection

- (MCTriboolValue)triboolValue
{
    if (self.isIndeterminate) {
        return MCTriboolIndeterminate;
    } else if (self.boolValue) {
        return MCTriboolYes;
    } else {
        return MCTriboolNo;
    }
}

- (BOOL)isIndeterminate
{
    return self.isIndeterminate;
}

- (BOOL)isYes
{
    return self.isIndeterminate ? NO : self.isYes;
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

- (MCTribool *)notTribool:(MCTribool *)tribool
{
    // TODO: implement based on triboolean logic
    return nil;
}

- (MCTribool *)nandTribool:(MCTribool *)tribool
{
    // TODO: implement based on triboolean logic
    return nil;
}

- (MCTribool *)norTribool:(MCTribool *)tribool
{
    // TODO: implement based on triboolean logic
    return nil;
}

- (MCTribool *)xorTribool:(MCTribool *)tribool
{
    // TODO: implement based on triboolean logic
    return nil;
}


@end

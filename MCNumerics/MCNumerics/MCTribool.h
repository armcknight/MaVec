//
//  MCTribool.h
//  MCNumerics
//
//  Created by andrew mcknight on 1/4/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MCTriboolValueNo = 0,
    MCTriboolValueYes,
    MCTriboolValueUnknown
} MCTriboolValue;

@interface MCTribool : NSValue <NSCopying>

@property (nonatomic, readonly, assign) MCTriboolValue triboolValue;

#pragma mark - Init

- (id)initWithTriboolValue:(MCTriboolValue)triboolValue;
+ (MCTribool *)triboolWithValue:(MCTriboolValue)triboolValue;

#pragma mark - Inspection

- (BOOL)isYes;

#pragma mark - Logical operations

- (MCTribool *)andTribool:(MCTribool *)tribool;
- (MCTribool *)orTribool:(MCTribool *)tribool;
- (MCTribool *)negate;
- (MCTribool *)kleeneImplication:(MCTribool *)tribool;
- (MCTribool *)lukasiewiczImplication:(MCTribool *)tribool;

@end

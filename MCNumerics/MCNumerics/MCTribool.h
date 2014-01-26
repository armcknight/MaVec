//
//  MCTribool.h
//  MCNumerics
//
//  Created by andrew mcknight on 1/4/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MCTriboolNo = 0,
    MCTriboolYes,
    MCTriboolIndeterminate
} MCTriboolValue;

@interface MCTribool : NSValue

#pragma mark - Init

- (id)initWithTriboolValue:(MCTriboolValue)triboolValue;
+ (MCTribool *)numberWithTriboolValue:(MCTriboolValue)triboolValue;

#pragma mark - Inspection

- (MCTriboolValue)triboolValue;
- (BOOL)isYes;
- (BOOL)isIndeterminate;

#pragma mark - Logical operations

- (MCTribool *)andTribool:(MCTribool *)tribool;
- (MCTribool *)orTribool:(MCTribool *)tribool;
- (MCTribool *)notTribool:(MCTribool *)tribool;
- (MCTribool *)nandTribool:(MCTribool *)tribool;
- (MCTribool *)norTribool:(MCTribool *)tribool;
- (MCTribool *)xorTribool:(MCTribool *)tribool;

@end

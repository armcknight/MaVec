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

/**
 @brief Construct an MCTribool object with specified ternary logic value.
 @param triboolValue The ternary logic value the MCTribool object should represent.
 @return A new MCTribool object representing the specified ternary logic value.
 */
- (instancetype)initWithTriboolValue:(MCTriboolValue)triboolValue;

/**
 @brief Convenience class method for initWithTriboolValue:
 @param triboolValue The ternary logic value the MCTribool object should represent.
 @return A new MCTribool object representing the specified ternary logic value.
 */
+ (instancetype)triboolWithValue:(MCTriboolValue)triboolValue;

#pragma mark - Inspection

/**
 @brief Method to determine if the underlying value evaluates to "yes" or "true".
 @return YES if underlying value is MCTriboolValueYes, or NO if value is MCTriboolValueNo or MCTriboolValueUnknown.
 */
- (BOOL)isYes;

/**
 @brief Method to determine if the underlying value evaluates to "no" or "false".
 @return YES if underlying value is MCTriboolValueNo, or NO if value is MCTriboolValueYes or MCTriboolValueUnknown.
 */
- (BOOL)isNo;

/**
 @brief Method to determine if the underlying value evaluates to "unknown".
 @return YES if underlying value is either MCTriboolValueYes or MCTriboolValueNo; NO if value is MCTriboolValueUnknown.
 */
- (BOOL)isKnown;

#pragma mark - Logical operations

- (MCTribool *)andTribool:(MCTribool *)tribool;
- (MCTribool *)orTribool:(MCTribool *)tribool;
- (MCTribool *)negate;
- (MCTribool *)kleeneImplication:(MCTribool *)tribool;
- (MCTribool *)lukasiewiczImplication:(MCTribool *)tribool;

@end

//
//  MCTribool.h
//  MCNumerics
//
//  Created by andrew mcknight on 1/4/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : SInt8 {
    /**
     @brief The ternary logical value for "no" or "false", defined in balanced ternary logic as -1.
     */
    MCTriboolValueNo        = -1,
    
    /**
     @brief The ternary logical value for "unknown", "unknowable/undecidable", "irrelevant", or "both", defined in balanced ternary logic as 0.
     */
    MCTriboolValueUnknown   = 0,
    
    /**
     @brief The ternary logical value for "yes" or "true", defined in balanced ternary logic as +1.
     */
    MCTriboolValueYes       = 1
}
/**
 @brief Constants specifying the numeric values of the three possible logical states. Based on assigned values from "balanced ternary logic": -1 for false, 0 for unknown, and +1 for true, or simply -, 0 and +.
 */
MCTriboolValue;

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

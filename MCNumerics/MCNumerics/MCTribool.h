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

/**
 @description The MCTribool class encapsulates the values and operations of ternary logic. See http://en.wikipedia.org/wiki/Three-valued_logic for an introduction. The truth table for the implemented logic functions follows:
 @code
                                   Kleene  Łukasiewicz
 | p q | ¬p | ¬q | p ∧ q | p v q | p → q | p → q |
 -------------------------------------------------
 | - - | +  | +  |   -   |   -   |   +   |   +   |
 | - 0 | +  | 0  |   -   |   0   |   +   |   +   |
 | - + | +  | -  |   -   |   +   |   +   |   +   |
 | 0 - | 0  | +  |   -   |   0   |   0   |   0   |
 | 0 0 | 0  | 0  |   0   |   0   |   0   |   +   |
 | 0 + | 0  | -  |   0   |   +   |   +   |   +   |
 | + - | -  | +  |   -   |   +   |   -   |   -   |
 | + 0 | -  | 0  |   0   |   +   |   0   |   0   |
 | + + | -  | -  |   +   |   +   |   +   |   +   |
 -------------------------------------------------
 */
@interface MCTribool : NSValue <NSCopying>

/**
 @property triboolValue
 @brief The underlying ternary logical value for this MCTribool object.
 */
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

#pragma mark - Instance operators

/**
 @brief Performs ternary logical AND with the supplied values (self ∧ tribool), yielding the results described in the following table:
 @param tribool The MCTribool object to perform the conjuction with.
 @return A new MCTribool object representing the result of the conjunction.
 @code
 ---------------
 | ∧ | + | 0 | - |
 ---------------
 | + | + | 0 | - |
 ---------------
 | 0 | 0 | 0 | - |
 ---------------
 | - | - | - | - |
 ---------------
 */
- (MCTribool *)andTribool:(MCTribool *)tribool;

/**
 @brief Performs ternary logical OR with the supplied values (self v tribool), yielding the results described in the following table:
 @param tribool The MCTribool object to perform the disjuction with.
 @return A new MCTribool object representing the result of the disjunction.
 @code
 ---------------
 | v | + | 0 | - |
 ---------------
 | + | + | + | + |
 ---------------
 | 0 | + | 0 | 0 |
 ---------------
 | - | + | 0 | - |
 ---------------
 */
- (MCTribool *)orTribool:(MCTribool *)tribool;

/**
 @brief Performs ternary logical NOT with the supplied values (¬self), yielding the results described in the following table:
 @return A new MCTribool object representing the result of the negation.
 @code
 -------
 | ¬ |   |
 -------
 | + | - |
 -------
 | 0 | 0 |
 -------
 | - | + |
 -------
 */
- (MCTribool *)negate;

/**
 @brief Performs ternary logical Kleene implication with the supplied values (self → tribool), yielding the results described in the following table:
 @param tribool The MCTribool object to perform the Kleene implication with.
 @return A new MCTribool object representing the result of the Kleene implication.
 @code
 -------------------
 | a → b | + | 0 | - |
 -------------------
 |     + | + | 0 | - |
 -------------------
 |     0 | + | 0 | 0 |
 -------------------
 |     - | + | + | + |
 -------------------
 */
- (MCTribool *)kleeneImplication:(MCTribool *)tribool;

/**
 @brief Performs ternary logical Łukasiewicz implication with the supplied values (self → tribool), yielding the results described in the following table:
 @param tribool The MCTribool object to perform the Łukasiewicz implication with.
 @return A new MCTribool object representing the result of the Łukasiewicz implication.
 @code
 -------------------
 | a → b | + | 0 | - |
 -------------------
 |     + | + | 0 | - |
 -------------------
 |     0 | + | + | 0 |
 -------------------
 |     - | + | + | + |
 -------------------
 */
- (MCTribool *)lukasiewiczImplication:(MCTribool *)tribool;

#pragma mark - Class operators

/**
 @brief Performs ternary logical AND with the supplied values (triboolValueA ∧ triboolValueB), yielding the results described in the following table:
 @param triboolValueA
 @param triboolValueB
 @return A MCTriboolValue enum constant representing the result of the conjunction.
 @code
  ---------------
 | ∧ | + | 0 | - |
  ---------------
 | + | + | 0 | - |
  ---------------
 | 0 | 0 | 0 | - |
  ---------------
 | - | - | - | - |
  ---------------
 */
+ (MCTriboolValue)conjunctionOfTriboolValueA:(MCTriboolValue)triboolValueA
                               triboolValueB:(MCTriboolValue)triboolValueB;

/**
 @brief Performs ternary logical OR with the supplied values (triboolValueA v triboolValueB), yielding the results described in the following table:
 @param triboolValueA
 @param triboolValueB
 @return A MCTriboolValue enum constant representing the result of the disjunction.
 @code
  ---------------
 | v | + | 0 | - |
  ---------------
 | + | + | + | + |
  ---------------
 | 0 | + | 0 | 0 |
  ---------------
 | - | + | 0 | - |
  ---------------
 */
+ (MCTriboolValue)disjunctionOfTriboolValueA:(MCTriboolValue)triboolValueA
                               triboolValueB:(MCTriboolValue)triboolValueB;

/**
 @brief Performs ternary logical NOT with the supplied values (¬triboolValue), yielding the results described in the following table:
 @param triboolValue
 @return A MCTriboolValue enum constant representing the result of the negation.
 @code
  -------
 | ¬ |   |
  -------
 | + | - |
  -------
 | 0 | 0 |
  -------
 | - | + |
  -------
 */
+ (MCTriboolValue)negationOfTriboolValue:(MCTriboolValue)triboolValue;

/**
 @brief Performs ternary logical Kleene implication with the supplied values (triboolValueA → triboolValueB), yielding the results described in the following table:
 @param triboolValueA
 @param triboolValueB
 @return A MCTriboolValue enum constant representing the result of the Kleene implication.
 @code
  -------------------
 | a → b | + | 0 | - |
  -------------------
 |     + | + | 0 | - |
  -------------------
 |     0 | + | 0 | 0 |
  -------------------
 |     - | + | + | + |
  -------------------
 */
+ (MCTriboolValue)kleeneImplicationOfTriboolValueA:(MCTriboolValue)triboolValueA
                                     triboolValueB:(MCTriboolValue)triboolValueB;

/**
 @brief Performs ternary logical Łukasiewicz implication with the supplied values (triboolValueA → triboolValueB), yielding the results described in the following table:
 @param triboolValueA
 @param triboolValueB
 @return A MCTriboolValue enum constant representing the result of the Łukasiewicz implication.
 @code
  -------------------
 | a → b | + | 0 | - |
  -------------------
 |     + | + | 0 | - |
  -------------------
 |     0 | + | + | 0 |
  -------------------
 |     - | + | + | + |
  -------------------
 */
+ (MCTriboolValue)lukasiewiczImplicationOfTriboolValueA:(MCTriboolValue)triboolValueA
                                          triboolValueB:(MCTriboolValue)triboolValueB;

@end

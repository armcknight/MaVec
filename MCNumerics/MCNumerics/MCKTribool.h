//
//  MCKTribool.h
//  MCKMath
//
//  Created by andrew mcknight on 1/4/14.
//
//  Copyright (c) 2014 Andrew Robert McKnight
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <Foundation/Foundation.h>

typedef enum : SInt8 {
    /**
     @brief The ternary logical value for "no" or "false", defined in balanced ternary logic as -1.
     */
    MCKTriboolValueNo        = -1,
    
    /**
     @brief The ternary logical value for "unknown", "unknowable/undecidable", "irrelevant", or "both", defined in balanced ternary logic as 0.
     */
    MCKTriboolValueUnknown   = 0,
    
    /**
     @brief The ternary logical value for "yes" or "true", defined in balanced ternary logic as +1.
     */
    MCKTriboolValueYes       = 1
}
/**
 @brief Constants specifying the numeric values of the three possible logical states. Based on assigned values from "balanced ternary logic": -1 for false, 0 for unknown, and +1 for true, or simply -, 0 and +.
 @note These constants must be represented as MCKTriboolValueNo = -1, MCKTriboolValueUnknown = 0 and MCKTriboolValueYes = 1 for the optimized ternary logical operations in conjunctionOfTriboolValueA:triboolValueB:, disjunctionOfTriboolValueA:triboolValueB:, negationOfTriboolValue:, kleeneImplicationOfTriboolValueA:triboolValueB: and lukasiewiczImplicationOfTriboolValueA:triboolValueB: to be computed correctly.
 */
MCKTriboolValue;

/**
 @description The MCKTribool class encapsulates the values and operations of ternary logic. See http://en.wikipedia.org/wiki/Three-valued_logic for an introduction. The truth table for the implemented logic functions follows:
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
@interface MCKTribool : NSValue <NSCopying>

/**
 @property triboolValue
 @brief The underlying ternary logical value for this MCKTribool object.
 */
@property (nonatomic, readonly, assign) MCKTriboolValue triboolValue;

#pragma mark - Init

/**
 @brief Construct an MCKTribool object with specified ternary logic value.
 @param triboolValue The ternary logic value the MCKTribool object should represent.
 @return A new MCKTribool object representing the specified ternary logic value.
 */
- (instancetype)initWithTriboolValue:(MCKTriboolValue)triboolValue;

/**
 @brief Convenience class method for initWithTriboolValue:
 @param triboolValue The ternary logic value the MCKTribool object should represent.
 @return A new MCKTribool object representing the specified ternary logic value.
 */
+ (instancetype)triboolWithValue:(MCKTriboolValue)triboolValue;

#pragma mark - Inspection

/**
 @brief Method to determine if the underlying value evaluates to "yes" or "true".
 @return YES if underlying value is MCKTriboolValueYes, or NO if value is MCKTriboolValueNo or MCKTriboolValueUnknown.
 */
- (BOOL)isYes;

/**
 @brief Method to determine if the underlying value evaluates to "no" or "false".
 @return YES if underlying value is MCKTriboolValueNo, or NO if value is MCKTriboolValueYes or MCKTriboolValueUnknown.
 */
- (BOOL)isNo;

/**
 @brief Method to determine if the underlying value evaluates to "unknown".
 @return YES if underlying value is either MCKTriboolValueYes or MCKTriboolValueNo; NO if value is MCKTriboolValueUnknown.
 */
- (BOOL)isKnown;

#pragma mark - Instance operators

/**
 @brief Performs ternary logical AND with the supplied values (self ∧ tribool), yielding the results described in the following table:
 @param tribool The MCKTribool object to perform the conjuction with.
 @return A new MCKTribool object representing the result of the conjunction.
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
- (MCKTribool *)andTribool:(MCKTribool *)tribool;

/**
 @brief Performs ternary logical OR with the supplied values (self v tribool), yielding the results described in the following table:
 @param tribool The MCKTribool object to perform the disjuction with.
 @return A new MCKTribool object representing the result of the disjunction.
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
- (MCKTribool *)orTribool:(MCKTribool *)tribool;

/**
 @brief Performs ternary logical NOT with the supplied values (¬self), yielding the results described in the following table:
 @return A new MCKTribool object representing the result of the negation.
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
- (MCKTribool *)negate;

/**
 @brief Performs ternary logical Kleene implication with the supplied values (self → tribool), yielding the results described in the following table:
 @param tribool The MCKTribool object to perform the Kleene implication with.
 @return A new MCKTribool object representing the result of the Kleene implication.
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
- (MCKTribool *)kleeneImplication:(MCKTribool *)tribool;

/**
 @brief Performs ternary logical Łukasiewicz implication with the supplied values (self → tribool), yielding the results described in the following table:
 @param tribool The MCKTribool object to perform the Łukasiewicz implication with.
 @return A new MCKTribool object representing the result of the Łukasiewicz implication.
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
- (MCKTribool *)lukasiewiczImplication:(MCKTribool *)tribool;

#pragma mark - Class operators

/**
 @brief Performs ternary logical AND with the supplied values (triboolValueA ∧ triboolValueB), yielding the results described in the following table:
 @param triboolValueA MCKTriboolValue enum constant for the left side of the conjunction.
 @param triboolValueB MCKTriboolValue enum constant for the right side of the conjunction.
 @return A MCKTriboolValue enum constant representing the result of the conjunction.
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
+ (MCKTriboolValue)conjunctionOfTriboolValueA:(MCKTriboolValue)triboolValueA
                               triboolValueB:(MCKTriboolValue)triboolValueB;

/**
 @brief Performs ternary logical OR with the supplied values (triboolValueA v triboolValueB), yielding the results described in the following table:
 @param triboolValueA MCKTriboolValue enum constant for the left side of the disjunction.
 @param triboolValueB MCKTriboolValue enum constant for the right side of the disjunction.
 @return A MCKTriboolValue enum constant representing the result of the disjunction.
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
+ (MCKTriboolValue)disjunctionOfTriboolValueA:(MCKTriboolValue)triboolValueA
                               triboolValueB:(MCKTriboolValue)triboolValueB;

/**
 @brief Performs ternary logical NOT with the supplied values (¬triboolValue), yielding the results described in the following table:
 @param triboolValue MCKTriboolValue enum constant to be negated.
 @return A MCKTriboolValue enum constant representing the result of the negation.
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
+ (MCKTriboolValue)negationOfTriboolValue:(MCKTriboolValue)triboolValue;

/**
 @brief Performs ternary logical Kleene implication with the supplied values (triboolValueA → triboolValueB), yielding the results described in the following table:
 @param triboolValueA MCKTriboolValue enum constant for the left side of the Kleene implication.
 @param triboolValueB MCKTriboolValue enum constant for the right side of the Kleene implication.
 @return A MCKTriboolValue enum constant representing the result of the Kleene implication.
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
+ (MCKTriboolValue)kleeneImplicationOfTriboolValueA:(MCKTriboolValue)triboolValueA
                                     triboolValueB:(MCKTriboolValue)triboolValueB;

/**
 @brief Performs ternary logical Łukasiewicz implication with the supplied values (triboolValueA → triboolValueB), yielding the results described in the following table:
 @param triboolValueA MCKTriboolValue enum constant for the left side of the Łukasiewicz implication.
 @param triboolValueB MCKTriboolValue enum constant for the right side of the Łukasiewicz implication.
 @return A MCKTriboolValue enum constant representing the result of the Łukasiewicz implication.
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
+ (MCKTriboolValue)lukasiewiczImplicationOfTriboolValueA:(MCKTriboolValue)triboolValueA
                                          triboolValueB:(MCKTriboolValue)triboolValueB;

@end

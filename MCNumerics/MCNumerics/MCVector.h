//
//  MCVector.h
//  MCNumerics
//
//  Created by andrew mcknight on 12/8/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : UInt8 {
    /**
     Specifies that the values in the vector form a row with each value in its own column.
     */
    MCVectorFormatRowVector,
    
    /**
     Specifies that the values in the vector form a column with each value in its own row.
     */
    MCVectorFormatColumnVector
}
/**
 Constants specifying whether the vector is a row- or column- vector.
 */
MCVectorFormat;

/**
 @class MCVector
 @description A class providing storage and operations for vectors of double precision floating-point numbers, where underlying details about the internal representation (e.g. row- or column- orientation are abstracted away).
 */
@interface MCVector : NSObject<NSCopying>

/**
 @property vectorFormat
 @brief Holds a constant value of type MCVectorFormat describing whether this is a row- or column- vector.
 */
@property (assign, readonly, nonatomic) MCVectorFormat vectorFormat;

/**
 @property length
 @brief The amount of values in this vector.
 */
@property (assign, readonly, nonatomic) int length;

/**
 @property values
 @brief An array containing the values as double precision floating-point numbers.
 */
@property (assign, readonly, nonatomic) double *values;

/**
 @property sumOfValues
 @brief The value obtained by adding together all values in the vector.
 */
@property (assign, readonly, nonatomic) double sumOfValues;

/**
 @property productOfValues
 @brief The value obtained by multiplying together all values in the vector.
 */
@property (assign, readonly, nonatomic) double productOfValues;

#pragma mark - Constructors

/**
 @brief Initializes a new MCVector with supplied values in the specified vector format.
 @param values The array of values to store in the vector.
 @param length The number of values being stored in the vector.
 @param vectorFormat The vector representation of the values, either MCVectorFormatRow or MCVectorFormatColumn.
 @return A new instance of MCVector representing the specified vector.
 */
- (instancetype)initWithValues:(double *)values length:(int)length vectorFormat:(MCVectorFormat)vectorFormat;

/**
 @brief Class convenience method to create a new MCVector with supplied values in column vector format.
 @param values The array of values to store in the vector.
 @param length The number of values being stored in the vector.
 @return A new instance of MCVector representing the specified vector.
 */
+ (instancetype)vectorWithValues:(double *)values length:(int)length;

/**
 @brief Class convenience method to create a new MCVector with supplied values in the specified vector format.
 @param values The array of values to store in the vector.
 @param length The number of values being stored in the vector.
 @param vectorFormat The vector representation of the values, either MCVectorFormatRow or MCVectorFormatColumn.
 @return A new instance of MCVector representing the specified vector.
 */
+ (instancetype)vectorWithValues:(double *)values length:(int)length vectorFormat:(MCVectorFormat)vectorFormat;

/**
 @brief Initializes a new MCVector with supplied values in the specified vector format.
 @param values The array of values to store in the vector passed as an NSArray.
 @param vectorFormat The vector representation of the values, either MCVectorFormatRow or MCVectorFormatColumn.
 @return A new instance of MCVector representing the specified vector.
 */
- (instancetype)initWithValuesInArray:(NSArray *)values vectorFormat:(MCVectorFormat)vectorFormat;

/**
 @brief Class convenience method to create a new MCVector with supplied values in column vector format.
 @param values The array of values to store in the vector passed as an NSArray.
 @return A new instance of MCVector representing the specified vector.
 */
+ (instancetype)vectorWithValuesInArray:(NSArray *)values;

/**
 @brief Class convenience method to create a new MCVector with supplied values in column vector format.
 @param values The array of values to store in the vector passed as an NSArray.
 @param vectorFormat The vector representation of the values, either MCVectorFormatRow or MCVectorFormatColumn.
 @return A new instance of MCVector representing the specified vector.
 */
+ (instancetype)vectorWithValuesInArray:(NSArray *)values vectorFormat:(MCVectorFormat)vectorFormat;

#pragma mark - NSObject overrides

/**
 @return YES is otherVector is either this instance of MCVector or is identical in length and contains identical values at all positions; NO otherwise.
 */
- (BOOL)isEqualToVector:(MCVector *)otherVector;

/**
 @return YES is otherVector is either this instance of MCVector or is identical in length and contains identical values at all positions; NO otherwise.
 */
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

/**
 @return An NSString representing a human-readable version of the vector, taking into account row or column format.
 */
- (NSString *)description;

#pragma mark - Inspection

/**
 @param index The index of the value to retrieve.
 @return The double-precision floating-point value at position index.
 */
- (double)valueAtIndex:(int)index;

/**
 @return The maximum value in the vector.
 */
- (double)maximumValue;

/**
 @return The minimum value in the vector.
 */
- (double)minimumValue;

/**
 @return The index of the maximum value in the vector.
 */
- (int)indexOfMaximumValue;

/**
 @return The index of the minimum value in the vector.
 */
- (int)indexOfMinimumValue;

#pragma mark - Subscripting

/**
 @brief Extract the value at a given index using overridden bracket operators.
 @param idx The index of the value to extract.
 @return The double-precision floating-point value at the specified index.
 */
- (NSNumber *)objectAtIndexedSubscript:(NSUInteger)idx;

#pragma mark - Class Operations

+ (MCVector *)productOfVector:(MCVector *)vector scalar:(double)scalar;
+ (MCVector *)sumOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB;
+ (MCVector *)differenceOfVectorMinuend:(MCVector *)vectorMinuend vectorSubtrahend:(MCVector *)vectorSubtrahend;
+ (MCVector *)productOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB;
+ (MCVector *)quotientOfVectorDividend:(MCVector *)vectorDividend vectorDivisor:(MCVector *)vectorDivisor;
+ (double)dotProductOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB;
+ (MCVector *)crossProductOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB;
+ (double)scalarTripleProductWithVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB vectorC:(MCVector *)vectorC;
+ (MCVector *)vectorTripleProductWithVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB vectorC:(MCVector *)vectorC;

@end

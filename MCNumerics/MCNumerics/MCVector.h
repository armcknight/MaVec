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

/**
 @brief Multiply a vector by a scalar. Effectively multiplies each element in the vector by the scalar and stores the products in a new vector.
 @param vector Vector to multiply by the scalar.
 @param scalar Value to multiply each element of the vector by.
 @return New instance of MCVector holding the result of the scalar multiplication with the same vector format as the provided vector.
 */
+ (MCVector *)productOfVector:(MCVector *)vector scalar:(double)scalar;

/**
 @brief Add two vectors together. Effectively adds elements in identical positions and stores the sums in a new vector.
 @param vectorA The first vector to be added.
 @param vectorB The second vector to be added.
 @return New instance of MCVector holding the result of the addition with the same vector format as the provided vectors, or MCVectorFormatRow if they are different.
 */
+ (MCVector *)sumOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB;

/**
 @brief Subtract the subtrahend vector from the minuend vector. Effectively subtracts elements in identical positions and stores the differences in a new vector.
 @param vectorMinuend The vector from which to subtract the subtrahend.
 @param vectorSubtrahend The vector to subtract from the minuend.
 @return New instance of MCVector holding the result of the subtraction with the same vector format as the provided vectors, or MCVectorFormatRow if they are different.
 */
+ (MCVector *)differenceOfVectorMinuend:(MCVector *)vectorMinuend vectorSubtrahend:(MCVector *)vectorSubtrahend;

/**
 @brief Multiply two vectors. Effectively multiplies elements in identical positions and stores the products in a new vector.
 @param vectorA The first vector to be multiplied.
 @param vectorB The first vector to be multiplied.
 @return New instance of MCVector holding the result of the multiplication with the same vector format as the provided vectors, or MCVectorFormatRow if they are different.
 */
+ (MCVector *)productOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB;

/**
 @brief Divide the dividend vector by the divisor vector. Effectively divides elements in identical positions and stores the quotients in a new vector.
 @param vectorDividend The vector to be divided by the divisor.
 @param vectorDivisor The vector to divide into the dividend.
 @return New instance of MCVector holding the result of the division with the same vector format as the provided vectors, or MCVectorFormatRow if they are different.
 */
+ (MCVector *)quotientOfVectorDividend:(MCVector *)vectorDividend vectorDivisor:(MCVector *)vectorDivisor;

/**
 @brief Compute the dot product of two vectors. Effectively sums the products of elements in identical positions in the vectors.
 @param vectorA The first vector of the dot product.
 @param vectorB The second vector of the dot product.
 @return A scalar value representing the dot product of the vectors.
 */
+ (double)dotProductOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB;

/**
 @brief Compute the cross product of the vectors, which is orthogonal to both input vectors. Currently only computes the cross product of two 3-dimensional vectors.
 @param vectorA The first vector of the cross product.
 @param vectorB The second vector of the cross product.
 @return A new instance representing the cross product of the two vectors in column format.
 */
+ (MCVector *)crossProductOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB;

/**
 @brief Computes the dot product of the last vector and the cross product of the first two vectors, representing the signed volumn of the parallelepiped defined by the three vectors. ( (A x B) • C )
 @param vectorA The vector on the left side of the cross product.
 @param vectorB The vector on the left side of the cross product.
 @param vectorC The vector on the right side of the dot product.
 @return A scalar value containing the value of the dot product between the third vector and the cross product of the first two vectors.
 */
+ (double)scalarTripleProductWithVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB vectorC:(MCVector *)vectorC;

/**
 @brief Computes the cross product of the first vector and the cross product of the remaining two vectors. ( A x (B x C) )
 @param vectorA The vector on the left side of the second cross product.
 @param vectorB The vector on the left side of the first cross product.
 @param vectorC The vector on the right side of the first cross product.
 @return A new instance of MCVector holding the result of the nested cross products.
 */
+ (MCVector *)vectorTripleProductWithVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB vectorC:(MCVector *)vectorC;

@end

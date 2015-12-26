//
//  MAVVector.h
//  MaVec
//
//  Created by andrew mcknight on 12/8/13.
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
#import <MCKNumerics/MCKNumerics.h>

#import "MAVTypedefs.h"

@class MCKTribool;

typedef enum : UInt8 {
    /**
     Specifies that the values in the vector form a row with each value in its own column.
     */
    MAVVectorFormatRowVector,
    
    /**
     Specifies that the values in the vector form a column with each value in its own row.
     */
    MAVVectorFormatColumnVector
}
/**
 Constants specifying whether the vector is a row- or column- vector.
 */
MAVVectorFormat;

/**
 @class MAVVector
 @description A class providing storage and operations for vectors of double precision floating-point numbers, where underlying details about the internal representation (e.g. row- or column- orientation are abstracted away).
 */
@interface MAVVector : NSObject<NSCopying, NSMutableCopying>

/**
 @property vectorFormat
 @brief Holds a constant value of type MAVVectorFormat describing whether this is a row- or column- vector.
 */
@property (assign, readonly, nonatomic) MAVVectorFormat vectorFormat;

/**
 @property length
 @brief The amount of values in this vector.
 */
@property (assign, readonly, nonatomic) int length;

/**
 @property values
 @brief An array containing the values as double precision floating-point numbers.
 */
@property (strong, readonly, nonatomic) NSData *values;

/**
 @property sumOfValues
 @brief The value obtained by adding together all values in the vector. (Lazy-loaded)
 */
@property (strong, readonly, nonatomic) NSNumber *sumOfValues;

/**
 @property productOfValues
 @brief The value obtained by multiplying together all values in the vector. (Lazy-loaded)
 */
@property (strong, readonly, nonatomic) NSNumber *productOfValues;

/**
 @property l1Norm
 @brief The L1 norm of a vector is the sum of the absolute values of it's values: |x|_1 = ∑_i(|x_i|) (Lazy-loaded)
 */
@property (strong, readonly, nonatomic) NSNumber *l1Norm;

/**
 @property l2Norm
 @brief The L2 norm of a vector is the square root of the sum of the squares of the absolute values of it's values: |x|_2 = √( ∑_i(|x_i|^2) ) (Lazy-loaded)
 */
@property (strong, readonly, nonatomic) NSNumber *l2Norm;

/**
 @property l3Norm
 @brief The L3 norm of a vector is the cube root of the sum of the cubes of the absolute values of it's values: |x|_1 = ( ∑_i(|x_i|^3) )^(1/3) (Lazy-loaded)
 */
@property (strong, readonly, nonatomic) NSNumber *l3Norm;

/**
 @property infinityNorm
 @brief The L∞ norm of a vector is the maximum absolute value of it's values: |x|_∞ = max_i( |x_i| ) (Lazy-loaded)
 */
@property (strong, readonly, nonatomic) NSNumber *infinityNorm;

/**
 @property maximumValue
 @brief The maximum value in the vector. (Lazy-loaded)
 */
@property (strong, readonly, nonatomic) NSNumber *maximumValue;

/**
 @property minimumValue
 @brief The minimum value in the vector. (Lazy-loaded)
 */
@property (strong, readonly, nonatomic) NSNumber *minimumValue;

/**
 @property maximumValueIndex
 @brief The index of the maximum value in the vector. (Lazy-loaded)
 */
@property (assign, readonly, nonatomic) int maximumValueIndex;

/**
 @property minimumValueIndex
 @brief The index of the minimum value in the vector. (Lazy-loaded)
 */
@property (assign, readonly, nonatomic) int minimumValueIndex;

/**
 @property absoluteVector
 @brief A vector whose values are the absolute values of the values in this vector, with the same vector format.  (Lazy-loaded)
 */
@property (strong, readonly, nonatomic) MAVVector *absoluteVector;

/**
 @property precision
 @brief The precision of the numeric values in the vector, either single- or double-precision floating point.
 */
@property (assign, readonly, nonatomic) MCKPrecision precision;

/**
 *  @property isIdentity
 *  @brief MCKTriboolValueYes if all values are 1, MCKTriboolValueNo otherwise. Defaults to MCKTriboolValueUnknown. (Lazy-loaded)
 */
@property (strong, readonly, nonatomic) MCKTribool *isIdentity;

/**
 *  @property isZero
 *  @brief MCKTriboolValueYes if all values are 0, MCKTriboolValueNo otherwise. Defaults to MCKTriboolValueUnknown. (Lazy-loaded)
 */
@property (strong, readonly, nonatomic) MCKTribool *isZero;

#pragma mark - Constructors

/**
 @brief Initializes a new MAVVector with supplied values in the specified vector format.
 @param values The array of values to store in the vector.
 @param length The number of values being stored in the vector.
 @param vectorFormat The vector representation of the values, either MAVVectorFormatRow or MAVVectorFormatColumn.
 @return A new instance of MAVVector representing the specified vector.
 */
- (instancetype)initWithValues:(NSData *)values length:(int)length vectorFormat:(MAVVectorFormat)vectorFormat;

/**
 @brief Class convenience method to create a new MAVVector with supplied values in column vector format.
 @param values The array of values to store in the vector.
 @param length The number of values being stored in the vector.
 @return A new instance of MAVVector representing the specified vector.
 */
+ (instancetype)vectorWithValues:(NSData *)values length:(int)length;

/**
 @brief Class convenience method to create a new MAVVector with supplied values in the specified vector format.
 @param values The array of values to store in the vector.
 @param length The number of values being stored in the vector.
 @param vectorFormat The vector representation of the values, either MAVVectorFormatRow or MAVVectorFormatColumn.
 @return A new instance of MAVVector representing the specified vector.
 */
+ (instancetype)vectorWithValues:(NSData *)values length:(int)length vectorFormat:(MAVVectorFormat)vectorFormat;

/**
 @brief Initializes a new MAVVector with supplied values in the specified vector format.
 @param values The array of values to store in the vector passed as an NSArray.
 @param vectorFormat The vector representation of the values, either MAVVectorFormatRow or MAVVectorFormatColumn.
 @return A new instance of MAVVector representing the specified vector.
 */
- (instancetype)initWithValuesInArray:(NSArray *)values vectorFormat:(MAVVectorFormat)vectorFormat;

/**
 @brief Class convenience method to create a new MAVVector with supplied values in column vector format.
 @param values The array of values to store in the vector passed as an NSArray.
 @return A new instance of MAVVector representing the specified vector.
 */
+ (instancetype)vectorWithValuesInArray:(NSArray *)values;

/**
 @brief Class convenience method to create a new MAVVector with supplied values in column vector format.
 @param values The array of values to store in the vector passed as an NSArray.
 @param vectorFormat The vector representation of the values, either MAVVectorFormatRow or MAVVectorFormatColumn.
 @return A new instance of MAVVector representing the specified vector.
 */
+ (instancetype)vectorWithValuesInArray:(NSArray *)values vectorFormat:(MAVVectorFormat)vectorFormat;

/**
 @brief Generate a vector containing random single- or double-precision floating point values.
 @param length The amount of random values to generate for the matrix.
 @param vectorFormat The format of the vector to generate, either column or row.
 @param precision The precision of the random values to generate, either single- or double- precision.
 @return A new MAVVector containing the amount of random values of specified precision.
 */
+ (instancetype)randomVectorOfLength:(int)length
                        vectorFormat:(MAVVectorFormat)vectorFormat
                           precision:(MCKPrecision)precision;

/**
 @brief Create a vector of specified length and vector format, whose values are all equal to the specified value.
 @param value The value to set each element of the vector to.
 @param length The amount of values to be in the array.
 @param vectorFormat Format of the vector, either row or column.
 @return A new MAVVector with specified length and vector format containing the specified value at each element.
 */
+ (instancetype)vectorFilledWithValue:(NSNumber *)value
                               length:(int)length
                         vectorFormat:(MAVVectorFormat)vectorFormat;

#pragma mark - NSObject overrides

/**
 @return YES is otherVector is either this instance of MAVVector or is identical in length and contains identical values at all positions; NO otherwise.
 */
- (BOOL)isEqualToVector:(MAVVector *)otherVector;

/**
 @return YES is otherVector is either this instance of MAVVector or is identical in length and contains identical values at all positions; NO otherwise.
 */
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

/**
 @return An NSString representing a human-readable version of the vector, taking into account row or column format.
 */
- (NSString *)description;

- (id)debugQuickLookObject;

#pragma mark - Inspection

/**
 @param index The index of the value to retrieve.
 @return The double-precision floating-point value at position index.
 */
- (NSNumber *)valueAtIndex:(MAVIndex)index;

#pragma mark - Subscripting

/**
 @brief Extract the value at a given index using overridden bracket operators.
 @param idx The index of the value to extract.
 @return The double-precision floating-point value at the specified index.
 */
- (NSNumber *)objectAtIndexedSubscript:(MAVIndex)idx;

#pragma mark - Instance Operations

/**
 @brief Compute the dot product of two vectors. Effectively sums the products of elements in identical positions in the vectors.
 @param vectorA The first vector of the dot product.
 @param vectorB The second vector of the dot product.
 @return A scalar value representing the dot product of the vectors.
 */
- (NSNumber *)dotProductWithVector:(MAVVector *)vector;

/**
 @brief Compute the cross product of the vectors, which is orthogonal to both input vectors. Currently only computes the cross product of two 3-dimensional vectors.
 @param vectorA The first vector of the cross product.
 @param vectorB The second vector of the cross product.
 @return A new instance representing the cross product of the two vectors in column format.
 */
- (MAVVector *)crossProductWithVector:(MAVVector *)vector;

#pragma mark - Class Operations

/**
 @brief Computes the dot product of the last vector and the cross product of the first two vectors, representing the signed volumn of the parallelepiped defined by the three vectors. ( (A x B) • C )
 @param vectorA The vector on the left side of the cross product.
 @param vectorB The vector on the left side of the cross product.
 @param vectorC The vector on the right side of the dot product.
 @return A scalar value containing the value of the dot product between the third vector and the cross product of the first two vectors.
 */
+ (NSNumber *)scalarTripleProductWithVectorA:(MAVVector *)vectorA vectorB:(MAVVector *)vectorB vectorC:(MAVVector *)vectorC;

/**
 @brief Computes the cross product of the first vector and the cross product of the remaining two vectors. ( A x (B x C) )
 @param vectorA The vector on the left side of the second cross product.
 @param vectorB The vector on the left side of the first cross product.
 @param vectorC The vector on the right side of the first cross product.
 @return A new instance of MAVVector holding the result of the nested cross products.
 */
+ (MAVVector *)vectorTripleProductWithVectorA:(MAVVector *)vectorA vectorB:(MAVVector *)vectorB vectorC:(MAVVector *)vectorC;

@end

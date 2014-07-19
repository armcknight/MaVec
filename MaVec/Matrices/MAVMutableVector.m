//
//  MAVMutableVector.m
//  MaVec
//
//  Created by Andrew McKnight on 6/1/14.
//  Copyright (c) 2014 AMProductions. All rights reserved.
//

#import <Accelerate/Accelerate.h>

#import "MAVVector-Protected.h"
#import "MAVMutableVector.h"

#import "NSNumber+MCKPrecision.h"

typedef enum {
    /**
     *  Enum constant representing mutation of a value at a particular index.
     */
    MAVVectorMutatingOperationTypeAssignment,
    
    /**
     *  Enum constant representing addition with another vector.
     */
    MAVVectorMutatingOperationTypeAddition,
    
    /**
     *  Enum constant representing subtraction of another vector.
     */
    MAVVectorMutatingOperationTypeSubtraction,
    
    /**
     *  Enum constant representing multiplication by a scalar value.
     */
    MAVVectorMutatingOperationTypeMultiplicationScalar,
    
    /**
     *  Enum constant representing multiplication by another vector.
     */
    MAVVectorMutatingOperationTypeMultiplicationVector,
    
    /**
     *  Enum constant representing division by another vector.
     */
    MAVVectorMutatingOperationTypeDivision,
    
    /**
     *  Enum constant representing raising a vector to an exponent.
     */
    MAVVectorMutatingOperationTypePower
}

/**
 *  Enum representing the supported mutating operations.
 */
MAVVectorMutatingOperationType;

@interface MAVMutableVector ()

@property (strong, nonatomic, readwrite) NSMutableData *values;

/**
 *  Reset the calculated state data of this vector if a mutable operation invalidates it.
 *
 *  @param operation The mutating operation being performed on this vector.
 *  @param input     The input to the mutating operation.
 *  @param index     The index being mutated, if operation is element-wise.
 */
- (void)resetToDefaultIfOperation:(MAVVectorMutatingOperationType)operation notIdempotentWithInput:(id)input atIndex:(int)index;

@end

@implementation MAVMutableVector

- (void)setValue:(NSNumber *)value atIndex:(int)index
{
    NSAssert(index >= 0 && index < self.length, @"index = %lu out of the range of values in the vector (%u)", (unsigned long)index, self.length);
    NSAssert(value.precision && self.precision,
             @"Precision of vector (%@) does not match precision of values (%@)",
             self.precision == MCKValuePrecisionSingle ? @"single" : @"double",
             value.precision == MCKValuePrecisionSingle ? @"single" : @"double");
    
    [self resetToDefaultIfOperation:MAVVectorMutatingOperationTypeAssignment notIdempotentWithInput:value atIndex:index];
    
    if ([value isDoublePrecision]) {
        double *bytes = malloc(sizeof(double));
        bytes[0] = value.doubleValue;
        [self.values replaceBytesInRange:NSMakeRange(index * sizeof(double), sizeof(double)) withBytes:bytes];
    } else {
        float *bytes = malloc(sizeof(float));
        bytes[0] = value.doubleValue;
        [self.values replaceBytesInRange:NSMakeRange(index * sizeof(float), sizeof(float)) withBytes:bytes];
    }
}

- (void)setValues:(NSArray *)values inRange:(NSRange)range
{
    NSAssert(values.count == range.length, @"Mismatch between amount of values (%lu) and range length (%lu)", (unsigned long)values.count, (unsigned long)range.length);
    for (NSUInteger i = 0; i < values.count; i++) {
        self[i+range.location] = values[i];
    }
}

- (void)setObject:(NSNumber *)obj atIndexedSubscript:(NSUInteger)idx
{
    [self setValue:obj atIndex:idx];
}

#pragma mark - Arithmetic

- (MAVMutableVector *)multiplyByScalar:(NSNumber *)scalar
{
    BOOL precisionsMatch = (self.precision == MCKValuePrecisionDouble && scalar.isDoublePrecision) || (self.precision == MCKValuePrecisionSingle && scalar.isSinglePrecision);
    NSAssert(precisionsMatch, @"Precisions do not match");
    
    [self resetToDefaultIfOperation:MAVVectorMutatingOperationTypeMultiplicationScalar notIdempotentWithInput:scalar atIndex:0];
    
    if (self.precision == MCKValuePrecisionDouble) {
        double *newValues = malloc(self.length * sizeof(double));
        for (int i = 0; i < self.length; i++) {
            newValues[i] = scalar.doubleValue * ((double *)self.values.bytes)[i];
        }
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:newValues];
    } else {
        float *newValues = malloc(self.length * sizeof(float));
        for (int i = 0; i < self.length; i++) {
            newValues[i] = scalar.floatValue * ((float *)self.values.bytes)[i];
        }
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:newValues];
    }
    
    return self;
}

- (MAVMutableVector *)addVector:(MAVVector *)vector
{
    NSAssert(self.length == vector.length, @"Vector dimensions do not match");
    NSAssert(self.precision == vector.precision, @"Vector precisions do not match");
    
    [self resetToDefaultIfOperation:MAVVectorMutatingOperationTypeAddition notIdempotentWithInput:vector atIndex:0];
    
    if (self.precision == MCKValuePrecisionDouble) {
        double *sum = malloc(self.length * sizeof(double));
        vDSP_vaddD(self.values.bytes, 1, vector.values.bytes, 1, sum, 1, self.length);
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:sum];
    } else {
        float *sum = malloc(self.length * sizeof(float));
        vDSP_vadd(self.values.bytes, 1, vector.values.bytes, 1, sum, 1, self.length);
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:sum];
    }
    
    return self;
}

- (MAVMutableVector *)subtractVector:(MAVVector *)vector
{
    NSAssert(self.length == vector.length, @"Vector dimensions do not match");
    NSAssert(self.precision == vector.precision, @"Vector precisions do not match");
    
    [self resetToDefaultIfOperation:MAVVectorMutatingOperationTypeSubtraction notIdempotentWithInput:vector atIndex:0];
    
    if (vector.precision == MCKValuePrecisionDouble) {
        double *diff = malloc(self.length * sizeof(double));
        vDSP_vsubD(vector.values.bytes, 1, self.values.bytes, 1, diff, 1, self.length);
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:diff];
    } else {
        float *diff = malloc(self.length * sizeof(float));
        vDSP_vsub(vector.values.bytes, 1, self.values.bytes, 1, diff, 1, self.length);
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:diff];
    }
    
    return self;
}

- (MAVMutableVector *)multiplyByVector:(MAVVector *)vector
{
    NSAssert(self.length == vector.length, @"Vector dimensions do not match");
    NSAssert(self.precision == vector.precision, @"Vector precisions do not match");
    
    [self resetToDefaultIfOperation:MAVVectorMutatingOperationTypeMultiplicationVector notIdempotentWithInput:vector atIndex:0];
    
    if (self.precision == MCKValuePrecisionDouble) {
        double *product = malloc(self.length * sizeof(double));
        vDSP_vmulD(self.values.bytes, 1, vector.values.bytes, 1, product, 1, self.length);
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:product];
    } else {
        float *product = malloc(self.length * sizeof(float));
        vDSP_vmul(self.values.bytes, 1, vector.values.bytes, 1, product, 1, self.length);
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:product];
    }
    
    return self;
}

- (MAVMutableVector *)divideByVector:(MAVVector *)vector
{
    NSAssert(self.length == vector.length, @"Vector dimensions do not match");
    NSAssert(self.precision == vector.precision, @"Vector precisions do not match");
    
    [self resetToDefaultIfOperation:MAVVectorMutatingOperationTypeDivision notIdempotentWithInput:vector atIndex:0];
    
    if (self.precision == MCKValuePrecisionDouble) {
        double *quotient = malloc(self.length * sizeof(double));
        vDSP_vdivD(vector.values.bytes, 1, self.values.bytes, 1, quotient, 1, self.length);
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:quotient];
    } else {
        float *quotient = malloc(self.length * sizeof(float));
        vDSP_vdiv(vector.values.bytes, 1, self.values.bytes, 1, quotient, 1, self.length);
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:quotient];
    }
    
    return self;
}

- (MAVMutableVector *)raiseToPower:(NSUInteger)power
{
    [self resetToDefaultIfOperation:MAVVectorMutatingOperationTypePower notIdempotentWithInput:@(power) atIndex:0];
    
    MAVVector *original = [self copy];
    
    if (original.precision == MCKValuePrecisionDouble) {
        double *powerValues = malloc(original.length * sizeof(double));
        for (int i = 0; i < original.length; i++) {
            powerValues[i] = pow([original valueAtIndex:i].doubleValue, power);
        }
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:powerValues];
    } else {
        float *powerValues = malloc(original.length * sizeof(float));
        for (int i = 0; i < original.length; i++) {
            powerValues[i] = powf([original valueAtIndex:i].floatValue, power);
        }
        [self.values replaceBytesInRange:NSMakeRange(0, self.values.length) withBytes:powerValues];
    }
    
    return self;
}

#pragma mark - Private

- (void)resetToDefaultIfOperation:(MAVVectorMutatingOperationType)operation notIdempotentWithInput:(id)input atIndex:(int)index
{
    BOOL isIdempotent;
    
    switch (operation) {
        case MAVVectorMutatingOperationTypeAddition:
        case MAVVectorMutatingOperationTypeSubtraction: {
            MAVVector *vector = input;
            isIdempotent = [vector isEqualToVector:[MAVVector vectorFilledWithValue:(vector.precision == MCKValuePrecisionDouble ? @0.0 : @0.0f)
                                                                             length:vector.length
                                                                       vectorFormat:vector.vectorFormat]];
            break;
        }
            
        case MAVVectorMutatingOperationTypeMultiplicationVector:
        case MAVVectorMutatingOperationTypeDivision: {
            MAVVector *vector = input;
            isIdempotent = [vector isEqualToVector:[MAVVector vectorFilledWithValue:(vector.precision == MCKValuePrecisionDouble ? @1.0 : @1.0f)
                                                                             length:vector.length
                                                                       vectorFormat:vector.vectorFormat]];
            break;
        }
            
        case MAVVectorMutatingOperationTypeMultiplicationScalar:
        case MAVVectorMutatingOperationTypePower:
            isIdempotent = [input compare:@1] == NSOrderedSame;
            break;
            
        case MAVVectorMutatingOperationTypeAssignment:
            isIdempotent = [input compare:[self valueAtIndex:index]] == NSOrderedSame;
            break;
            
        default:
            isIdempotent = NO;
            break;
    }
    
    if (!isIdempotent) {
        [self resetToDefaultState];
    }
}

@end

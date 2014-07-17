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

@interface MAVMutableVector ()

@property (strong, nonatomic, readwrite) NSMutableData *values;

@end

@implementation MAVMutableVector

- (void)setValue:(NSNumber *)value atIndex:(NSUInteger)index
{
    
}

- (void)setValues:(NSArray *)values inRange:(NSRange)range
{
#pragma mark - Arithmetic

- (MAVMutableVector *)multiplyByScalar:(NSNumber *)scalar
{
    BOOL precisionsMatch = (self.precision == MCKValuePrecisionDouble && scalar.isDoublePrecision) || (self.precision == MCKValuePrecisionSingle && scalar.isSinglePrecision);
    NSAssert(precisionsMatch, @"Precisions do not match");
    
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

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
- (MAVMutableVector *)raiseToPower:(NSUInteger)power
{
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

@end

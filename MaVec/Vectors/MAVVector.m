//
//  MAVVector.m
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

#import <Accelerate/Accelerate.h>

#import "MAVVector.h"
#import "MAVVector-Protected.h"
#import "MAVMutableVector.h"

#import "MCKTribool.h"

#import "NSNumber+MCKPrecision.h"
#import "NSData+MCKPrecision.h"

@implementation MAVVector

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self resetToDefaultState];
        _precision = MCKPrecisionSingle;
    }
    return self;
}

#pragma mark - Private

- (instancetype)initWithValues:(NSData *)values length:(int)length
{
    self = [self init];
    if (self) {
        _values = [[self class] isSubclassOfClass:[MAVMutableVector class]] ? [values mutableCopy] : values;
        _length = length;
        _precision = [values containsDoublePrecisionValues:length] ? MCKPrecisionDouble : MCKPrecisionSingle;
    }
    return self;
}

- (instancetype)initWithValuesInArray:(NSArray *)values
{
    self = [self init];
    if (self) {
        _length = (int)values.count;
        
        for (NSNumber *n in values) {
            if (n.isDoublePrecision) {
                _precision = MCKPrecisionDouble;
                break;
            }
        }
        
        if (_precision == MCKPrecisionDouble) {
            NSUInteger size = values.count * sizeof(double);
            double *valuesArray = malloc(size);
            [values enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
                valuesArray[idx] = value.doubleValue;
            }];
            _values = [NSData dataWithBytesNoCopy:valuesArray length:size];
            if ([[self class] isSubclassOfClass:[MAVMutableVector class]]) {
                _values = [_values mutableCopy];
            }
        } else {
            NSUInteger size = values.count * sizeof(float);
            float *valuesArray = malloc(size);
            [values enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
                valuesArray[idx] = value.floatValue;
            }];
            _values = [NSData dataWithBytesNoCopy:valuesArray length:size];
            if ([[self class] isSubclassOfClass:[MAVMutableVector class]]) {
                _values = [_values mutableCopy];
            }
        }
    }
    return self;
}

- (void)resetToDefaultState
{
    _sumOfValues = nil;
    _productOfValues = nil;
    _l1Norm = nil;
    _l2Norm = nil;
    _l3Norm = nil;
    _infinityNorm = nil;
    _minimumValue = nil;
    _maximumValue = nil;
    _minimumValueIndex = -1;
    _maximumValueIndex = -1;
    _absoluteVector = nil;
    _isIdentity = [MCKTribool triboolWithValue:MCKTriboolValueUnknown];
    _isZero = [MCKTribool triboolWithValue:MCKTriboolValueUnknown];
}

#pragma mark - Constructors

- (instancetype)initWithValues:(NSData *)values length:(int)length vectorFormat:(MAVVectorFormat)vectorFormat
{
    self = [self initWithValues:values length:length];
    if (self) {
        _vectorFormat = vectorFormat;
    }
    return self;
}

+ (instancetype)vectorWithValues:(NSData *)values length:(int)length
{
    return [[self alloc] initWithValues:values
                                 length:length
                           vectorFormat:MAVVectorFormatColumnVector];
}

+ (instancetype)vectorWithValues:(NSData *)values length:(int)length vectorFormat:(MAVVectorFormat)vectorFormat
{
    return [[self alloc] initWithValues:values
                                 length:length
                           vectorFormat:vectorFormat];
}

- (instancetype)initWithValuesInArray:(NSArray *)values vectorFormat:(MAVVectorFormat)vectorFormat
{
    self = [self initWithValuesInArray:values];
    if (self) {
        _vectorFormat = vectorFormat;
    }
    return self;
}

+ (instancetype)vectorWithValuesInArray:(NSArray *)values
{
    return [[self alloc] initWithValuesInArray:values
                                  vectorFormat:MAVVectorFormatColumnVector];
}

+ (instancetype)vectorWithValuesInArray:(NSArray *)values vectorFormat:(MAVVectorFormat)vectorFormat
{
    return [[self alloc] initWithValuesInArray:values
                                  vectorFormat:vectorFormat];
}

+ (instancetype)randomVectorOfLength:(int)length
                        vectorFormat:(MAVVectorFormat)vectorFormat
                           precision:(MCKPrecision)precision
{
    if (precision == MCKPrecisionDouble) {
        NSUInteger size = length * sizeof(double);
        double *values = malloc(size);
        for (int i = 0; i < length; i++) {
            values[i] = drand48();
        }
        return [[self class] vectorWithValues:[NSData dataWithBytesNoCopy:values length:size]
                                       length:length
                                 vectorFormat:vectorFormat];
    } else {
        NSUInteger size = length * sizeof(float);
        float *values = malloc(size);
        for (int i = 0; i < length; i++) {
            values[i] = rand() / RAND_MAX;
        }
        return [[self class] vectorWithValues:[NSData dataWithBytesNoCopy:values length:size]
                                       length:length
                                 vectorFormat:vectorFormat];
    }
}

+ (instancetype)vectorFilledWithValue:(NSNumber *)value
                               length:(int)length
                         vectorFormat:(MAVVectorFormat)vectorFormat
{
    NSMutableArray *values = [NSMutableArray array];
    for (int i = 0; i < length; i++) {
        [values addObject:value];
    }
    MAVVector *vector = [self vectorWithValuesInArray:values
                                         vectorFormat:vectorFormat];
    if ([value isEqualToNumber:@1]) {
        vector.isIdentity = [MCKTribool triboolWithValue:MCKTriboolValueYes];
        vector.isZero = [MCKTribool triboolWithValue:MCKTriboolValueNo];
    }
    else if ([value isEqualToNumber:@0]) {
        vector.isIdentity = [MCKTribool triboolWithValue:MCKTriboolValueNo];
        vector.isZero = [MCKTribool triboolWithValue:MCKTriboolValueYes];
    }
    return vector;
}

#pragma mark - Lazy loaded properties

- (MCKTribool *)isZero
{
    if (_isZero.triboolValue == MCKTriboolValueUnknown) {
        MCKTriboolValue isZero = MCKTriboolValueYes;
        for (__CLPK_integer valueIndex = 0; valueIndex < self.length; valueIndex++) {
            if (![[self valueAtIndex:valueIndex] isEqualToNumber:@0]) {
                isZero = MCKTriboolValueNo;
                break;
            }
        }
        _isZero = [MCKTribool triboolWithValue:isZero];
    }
    return _isZero;
}

- (MCKTribool *)isIdentity
{
    if (_isIdentity.triboolValue == MCKTriboolValueUnknown) {
        MCKTriboolValue isIdentity = MCKTriboolValueYes;
        for (__CLPK_integer valueIndex = 0; valueIndex < self.length; valueIndex++) {
            if (![[self valueAtIndex:valueIndex] isEqualToNumber:@1]) {
                isIdentity = MCKTriboolValueNo;
                break;
            }
        }
        _isIdentity = [MCKTribool triboolWithValue:isIdentity];
    }
    return _isIdentity;
}

- (NSNumber *)sumOfValues
{
    if (_sumOfValues == nil) {
        if (self.precision == MCKPrecisionDouble) {
            double sum = 0.0;
            for (int i = 0; i < self.length; i += 1) {
                sum += ((double *)self.values.bytes)[i];
            }
            _sumOfValues = @(sum);
        } else {
            float sum = 0.f;
            for (int i = 0; i < self.length; i += 1) {
                sum += ((float *)self.values.bytes)[i];
            }
            _sumOfValues = @(sum);
        }
    }
    return _sumOfValues;
}

- (NSNumber *)l1Norm
{
    if (_l1Norm == nil) {
        if (self.precision == MCKPrecisionDouble) {
            double norm;
            vDSP_svemgD(self.values.bytes, 1, &norm, self.length);
            _l1Norm = @(norm);
        } else {
            float norm;
            vDSP_svemg(self.values.bytes, 1, &norm, self.length);
            _l1Norm = @(norm);
        }
    }
    return _l1Norm;
}

- (NSNumber *)l2Norm
{
    if (_l2Norm == nil) {
        if (self.precision == MCKPrecisionDouble) {
            double squaredSum;
            vDSP_svesqD(self.values.bytes, 1, &squaredSum, self.length);
            _l2Norm = @(sqrt(squaredSum));
        } else {
            float squaredSum;
            vDSP_svesq(self.values.bytes, 1, &squaredSum, self.length);
            _l2Norm = @(sqrtf(squaredSum));
        }
    }
    return _l2Norm;
}

- (NSNumber *)l3Norm
{
    if (_l3Norm == nil) {
        MAVVector *cubedVector = [[self mutableCopy] raiseToPower:3];
        if (self.precision == MCKPrecisionDouble) {
            double cubedSum;
            vDSP_svemgD(cubedVector.values.bytes, 1, &cubedSum, self.length);
            _l3Norm = @(cbrt(cubedSum));
        } else {
            float cubedSum;
            vDSP_svemg(cubedVector.values.bytes, 1, &cubedSum, self.length);
            _l3Norm = @(cbrtf(cubedSum));
        }
    }
    return _l3Norm;
}

- (NSNumber *)infinityNorm
{
    if (_infinityNorm == nil) {
        _infinityNorm = self.absoluteVector.maximumValue;
    }
    return _infinityNorm;
}

- (NSNumber *)productOfValues
{
    if (_productOfValues == nil) {
        if (self.precision == MCKPrecisionDouble) {
            double product = 1.0;
            for (int i = 0; i < self.length; i += 1) {
                product *= ((double *)self.values.bytes)[i];
            }
            _productOfValues = @(product);
        } else {
            float product = 1.f;
            for (int i = 0; i < self.length; i += 1) {
                product *= ((float *)self.values.bytes)[i];
            }
            _productOfValues = @(product);
        }
    }
    return _productOfValues;
}

- (NSNumber *)maximumValue
{
    if (_maximumValue == nil) {
        if (self.precision == MCKPrecisionDouble) {
            double max = DBL_MIN;
            for (int i = 0; i < self.length; i++) {
                double value = ((double *)self.values.bytes)[i];
                if (value > max) {
                    max = value;
                    _maximumValueIndex = i;
                }
            }
            _maximumValue = @(max);
        } else {
            float max = FLT_MIN;
            for (int i = 0; i < self.length; i++) {
                float value = ((float *)self.values.bytes)[i];
                if (value > max) {
                    max = value;
                    _maximumValueIndex = i;
                }
            }
            _maximumValue = @(max);
        }
    }
    return _maximumValue;
}

- (NSNumber *)minimumValue
{
    if (_minimumValue == nil) {
        if (self.precision == MCKPrecisionDouble) {
            double min = DBL_MAX;
            for (int i = 0; i < self.length; i++) {
                double value = ((double *)self.values.bytes)[i];
                if (value < min) {
                    min = value;
                    _minimumValueIndex = i;
                }
            }
            _minimumValue = @(min);
        } else {
            float min = FLT_MAX;
            for (int i = 0; i < self.length; i++) {
                float value = ((float *)self.values.bytes)[i];
                if (value < min) {
                    min = value;
                    _minimumValueIndex = i;
                }
            }
            _minimumValue = @(min);
        }
    }
    return _minimumValue;
}

- (MAVVector *)absoluteVector
{
    if (_absoluteVector == nil) {
        if (self.precision == MCKPrecisionDouble) {
            size_t size = self.length * sizeof(double);
            double *absoluteValues = malloc(size);
            vDSP_vabsD(self.values.bytes, 1, absoluteValues, 1, self.length);
            _absoluteVector = [MAVVector vectorWithValues:[NSData dataWithBytesNoCopy:absoluteValues length:size]
                                                  length:self.length
                                            vectorFormat:self.vectorFormat];
        } else {
            size_t size = self.length * sizeof(float);
            float *absoluteValues = malloc(size);
            vDSP_vabs(self.values.bytes, 1, absoluteValues, 1, self.length);
            _absoluteVector = [MAVVector vectorWithValues:[NSData dataWithBytesNoCopy:absoluteValues length:size]
                                                  length:self.length
                                            vectorFormat:self.vectorFormat];
        }
    }
    
    if (self.isIdentity) {
        _absoluteVector.isIdentity = [MCKTribool triboolWithValue:MCKTriboolValueYes];
        _absoluteVector.isZero = [MCKTribool triboolWithValue:MCKTriboolValueNo];
    }
    else if (self.isZero) {
        _absoluteVector.isIdentity = [MCKTribool triboolWithValue:MCKTriboolValueNo];
        _absoluteVector.isZero = [MCKTribool triboolWithValue:MCKTriboolValueYes];
    }
    
    return _absoluteVector;
}

#pragma mark - NSObject overrides

- (BOOL)isEqualToVector:(MAVVector *)otherVector
{
    if (self == otherVector.self) {
        return YES;
    } else if (self.length == otherVector.length) {
        return [self.values isEqualToData:otherVector.values];
    } else {
        return NO;
    }
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    } else if (![object isKindOfClass:[MAVVector class]]) {
        return NO;
    } else {
        return [self isEqualToVector:(MAVVector *)object];
    }
}

- (NSUInteger)hash
{
    return self.values.hash;
}

- (NSString *)description
{
    int padding = 0;
    if (self.vectorFormat == MAVVectorFormatColumnVector) {
        if (self.precision == MCKPrecisionDouble) {
            double max = DBL_MIN;
            for (int i = 0; i < self.length; i++) {
                max = MAX(max, fabs(((double *)self.values.bytes)[i]));
            }
            padding = (__CLPK_integer)floor(log10(max)) + 5;
        } else {
            float max = FLT_MIN;
            for (int i = 0; i < self.length; i++) {
                max = MAX(max, fabsf(((float *)self.values.bytes)[i]));
            }
            padding = (__CLPK_integer)floorf(log10f(max)) + 5;
        }
    }
    
    NSMutableString *description = [@"\n" mutableCopy];
    
    for (int j = 0; j < self.length; j++) {
        NSString *valueString;
        if (self.precision == MCKPrecisionDouble) {
            valueString = [NSString stringWithFormat:@"%.1f", ((double *)self.values.bytes)[j]];
        } else {
            valueString = [NSString stringWithFormat:@"%.1f", ((float *)self.values.bytes)[j]];
        }
        if (self.vectorFormat == MAVVectorFormatColumnVector) {
            [description appendString:[valueString stringByPaddingToLength:padding withString:@" " startingAtIndex:0]];
            if (j < self.length - 1) {
                [description appendString:@"\n"];
            }
        } else {
            [description appendString:valueString];
            if (j < self.length - 1) {
                [description appendString:@" "];
            }
        }
    }
    
    return description;
}

- (id)debugQuickLookObject
{
    return self.description;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MAVVector *vectorCopy = [[self class] allocWithZone:zone];
    
    [self deepCopyVector:self intoNewVector:vectorCopy mutable:NO];
    
    return vectorCopy;
}

- (void)deepCopyVector:(MAVVector *)vector intoNewVector:(MAVVector *)newVector mutable:(BOOL)mutable
{
    newVector->_length = vector->_length;
    newVector->_vectorFormat = vector->_vectorFormat;
    newVector->_minimumValueIndex = vector->_minimumValueIndex;
    newVector->_maximumValueIndex = vector->_maximumValueIndex;
    newVector->_precision = vector->_precision;
    
    if (vector->_precision == MCKPrecisionDouble) {
        double *values = malloc(vector->_values.length);
        for (int i = 0; i < vector->_values.length / sizeof(double); i++) {
            values[i] = ((double *)vector->_values.bytes)[i];
        }
        if ( mutable ) {
            newVector->_values = [NSMutableData dataWithBytesNoCopy:values length:vector->_values.length];
        } else {
            newVector->_values = [NSData dataWithBytesNoCopy:values length:vector->_values.length];
        }
    } else {
        float *values = malloc(vector->_values.length);
        for (int i = 0; i < vector->_values.length / sizeof(float); i++) {
            values[i] = ((float *)vector->_values.bytes)[i];
        }
        if ( mutable ) {
            newVector->_values = [NSMutableData dataWithBytesNoCopy:values length:vector->_values.length];
        } else {
            newVector->_values = [NSData dataWithBytesNoCopy:values length:vector->_values.length];
        }
    }
    newVector->_l1Norm = vector->_l1Norm.copy;
    newVector->_l2Norm = vector->_l2Norm.copy;
    newVector->_l3Norm = vector->_l3Norm.copy;
    newVector->_infinityNorm = vector->_infinityNorm.copy;
    newVector->_minimumValue = vector->_minimumValue.copy;
    newVector->_maximumValue = vector->_maximumValue.copy;
    newVector->_absoluteVector = vector->_absoluteVector.copy;
}
    
#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    MAVMutableVector *newVector = [MAVMutableVector allocWithZone:zone];
    
    [self deepCopyVector:self intoNewVector:newVector mutable:YES];
    
    return newVector;
}

#pragma mark - Inspection

- (NSNumber *)valueAtIndex:(int)index
{
    NSNumber *value;
    
    if (self.precision == MCKPrecisionDouble) {
        value = @(((double *)self.values.bytes)[index]);
    } else {
        value = @(((float *)self.values.bytes)[index]);
    }
    
    return value;
}

#pragma mark - Subscripting

- (NSNumber *)objectAtIndexedSubscript:(NSUInteger)idx
{
    return [self valueAtIndex:(int)idx];
}

#pragma mark - Instance Operations

- (NSNumber *)dotProductWithVector:(MAVVector *)vector
{
    NSAssert(self.length == vector.length, @"Vector dimensions do not match");
    NSAssert(self.precision == vector.precision, @"Vector precisions do not match");
    
    NSNumber *dotProduct;
    
    if (self.precision == MCKPrecisionDouble) {
        double dotProductValue;
        vDSP_dotprD(self.values.bytes, 1,vector.values.bytes, 1, &dotProductValue, self.length);
        dotProduct = @(dotProductValue);
    } else {
        float dotProductValue;
        vDSP_dotpr(self.values.bytes, 1,vector.values.bytes, 1, &dotProductValue, self.length);
        dotProduct = @(dotProductValue);
    }
    
    return dotProduct;
}

- (MAVMutableVector *)crossProductWithVector:(MAVVector *)vector
{
    NSAssert(self.length == 3 && vector.length == 3, @"Vectors must both be of length 3 to perform cross products");
    NSAssert(self.precision == vector.precision, @"Vector precisions do not match");
    
    MAVMutableVector *crossProduct;
    
    if (self.precision == MCKPrecisionDouble) {
        double *values = malloc(self.length * sizeof(double));
        values[0] = [self valueAtIndex:1].doubleValue * [vector valueAtIndex:2].doubleValue - [self valueAtIndex:2].doubleValue * [vector valueAtIndex:1].doubleValue;
        values[1] = [self valueAtIndex:2].doubleValue * [vector valueAtIndex:0].doubleValue - [self valueAtIndex:0].doubleValue * [vector valueAtIndex:2].doubleValue;
        values[2] = [self valueAtIndex:0].doubleValue * [vector valueAtIndex:1].doubleValue - [self valueAtIndex:1].doubleValue * [vector valueAtIndex:0].doubleValue;
        crossProduct = [MAVMutableVector vectorWithValues:[NSMutableData dataWithBytesNoCopy:values length:self.values.length] length:self.length];
    } else {
        float *values = malloc(self.length * sizeof(float));
        values[0] = [self valueAtIndex:1].floatValue * [vector valueAtIndex:2].floatValue - [self valueAtIndex:2].floatValue * [vector valueAtIndex:1].floatValue;
        values[1] = [self valueAtIndex:2].floatValue * [vector valueAtIndex:0].floatValue - [self valueAtIndex:0].floatValue * [vector valueAtIndex:2].floatValue;
        values[2] = [self valueAtIndex:0].floatValue * [vector valueAtIndex:1].floatValue - [self valueAtIndex:1].floatValue * [vector valueAtIndex:0].floatValue;
        crossProduct = [MAVMutableVector vectorWithValues:[NSMutableData dataWithBytesNoCopy:values length:self.values.length] length:self.length];
    }
    
    return crossProduct;
}

#pragma mark - Class Operations

+ (NSNumber *)scalarTripleProductWithVectorA:(MAVVector *)vectorA vectorB:(MAVVector *)vectorB vectorC:(MAVVector *)vectorC
{
    MAVVector *crossProduct = [vectorA crossProductWithVector:vectorB];
    return [crossProduct dotProductWithVector:vectorC];
}

+ (MAVVector *)vectorTripleProductWithVectorA:(MAVVector *)vectorA vectorB:(MAVVector *)vectorB vectorC:(MAVVector *)vectorC
{
    MAVVector *crossProduct = [vectorB crossProductWithVector:vectorC];
    return [vectorA crossProductWithVector:crossProduct];
}

@end

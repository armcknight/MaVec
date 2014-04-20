//
//  MCVector.m
//  MCNumerics
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

#import "MCVector.h"

@interface MCVector()

@property (strong, readwrite, nonatomic) NSNumber *sumOfValues;
@property (strong, readwrite, nonatomic) NSNumber *productOfValues;
@property (strong, readwrite, nonatomic) NSNumber *l1Norm;
@property (strong, readwrite, nonatomic) NSNumber *l2Norm;
@property (strong, readwrite, nonatomic) NSNumber *l3Norm;
@property (strong, readwrite, nonatomic) NSNumber *infinityNorm;
@property (strong, readwrite, nonatomic) NSNumber *minimumValue;
@property (strong, readwrite, nonatomic) NSNumber *maximumValue;
@property (assign, readwrite, nonatomic) int minimumValueIndex;
@property (assign, readwrite, nonatomic) int maximumValueIndex;
@property (strong, readwrite, nonatomic) MCVector *absoluteVector;
@property (assign, readwrite, nonatomic) MCValuePrecision precision;

/**
 @brief Sets all properties to default states.
 @return A new instance of MCVector in a default state with no values or length.
 */
- (instancetype)init;

/**
 @brief Constructs new instance by calling [self init] and sets the supplied values and length.
 @param values C array of floating-point values.
 @param length The length of the C array.
 @return A new instance of MCVector in a default state.
 */
- (instancetype)initWithValues:(NSData *)values length:(int)length;

/**
 @brief Constructs new instance by calling [self init] and sets the supplied values and inferred length.
 @param values An NSArray of NSNumbers.
 @return A new instance of MCVector in a default state.
 */
- (instancetype)initWithValuesInArray:(NSArray *)values;

@end

@implementation MCVector

#pragma mark - Private constructor helpers

- (instancetype)init
{
    self = [super init];
    if (self) {
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
        _precision = MCValuePrecisionSingle;
    }
    return self;
}

- (instancetype)initWithValues:(NSData *)values length:(int)length
{
    self = [self init];
    if (self) {
        _values = values;
        _length = length;
        _precision = kMCIsDoubleType(values.length / length) ? MCValuePrecisionDouble : MCValuePrecisionSingle;
    }
    return self;
}

- (instancetype)initWithValuesInArray:(NSArray *)values
{
    self = [self init];
    if (self) {
        _length = (int)values.count;
        
        for (NSNumber *n in values) {
            if (kMCIsDoubleEncoding(n.objCType)) {
                _precision = MCValuePrecisionDouble;
                break;
            }
        }
        
        if (_precision == MCValuePrecisionDouble) {
            NSUInteger size = values.count * sizeof(double);
            double *valuesArray = malloc(size);
            [values enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
                valuesArray[idx] = value.doubleValue;
            }];
            _values = [NSData dataWithBytes:valuesArray length:size];
        } else {
            NSUInteger size = values.count * sizeof(float);
            float *valuesArray = malloc(size);
            [values enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
                valuesArray[idx] = value.floatValue;
            }];
            _values = [NSData dataWithBytes:valuesArray length:size];
        }
    }
    return self;
}

#pragma mark - Constructors

- (instancetype)initWithValues:(NSData *)values length:(int)length vectorFormat:(MCVectorFormat)vectorFormat
{
    self = [self initWithValues:values length:length];
    if (self) {
        _vectorFormat = vectorFormat;
    }
    return self;
}

+ (instancetype)vectorWithValues:(NSData *)values length:(int)length
{
    return [[MCVector alloc] initWithValues:values length:length vectorFormat:MCVectorFormatColumnVector];
}

+ (instancetype)vectorWithValues:(NSData *)values length:(int)length vectorFormat:(MCVectorFormat)vectorFormat
{
    return [[MCVector alloc] initWithValues:values length:length vectorFormat:vectorFormat];
}

- (instancetype)initWithValuesInArray:(NSArray *)values vectorFormat:(MCVectorFormat)vectorFormat
{
    self = [self initWithValuesInArray:values];
    if (self) {
        _vectorFormat = vectorFormat;
    }
    return self;
}

+ (instancetype)vectorWithValuesInArray:(NSArray *)values
{
    return [[MCVector alloc] initWithValuesInArray:values vectorFormat:MCVectorFormatColumnVector];
}

+ (instancetype)vectorWithValuesInArray:(NSArray *)values vectorFormat:(MCVectorFormat)vectorFormat
{
    return [[MCVector alloc] initWithValuesInArray:values vectorFormat:vectorFormat];
}

+ (instancetype)randomVectorOfLength:(int)length vectorFormat:(MCVectorFormat)vectorFormat precision:(MCValuePrecision)precision
{
    if (precision == MCValuePrecisionDouble) {
        NSUInteger size = length * sizeof(double);
        double *values = malloc(size);
        for (int i = 0; i < length; i++) {
            values[i] = drand48();
        }
        return [MCVector vectorWithValues:[NSData dataWithBytes:values length:size] length:length vectorFormat:vectorFormat];
    } else {
        NSUInteger size = length * sizeof(float);
        float *values = malloc(size);
        for (int i = 0; i < length; i++) {
            values[i] = rand() / RAND_MAX;
        }
        return [MCVector vectorWithValues:[NSData dataWithBytes:values length:size] length:length vectorFormat:vectorFormat];
    }
}

#pragma mark - Lazy loaded properties

- (NSNumber *)sumOfValues
{
    if (_sumOfValues == nil) {
        if (self.precision == MCValuePrecisionDouble) {
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
        if (self.precision == MCValuePrecisionDouble) {
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
        if (self.precision == MCValuePrecisionDouble) {
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
        if (self.precision == MCValuePrecisionDouble) {
            MCVector *cubedVector = [MCVector vectorByRaisingVector:self power:3];
            double cubedSum;
            vDSP_svemgD(cubedVector.values.bytes, 1, &cubedSum, self.length);
            _l3Norm = @(cbrt(cubedSum));
        } else {
            MCVector *cubedVector = [MCVector vectorByRaisingVector:self power:3];
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
        if (self.precision == MCValuePrecisionDouble) {
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
        if (self.precision == MCValuePrecisionDouble) {
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
        if (self.precision == MCValuePrecisionDouble) {
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

- (MCVector *)absoluteVector
{
    if (_absoluteVector == nil) {
        if (self.precision == MCValuePrecisionDouble) {
            size_t size = self.length * sizeof(double);
            double *absoluteValues = malloc(size);
            vDSP_vabsD(self.values.bytes, 1, absoluteValues, 1, self.length);
            _absoluteVector = [MCVector vectorWithValues:[NSData dataWithBytes:absoluteValues length:size]
                                                  length:self.length
                                            vectorFormat:self.vectorFormat];
        } else {
            size_t size = self.length * sizeof(float);
            float *absoluteValues = malloc(size);
            vDSP_vabs(self.values.bytes, 1, absoluteValues, 1, self.length);
            _absoluteVector = [MCVector vectorWithValues:[NSData dataWithBytes:absoluteValues length:size]
                                                  length:self.length
                                            vectorFormat:self.vectorFormat];
        }
    }
    return _absoluteVector;
}

#pragma mark - NSObject overrides

- (BOOL)isEqualToVector:(MCVector *)otherVector
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
    } else if (![object isKindOfClass:[MCVector class]]) {
        return NO;
    } else {
        return [self isEqualToVector:(MCVector *)object];
    }
}

- (NSUInteger)hash
{
    return self.values.hash;
}

- (NSString *)description
{
    int padding = 0;
    if (self.vectorFormat == MCVectorFormatColumnVector) {
        if (self.precision == MCValuePrecisionDouble) {
            double max = DBL_MIN;
            for (int i = 0; i < self.length; i++) {
                max = MAX(max, fabs(((double *)self.values.bytes)[i]));
            }
            padding = floor(log10(max)) + 5;
        } else {
            float max = FLT_MIN;
            for (int i = 0; i < self.length; i++) {
                max = MAX(max, fabsf(((float *)self.values.bytes)[i]));
            }
            padding = floorf(log10f(max)) + 5;
        }
    }
    
    NSMutableString *description = [@"\n" mutableCopy];
    
    for (int j = 0; j < self.length; j++) {
        NSString *valueString;
        if (self.precision == MCValuePrecisionDouble) {
            valueString = [NSString stringWithFormat:@"%.1f", ((double *)self.values.bytes)[j]];
        } else {
            valueString = [NSString stringWithFormat:@"%.1f", ((float *)self.values.bytes)[j]];
        }
        if (self.vectorFormat == MCVectorFormatColumnVector) {
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
    MCVector *vectorCopy = [[self class] allocWithZone:zone];
    
    vectorCopy->_length = _length;
    vectorCopy->_vectorFormat = _vectorFormat;
    vectorCopy->_minimumValueIndex = _minimumValueIndex;
    vectorCopy->_maximumValueIndex = _maximumValueIndex;
    vectorCopy->_precision = _precision;
    
    vectorCopy->_values = _values.copy;
    vectorCopy->_l1Norm = _l1Norm.copy;
    vectorCopy->_l2Norm = _l2Norm.copy;
    vectorCopy->_l3Norm = _l3Norm.copy;
    vectorCopy->_infinityNorm = _infinityNorm.copy;
    vectorCopy->_minimumValue = _minimumValue.copy;
    vectorCopy->_maximumValue = _maximumValue.copy;
    vectorCopy->_absoluteVector = _absoluteVector.copy;
    
    return vectorCopy;
}

#pragma mark - Inspection

- (NSNumber *)valueAtIndex:(int)index
{
    NSNumber *value;
    
    if (self.precision == MCValuePrecisionDouble) {
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

#pragma mark - Class Operations

+ (MCVector *)productOfVector:(MCVector *)vector scalar:(NSNumber *)scalar
{
    BOOL precisionsMatch = (vector.precision == MCValuePrecisionDouble && kMCIsDoubleEncoding(scalar.objCType)) || (vector.precision == MCValuePrecisionSingle && kMCIsFloatEncoding(scalar.objCType));
    NSAssert(precisionsMatch, @"Precisions do not match");
    
    MCVector *product;
    
    if (vector.precision == MCValuePrecisionDouble) {
        double *newValues = malloc(vector.length * sizeof(double));
        for (int i = 0; i < vector.length; i++) {
            newValues[i] = scalar.doubleValue * ((double *)vector.values.bytes)[i];
        }
        product = [MCVector vectorWithValues:[NSData dataWithBytes:newValues length:vector.values.length] length:vector.length vectorFormat:vector.vectorFormat];
    } else {
        float *newValues = malloc(vector.length * sizeof(float));
        for (int i = 0; i < vector.length; i++) {
            newValues[i] = scalar.floatValue * ((float *)vector.values.bytes)[i];
        }
        product = [MCVector vectorWithValues:[NSData dataWithBytes:newValues length:vector.values.length] length:vector.length vectorFormat:vector.vectorFormat];
    }
    
    return product;
}

+ (MCVector *)sumOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB
{
    NSAssert(vectorA.length == vectorB.length, @"Vector dimensions do not match");
    NSAssert(vectorA.precision == vectorB.precision, @"Vector precisions do not match");
    
    MCVector *sumVector;
    
    if (vectorA.precision == MCValuePrecisionDouble) {
        double *sum = malloc(vectorA.length * sizeof(double));
        vDSP_vaddD(vectorA.values.bytes, 1, vectorB.values.bytes, 1, sum, 1, vectorA.length);
        sumVector = [MCVector vectorWithValues:[NSData dataWithBytes:sum length:vectorA.values.length] length:vectorA.length];
    } else {
        float *sum = malloc(vectorA.length * sizeof(float));
        vDSP_vadd(vectorA.values.bytes, 1, vectorB.values.bytes, 1, sum, 1, vectorA.length);
        sumVector = [MCVector vectorWithValues:[NSData dataWithBytes:sum length:vectorA.values.length] length:vectorA.length];
    }
    
    return sumVector;
}

+ (MCVector *)differenceOfVectorMinuend:(MCVector *)vectorMinuend vectorSubtrahend:(MCVector *)vectorSubtrahend
{
    NSAssert(vectorMinuend.length == vectorSubtrahend.length, @"Vector dimensions do not match");
    NSAssert(vectorMinuend.precision == vectorSubtrahend.precision, @"Vector precisions do not match");
    
    MCVector *differenceVector;
    
    if (vectorSubtrahend.precision == MCValuePrecisionDouble) {
        double *diff = malloc(vectorMinuend.length * sizeof(double));
        vDSP_vsubD(vectorSubtrahend.values.bytes, 1, vectorMinuend.values.bytes, 1, diff, 1, vectorMinuend.length);
        differenceVector = [MCVector vectorWithValues:[NSData dataWithBytes:diff length:vectorSubtrahend.values.length] length:vectorMinuend.length];
    } else {
        float *diff = malloc(vectorMinuend.length * sizeof(float));
        vDSP_vsub(vectorSubtrahend.values.bytes, 1, vectorMinuend.values.bytes, 1, diff, 1, vectorMinuend.length);
        differenceVector = [MCVector vectorWithValues:[NSData dataWithBytes:diff length:vectorSubtrahend.values.length] length:vectorMinuend.length];
    }
    
    return differenceVector;
}

+ (MCVector *)productOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB
{
    NSAssert(vectorA.length == vectorB.length, @"Vector dimensions do not match");
    NSAssert(vectorA.precision == vectorB.precision, @"Vector precisions do not match");
    
    MCVector *productVector;
    
    if (vectorA.precision == MCValuePrecisionDouble) {
        double *product = malloc(vectorA.length * sizeof(double));
        vDSP_vmulD(vectorA.values.bytes, 1, vectorB.values.bytes, 1, product, 1, vectorA.length);
        productVector = [MCVector vectorWithValues:[NSData dataWithBytes:product length:vectorA.values.length] length:vectorA.length];
    } else {
        float *product = malloc(vectorA.length * sizeof(float));
        vDSP_vmul(vectorA.values.bytes, 1, vectorB.values.bytes, 1, product, 1, vectorA.length);
        productVector = [MCVector vectorWithValues:[NSData dataWithBytes:product length:vectorA.values.length] length:vectorA.length];
    }
    
    return productVector;
}

+ (MCVector *)quotientOfVectorDividend:(MCVector *)vectorDividend vectorDivisor:(MCVector *)vectorDivisor
{
    NSAssert(vectorDividend.length == vectorDivisor.length, @"Vector dimensions do not match");
    NSAssert(vectorDividend.precision == vectorDivisor.precision, @"Vector precisions do not match");
    
    MCVector *quotientVector;
    
    if (vectorDividend.precision == MCValuePrecisionDouble) {
        double *quotient = malloc(vectorDividend.length * sizeof(double));
        vDSP_vdivD(vectorDivisor.values.bytes, 1, vectorDividend.values.bytes, 1, quotient, 1, vectorDividend.length);
        quotientVector = [MCVector vectorWithValues:[NSData dataWithBytes:quotient length:vectorDividend.values.length] length:vectorDividend.length];
    } else {
        float *quotient = malloc(vectorDividend.length * sizeof(float));
        vDSP_vdiv(vectorDivisor.values.bytes, 1, vectorDividend.values.bytes, 1, quotient, 1, vectorDividend.length);
        quotientVector = [MCVector vectorWithValues:[NSData dataWithBytes:quotient length:vectorDividend.values.length] length:vectorDividend.length];
    }
    
    return quotientVector;
}

+ (NSNumber *)dotProductOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB
{
    NSAssert(vectorA.length == vectorB.length, @"Vector dimensions do not match");
    NSAssert(vectorA.precision == vectorB.precision, @"Vector precisions do not match");
    
    NSNumber *dotProduct;
    
    if (vectorA.precision == MCValuePrecisionDouble) {
        double dotProductValue;
        vDSP_dotprD(vectorA.values.bytes, 1,vectorB.values.bytes, 1, &dotProductValue, vectorA.length);
        dotProduct = @(dotProductValue);
    } else {
        float dotProductValue;
        vDSP_dotpr(vectorA.values.bytes, 1,vectorB.values.bytes, 1, &dotProductValue, vectorA.length);
        dotProduct = @(dotProductValue);
    }
    
    return dotProduct;
}

+ (MCVector *)crossProductOfVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB
{
    NSAssert(vectorA.length == 3 && vectorB.length == 3, @"Vectors must both be of length 3 to perform cross products");
    NSAssert(vectorA.precision == vectorB.precision, @"Vector precisions do not match");
    
    MCVector *crossProduct;
    
    if (vectorA.precision == MCValuePrecisionDouble) {
        double *values = malloc(vectorA.length * sizeof(double));
        values[0] = [vectorA valueAtIndex:1].doubleValue * [vectorB valueAtIndex:2].doubleValue - [vectorA valueAtIndex:2].doubleValue * [vectorB valueAtIndex:1].doubleValue;
        values[1] = [vectorA valueAtIndex:2].doubleValue * [vectorB valueAtIndex:0].doubleValue - [vectorA valueAtIndex:0].doubleValue * [vectorB valueAtIndex:2].doubleValue;
        values[2] = [vectorA valueAtIndex:0].doubleValue * [vectorB valueAtIndex:1].doubleValue - [vectorA valueAtIndex:1].doubleValue * [vectorB valueAtIndex:0].doubleValue;
        crossProduct = [MCVector vectorWithValues:[NSData dataWithBytes:values length:vectorA.values.length] length:vectorA.length];
    } else {
        float *values = malloc(vectorA.length * sizeof(float));
        values[0] = [vectorA valueAtIndex:1].floatValue * [vectorB valueAtIndex:2].floatValue - [vectorA valueAtIndex:2].floatValue * [vectorB valueAtIndex:1].floatValue;
        values[1] = [vectorA valueAtIndex:2].floatValue * [vectorB valueAtIndex:0].floatValue - [vectorA valueAtIndex:0].floatValue * [vectorB valueAtIndex:2].floatValue;
        values[2] = [vectorA valueAtIndex:0].floatValue * [vectorB valueAtIndex:1].floatValue - [vectorA valueAtIndex:1].floatValue * [vectorB valueAtIndex:0].floatValue;
        crossProduct = [MCVector vectorWithValues:[NSData dataWithBytes:values length:vectorA.values.length] length:vectorA.length];
    }
    
    return crossProduct;
    
}

+ (NSNumber *)scalarTripleProductWithVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB vectorC:(MCVector *)vectorC
{
    MCVector *crossProduct = [MCVector crossProductOfVectorA:vectorA vectorB:vectorB];
    return [MCVector dotProductOfVectorA:crossProduct vectorB:vectorC];
}

+ (MCVector *)vectorTripleProductWithVectorA:(MCVector *)vectorA vectorB:(MCVector *)vectorB vectorC:(MCVector *)vectorC
{
    MCVector *crossProduct = [MCVector crossProductOfVectorA:vectorB vectorB:vectorC];
    return [MCVector crossProductOfVectorA:vectorA vectorB:crossProduct];
}

+ (MCVector *)vectorByRaisingVector:(MCVector *)vector power:(NSUInteger)power
{
    MCVector *powerVector;
    
    if (vector.precision == MCValuePrecisionDouble) {
        double *powerValues = malloc(vector.length * sizeof(double));
        for (int i = 0; i < vector.length; i++) {
            powerValues[i] = pow([vector valueAtIndex:i].doubleValue, power);
        }
        powerVector = [MCVector vectorWithValues:[NSData dataWithBytes:powerValues length:vector.values.length]
                                          length:vector.length
                                    vectorFormat:vector.vectorFormat];
    } else {
        float *powerValues = malloc(vector.length * sizeof(float));
        for (int i = 0; i < vector.length; i++) {
            powerValues[i] = powf([vector valueAtIndex:i].floatValue, power);
        }
        powerVector = [MCVector vectorWithValues:[NSData dataWithBytes:powerValues length:vector.values.length]
                                          length:vector.length
                                    vectorFormat:vector.vectorFormat];
    }
    
    return powerVector;
}

@end

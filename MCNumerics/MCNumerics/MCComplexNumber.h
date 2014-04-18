//
//  MCImaginaryNumber.h
//  MCNumerics
//
//  Created by andrew mcknight on 4/13/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import "MCRealNumber.h"

@interface MCComplexNumber : MCRealNumber

@property (strong, nonatomic, readonly) NSValue *imaginaryValue;

- (instancetype)initWithRealValue:(const void *)realValue imaginaryValue:(const void *)imaginaryValue precision:(MCValuePrecision)precision;
+ (instancetype)complexNumberWithRealValue:(const void *)realValue imaginaryValue:(const void *)imaginaryValue precision:(MCValuePrecision)precision;

@end

//
//  MCKRealNumber.m
//  MCKMath
//
//  Created by andrew mcknight on 4/12/14.
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

#import "MCKRealNumber.h"

@interface MCKRealNumber ()

@property (assign, nonatomic, readwrite) MCKValuePrecision precision;
@property (strong, nonatomic, readwrite) NSNumber *realValue;

@end

@implementation MCKRealNumber

- (instancetype)initWithValue:(NSNumber *)value precision:(MCKValuePrecision)precision
{
    self = [super init];
    if (self != nil) {
        _precision = precision;
        _realValue = value;
    }
    return self;
}

+ (instancetype)realNumberWithValue:(NSNumber *)value precision:(MCKValuePrecision)precision
{
    return [[self alloc] initWithValue:value precision:precision];
}

@end

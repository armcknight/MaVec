//
//  MCKTribool.m
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

#import "MCKTribool.h"

@interface MCKTribool ()

@end

@implementation MCKTribool

@synthesize triboolValue = _triboolValue;

#pragma mark - Init

- (id)initWithTriboolValue:(MCKTriboolValue)triboolValue
{
    self = [super init];
    if (self) {
        _triboolValue = triboolValue;
    }
    return self;
}

+ (MCKTribool *)triboolWithValue:(MCKTriboolValue)triboolValue
{
    return [[MCKTribool alloc] initWithTriboolValue:triboolValue];
}

#pragma mark - Inspection

- (BOOL)isYes
{
    return (_triboolValue == MCKTriboolValueYes);
}

- (BOOL)isNo
{
    return (_triboolValue == MCKTriboolValueNo);
}

- (BOOL)isKnown
{
    return (_triboolValue != MCKTriboolValueUnknown);
}

#pragma mark - Instance operators

- (MCKTribool *)andTribool:(MCKTribool *)tribool
{
    return [MCKTribool triboolWithValue:[MCKTribool conjunctionOfTriboolValueA:self.triboolValue
                                                               triboolValueB:tribool.triboolValue]];
}

- (MCKTribool *)orTribool:(MCKTribool *)tribool
{
    return [MCKTribool triboolWithValue:[MCKTribool disjunctionOfTriboolValueA:self.triboolValue
                                                               triboolValueB:tribool.triboolValue]];
}

- (MCKTribool *)negate
{
    return [MCKTribool triboolWithValue:[MCKTribool negationOfTriboolValue:self.triboolValue]];
}

- (MCKTribool *)kleeneImplication:(MCKTribool *)tribool
{
    return [MCKTribool triboolWithValue:[MCKTribool kleeneImplicationOfTriboolValueA:self.triboolValue
                                                                     triboolValueB:tribool.triboolValue]];
}

- (MCKTribool *)lukasiewiczImplication:(MCKTribool *)tribool
{
    return [MCKTribool triboolWithValue:[MCKTribool lukasiewiczImplicationOfTriboolValueA:self.triboolValue
                                                                          triboolValueB:tribool.triboolValue]];
}

#pragma mark - Class operators

+ (MCKTriboolValue)conjunctionOfTriboolValueA:(MCKTriboolValue)triboolValueA
                               triboolValueB:(MCKTriboolValue)triboolValueB
{
    return MIN(triboolValueA, triboolValueB);
}

+ (MCKTriboolValue)disjunctionOfTriboolValueA:(MCKTriboolValue)triboolValueA
                               triboolValueB:(MCKTriboolValue)triboolValueB
{
    return MAX(triboolValueA, triboolValueB);
}

+ (MCKTriboolValue)negationOfTriboolValue:(MCKTriboolValue)triboolValue
{
    return -1 * triboolValue;
}

+ (MCKTriboolValue)kleeneImplicationOfTriboolValueA:(MCKTriboolValue)triboolValueA
                                     triboolValueB:(MCKTriboolValue)triboolValueB
{
    return MAX(-1 * triboolValueA, triboolValueB);
}

+ (MCKTriboolValue)lukasiewiczImplicationOfTriboolValueA:(MCKTriboolValue)triboolValueA
                                          triboolValueB:(MCKTriboolValue)triboolValueB
{
    return MIN(1, 1 - triboolValueA + triboolValueB);
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MCKTribool *triboolCopy = [[self class] allocWithZone:zone];
    
    triboolCopy->_triboolValue = _triboolValue;
    
    return triboolCopy;
}

@end

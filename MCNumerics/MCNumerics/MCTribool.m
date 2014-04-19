//
//  MCTribool.m
//  MCNumerics
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

#import "MCTribool.h"

@interface MCTribool ()

@end

@implementation MCTribool

@synthesize triboolValue = _triboolValue;

#pragma mark - Init

- (id)initWithTriboolValue:(MCTriboolValue)triboolValue
{
    self = [super init];
    if (self) {
        _triboolValue = triboolValue;
    }
    return self;
}

+ (MCTribool *)triboolWithValue:(MCTriboolValue)triboolValue
{
    return [[MCTribool alloc] initWithTriboolValue:triboolValue];
}

#pragma mark - Inspection

- (BOOL)isYes
{
    return (_triboolValue == MCTriboolValueYes);
}

- (BOOL)isNo
{
    return (_triboolValue == MCTriboolValueNo);
}

- (BOOL)isKnown
{
    return (_triboolValue != MCTriboolValueUnknown);
}

#pragma mark - Instance operators

- (MCTribool *)andTribool:(MCTribool *)tribool
{
    return [MCTribool triboolWithValue:[MCTribool conjunctionOfTriboolValueA:self.triboolValue
                                                               triboolValueB:tribool.triboolValue]];
}

- (MCTribool *)orTribool:(MCTribool *)tribool
{
    return [MCTribool triboolWithValue:[MCTribool disjunctionOfTriboolValueA:self.triboolValue
                                                               triboolValueB:tribool.triboolValue]];
}

- (MCTribool *)negate
{
    return [MCTribool triboolWithValue:[MCTribool negationOfTriboolValue:self.triboolValue]];
}

- (MCTribool *)kleeneImplication:(MCTribool *)tribool
{
    return [MCTribool triboolWithValue:[MCTribool kleeneImplicationOfTriboolValueA:self.triboolValue
                                                                     triboolValueB:tribool.triboolValue]];
}

- (MCTribool *)lukasiewiczImplication:(MCTribool *)tribool
{
    return [MCTribool triboolWithValue:[MCTribool lukasiewiczImplicationOfTriboolValueA:self.triboolValue
                                                                          triboolValueB:tribool.triboolValue]];
}

#pragma mark - Class operators

+ (MCTriboolValue)conjunctionOfTriboolValueA:(MCTriboolValue)triboolValueA
                               triboolValueB:(MCTriboolValue)triboolValueB
{
    return MIN(triboolValueA, triboolValueB);
}

+ (MCTriboolValue)disjunctionOfTriboolValueA:(MCTriboolValue)triboolValueA
                               triboolValueB:(MCTriboolValue)triboolValueB
{
    return MAX(triboolValueA, triboolValueB);
}

+ (MCTriboolValue)negationOfTriboolValue:(MCTriboolValue)triboolValue
{
    return -1 * triboolValue;
}

+ (MCTriboolValue)kleeneImplicationOfTriboolValueA:(MCTriboolValue)triboolValueA
                                     triboolValueB:(MCTriboolValue)triboolValueB
{
    return MAX(-1 * triboolValueA, triboolValueB);
}

+ (MCTriboolValue)lukasiewiczImplicationOfTriboolValueA:(MCTriboolValue)triboolValueA
                                          triboolValueB:(MCTriboolValue)triboolValueB
{
    return MIN(1, 1 - triboolValueA + triboolValueB);
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MCTribool *triboolCopy = [[self class] allocWithZone:zone];
    
    triboolCopy->_triboolValue = _triboolValue;
    
    return triboolCopy;
}

@end

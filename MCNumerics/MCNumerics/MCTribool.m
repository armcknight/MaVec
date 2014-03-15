//
//  MCTribool.m
//  MCNumerics
//
//  Created by andrew mcknight on 1/4/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import "MCTribool.h"

typedef enum : NSUInteger {
    MCTriboolBinaryOperationAnd,
    MCTriboolBinaryOperationOr,
    MCTriboolBinaryOperationKleeneImplication,
    MCTriboolBinaryOperationLukasiewiczImplication
} MCTriboolBinaryOperation;

@interface MCTribool ()

- (MCTribool *)performBinaryOperation:(MCTriboolBinaryOperation)operation
                             triboolA:(MCTribool *)triboolA
                             triboolB:(MCTribool *)triboolB;

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

#pragma mark - Logical operations

- (MCTribool *)andTribool:(MCTribool *)tribool
{
    return [self performBinaryOperation:MCTriboolBinaryOperationAnd triboolA:self triboolB:tribool];
}

- (MCTribool *)orTribool:(MCTribool *)tribool
{
    return [self performBinaryOperation:MCTriboolBinaryOperationOr triboolA:self triboolB:tribool];
}

- (MCTribool *)negate
{
    if (self.triboolValue == MCTriboolValueUnknown) {
        return [MCTribool triboolWithValue:MCTriboolValueUnknown];
    } else {
        return [MCTribool triboolWithValue:![self isYes]];
    }
}

- (MCTribool *)kleeneImplication:(MCTribool *)tribool
{
    return [self performBinaryOperation:MCTriboolBinaryOperationKleeneImplication triboolA:self triboolB:tribool];
}

- (MCTribool *)lukasiewiczImplication:(MCTribool *)tribool
{
    return [self performBinaryOperation:MCTriboolBinaryOperationLukasiewiczImplication triboolA:self triboolB:tribool];
}

- (MCTribool *)performBinaryOperation:(MCTriboolBinaryOperation)operation
                             triboolA:(MCTribool *)triboolA
                             triboolB:(MCTribool *)triboolB
{
    MCTribool *result;
    
    if (triboolA.triboolValue == MCTriboolValueUnknown) {
        if (triboolB.triboolValue == MCTriboolValueUnknown) {
            if (operation == MCTriboolBinaryOperationLukasiewiczImplication) {
                result = [MCTribool triboolWithValue:MCTriboolValueYes];
            } else {
                result = [MCTribool triboolWithValue:MCTriboolValueUnknown];
            }
        } else {
            switch (operation) {
                default: case MCTriboolBinaryOperationAnd:
                    result = [MCTribool triboolWithValue:[triboolB isYes] ? MCTriboolValueUnknown : MCTriboolValueNo];
                    break;
                case MCTriboolBinaryOperationOr:
                    result = [MCTribool triboolWithValue:[triboolB isYes] ? MCTriboolValueYes : MCTriboolValueUnknown];
                    break;
                case MCTriboolBinaryOperationKleeneImplication:
                case MCTriboolBinaryOperationLukasiewiczImplication:
                    result = [MCTribool triboolWithValue:[triboolB isYes] ? MCTriboolValueYes : MCTriboolValueUnknown];
                    break;
            }
        }
    } else if (triboolB.triboolValue == MCTriboolValueUnknown) {
        if (triboolA.triboolValue == MCTriboolValueUnknown) {
            if (operation == MCTriboolBinaryOperationLukasiewiczImplication) {
                result = [MCTribool triboolWithValue:MCTriboolValueYes];
            } else {
                result = [MCTribool triboolWithValue:MCTriboolValueUnknown];
            }
        } else {
            switch (operation) {
                default: case MCTriboolBinaryOperationAnd:
                    result = [MCTribool triboolWithValue:[triboolA isYes] ? MCTriboolValueUnknown : MCTriboolValueNo];
                    break;
                case MCTriboolBinaryOperationOr:
                    result = [MCTribool triboolWithValue:[triboolA isYes] ? MCTriboolValueYes : MCTriboolValueUnknown];
                    break;
                case MCTriboolBinaryOperationKleeneImplication:
                case MCTriboolBinaryOperationLukasiewiczImplication:
                    result = [MCTribool triboolWithValue:[triboolA isYes] ? MCTriboolValueUnknown : MCTriboolValueYes];
                    break;
            }
        }
    } else {
        switch (operation) {
            default: case MCTriboolBinaryOperationAnd:
                result = [MCTribool triboolWithValue:([triboolA isYes] && [triboolB isYes]) ? MCTriboolValueYes : MCTriboolValueNo];
                break;
            case MCTriboolBinaryOperationOr:
                result = [MCTribool triboolWithValue:([triboolA isYes] || [triboolB isYes]) ? MCTriboolValueYes : MCTriboolValueNo];
                break;
            case MCTriboolBinaryOperationKleeneImplication:
            case MCTriboolBinaryOperationLukasiewiczImplication:
                result = [MCTribool triboolWithValue:(![triboolA isYes] || [triboolB isYes]) ? MCTriboolValueYes : MCTriboolValueNo];
                break;
        }
    }
    
    return result;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MCTribool *triboolCopy = [[self class] allocWithZone:zone];
    
    triboolCopy->_triboolValue = _triboolValue;
    
    return triboolCopy;
}

@end

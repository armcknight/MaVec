//
//  MCQRFactorization.m
//  MCNumerics
//
//  Created by andrew mcknight on 1/14/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import "MCQRFactorization.h"

@implementation MCQRFactorization

#pragma mark - Init

- (instancetype)initWithMatrix:(MCMatrix *)matrix
{
    self = [super init];
    if (self) {
        // TODO: implement
        @throw kMCUnimplementedMethodException;
    }
    return self;
}

+ (instancetype)qrFactorizationOfMatrix:(MCMatrix *)matrix
{
    return [[MCQRFactorization alloc] initWithMatrix:matrix];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MCQRFactorization *qrCopy = [[self class] allocWithZone:zone];
    
    qrCopy->_q = _q;
    qrCopy->_r = _r;
    
    return qrCopy;
}

@end

//
//  MCLUFactorization.m
//  MCNumerics
//
//  Created by andrew mcknight on 12/15/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import "MCLUFactorization.h"

@implementation MCLUFactorization

#pragma mark - Init

- (id)initWithL:(MCMatrix *)l u:(MCMatrix *)u
{
    self = [super init];
    if (self) {
        self.l = l;
        self.u = u;
        self.d = nil;
    }
    return self;
}

+ (id)luFactorizationWithL:(MCMatrix *)l u:(MCMatrix *)u
{
    return [[MCLUFactorization alloc] initWithL:l u:u];
}

@end

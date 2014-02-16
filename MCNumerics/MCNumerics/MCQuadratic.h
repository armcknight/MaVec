//
//  MCQuadratic.h
//  MCNumerics
//
//  Created by andrew mcknight on 2/15/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCPolynomial.h"

@class MCPair;

@interface MCQuadratic : MCPolynomial

@property (strong, nonatomic, readonly) MCPair *roots;

- (instancetype)initWithA:(NSNumber *)a b:(NSNumber *)b c:(NSNumber *)c;
+ (instancetype)quadraticWithA:(NSNumber *)a b:(NSNumber *)b c:(NSNumber *)c;

@end

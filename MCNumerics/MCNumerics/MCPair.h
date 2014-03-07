//
//  MCPair.h
//  MCNumerics
//
//  Created by andrew mcknight on 2/15/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCPair : NSObject

@property (strong, nonatomic, readonly) NSNumber *first;
@property (strong, nonatomic, readonly) NSNumber *second;

- (instancetype)initWithFirst:(NSNumber *)first second:(NSNumber *)second;
+ (instancetype)pairWithFirst:(NSNumber *)first second:(NSNumber *)second;

@end

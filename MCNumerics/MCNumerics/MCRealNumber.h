//
//  MCValue.h
//  MCNumerics
//
//  Created by andrew mcknight on 4/12/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : UInt8 {
    MCValuePrecisionSingle,
    MCValuePrecisionDouble,
} MCValuePrecision;

@interface MCRealNumber : NSObject

@property (assign, nonatomic, readonly) MCValuePrecision precision;
@property (strong, nonatomic, readonly) NSNumber *realValue;

- (instancetype)initWithValue:(NSNumber *)value precision:(MCValuePrecision)precision;
+ (instancetype)realNumberWithValue:(NSNumber *)value precision:(MCValuePrecision)precision;

@end

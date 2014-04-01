//
//  DynamicArrayUtility.h
//  MCNumerics
//
//  Created by andrew mcknight on 3/31/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DynamicArrayUtility : NSObject

+ (double *)dynamicArrayForStaticArray:(double [])array size:(int)size;

@end

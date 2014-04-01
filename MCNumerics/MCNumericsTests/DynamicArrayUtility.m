//
//  DynamicArrayUtility.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/31/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#include "DynamicArrayUtility.h"

@implementation DynamicArrayUtility

+ (double *)dynamicArrayForStaticArray:(double [])array size:(int)size
{
    double *dynamicValues = malloc(size * sizeof(double));
    for (int i = 0; i < size; i++) {
        dynamicValues[i] = array[i];
    }
    return dynamicValues;
}

@end

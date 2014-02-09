//
//  EigenvalueDecomposition.h
//  MCNumerics
//
//  Created by andrew mcknight on 1/4/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCMatrix;
@class MCVector;

@interface MCEigendecomposition : NSObject

@property (strong, nonatomic) MCMatrix *z;
@property (strong, nonatomic) MCVector *a;

- (instancetype)initWithMatrix:(MCMatrix *)matrix;
+ (instancetype)eigendecompositionOfMatrix:(MCMatrix *)matrix;

@end

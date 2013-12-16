//
//  MCSingularValueDecomposition.m
//  MCNumerics
//
//  Created by andrew mcknight on 12/15/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import "MCSingularValueDecomposition.h"
#import "MCMatrix.h"

@implementation MCSingularValueDecomposition

- (id)initWithM:(NSUInteger)m n:(NSUInteger)n numberOfSingularValues:(NSUInteger)s
{
    self = [super init];
    if (self) {
        self.u = [MCMatrix matrixWithRows:m columns:m];
        self.vT = [MCMatrix matrixWithRows:n columns:n];
        self.s = [MCMatrix matrixWithRows:m columns:n];
    }
    return self;
}

+ (id)SingularValueDecompositionWithM:(NSUInteger)m n:(NSUInteger)n numberOfSingularValues:(NSUInteger)s
{
    return [[MCSingularValueDecomposition alloc] initWithM:m n:n numberOfSingularValues:s];
}

@end

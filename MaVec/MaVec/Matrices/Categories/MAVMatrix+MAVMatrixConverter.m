//
//  MAVMatrix+MAVMatrixConverter.m
//  MaVec
//
//  Created by Andrew McKnight on 6/29/15.
//  Copyright © 2015 AMProductions. All rights reserved.
//

#import "MAVMatrix+MAVMatrixConverter.h"

@implementation MAVMatrix (MAVMatrixConverter)

- (CMRotationMatrix)CMRotationMatrix {
    CMRotationMatrix rotationMatrix;

    rotationMatrix.m11 = [[self valueAtRow:0 column:0] doubleValue];
    rotationMatrix.m12 = [[self valueAtRow:0 column:1] doubleValue];
    rotationMatrix.m13 = [[self valueAtRow:0 column:2] doubleValue];
    rotationMatrix.m21 = [[self valueAtRow:1 column:0] doubleValue];
    rotationMatrix.m22 = [[self valueAtRow:1 column:1] doubleValue];
    rotationMatrix.m23 = [[self valueAtRow:1 column:2] doubleValue];
    rotationMatrix.m31 = [[self valueAtRow:2 column:0] doubleValue];
    rotationMatrix.m32 = [[self valueAtRow:2 column:1] doubleValue];
    rotationMatrix.m33 = [[self valueAtRow:2 column:2] doubleValue];

    return rotationMatrix;
}

@end

//
//  MAVMatrix+MAVMatrixConverter.m
//  MaVec
//
//  Created by Andrew McKnight on 6/29/15.
//
//  Copyright © 2015 AMProductions
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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

//
//  MAVMatrix+MAVMatrixConverter.h
//  MaVec
//
//  Created by Andrew McKnight on 6/29/15.
//  Copyright © 2015 AMProductions. All rights reserved.
//

#import "MAVMatrix.h"

@import CoreMotion;

@interface MAVMatrix (MAVMatrixConverter)

- (CMRotationMatrix)CMRotationMatrix;

@end

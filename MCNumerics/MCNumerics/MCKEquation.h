//
//  MCKEquation.h
//  
//
//  Created by Andrew McKnight on 12/31/13.
//
//

#import <Foundation/Foundation.h>

@protocol MAVEquation <NSObject>

@required

- (id<MAVEquation>)derivativeOfDegree:(NSUInteger)degree;

- (NSNumber *)evaluateAtValue:(NSNumber *)value;
- (NSNumber *)evaluateDerivativeOfDegree:(NSUInteger)degree withValue:(NSNumber *)value;

- (NSNumber *)areaUnderCurveBetweenA:(NSNumber *)a b:(NSNumber *)b;
- (NSNumber *)arcLengthBetweenA:(NSNumber *)a b:(NSNumber *)b;

@end

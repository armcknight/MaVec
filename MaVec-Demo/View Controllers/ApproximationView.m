//
//  ApproximationView.m
//  MaVec-Demo
//
//  Created by andrew mcknight on 12/19/13.
//
//  Copyright (c) 2014 Andrew Robert McKnight
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

#import "ApproximationView.h"
#import "MAVMatrix+MAVMatrixFactory.h"
#import "MAVMatrix.h"
#import "MAVVector.h"
#import "MCKPolynomial.h"

@interface MAVPoint : NSObject

@property (assign, nonatomic) CGFloat x, y;
- (id)initWithX:(CGFloat)x y:(CGFloat)y;

@end

@implementation MAVPoint

- (id)initWithX:(CGFloat)x y:(CGFloat)y
{
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
    }
    return self;
}

@end

@interface ApproximationView ()

@property (strong, nonatomic) NSMutableArray *points;
@property (strong, nonatomic) MCKPolynomial *polynomial;


@end

@implementation ApproximationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.points = [NSMutableArray array];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    [self.points addObject:[[MAVPoint alloc] initWithX:touchPoint.x y:touchPoint.y]];
    [self approximate];
    [self setNeedsDisplay];
}

- (void)approximate
{
    if (self.points.count >= self.order) {
        size_t aSize = self.points.count * self.order * sizeof(double);
        double *aVals = malloc(aSize);
        
        size_t bSize = self.points.count * sizeof(double);
        double *bVals = malloc(bSize);
        
        for (int i = 0; i < self.points.count; i++) {
            for (int p = 0; p < self.order; p++) {
                int idx = i * self.order + p;
                double val = pow(((MAVPoint *)self.points[i]).x, p);
                aVals[idx] = val;
            }
        }
        
        for (int i = 0; i < self.points.count; i++) {
            bVals[i] = ((MAVPoint *)self.points[i]).y;
        }
        
        MAVMatrix *a = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:aVals length:aSize] rows:(int)self.points.count columns:self.order leadingDimension:MAVMatrixLeadingDimensionRow];
        MAVVector *b = [MAVVector vectorWithValues:[NSData dataWithBytesNoCopy:bVals length:bSize] length:(int)self.points.count];
        
        MAVVector *coefficients = [MAVMatrix solveLinearSystemWithMatrixA:a valuesB:b];
        
        NSMutableArray *cArray = [NSMutableArray array];
        for (int i = 0; i < self.order; i++) {
            [cArray addObject:coefficients[i]];
        }
        
        self.polynomial = [MCKPolynomial polynomialWithCoefficients:cArray];
    } else {
        self.polynomial = nil;
    }
    [self setNeedsDisplay];
}

- (void)setOrder:(int)order
{
    _order = order;
    [self approximate];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    
    for (MAVPoint *p in self.points) {
        CGContextFillEllipseInRect(ctx, CGRectMake(p.x - 3.f, p.y - 3.f, 6.f, 6.f));
    }
    
    CGContextMoveToPoint(ctx, 0, [self.polynomial evaluateAtValue:@0].floatValue);
    if (self.polynomial) {
        for (int i = 0; i < self.frame.size.width - 1; i++) {
            CGFloat x = i;
            CGFloat y = /*self.frame.size.height -*/ [self.polynomial evaluateAtValue:@(x)].floatValue;
            CGContextAddLineToPoint(ctx, x, y);
            CGContextStrokePath(ctx);
            CGContextMoveToPoint(ctx, x, y);
        }
    }
}

@end

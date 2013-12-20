//
//  ApproximationView.m
//  MCNumerics
//
//  Created by andrew mcknight on 12/19/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import "ApproximationView.h"
#import "MCPolynomial.h"
#import "MCMatrix.h"

@interface MCPoint : NSObject

@property (assign, nonatomic) CGFloat x, y;
- (id)initWithX:(CGFloat)x y:(CGFloat)y;

@end

@implementation MCPoint

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
@property (strong, nonatomic) MCPolynomial *polynomial;


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
    [self.points addObject:[[MCPoint alloc] initWithX:touchPoint.x y:touchPoint.y]];
    [self approximate];
    [self setNeedsDisplay];
}

- (void)approximate
{
    if (self.points.count >= self.order) {
        double *aVals = malloc(self.points.count * self.order * sizeof(double));
        double *bVals = malloc(self.points.count * sizeof(double));
        
        for (int i = 0; i < self.points.count; i++) {
            for (int p = 0; p < self.order; p++) {
                int idx = i * self.order + p;
                double val = pow(((MCPoint *)self.points[i]).x, p);
                aVals[idx] = val;
            }
        }
        
        for (int i = 0; i < self.points.count; i++) {
            bVals[i] = ((MCPoint *)self.points[i]).y;
        }
        MCMatrix *a = [[MCMatrix matrixWithValues:aVals rows:self.points.count columns:self.order valueStorageFormat:MCMatrixValueStorageFormatRowMajor] matrixWithValuesStoredInFormat:MCMatrixValueStorageFormatColumnMajor];
        MCMatrix *b = [MCMatrix matrixWithValues:bVals rows:self.points.count columns:1];
        
        MCMatrix *coefficients = [MCMatrix solveLinearSystemWithMatrixA:a valuesB:b];
        
        NSMutableArray *cArray = [NSMutableArray array];
        for (int i = 0; i < self.order; i++) {
            [cArray addObject:@([coefficients valueAtRow:i column:0])];
        }
        
        self.polynomial = [MCPolynomial polynomialWithCoefficients:cArray];
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
    
    for (MCPoint *p in self.points) {
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

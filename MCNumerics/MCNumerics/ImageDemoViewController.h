//
//  ImageDemoViewController.h
//  MCNumerics
//
//  Created by andrew mcknight on 12/17/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ImageDemoTypeAlphaCompositing,
    ImageDemoTypeConvolution,
    ImageDemoTypeDecompression,
    ImageDemoTypeGeometry,
    ImageDemoTypeHistogram,
    ImageDemoTypeMorphology,
    ImageDemoTypeTransform
} ImageDemoType;

@interface ImageDemoViewController : UIViewController

- (id)initWithDemoType:(ImageDemoType)demoType;

@end

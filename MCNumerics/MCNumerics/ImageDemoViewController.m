//
//  ImageDemoViewController.m
//  MCNumerics
//
//  Created by andrew mcknight on 12/17/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Accelerate/Accelerate.h>

#import "ImageDemoViewController.h"

@interface ImageDemoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@property (assign, nonatomic) ImageDemoType demoType;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation ImageDemoViewController

- (id)initWithDemoType:(ImageDemoType)demoType
{
    self = [super init];
    if (self) {
        self.demoType = demoType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    
    [[[UIAlertView alloc] initWithTitle:@"Choose image source" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Camera roll", @"Take a photo", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    if (buttonIndex == 0) {
        // obtain a picture from camera or camera roll
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else if (buttonIndex == 1) {
        // bring up the camera
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CGImageRef imageRef = image.CGImage;
    CGDataProviderRef inputProvider = CGImageGetDataProvider(imageRef);
    CFDataRef inputData = CGDataProviderCopyData(inputProvider);
    
    vImage_Buffer input;
    input.data = (void *)CFDataGetBytePtr(inputData);
    input.width = CGImageGetWidth(imageRef);
    input.height = CGImageGetHeight(imageRef);
    input.rowBytes = CGImageGetBytesPerRow(imageRef);
    
    void *outputBuffer = malloc(input.rowBytes * input.height);
    
    vImage_Buffer output;
    output.data = outputBuffer;
    output.width = CGImageGetWidth(imageRef);
    output.height = CGImageGetHeight(imageRef);
    output.rowBytes = CGImageGetBytesPerRow(imageRef);
    
    int16_t gaussianBlurKernel[13] = {1, 2, 4, 8, 16, 32, 64, 32, 16, 8, 4, 2, 1};
    
    int16_t *kernel = gaussianBlurKernel;
    int32_t divisor = 0;
    for (int i = 0; i < 9; i++) {
        divisor += kernel[i];
    }
    
    vImage_Error error = vImageConvolve_ARGB8888(&input, &input, NULL, 0, 0, kernel, 13, 1, divisor, NULL, kvImageEdgeExtend);
    BOOL succeeded = [self handleVimageErrorCode:error];
    if (succeeded) {
        error = vImageConvolve_ARGB8888(&input, &input, NULL, 0, 0, kernel, 1, 13, divisor, NULL, kvImageEdgeExtend);
        BOOL succeeded = [self handleVimageErrorCode:error];
        if (succeeded) {
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            
            CGContextRef ctx = CGBitmapContextCreate(input.data,
                                                     input.width,
                                                     input.height,
                                                     8,
                                                     input.rowBytes,
                                                     colorSpace,
                                                     kCGImageAlphaNoneSkipLast);
            
            CGImageRef convolvedImageRef = CGBitmapContextCreateImage (ctx);
            
            UIImage *returnImage = [UIImage imageWithCGImage:convolvedImageRef];
            
            //clean up
            CGContextRelease(ctx);
            CGColorSpaceRelease(colorSpace);
            
            // ???: these are causing crashes
            //        free(outputBuffer);
            //        CFRelease(inputData);
            //        CGDataProviderRelease(inputProvider);
            //        CGImageRelease(imageRef);
            
            //- See more at: http://indieambitions.com/idevblogaday/perform-blur-vimage-accelerate-framework-tutorial/#sthash.ibraHDkN.dpuf
            
            self.imageView.image = returnImage;
        }
    }
}

- (BOOL)handleVimageErrorCode:(vImage_Error)error
{
    switch (error) {
        default: case kvImageNoError:
            return YES;
            break;
        case kvImageRoiLargerThanInputBuffer:
            
            break;
            
        case kvImageInvalidKernelSize :
            
            break;
        case kvImageInvalidEdgeStyle :
            
            break;
        case kvImageInvalidOffset_X  :
            
            break;
        case kvImageInvalidOffset_Y :
            
            break;
        case kvImageMemoryAllocationError :
            
            break;
        case kvImageNullPointerArgument :
            
            break;
        case kvImageInvalidParameter :
            
            break;
        case kvImageBufferSizeMismatch :
            
            break;
        case kvImageUnknownFlagsBit :
            
            break;
        case kvImageInternalError :
            /* Should never see this. File a bug! */
            
            break;
        case kvImageInvalidRowBytes  :
            
            break;
        case kvImageInvalidImageFormat :
            
            break;
        case kvImageColorSyncIsAbsent :
            
            break;
        case kvImageOutOfPlaceOperationRequired :
            
            break;
    }
    return NO;
}

@end

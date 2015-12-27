//
//  SVDImageCompressionViewController.m
//  MaVec-Demo
//
//  Created by andrew mcknight on 3/30/14.
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

#import <MaVec/MaVec.h>

#import "SVDImageCompressionViewController.h"

@interface SVDImageCompressionViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UISlider *compressionSlider;
@property (strong, nonatomic) IBOutlet UILabel *compressionLabel;

@property (strong, nonatomic) IBOutlet UIView *progressView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) MAVSingularValueDecomposition *imageSVD;

@property (assign, nonatomic) int currentAmountOfSingularValues;

void freePixelValues(void *info, const void *data, size_t size);

@end

@implementation SVDImageCompressionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - Actions

- (IBAction)takePhotoPressed:(id)sender
{
    ((UIButton *)sender).enabled = NO;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)compressionSliderValueChanged:(id)sender
{
    MAVIndex singularValues = (MAVIndex)((UISlider *)sender).value;
    self.compressionLabel.text = [NSString stringWithFormat:@"Singular values: %d/%d", singularValues, self.imageSVD.s.diagonalValues.length];
}

- (IBAction)compressionSliderFinishedChangingValue:(id)sender
{
    MAVIndex singularValues = (MAVIndex)((UISlider *)sender).value;
    if (self.currentAmountOfSingularValues != singularValues) {
        self.currentAmountOfSingularValues = singularValues;
        __weak SVDImageCompressionViewController *wself = self;
        [self setProgressViewVisible:YES completion:^{
            wself.imageView.image = [wself compressedImageWithSingularValues:singularValues];
            [wself setProgressViewVisible:NO completion:nil];
        }];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *grayscaleImage = [self getGrayscaleImageFromImage:image];
    UIImage *croppedGrayscaleImage = [self cropImage:grayscaleImage];
    
    self.imageView.image = croppedGrayscaleImage;
    
    MAVMatrix *grayscaleValues = [self getGrayscalePixelValuesFromImage:croppedGrayscaleImage];
    self.imageSVD = [MAVSingularValueDecomposition singularValueDecompositionWithMatrix:grayscaleValues];
    
    MAVVector *singularValues = self.imageSVD.s.diagonalValues;
    self.compressionSlider.minimumValue = 1;
    self.compressionSlider.maximumValue = singularValues.length;
    self.currentAmountOfSingularValues = singularValues.length;
    self.compressionSlider.enabled = YES;
    [self.compressionSlider setValue:singularValues.length animated:YES];
    self.compressionLabel.text = [NSString stringWithFormat:@"Singular values: %d/%d", singularValues.length, self.imageSVD.s.diagonalValues.length];
}

#pragma mark - Private interface

// adapted from http://stackoverflow.com/questions/448125/how-to-get-pixel-data-from-a-uiimage-cocoa-touch-or-cgimage-core-graphics
- (MAVMatrix *)getGrayscalePixelValuesFromImage:(UIImage*)image
{
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger numberOfPixels = height * width;
    double *grayscaleValues = calloc(numberOfPixels, sizeof(double));
    NSUInteger z = 0;
    for (NSUInteger i = 0 ; i < numberOfPixels ; i++) {
        grayscaleValues[i] = (rawData[z] * 1.0) / 255.0;
        z += 4;
    }
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
//    CGImageRelease(imageRef); // bad access
    free(rawData);
    
    MAVMatrix *grayscaleMatrix = [MAVMatrix matrixWithValues:[NSData dataWithBytesNoCopy:grayscaleValues length:numberOfPixels*sizeof(double)] rows:(int)height columns:(int)width];
    
    return grayscaleMatrix;
}

// adapted from http://stackoverflow.com/questions/1298867/convert-image-to-grayscale
- (UIImage *)getGrayscaleImageFromImage:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, YES, 1.0);
    CGRect imageRect;
    imageRect.origin = CGPointZero;
    imageRect.size = image.size;
    
    // Draw the image with the luminosity blend mode.
    // On top of a white background, this will give a black and white image.
    [image drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0];
    
    // Get the resulting image.
    UIImage *filteredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return filteredImage;
}

// adapted from http://stackoverflow.com/questions/158914/cropping-a-uiimage
- (UIImage *)cropImage:(UIImage *)image
{
    CGFloat squareSize = 300;
    CGRect imageRect = CGRectMake((image.size.width - squareSize) / 2, (image.size.height - squareSize) / 2, squareSize, squareSize);
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(image.CGImage, imageRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef scale:1 orientation:UIImageOrientationUp];
    CGImageRelease(croppedImageRef);
    
    return croppedImage;
}

void freePixelValues(void *info, const void *data, size_t size) {
    free((unsigned char *)data);
}

// adapted from http://stackoverflow.com/questions/4545237/creating-uiimage-from-raw-rgba-data
- (UIImage *)compressedImageWithSingularValues:(int)singularValues
{
    MAVMutableVector *partialSum = [(MAVMutableVector *)[[self.imageSVD.u columnVectorForColumn:0] mutableCopy] multiplyByScalar:[self.imageSVD.s.diagonalValues valueAtIndex:0]];
    MAVMutableMatrix *leftMultiplicand = [MAVMutableMatrix matrixWithValues:partialSum.values rows:partialSum.length columns:1];
    MAVVector *rightMultiplicandVector = [self.imageSVD.vT rowVectorForRow:0];
    MAVMatrix *rightMultiplicand = [MAVMatrix matrixWithValues:rightMultiplicandVector.values rows:1 columns:rightMultiplicandVector.length];
    MAVMutableMatrix *sum = [[leftMultiplicand mutableCopy] multiplyByMatrix:rightMultiplicand];
    for (int i = singularValues - 1; i >= 0; i--) {
        partialSum = [(MAVMutableVector *)[[self.imageSVD.u columnVectorForColumn:i] mutableCopy] multiplyByScalar:[self.imageSVD.s.diagonalValues valueAtIndex:i]];
        leftMultiplicand = [MAVMutableMatrix matrixWithValues:partialSum.values rows:partialSum.length columns:1];
        rightMultiplicandVector = [self.imageSVD.vT rowVectorForRow:i];
        rightMultiplicand = [MAVMatrix matrixWithValues:rightMultiplicandVector.values rows:1 columns:rightMultiplicandVector.length];
        [sum multiplyByMatrix:[leftMultiplicand multiplyByMatrix:rightMultiplicand]];
    }
    
    int size = sum.rows * sum.columns;
    unsigned char *pixelValues = malloc(size * 4);
    for (int i = 0; i < size; i++) {
        double grayscaleValue = ((double *)sum.values.bytes)[i];
        unsigned char bitValue = (unsigned char)MIN(255, MAX(0, (int)(grayscaleValue * 255)));
        pixelValues[4 * i] = bitValue;
        pixelValues[4 * i + 1] = bitValue;
        pixelValues[4 * i + 2] = bitValue;
        pixelValues[4 * i + 3] = 255;
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, pixelValues, size * 4, (CGDataProviderReleaseDataCallback)&freePixelValues);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imageRef = CGImageCreate(sum.columns,
                                        sum.rows,
                                        8,
                                        32,
                                        4 * sum.columns,
                                        colorSpace,
                                        kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        NO,
                                        kCGRenderingIntentDefault);
    
    UIImage *compressedImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
//    free(pixelValues); // bad access
    
    return compressedImage;
}

- (void)setProgressViewVisible:(BOOL)visible completion:(void(^)())completion
{
    if (visible) {
        [self.activityIndicator startAnimating];
        self.progressView.hidden = NO;
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.progressView.alpha = visible ? 0.5f : 0.f;
                     }
                     completion:^(BOOL finished) {
                         if (!visible) {
                             self.progressView.hidden = YES;
                             [self.activityIndicator stopAnimating];
                         }
                         if (completion) {
                             completion();
                         }
                     }];
}

@end

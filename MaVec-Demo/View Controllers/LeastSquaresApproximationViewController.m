//
//  LinearApproximationViewController.m
//  MaVec-Demo
//
//  Created by andrew mcknight on 12/3/13.
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

#import <Accelerate/Accelerate.h>

#import "LeastSquaresApproximationViewController.h"
#import "ApproximationView.h"

@interface LeastSquaresApproximationViewController ()

@property (strong, nonatomic) IBOutlet ApproximationView *approximationView;
@property (strong, nonatomic) IBOutlet UISlider *orderSlider;
@property (strong, nonatomic) IBOutlet UILabel *orderLabel;

@end

@implementation LeastSquaresApproximationViewController

- (id)init
{
    return [super initWithNibName:@"LinearApproximationView" bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.approximationView.order = 3;
    self.orderLabel.text = @"2";
    [self.orderSlider setValue:0.3f animated:YES];
}

- (IBAction)changedOrder:(id)sender {
    __CLPK_integer order = (__CLPK_integer)self.orderSlider.value * 10;
    self.approximationView.order = order;
    self.orderLabel.text = [NSString stringWithFormat:@"%lld", (long long int)order-1];
}

@end

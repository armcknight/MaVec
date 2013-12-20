//
//  LinearApproximationViewController.m
//  MCNumerics
//
//  Created by andrew mcknight on 12/3/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import "LinearApproximationViewController.h"
#import "ApproximationView.h"

@interface LinearApproximationViewController ()

@property (strong, nonatomic) IBOutlet ApproximationView *approximationView;
@property (strong, nonatomic) IBOutlet UISlider *orderSlider;
@property (strong, nonatomic) IBOutlet UILabel *orderLabel;

@end

@implementation LinearApproximationViewController

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
    [self.orderSlider setValue:0.3 animated:YES];
}

- (IBAction)changedOrder:(id)sender {
    int order = self.orderSlider.value * 10;
    self.approximationView.order = order;
    self.orderLabel.text = [NSString stringWithFormat:@"%u", order-1];
}

@end

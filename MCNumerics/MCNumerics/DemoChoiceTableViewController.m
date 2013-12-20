//
//  DemoChoiceTableViewController.m
//  MCNumerics
//
//  Created by andrew mcknight on 12/3/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import "DemoChoiceTableViewController.h"
#import "ImageDemoViewController.h"
#import "LinearApproximationViewController.h"

#define kCellIdentifier @"kCellIdentifier"

@interface DemoChoiceTableViewController () <RZCollectionListTableViewDataSourceDelegate, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) RZArrayCollectionList *demosACL;
@property (strong, nonatomic) RZCollectionListTableViewDataSource *tableViewDataSource;

@end

#define kImageDemoNameAlphaCompositing @"Alpha Compositing"
#define kImageDemoNameConvolution @"Convolution"
#define kImageDemoNameDecompression @"Decompression Filtering"
#define kImageDemoNameGeometry @"Geometry"
#define kImageDemoNameHistogram @"Histogram"
#define kImageDemoNameMorphology @"Morphology"
#define kImageDemoNameTransform @"Transform"

@implementation DemoChoiceTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    self.demosACL = [[RZArrayCollectionList alloc] initWithSectionTitlesAndSectionArrays:@"Approximations", @[@"Linear Approximation"],
                     @"Images", @[kImageDemoNameAlphaCompositing, kImageDemoNameConvolution, kImageDemoNameDecompression, kImageDemoNameGeometry, kImageDemoNameHistogram, kImageDemoNameMorphology, kImageDemoNameTransform], nil];
    
    self.tableViewDataSource = [[RZCollectionListTableViewDataSource alloc] initWithTableView:self.tableView collectionList:self.demosACL delegate:self];
}

#pragma mark - RZCollectionListTableViewDataSourceDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        cell.textLabel.text = object;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return ((RZArrayCollectionListSectionInfo *)[self.demosACL.sections objectAtIndex:section]).name;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.navigationController pushViewController:[[LinearApproximationViewController alloc] initWithNibName:@"LinearApproximationViewController" bundle:[NSBundle mainBundle]] animated:YES];
    } else {
        NSString *demoName = [self.demosACL objectAtIndexPath:indexPath];
        ImageDemoType demoType;
        
        if ([demoName isEqualToString:kImageDemoNameAlphaCompositing]) {
            demoType = ImageDemoTypeAlphaCompositing;
        } else if ([demoName isEqualToString:kImageDemoNameConvolution]) {
            demoType = ImageDemoTypeConvolution;
        } else if ([demoName isEqualToString:kImageDemoNameConvolution]) {
            demoType = ImageDemoTypeConvolution;
        } else if ([demoName isEqualToString:kImageDemoNameDecompression]) {
            demoType = ImageDemoTypeDecompression;
        } else if ([demoName isEqualToString:kImageDemoNameGeometry]) {
            demoType = ImageDemoTypeGeometry;
        } else if ([demoName isEqualToString:kImageDemoNameHistogram]) {
            demoType = ImageDemoTypeHistogram;
        } else if ([demoName isEqualToString:kImageDemoNameMorphology]) {
            demoType = ImageDemoTypeMorphology;
        } else {
            demoType = ImageDemoTypeTransform;
        }
        
        ImageDemoViewController *imageDemoVC = [[ImageDemoViewController alloc] initWithDemoType:demoType];
        [self.navigationController pushViewController:imageDemoVC animated:YES];
    }
}

@end

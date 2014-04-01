//
//  DemoChoiceTableViewController.m
//  MCNumerics
//
//  Created by andrew mcknight on 12/3/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import "DemoChoiceTableViewController.h"
#import "LeastSquaresApproximationViewController.h"

#import "RZCollectionListTableViewDataSource.h"
#import "RZArrayCollectionList.h"

#define kCellIdentifier @"kCellIdentifier"

@interface DemoChoiceTableViewController () <RZCollectionListTableViewDataSourceDelegate, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) RZArrayCollectionList *demosACL;
@property (strong, nonatomic) RZCollectionListTableViewDataSource *tableViewDataSource;

@end

@implementation DemoChoiceTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    self.demosACL = [[RZArrayCollectionList alloc] initWithSectionTitlesAndSectionArrays:@"Approximations", @[@"Linear Approximation"], nil];
    
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
    } else {
        
        [self.navigationController pushViewController:[[LeastSquaresApproximationViewController alloc] initWithNibName:@"LinearApproximationViewController" bundle:[NSBundle mainBundle]] animated:YES];
    }
}

@end

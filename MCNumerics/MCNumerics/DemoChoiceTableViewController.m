//
//  DemoChoiceTableViewController.m
//  MCNumerics
//
//  Created by andrew mcknight on 12/3/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import "DemoChoiceTableViewController.h"

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
    
    NSArray *approximations = @[@"Linear Approximation"];
    self.demosACL = [[RZArrayCollectionList alloc] initWithSectionTitlesAndSectionArrays:@"Approximations", approximations, nil];
    
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
    return [self.demosACL.sectionIndexTitles objectAtIndex:section];
}

@end

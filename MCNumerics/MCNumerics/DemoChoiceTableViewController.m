//
//  DemoChoiceTableViewController.m
//  MCNumerics
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

#import "DemoChoiceTableViewController.h"
#import "LeastSquaresApproximationViewController.h"
#import "SVDImageCompressionViewController.h"

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
    
    self.demosACL = [[RZArrayCollectionList alloc] initWithSectionTitlesAndSectionArrays:@"Demos", @[@"Least Squares Approximation", @"SVD Image Compression"], nil];
    
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
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[[LeastSquaresApproximationViewController alloc] initWithNibName:@"LinearApproximationViewController" bundle:[NSBundle mainBundle]] animated:YES];
    } else if (indexPath.row == 1) {
        [self.navigationController pushViewController:[[SVDImageCompressionViewController alloc] initWithNibName:@"SVDImageCompressionViewController" bundle:[NSBundle mainBundle]] animated:YES];
    }
}

@end

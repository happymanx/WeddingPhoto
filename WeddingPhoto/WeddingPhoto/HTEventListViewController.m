//
//  HTListViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/10.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTEventListViewController.h"
#import "HTEventCell.h"

@interface HTEventListViewController ()

@end

@implementation HTEventListViewController

- (id)initWithEventArr:(NSArray *)array
{
    self = [super initWithNibName:@"HTEventListViewController" bundle:nil];
    if (self) {
        eventArr = array;
        
        eventArr = @[@"Happy 1", @"Happy 2", @"Happy 3"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [eventArr count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HTEventCell *cell = [HTEventCell cell];
    
    cell.titleLabel.text = eventArr[indexPath.row];
    
    if (isEdit) {
        cell.deleteButton.hidden = NO;
        cell.arrowImageView.hidden = YES;
    }
    else {
        cell.deleteButton.hidden = YES;
        cell.arrowImageView.hidden = NO;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isEdit) {
        return;
    }
    else {
        // push
    }
}

#pragma mark - Button Methods

-(IBAction)backButtonClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)editButtonClicked:(UIButton *)button
{
    isEdit = !isEdit;
    if (isEdit) {
        [editButtom setTitle:@"完成" forState:UIControlStateNormal];
    }
    else {
        [editButtom setTitle:@"編輯" forState:UIControlStateNormal];
    }
    [displayTableView reloadData];
}
@end

//
//  HTTrialListViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/22.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTTrialListViewController.h"
#import "HTTrialCell.h"
#import "HTAdViewController.h"

@interface HTTrialListViewController ()

@end

@implementation HTTrialListViewController

- (id)initWithTrialArr:(NSArray *)array
{
    self = [super initWithNibName:@"HTTrialListViewController" bundle:nil];
    if (self) {
        trialArr = array;
        
        trialArr = @[@"Trial 1", @"Trial 2", @"Trial 3", @"Trial 4", @"Trial 5"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 顯示廣告
        HTAdViewController *vc = [[HTAdViewController alloc] initWithAdArr:@[] adType:HTAdTypeTrial];
        [self.navigationController presentViewController:vc animated:NO completion:nil];
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [trialArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HTTrialCell *cell = [HTTrialCell cell];

    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 開始下載程序
}

#pragma mark - Button Methods

-(IBAction)backButtonClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

//
//  HTVideoListViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/12.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTVideoListViewController.h"
#import "HTVideoCell.h"

@interface HTVideoListViewController ()

@end

@implementation HTVideoListViewController

- (id)initWithEventArr:(NSArray *)array
{
    self = [super initWithNibName:@"HTVideoListViewController" bundle:nil];
    if (self) {
        videoArr = array;
        
        videoArr = @[@"0BUphSdjPEw", @"uAfVxhUCDis", @"4oPw63oVqpA"];
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
    return [videoArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HTVideoCell *cell = [HTVideoCell cell];
    
    NSURL *youtubeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", videoArr[indexPath.row]]];
                         
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:youtubeURL];
        if (data) {
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.thumbnailImageView.image = image;
                });
            }
            else {
                // 預設圖
            }
        }
    });

    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - Button Methods

-(IBAction)backButtonClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

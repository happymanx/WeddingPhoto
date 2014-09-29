//
//  HTBasicViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/9.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTBasicViewController.h"

@interface HTBasicViewController ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation HTBasicViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundImageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.backgroundImageView.frame = [UIScreen mainScreen].bounds;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  HTSplashViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/10/13.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTSplashViewController.h"

@interface HTSplashViewController ()

@end

@implementation HTSplashViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [splashImageView setImage:[UIImage imageNamed:HTLocalizedString(@"bg_landing_tc.jpg", nil)]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 移除Splash影像
        [self dismissSplash];
    });
}

-(void)dismissSplash
{
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end

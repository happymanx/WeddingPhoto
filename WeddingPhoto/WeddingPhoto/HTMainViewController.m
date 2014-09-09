//
//  HTMainViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/9.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTMainViewController.h"
#import "HTListViewController.h"
#import "HTAdViewController.h"

@interface HTMainViewController ()

@end

@implementation HTMainViewController

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
    // Do any additional setup after loading the view from its nib.
    passwordTextField.placeholder = NSLocalizedString(@"請輸入下載密碼", nil);
}

-(IBAction)downloadButtonClicked:(UIButton *)button
{
    
}

-(IBAction)listButtonClicked:(UIButton *)button
{
    HTListViewController *vc = [[HTListViewController alloc] initWithEventArr:@[]];
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)cameraButtonClicked:(UIButton *)button
{
    HTAdViewController *vc = [[HTAdViewController alloc] initWithAdArr:@[]];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

-(IBAction)aboutButtonClicked:(UIButton *)button
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://google.com.tw"]];
}

@end

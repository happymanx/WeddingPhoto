//
//  HTMainViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/9.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTMainViewController.h"
#import "HTEventListViewController.h"
#import "HTVideoListViewController.h"
#import "HTTrialListViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

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

-(IBAction)eventButtonClicked:(UIButton *)button
{
    HTEventListViewController *vc = [[HTEventListViewController alloc] initWithEventArr:@[]];
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)trailButtonClicked:(UIButton *)button
{
    HTTrialListViewController *vc = [[HTTrialListViewController alloc] initWithTrialArr:@[]];
    [self.navigationController pushViewController:vc animated:YES];
    
//    DBCameraContainerViewController *cameraContainer = [[DBCameraContainerViewController alloc] initWithDelegate:self];
//    [cameraContainer setFullScreenMode];
//    
//    cameraContainer.delegate = self;
//    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraContainer];
//    [nav setNavigationBarHidden:YES];
//    [self presentViewController:nav animated:YES completion:nil];
}

-(IBAction)aboutButtonClicked:(UIButton *)button
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://google.com.tw"]];
}

#pragma mark - DBCameraViewControllerDelegate

-(void)dismissCamera:(id)cameraViewController
{
    [cameraViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
}

@end

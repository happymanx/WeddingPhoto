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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // 以暫時碼取得真實碼
    [[HTNetworkManager requestWithFinishBlock:^(NSObject *objcet) {
        DLog(@"objcet: %@", objcet);
        NSDictionary *resultDict = (NSDictionary *)objcet;
        
        // 以真實碼取得專案
        [[HTNetworkManager requestWithFinishBlock:^(NSObject *objcet) {
            DLog(@"objcet: %@", objcet);
            NSDictionary *resultDict2 = (NSDictionary *)objcet;
            // 儲存取得結果為檔案（在Documents中）
            NSString *targetPath = [[HTFileManager documentsPath] stringByAppendingPathComponent:[resultDict[@"RealDownloadKey"] description]];
            [resultDict2 writeToFile:targetPath atomically:YES];
            // 創立同名的資料夾（在Documents -> Events中）
            targetPath = [[HTFileManager eventsPath] stringByAppendingPathComponent:[resultDict[@"RealDownloadKey"] description]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:targetPath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            // 儲存Frame Image
            [HTFileManager saveFrameImageWithEventKey:[resultDict[@"RealDownloadKey"] description] infoArr:resultDict2[@"ImageFiles"]];
            
            // 儲存Ad Image
            [HTFileManager saveAdImageWithEventKey:[resultDict[@"RealDownloadKey"] description] infoArr:resultDict2[@"AdFiles"]];
            
            // 提示成功訊息
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"恭喜" message:@"你成功了！" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [av show];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failBlock:^(NSString *errStr, NSInteger errCode) {
            DLog(@"errStr: %@", errStr);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }] getProject:resultDict[@"RealDownloadKey"]];

        
    } failBlock:^(NSString *errStr, NSInteger errCode) {
        DLog(@"errStr: %@", errStr);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"注意" message:@"沒有此密碼喔！" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [av show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }] getDownloadKey:passwordTextField.text];
    

//    [[HTNetworkManager requestWithFinishBlock:^(NSObject *objcet) {
//        DLog(@"objcet: %@", objcet);
//        NSDictionary *resultDit = (NSDictionary *)objcet;
//        
//    } failBlock:^(NSString *errStr, NSInteger errCode) {
//        DLog(@"errStr: %@", errStr);
//    }] getSharedFile:@"2"];

}

-(IBAction)eventButtonClicked:(UIButton *)button
{
    HTEventListViewController *vc = [[HTEventListViewController alloc] initWithEventArr:@[]];
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)trailButtonClicked:(UIButton *)button
{
    [[HTNetworkManager requestWithFinishBlock:^(NSObject *objcet) {
        DLog(@"objcet: %@", objcet);
        NSDictionary *resultDit = (NSDictionary *)objcet;
        
        HTTrialListViewController *vc = [[HTTrialListViewController alloc] initWithTrialArr:resultDit[@"Files"]];
        [self.navigationController pushViewController:vc animated:YES];
        
    } failBlock:^(NSString *errStr, NSInteger errCode) {
        DLog(@"errStr: %@", errStr);
    }] getDemoAd];

    
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

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end

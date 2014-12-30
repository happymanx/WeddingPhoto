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
    // Do any additional setup after loading the view from its nib.
    
    [self localizeUI];
    
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    toButtonConstraintConstant = toButtonConstraint.constant;
}

-(void)localizeUI
{
    passwordTextField.placeholder = HTLocalizedString(@"請輸入下載密碼", nil);
    [trialButton setImage:[UIImage imageNamed:HTLocalizedString(@"but_demo_tc.png", nil)] forState:UIControlStateNormal];
    [eventButton setImage:[UIImage imageNamed:HTLocalizedString(@"but_folder_tc.png", nil)] forState:UIControlStateNormal];
    [aboutButton setImage:[UIImage imageNamed:HTLocalizedString(@"but_about_tc.png", nil)] forState:UIControlStateNormal];
}

-(IBAction)downloadButtonClicked:(UIButton *)button
{
    // 如果沒有輸入下載密碼
    if ([passwordTextField.text isEqualToString:@""]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"提醒", nil) message:HTLocalizedString(@"請輸入下載密碼", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"好", nil) otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    // 收起鍵盤
    [passwordTextField resignFirstResponder];
    
    // 秀HUD
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // 判斷是否有網路
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意",nil) message:HTLocalizedString(@"請開啟網路",nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"好",nil) otherButtonTitles:nil, nil];
        [av show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    // 以暫時碼取得真實碼
    [[HTNetworkManager requestWithFinishBlock:^(NSObject *objcet) {
        DLog(@"objcet: %@", objcet);
        NSDictionary *resultDict = (NSDictionary *)objcet;
        if (![[resultDict[@"Status"] description] isEqualToString:@"0"]) {// 非成功
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"提醒", nil) message:resultDict[@"ErrorMessage"] delegate:nil cancelButtonTitle:HTLocalizedString(@"確認", nil) otherButtonTitles:nil, nil];
            [av show];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            return;
        }
        // 以真實碼取得專案
        [[HTNetworkManager requestWithFinishBlock:^(NSObject *objcet) {
            DLog(@"objcet: %@", objcet);
            NSDictionary *resultDict2 = (NSDictionary *)objcet;
            if (![[resultDict2[@"Status"] description] isEqualToString:@"0"]) {// 非成功
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"提醒", nil) message:resultDict2[@"ErrorMessage"] delegate:nil cancelButtonTitle:HTLocalizedString(@"確認", nil) otherButtonTitles:nil, nil];
                [av show];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                return;
            }
            // 儲存取得結果為檔案（在Documents中）
            NSString *targetPath = [[HTFileManager documentsPath] stringByAppendingPathComponent:[resultDict[@"RealDownloadKey"] description]];
            
            // 判斷是否有舊的檔案
            if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
                // 比對舊檔與新檔的版本
                NSDictionary *oldJSON = [[NSDictionary alloc] initWithContentsOfFile:targetPath];
                NSString *oldFrameVersion = [oldJSON[@"ImageFileVersion"] description];
                NSString *oldAdVersion = [oldJSON[@"AdFileVersion"] description];
                NSString *newFrameVersion = [resultDict2[@"ImageFileVersion"] description];
                NSString *newAdVersion = [resultDict2[@"AdFileVersion"] description];
                if ([oldFrameVersion isEqualToString:newFrameVersion] && [oldAdVersion isEqualToString:newAdVersion]) {
                    
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"提醒", nil) message:HTLocalizedString(@"此密碼已下載", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"確認", nil) otherButtonTitles:nil, nil];
                    [av show];
                    
                    // 藏HUD
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    return;
                }
            }
            
            [resultDict2 writeToFile:targetPath atomically:YES];
            // 創立同名的資料夾（在Documents -> Events中）
            targetPath = [[HTFileManager eventsPath] stringByAppendingPathComponent:[resultDict[@"RealDownloadKey"] description]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:targetPath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            // 儲存Frame Image
            [[HTFileManager sharedManager] saveFrameImageWithEventKey:[resultDict[@"RealDownloadKey"] description] infoArr:resultDict2[@"ImageFiles"] update:NO];
            
            // 儲存Ad Image
            [[HTFileManager sharedManager] saveAdImageWithEventKey:[resultDict[@"RealDownloadKey"] description] infoArr:resultDict2[@"AdFiles"] update:NO];
                        
            // 密碼欄位清空
            passwordTextField.text = @"";
            // 鍵盤退出
            [passwordTextField resignFirstResponder];
            
            // 導航到目錄頁
            [self eventButtonClicked:nil];
            
            // 藏HUD
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failBlock:^(NSString *errStr, NSInteger errCode) {
//            DLog(@"errStr: %@", errStr);
//            UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意", nil) message:HTLocalizedString(@"發生錯誤", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"確認", nil) otherButtonTitles:nil, nil];
//            [av show];
            // 藏HUD
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }] getProject:resultDict[@"RealDownloadKey"]];
        
    } failBlock:^(NSString *errStr, NSInteger errCode) {
        DLog(@"errStr: %@", errStr);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意", nil) message:HTLocalizedString(@"此下載密碼不存在", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"好", nil) otherButtonTitles:nil, nil];
        [av show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }] getDownloadKey:passwordTextField.text];
}

-(IBAction)eventButtonClicked:(UIButton *)button
{
    // 秀HUD
    [MBProgressHUD showHUDAddedTo:[HTAppDelegate sharedDelegate].window animated:YES];

    HTEventListViewController *vc = [[HTEventListViewController alloc] initWithEventArr:@[]];
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)trailButtonClicked:(UIButton *)button
{
    // 秀HUD
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // 判斷是否有網路
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意",nil) message:HTLocalizedString(@"請開啟網路",nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"好",nil) otherButtonTitles:nil, nil];
        [av show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    [[HTNetworkManager requestWithFinishBlock:^(NSObject *objcet) {
        DLog(@"objcet: %@", objcet);
        NSDictionary *resultDit = (NSDictionary *)objcet;
        
        HTTrialListViewController *vc = [[HTTrialListViewController alloc] initWithTrialArr:resultDit[@"Files"]];
        [self.navigationController pushViewController:vc animated:YES];
        
        // 藏HUD
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failBlock:^(NSString *errStr, NSInteger errCode) {
        DLog(@"errStr: %@", errStr);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意", nil) message:HTLocalizedString(@"發生錯誤", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"確認", nil) otherButtonTitles:nil, nil];
        [av show];
        // 藏HUD
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }] getDemoSectionAd];
}

-(IBAction)aboutButtonClicked:(UIButton *)button
{
    // 連結到官方網站
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.woshot.com/"]];
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
    if(![textField.text isEqualToString:@""]){
        [self downloadButtonClicked:nil];
        textField.text=@"";
    }
    return YES;
}

#pragma mark - NSNotification Methods

- (void)keyboardDidShow: (NSNotification *) notification {
    // Get the size of the keyboard
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    toButtonConstraint.constant = keyboardSize.height;
}

- (void)keyboardDidHide: (NSNotification *) notification {
    toButtonConstraint.constant = toButtonConstraintConstant;
}
@end

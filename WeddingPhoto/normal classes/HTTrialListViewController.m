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
#import "UIImageView+AFNetworking.h"

@implementation NSArray (Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end

@implementation NSMutableArray (Reverse)

- (void)reverse {
    if ([self count] == 0)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        
        i++;
        j--;
    }
}

@end

@interface HTTrialListViewController ()

@end

@implementation HTTrialListViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (id)initWithTrialArr:(NSArray *)array
{
    self = [super initWithNibName:@"HTTrialListViewController" bundle:nil];
    if (self) {
        // 反向廣告順序
        trialArr = array;
        
        // 擋住相機螢幕
        blockView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        blockView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:blockView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 秀HUD
    [MBProgressHUD showHUDAddedTo:[HTAppDelegate sharedDelegate].window animated:YES];
    // 判斷是否有網路
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意",nil) message:HTLocalizedString(@"請開啟網路",nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"好",nil) otherButtonTitles:nil, nil];
        [av show];
        // 藏HUD
        [MBProgressHUD hideAllHUDsForView:[HTAppDelegate sharedDelegate].window animated:YES];
        return;
    }
    // 顯示廣告
    [[HTNetworkManager requestWithFinishBlock:^(NSObject *objcet) {
        DLog(@"objcet: %@", objcet);
        NSDictionary *resultDit = (NSDictionary *)objcet;
        
        adViewController = [[HTAdViewController alloc] initWithAdArr:resultDit[@"Files"] adType:HTAdTypeTrial];
        adViewController.delegate = self;
        [self.navigationController presentViewController:adViewController animated:NO completion:nil];
        // 藏HUD
        [MBProgressHUD hideAllHUDsForView:[HTAppDelegate sharedDelegate].window animated:YES];
    } failBlock:^(NSString *errStr, NSInteger errCode) {
        DLog(@"errStr: %@", errStr);
        // 藏HUD
        [MBProgressHUD hideAllHUDsForView:[HTAppDelegate sharedDelegate].window animated:YES];
    }] getDemoBlockAd];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [trialArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HTTrialCell *cell = [HTTrialCell cell];
    [cell.trialImageView setImageWithURL:[NSURL URLWithString:trialArr[indexPath.row][@"File"]]];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 開始下載程序
    [self.view makeToast:trialArr[indexPath.row][@"DownloadKey"]];
    
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
            

            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failBlock:^(NSString *errStr, NSInteger errCode) {
            DLog(@"errStr: %@", errStr);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }] getProject:resultDict[@"RealDownloadKey"]];
        
        
    } failBlock:^(NSString *errStr, NSInteger errCode) {
        DLog(@"errStr: %@", errStr);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意", nil) message:HTLocalizedString(@"沒有此密碼喔！", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"好", nil) otherButtonTitles:nil, nil];
        [av show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }] getDownloadKey:trialArr[indexPath.row][@"DownloadKey"]];
}

#pragma mark - Button Methods

-(IBAction)backButtonClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - HTAdViewControllerDelegate

-(void)removeBlockView
{
    // 最後一張廣告關掉後移除黑幕
    [blockView removeFromSuperview];
}


@end

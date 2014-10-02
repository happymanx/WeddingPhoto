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

@interface HTTrialListViewController ()

@end

@implementation HTTrialListViewController

- (id)initWithTrialArr:(NSArray *)array
{
    self = [super initWithNibName:@"HTTrialListViewController" bundle:nil];
    if (self) {
        trialArr = array;
        
//        trialArr = @[@"Trial 1", @"Trial 2", @"Trial 3", @"Trial 4", @"Trial 5"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 顯示廣告
        [[HTNetworkManager requestWithFinishBlock:^(NSObject *objcet) {
            DLog(@"objcet: %@", objcet);
            NSDictionary *resultDit = (NSDictionary *)objcet;
            
            HTAdViewController *vc = [[HTAdViewController alloc] initWithAdArr:resultDit[@"Files"] adType:HTAdTypeTrial];
            [self.navigationController presentViewController:vc animated:NO completion:nil];
            
        } failBlock:^(NSString *errStr, NSInteger errCode) {
            DLog(@"errStr: %@", errStr);
        }] getDemoAd];

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
    return 250.0;
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
    }] getDownloadKey:trialArr[indexPath.row][@"DownloadKey"]];
}

#pragma mark - Button Methods

-(IBAction)backButtonClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

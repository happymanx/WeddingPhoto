//
//  HTAdViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/10.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTAdViewController.h"
#import "UIImageView+AFNetworking.h"
#import "HTAppDelegate.h"

@interface HTAdViewController ()

@end

@implementation HTAdViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (id)initWithAdArr:(NSArray *)array adType:(HTAdType)type
{
    self = [super initWithNibName:@"HTAdViewController" bundle:nil];
    if (self) {
        adType = type;
        
        if (adType == HTAdTypeTrial) {
            adTypeTrialArr = array;
            // 測試
//            adTypeTrialArr = @[@"a1", @"b2", @"c3"];
        }
        if (adType == HTAdTypeEvent) {
//            adTypeEventArr = array;
            NSString *jsonFilePath = [[HTFileManager documentsPath] stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName];
            NSDictionary *eventDict = [[NSDictionary alloc] initWithContentsOfFile:jsonFilePath];
            NSArray *adInfoArr = eventDict[@"AdFiles"];
            // 測試
            adTypeEventArr = [NSMutableArray array];
            for (int i = 0; i < [adInfoArr count]; i++) {
                [adTypeEventArr addObject:adInfoArr[i][@"Url"]];
            }
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSArray *contentArr;
    if (adType == HTAdTypeEvent) {
        contentArr = adTypeEventArr;
        
        NSString *projectPath = [[HTFileManager eventsPath] stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName];
        NSString *adPath = [projectPath stringByAppendingPathComponent:@"Ads"];
        adTypeEventAdNameArr = [[HTFileManager sharedManager] listFileAtPath:adPath];
    }
    if (adType == HTAdTypeTrial) {
        contentArr = adTypeTrialArr;
    }
    
    // 棄用 Scroll View
//    displayScrollView.contentSize = CGSizeMake(self.view.frame.size.width * [contentArr count], self.view.frame.size.height);
//    displayPageControl.numberOfPages = [contentArr count];
//    
//    for (int i = 0; i < [contentArr count]; i++) {
//        UIImageView *imageView = [[UIImageView alloc] init];
//        imageView.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
//        [imageView addGestureRecognizer:tap];
//        imageView.frame = CGRectMake(self.view.frame.size.width * i, 0, self.view.frame.size.width, self.view.frame.size.height);
//        if (i % 2 == 0) {
//            imageView.backgroundColor = [UIColor greenColor];
//        }
//        else {
//            imageView.backgroundColor = [UIColor blueColor];
//        }
//        [displayScrollView addSubview:imageView];
//    }
    
    // 使用疊起來 Image View
    adImageViewArr = [NSMutableArray array];
    for (int i = 0; i < [contentArr count]; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        if (adType == HTAdTypeTrial) {// 試用
            [imageView setImageWithURL:[NSURL URLWithString:contentArr[i][@"File"]]];
        }
        if (adType == HTAdTypeEvent) {// 事件
            NSString *projectPath = [[HTFileManager eventsPath] stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName];
            NSString *adPath = [projectPath stringByAppendingPathComponent:@"Ads"];
            NSString *targetPath = [adPath stringByAppendingPathComponent:adTypeEventAdNameArr[i]];
            [imageView setImage:[UIImage imageWithContentsOfFile:targetPath]];
        }
        
        // 貼上關閉按鈕
        UIImage *closeImage = [UIImage imageNamed:@"but_photo_close.png"];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, closeImage.size.width/2, closeImage.size.height/2);
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        closeButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width - closeButton.frame.size.width, 40);
        [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [imageView addSubview:closeButton];
        imageView.userInteractionEnabled = YES;
        
        [self.view addSubview:imageView];
        
        // 手勢點擊
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:tap];
        
        [adImageViewArr addObject:imageView];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ((NSInteger)scrollView.contentOffset.x % (NSInteger)self.view.frame.size.width == 0) {
        displayPageControl.currentPage = (NSInteger)scrollView.contentOffset.x / (NSInteger)self.view.frame.size.width;
        
        selectedIndex = (NSInteger)scrollView.contentOffset.x / (NSInteger)self.view.frame.size.width;
    }
}

#pragma mark - Button Methods

-(IBAction)backButtonClicked:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tapAction:(UITapGestureRecognizer *)tap
{
    if (adType == HTAdTypeEvent) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adTypeEventArr[[adImageViewArr count] - 1]]];
    }
    if (adType == HTAdTypeTrial) {
        // 透過密碼下載
        // 開始下載程序
        [self.view makeToast:adTypeTrialArr[[adImageViewArr count] - 1][@"DownloadKey"]];
        
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
        }] getDownloadKey:adTypeTrialArr[[adImageViewArr count] - 1][@"DownloadKey"]];
    }
}

-(void)closeButtonClicked:(UIButton *)button
{
    UIImageView *imageView = [adImageViewArr lastObject];
    [imageView removeFromSuperview];
    [adImageViewArr removeLastObject];
    imageView = nil;
    
    if ([adImageViewArr count] == 0) {// 最後一張廣告移除後退出
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end

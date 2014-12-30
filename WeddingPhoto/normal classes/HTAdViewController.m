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
            // 反排序廣告顯示順序，index最大最先顯示
            adTypeTrialArr = [array reversedArray];
        }
        if (adType == HTAdTypeEvent) {
            // 從APP中讀取廣告影像
            NSString *jsonFilePath = [[HTFileManager documentsPath] stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName];
            NSDictionary *eventDict = [[NSDictionary alloc] initWithContentsOfFile:jsonFilePath];
            NSArray *adInfoArr = eventDict[@"AdFiles"];
            adTypeEventArr = [NSMutableArray array];
            for (int i = 0; i < [adInfoArr count]; i++) {
                [adTypeEventArr addObject:adInfoArr[i][@"Url"]];
            }
            // 反排序廣告顯示順序，index最大最先顯示
            [adTypeEventArr reverse];
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
        
        // 讀取Ad圖
        NSString *projectPath = [[HTFileManager eventsPath] stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName];
        NSString *adPath = [projectPath stringByAppendingPathComponent:@"Ads"];
        adTypeEventAdNameArr = [[HTFileManager sharedManager] listFileAtPath:adPath];
        adTypeEventAdNameArr = [adTypeEventAdNameArr reversedArray];
    }
    if (adType == HTAdTypeTrial) {
        contentArr = adTypeTrialArr;
    }

    // 使用疊起來 Image View
    adImageViewArr = [NSMutableArray array];
    for (int i = 0; i < [contentArr count]; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        if (adType == HTAdTypeTrial) {// 試用
            [imageView setImageWithURL:[NSURL URLWithString:contentArr[i][@"File"]]];
        }
        if (adType == HTAdTypeEvent) {// 事件
            NSString *projectPath = [[HTFileManager eventsPath] stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName];
            NSString *adPath = [projectPath stringByAppendingPathComponent:@"Ads"];
//            NSString *targetPath = [adPath stringByAppendingPathComponent:[file lastObject]];

            NSString *targetPath = [adPath stringByAppendingPathComponent:adTypeEventAdNameArr[i]];
            NSLog(@"targetPath:%@",targetPath);
            [imageView setImage:[UIImage imageWithContentsOfFile:targetPath]];
        }
        
        // 貼上關閉按鈕
        UIImage *closeImage = [UIImage imageNamed:@"but_photo_close.png"];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, closeImage.size.width/2, closeImage.size.height/2);
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        closeButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width - (closeButton.frame.size.width/2), closeButton.frame.size.height/2);
        [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

        [imageView addSubview:closeButton];
        
        // 貼上觸控按鈕
        UIButton *tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tapButton.frame = CGRectMake(0, 0, closeImage.size.width*3, closeImage.size.height*3);
        tapButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width - (closeButton.frame.size.width/2), closeButton.frame.size.height/2);
        [tapButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:tapButton];

        imageView.userInteractionEnabled = YES;
        
        // 廣告底下有黑色的view
        UIView *view = [[UIView alloc] initWithFrame:imageView.frame];
        view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        [view addSubview:imageView];
        [self.view addSubview:view];
        
        // 手勢點擊
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:tap];
        
        [adImageViewArr addObject:view];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (adType == HTAdTypeEvent) {// 事件
        if ([adTypeEventAdNameArr count] == 0) {// 沒有廣告就退出此view
            [self dismissViewControllerAnimated:YES completion:nil];
            if ([self.delegate respondsToSelector:@selector(removeBlockView)]) {
                [self.delegate removeBlockView];
            }
        }
    }
    if (adType == HTAdTypeTrial) {// 試用
        if ([adTypeTrialArr count] == 0) {// 沒有廣告就退出此view
            [self dismissViewControllerAnimated:YES completion:nil];
            if ([self.delegate respondsToSelector:@selector(removeBlockView)]) {
                [self.delegate removeBlockView];
            }
        }
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
        // 須加前綴http://
        NSString *httpPrefix = @"http://";
        if (![adTypeEventArr[[adImageViewArr count] - 1] isEqualToString:@""]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[httpPrefix stringByAppendingString:adTypeEventArr[[adImageViewArr count] - 1]]]];
        }
    }
    if (adType == HTAdTypeTrial) {
        // 透過密碼下載
        // 開始下載程序
        [self.view makeToast:adTypeTrialArr[[adImageViewArr count] - 1][@"DownloadKey"]];
        
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
        }] getDownloadKey:adTypeTrialArr[[adImageViewArr count] - 1][@"DownloadKey"]];
    }
}

-(void)closeButtonClicked:(UIButton *)button
{
    UIView *view = [adImageViewArr lastObject];
    [view removeFromSuperview];
    [adImageViewArr removeLastObject];
    view = nil;
    
    if ([adImageViewArr count] == 0) {// 最後一張廣告移除後退出
        [self dismissViewControllerAnimated:YES completion:nil];
        if ([self.delegate respondsToSelector:@selector(removeBlockView)]) {
            [self.delegate removeBlockView];
        }
    }
}
@end

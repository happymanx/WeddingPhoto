//
//  HTListViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/10.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTEventListViewController.h"
#import "HTEventCell.h"
#import "HTCollectionViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface HTEventListViewController ()

@end

@implementation HTEventListViewController

- (id)initWithEventArr:(NSArray *)array
{
    self = [super initWithNibName:@"HTEventListViewController" bundle:nil];
    if (self) {
        eventArr = [NSMutableArray array];
        [eventArr addObjectsFromArray:array];
        
        // 從APP中讀取事件目錄
        [eventArr addObjectsFromArray:[[HTFileManager sharedManager] listFileAtPath:[HTFileManager eventsPath]]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 藏HUD
    [MBProgressHUD hideHUDForView:[HTAppDelegate sharedDelegate].window animated:YES];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [eventArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HTEventCell *cell = [HTEventCell cell];
    
    // 標題從API回傳的檔案中找事件標題
    NSString *targetPath = [[HTFileManager documentsPath] stringByAppendingPathComponent:eventArr[indexPath.row]];
    NSDictionary *fileDict = [[NSDictionary alloc] initWithContentsOfFile:targetPath];
    cell.titleLabel.text = fileDict[@"ProjectName"];
    
    cell.deleteButton.tag = indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.albumButton addTarget:self action:@selector(albumButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.albumButton.tag = indexPath.row;
    
    if (isEdit) {
        cell.deleteButton.hidden = NO;
        cell.albumButton.hidden = YES;
    }
    else {
        cell.deleteButton.hidden = YES;
        cell.albumButton.hidden = NO;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 記錄事件名稱，之後其它頁面會用到
    [HTAppDelegate sharedDelegate].eventName = eventArr[indexPath.row];
    
    if (isEdit) {// 編輯模式時，無法進入拍攝
        return;
    }
    else {// 非編輯模式時，進入拍攝
        
        // 秀HUD
        [MBProgressHUD showHUDAddedTo:[HTAppDelegate sharedDelegate].window animated:YES];

        // 建立相簿
        // 標題從API回傳的檔案中找事件標題
        NSString *eventJSONPath = [[HTFileManager documentsPath] stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName];
        NSDictionary *fileDict = [[NSDictionary alloc] initWithContentsOfFile:eventJSONPath];
        NSString *eventName = fileDict[@"ProjectName"];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library addAssetsGroupAlbumWithName:eventName
                                 resultBlock:^(ALAssetsGroup *group) {
                                     DLog(@"added album:%@", eventName);
                                 }
                                failureBlock:^(NSError *error) {
                                    DLog(@"error adding album");
                                }];

        
        DBCameraContainerViewController *cameraContainer = [[DBCameraContainerViewController alloc] initWithDelegate:self];
        [cameraContainer setFullScreenMode];
        
        cameraContainer.delegate = self;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraContainer];
        [nav setNavigationBarHidden:YES];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - Button Methods

-(IBAction)backButtonClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)editButtonClicked:(UIButton *)button
{
    isEdit = !isEdit;
    if (isEdit) {
        editButton.selected = YES;
    }
    else {
        editButton.selected = NO;
    }
    [displayTableView reloadData];
}

-(void)deleteButtonClicked:(UIButton *)button
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意", nil) message:HTLocalizedString(@"確定要刪除？", nil) delegate:self cancelButtonTitle:HTLocalizedString(@"不", nil) otherButtonTitles:HTLocalizedString(@"好", nil), nil];
    av.tag = button.tag;
    [av show];
}

-(void)albumButtonClicked:(UIButton *)button
{
    // 記錄事件名稱
    [HTAppDelegate sharedDelegate].eventName = eventArr[button.tag];

#pragma mark - 開啓網路相簿
    // 秀HUD
    [MBProgressHUD showHUDAddedTo:[HTAppDelegate sharedDelegate].window animated:YES];
    // 判斷是否有網路
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意",nil) message:HTLocalizedString(@"請開啟網路",nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"好",nil) otherButtonTitles:nil, nil];
        [av show];
        [MBProgressHUD hideHUDForView:[HTAppDelegate sharedDelegate].window animated:YES];
        return;
    }
    NSString *keyStr = eventArr[button.tag];
    
    //Leader fix
    [MBProgressHUD hideHUDForView:[HTAppDelegate sharedDelegate].window animated:YES];
    HTCollectionViewController *vc = [[HTCollectionViewController alloc] initWithWorkArr:@[] collectionType:HTCollectionTypeNetWork];
    vc.keyStr=keyStr;
    [self.navigationController pushViewController:vc animated:YES];
    //Leader fix

    
//    [[HTNetworkManager requestWithFinishBlock:^(NSObject *objcet) {
//        DLog(@"objcet: %@", objcet);
//        NSDictionary *resultDict = (NSDictionary *)objcet;
//
//        if (![[resultDict[@"Status"] description] isEqualToString:@"0"]) {// 非成功
//            UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"提醒", nil) message:resultDict[@"ErrorMessage"] delegate:nil cancelButtonTitle:HTLocalizedString(@"確認", nil) otherButtonTitles:nil, nil];
//            [av show];
//            // 藏HUD
//            [MBProgressHUD hideHUDForView:[HTAppDelegate sharedDelegate].window animated:YES];
//            return;
//        }
//        NSArray *itemArr = resultDict[@"Files"];
//        if ([itemArr count] == 0) {
//            UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"提醒", nil) message:HTLocalizedString(@"此相簿為空", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"確認", nil) otherButtonTitles:nil, nil];
//            [av show];
//        }
//        else {
//            HTCollectionViewController *vc = [[HTCollectionViewController alloc] initWithWorkArr:itemArr collectionType:HTCollectionTypeNetWork];
//            vc.keyStr=keyStr;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//        // 藏HUD
//        [MBProgressHUD hideHUDForView:[HTAppDelegate sharedDelegate].window animated:YES];
//    } failBlock:^(NSString *errStr, NSInteger errCode) {
//        DLog(@"errStr: %@", errStr);
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意", nil) message:HTLocalizedString(@"發生錯誤", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"確認", nil) otherButtonTitles:nil, nil];
//        [av show];
//        // 藏HUD
//        [MBProgressHUD hideHUDForView:[HTAppDelegate sharedDelegate].window animated:YES];
//    }] getSharedFile:keyStr];
}

#pragma mark - DBCameraViewControllerDelegate

-(void)dismissCamera:(id)cameraViewController
{
    [cameraViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {// 不，結束
        
    }
    if (buttonIndex == 1) {// 好，移除
        // APP中的JSON檔移除
        NSString *targetPath = [[HTFileManager documentsPath] stringByAppendingPathComponent:eventArr[alertView.tag]];
        [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
        // APP中的資料移除
        targetPath = [[HTFileManager eventsPath] stringByAppendingPathComponent:eventArr[alertView.tag]];
        [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
        // 暫存資料移除
        [eventArr removeObjectAtIndex:alertView.tag];
        // 重載
        [displayTableView reloadData];
    }
}
@end

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

@interface HTEventListViewController ()

@end

@implementation HTEventListViewController

- (id)initWithEventArr:(NSArray *)array
{
    self = [super initWithNibName:@"HTEventListViewController" bundle:nil];
    if (self) {
        eventArr = [NSMutableArray array];
        [eventArr addObjectsFromArray:array];
        
        // 測試用
//        [eventArr addObjectsFromArray:@[@"Happy 1", @"Happy 2", @"Happy 3"]];
        [eventArr addObjectsFromArray:[[HTFileManager sharedManager] listFileAtPath:[HTFileManager eventsPath]]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    
    cell.titleLabel.text = eventArr[indexPath.row];
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
    // 記錄事件名稱
    [HTAppDelegate sharedDelegate].eventName = eventArr[indexPath.row];
    
    if (isEdit) {// 編輯模式時，無法進入拍攝
        return;
    }
    else {// 非編輯模式時，進入拍攝
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
        [editButtom setTitle:@"完成" forState:UIControlStateNormal];
    }
    else {
        [editButtom setTitle:@"編輯" forState:UIControlStateNormal];
    }
    [displayTableView reloadData];
}

-(void)deleteButtonClicked:(UIButton *)button
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"注意" message:@"確定要刪除？" delegate:self cancelButtonTitle:@"不" otherButtonTitles:@"好", nil];
    av.tag = button.tag;
    [av show];
}

-(void)albumButtonClicked:(UIButton *)button
{
    // 記錄事件名稱
    [HTAppDelegate sharedDelegate].eventName = eventArr[button.tag];

#pragma mark - 開啓自己的作品
    HTCollectionViewController *vc = [[HTCollectionViewController alloc] initWithWorkArr:@[] collectionType:HTCollectionTypeNetWork];
    [self.navigationController pushViewController:vc animated:YES];
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
        // APP中的資料移除
        NSString *targetPath = [[HTFileManager eventsPath] stringByAppendingPathComponent:eventArr[alertView.tag]];
        [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
        // 暫存資料移除
        [eventArr removeObjectAtIndex:alertView.tag];
        // 重載
        [displayTableView reloadData];
    }
}
@end

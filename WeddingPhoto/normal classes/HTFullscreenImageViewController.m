//
//  HTFullscreenImageViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/25.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTFullscreenImageViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImageView+AFNetworking.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "HTEditPhotoViewController.h"

@implementation UINavigationController (popTwice)

- (void) popTwoViewControllersAnimated:(BOOL)animated{
    [self popViewControllerAnimated:NO];
    [self popViewControllerAnimated:animated];
}

@end

@interface HTFullscreenImageViewController ()

@end

@implementation HTFullscreenImageViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (id)initWithItemArr:(NSArray *)arr index:(NSInteger)index type:(HTFullscreenType)type
{
    self = [super initWithNibName:@"HTFullscreenImageViewController" bundle:nil];
    if (self) {
        itemArr = arr;
        itemIndex = index;
        fullscreenType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 設定左右手勢
    UISwipeGestureRecognizer *leftSwipe =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeAction:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [happyImageView addGestureRecognizer:leftSwipe];
    UISwipeGestureRecognizer *rightSwipe =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeAction:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [happyImageView addGestureRecognizer:rightSwipe];

    // 設定點擊手勢
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo)];
    [happyImageView addGestureRecognizer:tap];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (fullscreenType == HTFullscreenTypeNetWork) {
        saveButton.hidden = NO;
        commentTextView.hidden = NO;
        functionView.hidden = YES;
        
        [happyImageView addSubview:playImageView];
        // 顯示圖片
        [happyImageView setImageWithURL:[NSURL URLWithString:itemArr[itemIndex][@"File"]]];
        // 設定Text View中的字有陰影
        commentTextView.layer.shadowColor = [[UIColor blackColor] CGColor];
        commentTextView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        commentTextView.layer.shadowOpacity = 1.0f;
        commentTextView.layer.shadowRadius = 1.0f;
        // 顯示留言
        if ([itemArr[itemIndex][@"UserComments"] isEqualToString:@""]) {
            commentTextView.hidden = YES;
        }
        else {
            commentTextView.hidden = NO;
            commentTextView.text = itemArr[itemIndex][@"UserComments"];
        }
    }
    if (fullscreenType == HTFullscreenTypeSelfWork) {
        saveButton.hidden = YES;
        commentTextView.hidden = YES;
        functionView.hidden = NO;
        
        // Documents -> Events -> xxx -> Works -> zzz.jpg
        NSString *eventPath = [HTFileManager eventsPath];
        NSString *workPath = [[eventPath stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Works"];
        NSString *targetPath = [workPath stringByAppendingPathComponent:itemArr[itemIndex]];
        // 顯示圖片
        [happyImageView setImage:[UIImage imageWithContentsOfFile:targetPath]];
    }
}

//-(void)setupScrollView
//{
//    [displayScrollView setMaximumZoomScale:5.0];
//    [displayScrollView setMinimumZoomScale:1.0];
//    
//    happyImageView = [[UIImageView alloc] initWithImage:originalImage];
//    float ratio = self.view.frame.size.width / happyImageView.frame.size.width;
//    happyImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, happyImageView.frame.size.height * ratio);
//    happyImageView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
//    happyImageView.userInteractionEnabled = YES;
//    
//    [displayScrollView addSubview:happyImageView];
//}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView subviews][0];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    DLog(@"scrollViewWillBeginDecelerating");
}

- (void) onDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)playVideo
{
    if (fullscreenType == HTFullscreenTypeNetWork) {
        NSString *fileStr = itemArr[itemIndex][@"File"];
        if ([fileStr rangeOfString:@"youtube"].location != NSNotFound) {
            NSRange range = [fileStr rangeOfString:@"="];
            NSString *youtubeIDStr = [fileStr substringFromIndex:range.location + 1];
            
            XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:youtubeIDStr];
            //            videoPlayerViewController.delegate = self;
            [self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
        }
    }
}

-(IBAction)backButtonClicked:(UIButton *)button
{
    if (fullscreenType == HTFullscreenTypeNetWork) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (fullscreenType == HTFullscreenTypeSelfWork) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Button Methods

-(IBAction)saveButtonClicked:(UIButton *)button
{
#pragma mark - 儲存影像到相簿
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:[happyImageView.image CGImage] orientation:(ALAssetOrientation)[happyImageView.image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            // TODO: error handling
            [self.view makeToast:HTLocalizedString(@"發生錯誤", nil)];
        } else {
            // TODO: success handling
            [self.view makeToast:HTLocalizedString(@"已儲存到相簿", nil)];
        }
    }];
}

#pragma mark - Gesture Action

-(void)leftSwipeAction:(UISwipeGestureRecognizer *)swipe
{
    if (itemIndex + 1 > [itemArr count] - 1) {
        itemIndex -= [itemArr count] - 1;
    }
    else {
        itemIndex++;
    }
    [self setupImageView];
}

-(void)rightSwipeAction:(UISwipeGestureRecognizer *)swipe
{
    if (itemIndex - 1 < 0) {
        itemIndex += [itemArr count] - 1;
    }
    else {
        itemIndex--;
    }
    [self setupImageView];
}

-(void)setupImageView
{
    if (fullscreenType == HTFullscreenTypeNetWork) {
        NSString *fileStr = itemArr[itemIndex][@"File"];
        if ([fileStr rangeOfString:@"youtube"].location != NSNotFound) {// 影片
            // 尋找Youtube ID
            NSRange range = [fileStr rangeOfString:@"="];
            NSString *youtubeIDStr = [fileStr substringFromIndex:range.location + 1];
            NSURL *youtubeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", youtubeIDStr]];
            [happyImageView setImageWithURL:youtubeURL];
            
            playImageView.hidden = NO;
        }
        else {
            [happyImageView setImageWithURL:[NSURL URLWithString:itemArr[itemIndex][@"File"]]];
            
            playImageView.hidden = YES;
        }
        
        happyImageView.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            happyImageView.alpha = 1.0;
        }];
        
        // 顯示留言
        if ([itemArr[itemIndex][@"UserComments"] isEqualToString:@""]) {
            commentTextView.hidden = YES;
        }
        else {
            commentTextView.hidden = NO;
            commentTextView.text = itemArr[itemIndex][@"UserComments"];
        }
    }
    if (fullscreenType == HTFullscreenTypeSelfWork) {
        // Documents -> Events -> xxx -> Works -> zzz.jpg
        NSString *eventPath = [HTFileManager eventsPath];
        NSString *workPath = [[eventPath stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Works"];
        NSString *targetPath = [workPath stringByAppendingPathComponent:itemArr[itemIndex]];
        // 顯示圖片
        [happyImageView setImage:[UIImage imageWithContentsOfFile:targetPath]];
    }
}

-(IBAction)uploadButtonClicked:(UIButton *)button
{
    [self setupStatementView];
}

-(IBAction)trashButtonClicked:(UIButton *)button
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意", nil) message:HTLocalizedString(@"刪掉本張相片？", nil) delegate:self cancelButtonTitle:HTLocalizedString(@"取消", nil) otherButtonTitles:HTLocalizedString(@"確認", nil), nil];
    av.tag = 1;
    [av show];
}

-(IBAction)editButtonClicked:(UIButton *)button
{
    HTEditPhotoViewController *vc = [[HTEditPhotoViewController alloc] initWithImage:happyImageView.image];
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)cameraButtonClicked:(UIButton *)button
{
    [self.navigationController popTwoViewControllersAnimated:YES];
}

#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        // 準備上傳相片
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"提醒", nil) message:HTLocalizedString(@"上傳本張相片？", nil) delegate:self cancelButtonTitle:HTLocalizedString(@"取消", nil) otherButtonTitles:HTLocalizedString(@"確認", nil), nil];
        av.tag = 2;
        [av show];
    }
    return YES;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {// 刪除功能
        if (buttonIndex == 0) {// 取消
            ;
        }
        if (buttonIndex == 1) {// 確認
            [self deleteOperation];
        }
    }
    if (alertView.tag == 2) {// 上傳功能
        if (buttonIndex == 0) {// 取消
            ;
        }
        if (buttonIndex == 1) {// 確認
            [self uploadOperation:happyImageView.image];
        }
        [statementView removeFromSuperview];
    }
}

-(void)uploadOperation:(UIImage *)image
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
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.woshot.com/api/"]];
    NSDictionary *parameters = @{@"download_key": [HTAppDelegate sharedDelegate].eventName,
                                 @"user_notes": statementTextView.text,
                                 @"user_unique_id": [HTAppDelegate sharedDelegate].udid,
                                 @"language": [HTAppDelegate sharedDelegate].languageCode};
    AFHTTPRequestOperation *op = [manager POST:@"api_upload_shared_files1.php" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        [formData appendPartWithFileData:imageData name:@"file1" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        
        if ([resultDict[@"Status"] integerValue] == 0) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"恭喜", nil) message:HTLocalizedString(@"上傳成功", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"好", nil) otherButtonTitles:nil, nil];
            [av show];
        }
        else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意", nil) message:resultDict[@"ErrorMessage"] delegate:nil cancelButtonTitle:HTLocalizedString(@"好", nil) otherButtonTitles:nil, nil];
            [av show];
        }
        // 藏HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意", nil) message:HTLocalizedString(@"發生錯誤", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"確認", nil) otherButtonTitles:nil, nil];
        [av show];
        // 藏HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    [op start];
}

-(void)deleteOperation
{
    // Documents -> Events -> xxx -> Works -> zzz.jpg
    NSString *eventPath = [HTFileManager eventsPath];
    NSString *workPath = [[eventPath stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Works"];
    NSString *targetPath = [workPath stringByAppendingPathComponent:itemArr[itemIndex]];
    if ([[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil])
    {
        [self.view makeToast:HTLocalizedString(@"刪除成功", nil)];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.view makeToast:HTLocalizedString(@"刪除失敗", nil)];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
//    if ([textView.text isEqualToString:HTLocalizedString(@"請留下您想說的話", nil)]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
//    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
//        textView.text = HTLocalizedString(@"請留下您想說的話", nil);
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

-(void)setupStatementView
{
    statementLabel.text = HTLocalizedString(@"請留下您想說的話", nil);
    statementTextView.textColor = [UIColor lightGrayColor];
    
    [self.view addSubview:statementView];
    
    statementView.frame = CGRectMake(0, 0, statementView.frame.size.width, statementView.frame.size.height);
    statementTextView.layer.cornerRadius = 10;
    
    [statementTextView becomeFirstResponder];
}

@end

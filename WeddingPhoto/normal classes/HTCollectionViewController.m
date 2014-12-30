//
//  HTCollectionViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/22.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTCollectionViewController.h"
#import "HTCollectionCell.h"
#import "HTEditPhotoViewController.h"
#import "HTFullscreenImageViewController.h"
#import "UIImageView+AFNetworking.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "Haneke.h"


@interface HTCollectionViewController ()
@end

@implementation HTCollectionViewController

- (id)initWithWorkArr:(NSArray *)arr collectionType:(HTCollectionType)type
{
    self = [super initWithNibName:@"HTCollectionViewController" bundle:nil];
    if (self) {
        collectionType = type;
        if (collectionType == HTCollectionTypeSelfWorkBrowse) {// 自己的作品瀏覽上傳
            
        }
        if (collectionType == HTCollectionTypeSelfWorkEdit) {// 自己的作品編輯
            
        }
        if (collectionType == HTCollectionTypeNetWork) {// 網路相簿
            // 儲存檔案URL與意見
            itemArr = arr;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [displayCollectionView registerNib:[UINib nibWithNibName:@"HTCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"HappyCell"];
    
    if (collectionType == HTCollectionTypeNetWork) {// 網路相簿
        uploadButton.hidden = NO;
    }
    if (collectionType == HTCollectionTypeSelfWorkBrowse) {// 自己作品瀏覽上傳
        uploadButton.hidden = NO;
        uploadIndex = 0;
    }
    if (collectionType == HTCollectionTypeSelfWorkEdit) {// 自己作品編輯
        uploadButton.hidden = YES;
    }
    
    // 註冊觀察Youtube播放影片
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeStarted:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    // 多國語言化
    [uploadButton setTitle:HTLocalizedString(@"上傳", nil) forState:UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (collectionType == HTCollectionTypeSelfWorkBrowse ||
        collectionType == HTCollectionTypeSelfWorkEdit) {// 自己的作品
        // Documents -> Events -> xxx -> Works -> zzz.jpg
        NSString *eventPath = [HTFileManager eventsPath];
        workPath = [[eventPath stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Works"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:workPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:workPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        // 儲存檔案名稱（非路徑）
        itemArr = [[HTFileManager sharedManager] listFileAtPath:workPath];

        uploadArr = [NSMutableArray array];
    }
    if (collectionType == HTCollectionTypeNetWork) {// 網路相簿
        
        
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
        [[HTNetworkManager requestWithFinishBlock:^(NSObject *objcet) {
            DLog(@"objcet: %@", objcet);
            NSDictionary *resultDict = (NSDictionary *)objcet;
            
            if (![[resultDict[@"Status"] description] isEqualToString:@"0"]) {// 非成功
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"提醒", nil) message:resultDict[@"ErrorMessage"] delegate:nil cancelButtonTitle:HTLocalizedString(@"確認", nil) otherButtonTitles:nil, nil];
                [av show];
                // 藏HUD
                [MBProgressHUD hideHUDForView:[HTAppDelegate sharedDelegate].window animated:YES];
                return;
            }
            itemArr = resultDict[@"Files"];
            if ([itemArr count] == 0) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"提醒", nil) message:HTLocalizedString(@"此相簿為空", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"確認", nil) otherButtonTitles:nil, nil];
                [av show];
            }
            else {
                [MBProgressHUD hideHUDForView:[HTAppDelegate sharedDelegate].window animated:YES];
                [displayCollectionView reloadData];

//                HTCollectionViewController *vc = [[HTCollectionViewController alloc] initWithWorkArr:itemArr collectionType:HTCollectionTypeNetWork];
//                [self.navigationController pushViewController:vc animated:YES];
            }
            // 藏HUD
            [MBProgressHUD hideHUDForView:[HTAppDelegate sharedDelegate].window animated:YES];
        } failBlock:^(NSString *errStr, NSInteger errCode) {
            DLog(@"errStr: %@", errStr);
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意", nil) message:HTLocalizedString(@"發生錯誤", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"確認", nil) otherButtonTitles:nil, nil];
            [av show];
            // 藏HUD
            [MBProgressHUD hideHUDForView:[HTAppDelegate sharedDelegate].window animated:YES];
        }] getSharedFile:self.keyStr];

    }
    
    [displayCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [itemArr count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HTCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HappyCell" forIndexPath:indexPath];
    // 設回初始狀態，因會重複利用cell
    [cell.photoImageView setImage:nil];
    cell.playImageView.hidden = YES;
    cell.checkButton.selected = NO;
    cell.checkButton2.selected = NO;
    
    if (collectionType == HTCollectionTypeSelfWorkBrowse) {// 自己作品瀏覽上傳
        NSString *targetPath = [workPath stringByAppendingPathComponent:itemArr[indexPath.row]];
        [cell.photoImageView hnk_setImageFromFile:targetPath];
        [cell.checkButton addTarget:self action:@selector(checkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.checkButton2 addTarget:self action:@selector(checkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.checkButton.tag = indexPath.row;
        cell.checkButton2.tag = indexPath.row;
        
        // 回捲的時候要回復顯示勾選
        if ([uploadArr containsObject:@(indexPath.row)]) {
            cell.checkButton.selected = YES;
            cell.checkButton2.selected = YES;
        }
        else {
            cell.checkButton.selected = NO;
            cell.checkButton2.selected = NO;
        }
    }
    if (collectionType == HTCollectionTypeSelfWorkEdit) {// 自己作品編輯
        NSString *targetPath = [workPath stringByAppendingPathComponent:itemArr[indexPath.row]];
        [cell.photoImageView hnk_setImageFromFile:targetPath];
        cell.checkButton.hidden = YES;
        cell.checkButton2.hidden = YES;
    }
    if (collectionType == HTCollectionTypeNetWork) {// 網路相簿
        NSString *fileStr = itemArr[indexPath.row][@"File"];
        if ([fileStr rangeOfString:@"youtube"].location != NSNotFound) {// 影片
            // 尋找Youtube ID
            NSRange range = [fileStr rangeOfString:@"="];
            NSString *youtubeIDStr = [fileStr substringFromIndex:range.location + 1];
            NSURL *youtubeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", youtubeIDStr]];
            [cell.photoImageView setImageWithURL:youtubeURL];
            
            cell.playImageView.hidden = NO;
        }
        else {// 相片
            NSLog(@"image:%@",itemArr[indexPath.row][@"File"]);
            [cell.photoImageView setImageWithURL:[NSURL URLWithString:itemArr[indexPath.row][@"File"]]];
            cell.photoImageView.alpha = 0.0;
            [UIView animateWithDuration:0.7 animations:^{
                cell.photoImageView.alpha = 1.0;
            }];
        }
        cell.checkButton.hidden = YES;
        cell.checkButton2.hidden = YES;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionType == HTCollectionTypeSelfWorkBrowse) {// 自己作品瀏覽上傳
    }
    if (collectionType == HTCollectionTypeSelfWorkEdit) {// 自己作品編輯
//        NSString *targetPath = [workPath stringByAppendingPathComponent:itemArr[indexPath.row]];
//        UIImage *image = [UIImage imageWithContentsOfFile:targetPath];
//        
//        // 儲存相片路徑，之後刪除會用到
//        [HTAppDelegate sharedDelegate].photoPath = targetPath;
//        
//        HTEditPhotoViewController *vc = [[HTEditPhotoViewController alloc] initWithImage:image];
//        
//        [self.navigationController pushViewController:vc animated:YES];
        
        HTFullscreenImageViewController *vc = [[HTFullscreenImageViewController alloc] initWithItemArr:itemArr index:indexPath.row type:HTFullscreenTypeSelfWork];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (collectionType == HTCollectionTypeNetWork) {// 網路相簿
        NSString *fileStr = itemArr[indexPath.row][@"File"];
        if ([fileStr rangeOfString:@"youtube"].location != NSNotFound) {// 影片
            NSRange range = [fileStr rangeOfString:@"="];
            NSString *youtubeIDStr = [fileStr substringFromIndex:range.location + 1];

            XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:youtubeIDStr];
//            videoPlayerViewController.delegate = self;
            [self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];

        }
        else {// 相片
            HTFullscreenImageViewController *vc = [[HTFullscreenImageViewController alloc] initWithItemArr:itemArr index:indexPath.row type:HTFullscreenTypeNetWork];
            [self presentViewController:vc animated:YES completion:nil];
            
//            UIImageView *imageView = [[UIImageView alloc] init];
//            [imageView setImageWithURL:[NSURL URLWithString:itemArr[indexPath.row][@"File"]]];
//            UIImage *image = imageView.image;
//            NSString *commentStr = itemArr[indexPath.row][@"UserComments"];
            
            // 全螢幕顯示相片
//            if (image) {
//                HTFullscreenImageViewController *vc = [[HTFullscreenImageViewController alloc] initWithImage:image commentStr:commentStr];
//            }
//            else {
//                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"注意" message:@"相片尚未載入" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil, nil];
//                [av show];
//            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(77, 77);
    return size;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(3, 0, 3, 0);
}

#pragma mark - Button Methods

-(IBAction)backButtonClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)uploadButtonClicked:(UIButton *)button
{
    // 判斷是否有網路
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意",nil) message:HTLocalizedString(@"請開啟網路",nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"好",nil) otherButtonTitles:nil, nil];
        [av show];
        return;
    }

    if (collectionType == HTCollectionTypeSelfWorkBrowse) {// 自己作品瀏覽上傳
        if ([uploadArr count] == 0) {// 無選擇任何相片
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"提醒", nil) message:HTLocalizedString(@"請選擇相片", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"好", nil) otherButtonTitles:nil, nil];
            [av show];
            return;
        }
        DLog(@"uploadArr: %@", uploadArr);
        if (uploadIndex <= [uploadArr count] - 1) {// 繼續上傳
            if (uploadIndex == 0) {// 第一張相片
                // 轉轉現身
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            }
            
            NSInteger index = [uploadArr[uploadIndex] integerValue];
            NSString *targetPath = [workPath stringByAppendingPathComponent:itemArr[index]];
            
            UIImage *image = [UIImage imageWithContentsOfFile:targetPath];
            
            [self uploadOperation:image];
        }
        else {// 上傳完畢
            uploadIndex = 0;
            [uploadArr removeAllObjects];
            [displayCollectionView reloadData];
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"恭喜", nil) message:HTLocalizedString(@"上傳成功", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"好", nil) otherButtonTitles:nil, nil];
            [av show];
            
            // 轉轉消失
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }
    if (collectionType == HTCollectionTypeSelfWorkEdit) {// 自己作品編輯
        // 無作用
    }
    if (collectionType == HTCollectionTypeNetWork) {// 網路相簿
        HTCollectionViewController *vc = [[HTCollectionViewController alloc] initWithWorkArr:@[] collectionType:HTCollectionTypeSelfWorkBrowse];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)uploadOperation:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.woshot.com/api/"]];
    NSDictionary *parameters = @{@"download_key": [HTAppDelegate sharedDelegate].eventName,
                                 @"user_notes": @"",
                                 @"user_unique_id": [HTAppDelegate sharedDelegate].udid,
                                 @"language": [HTAppDelegate sharedDelegate].languageCode};
    AFHTTPRequestOperation *op = [manager POST:@"api_upload_shared_files1.php" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        [formData appendPartWithFileData:imageData name:@"file1" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        
        if ([resultDict[@"Status"] integerValue] == 0) {// 上傳成功
            NSString *message = [NSString stringWithFormat:@"%li / %li", (long)(uploadIndex + 1), (long)[uploadArr count]];
            [self.view makeToast:message];

            // 繼續上傳下一張相片
            uploadIndex++;
            [self uploadButtonClicked:nil];
        }
        else {// 上傳失敗
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意", nil) message:resultDict[@"ErrorMessage"] delegate:nil cancelButtonTitle:HTLocalizedString(@"好", nil) otherButtonTitles:nil, nil];
            [av show];
            // 轉轉消失
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"注意", nil) message:HTLocalizedString(@"上傳失敗", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"好", nil) otherButtonTitles:nil, nil];
        [av show];
        // 轉轉消失
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    [op start];
}

-(void)checkButtonClicked:(UIButton *)button
{
    button.selected = !button.selected;
    [displayCollectionView reloadData];
    if ([uploadArr containsObject:@(button.tag)]) {
        [uploadArr removeObject:@(button.tag)];
    }
    else {
        [uploadArr addObject:@(button.tag)];
    }
    DLog(@"uploadArr: %@", uploadArr);
}

-(void)youTubeStarted:(NSNotification *)notification
{
    HTAppDelegate *appDelegate = (HTAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.fullScreenVideoIsPlaying = YES;
}
-(void)youTubeFinished:(NSNotification *)notification
{
    HTAppDelegate *appDelegate = (HTAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.fullScreenVideoIsPlaying = NO;
}

-(UIImage *)resizeImage:(UIImage *)image scale:(double)scale
{
    CGSize newSize = CGSizeMake(image.size.width * scale, image.size.height * scale);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 2.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end

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


@interface HTCollectionViewController ()

@end

@implementation HTCollectionViewController

- (id)initWithWorkArr:(NSArray *)arr collectionType:(HTCollectionType)type
{
    self = [super initWithNibName:@"HTCollectionViewController" bundle:nil];
    if (self) {
        collectionType = type;
        if (collectionType == HTCollectionTypeSelfWork) {// 自己的作品

        }
        if (collectionType == HTCollectionTypeNetWork) {// 他人的作品
            // 儲存檔案URL與意見
            itemArr = arr;
        }
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [displayCollectionView registerNib:[UINib nibWithNibName:@"HTCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"HappyCell"];
    
    if (collectionType == HTCollectionTypeNetWork) {
        uploadButton.hidden = YES;
    }
    
    // 註冊觀察Youtube播放影片
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeStarted:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (collectionType == HTCollectionTypeSelfWork) {// 自己的作品
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
    if (collectionType == HTCollectionTypeNetWork) {// 他人的作品
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
    if (collectionType == HTCollectionTypeSelfWork) {
        NSString *targetPath = [workPath stringByAppendingPathComponent:itemArr[indexPath.row]];
        [cell.photoImageView setImage:[UIImage imageWithContentsOfFile:targetPath]];
        [cell.checkButton addTarget:self action:@selector(checkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.checkButton.tag = indexPath.row;
    }
    if (collectionType == HTCollectionTypeNetWork) {
        NSString *fileStr = itemArr[indexPath.row][@"File"];
        if ([fileStr rangeOfString:@"youtube"].location != NSNotFound) {
            NSRange range = [fileStr rangeOfString:@"="];
            NSString *youtubeIDStr = [fileStr substringFromIndex:range.location + 1];
            NSURL *youtubeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", youtubeIDStr]];
            [cell.photoImageView setImageWithURL:youtubeURL];
        }
        else {
            [cell.photoImageView setImageWithURL:[NSURL URLWithString:itemArr[indexPath.row][@"File"]]];
        }
        cell.checkButton.hidden = YES;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionType == HTCollectionTypeSelfWork) {
        NSString *targetPath = [workPath stringByAppendingPathComponent:itemArr[indexPath.row]];
        UIImage *image = [UIImage imageWithContentsOfFile:targetPath];

        HTEditPhotoViewController *vc = [[HTEditPhotoViewController alloc] initWithImage:image];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (collectionType == HTCollectionTypeNetWork) {
        NSString *fileStr = itemArr[indexPath.row][@"File"];
        if ([fileStr rangeOfString:@"youtube"].location != NSNotFound) {
            NSRange range = [fileStr rangeOfString:@"="];
            NSString *youtubeIDStr = [fileStr substringFromIndex:range.location + 1];

            XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:youtubeIDStr];
//            videoPlayerViewController.delegate = self;
            [self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];

        }
        else {
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:[NSURL URLWithString:itemArr[indexPath.row][@"File"]]];
            UIImage *image = imageView.image;
            NSString *commentStr = itemArr[indexPath.row][@"UserComments"];
            // 全螢幕顯示相片
            HTFullscreenImageViewController *vc = [[HTFullscreenImageViewController alloc] initWithImage:image commentStr:commentStr];
            [self presentViewController:vc animated:YES completion:nil];
        }

//        // 全螢幕顯示相片
//        UIImage *image = [UIImage imageNamed:@"HappyMan.jpg"];HTFullscreenImageViewController *vc = [[HTFullscreenImageViewController alloc] initWithImage:image];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(80, 80);
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

}

-(void)checkButtonClicked:(UIButton *)button
{
    button.selected = !button.selected;
    if ([uploadArr containsObject:button]) {
        [uploadArr removeObject:button];
    }
    else {
        [uploadArr addObject:button];
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

@end

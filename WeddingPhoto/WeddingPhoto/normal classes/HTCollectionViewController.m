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

@interface HTCollectionViewController ()

@end

@implementation HTCollectionViewController

- (id)initWithWorkArr:(NSArray *)arr collectionType:(HTCollectionType)type
{
    self = [super initWithNibName:@"HTCollectionViewController" bundle:nil];
    if (self) {
        collectionType = type;
        if (collectionType == HTCollectionTypeSelfWork) {// 自己的作品
            // Documents -> Events -> xxx -> Works -> zzz.jpg
            NSString *eventPath = [HTFileManager eventsPath];
            workPath = [[eventPath stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Works"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:workPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:workPath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            itemArr = [[HTFileManager sharedManager] listFileAtPath:workPath];
            
            collectionType = type;
            
            uploadArr = [NSMutableArray array];
        }
        if (collectionType == HTCollectionTypeNetWork) {// 他人的作品

            itemArr = arr;
            // 測試
            itemArr = @[@"", @"", @""];
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
    }
    if (collectionType == HTCollectionTypeNetWork) {
        [cell.photoImageView setImage:[UIImage imageNamed:@"HappyMan.jpg"]];
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
        // 全螢幕顯示相片
//        HTFullscreenImageViewController *vc = [[HTFullscreenImageViewController alloc] initWithImage:image];
//        [self presentViewController:vc animated:YES completion:nil];
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
    DLog(@"uploadArr: %@", uploadArr);
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
@end

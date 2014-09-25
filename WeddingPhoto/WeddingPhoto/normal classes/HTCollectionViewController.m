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

- (id)initWithItemArr:(NSArray *)arr
{
    self = [super initWithNibName:@"HTCollectionViewController" bundle:nil];
    if (self) {
        itemArray = @[@"Happy1", @"Happy2", @"Happy3", @"Happy4", @"Happy5", @"Happy1", @"Happy2", @"Happy3", @"Happy4", @"Happy5"];

        isSelfWork = NO;
    }
    return self;
}

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
            itemArray = [[HTFileManager sharedManager] listFileAtPath:workPath];
            
            isSelfWork = YES;
            collectionType = type;
        }
        if (collectionType == HTCollectionTypeNetWork) {// 他人的作品

            itemArray = arr;
            // 測試
            itemArray = @[@"", @"", @""];
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
    return [itemArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HTCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HappyCell" forIndexPath:indexPath];
    if (collectionType == HTCollectionTypeSelfWork) {
        NSString *targetPath = [workPath stringByAppendingPathComponent:itemArray[indexPath.row]];
        [cell.photoImageView setImage:[UIImage imageWithContentsOfFile:targetPath]];
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
        NSString *targetPath = [workPath stringByAppendingPathComponent:itemArray[indexPath.row]];
        UIImage *image = [UIImage imageWithContentsOfFile:targetPath];
        if (collectionType == HTCollectionTypeSelfWork) {
            
            HTEditPhotoViewController *vc = [[HTEditPhotoViewController alloc] initWithImage:image];
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        if (collectionType == HTCollectionTypeNetWork) {
            HTFullscreenImageViewController *vc = [[HTFullscreenImageViewController alloc] initWithImage:image];
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
    if (collectionType == HTCollectionTypeNetWork) {
        
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
@end

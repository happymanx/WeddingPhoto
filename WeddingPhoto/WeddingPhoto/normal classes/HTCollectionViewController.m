//
//  HTCollectionViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/22.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTCollectionViewController.h"
#import "HTCollectionCell.h"

@interface HTCollectionViewController ()

@end

@implementation HTCollectionViewController

- (id)initWithItemArr:(NSArray *)arr
{
    self = [super initWithNibName:@"HTCollectionViewController" bundle:nil];
    if (self) {
        itemArray = @[@"Happy1", @"Happy2", @"Happy3", @"Happy4", @"Happy5", @"Happy1", @"Happy2", @"Happy3", @"Happy4", @"Happy5"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [displayCollectionView registerNib:[UINib nibWithNibName:@"HTCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"HappyCell"];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [itemArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HTCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HappyCell" forIndexPath:indexPath];
    [cell.titleLabel setText:itemArray[indexPath.row]];
    [cell.photoImageView setImage:[UIImage imageNamed:@"HappyMan.jpg"]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    NSLog(@"Select indexPath.row: %i", indexPath.row);
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
    NSLog(@"Deselect indexPath.row: %i", indexPath.row);
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(80, 130);
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

@end

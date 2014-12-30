//
//  HTCollectionViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/22.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTCollectionViewController : HTBasicViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    IBOutlet UICollectionView *displayCollectionView;
    IBOutlet UIButton *uploadButton;
    IBOutlet UIButton *backButton;
    
    NSArray *itemArr;
    NSMutableArray *uploadArr;

    HTCollectionType collectionType;
    
    NSString *workPath;
    
    NSInteger uploadIndex;
}

- (id)initWithWorkArr:(NSArray *)arr collectionType:(HTCollectionType)mode;
@property(nonatomic,strong) NSString *keyStr;
@end

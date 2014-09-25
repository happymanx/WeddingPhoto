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
    
    NSArray *itemArray;
    
    BOOL isSelfWork;
    HTCollectionType collectionType;
    
    NSString *workPath;
}

- (id)initWithWorkArr:(NSArray *)arr collectionType:(HTCollectionType)mode;

@end

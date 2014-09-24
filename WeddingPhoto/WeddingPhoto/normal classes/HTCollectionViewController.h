//
//  HTCollectionViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/22.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HTCollectionViewModeEdit = 0,
    HTCollectionViewModeBrowse
} HTCollectionViewMode;

@interface HTCollectionViewController : HTBasicViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    IBOutlet UICollectionView *displayCollectionView;
    
    NSArray *itemArray;
    
    BOOL isSelfWork;
    HTCollectionViewMode collectionViewMode;
    
    NSString *workPath;
    
    NSMutableArray *cellImageViewArr;
}

- (id)initWithItemArr:(NSArray *)arr;
- (id)initWithSelfWorkArr:(NSArray *)arr collectionViewMode:(HTCollectionViewMode)mode;

@end

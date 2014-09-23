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
    
    NSArray *itemArray;
    
    BOOL isSelfWork;
    
    NSString *workPath;
}

- (id)initWithItemArr:(NSArray *)arr;
- (id)initWithSelfWorkArr:(NSArray *)arr;

@end

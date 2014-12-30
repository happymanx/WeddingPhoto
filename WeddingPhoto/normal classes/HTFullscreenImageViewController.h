//
//  HTFullscreenImageViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/25.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "GGFullscreenImageViewController.h"

@interface HTFullscreenImageViewController : HTBasicViewController <UIScrollViewDelegate>
{    
    NSArray *itemArr;
    NSInteger itemIndex;
    
    IBOutlet UIImageView *happyImageView;
    IBOutlet UIImageView *playImageView;
    IBOutlet UITextView *commentTextView;
    IBOutlet UIButton *saveButton;
    
    IBOutlet UIScrollView *displayScrollView;
    IBOutlet UIView *functionView;
    
    HTFullscreenType fullscreenType;
    IBOutlet UITextView *statementTextView;
    IBOutlet UILabel *statementLabel;
    IBOutlet UIView *statementView;
}

- (id)initWithItemArr:(NSArray *)arr index:(NSInteger)index type:(HTFullscreenType)type;

@end

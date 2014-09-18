//
//  HTEditPhotoViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/19.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACEDrawingView.h"


@interface HTEditPhotoViewController : HTBasicViewController <UIActionSheetDelegate, ACEDrawingViewDelegate>
{
    IBOutlet UIImageView *photoImageView;
    
    UIImage *sourceImage;
    UIImage *previewImage;
}

- (id) initWithImage:(UIImage *)image;

@property (nonatomic, unsafe_unretained) IBOutlet ACEDrawingView *drawingView;

@property (nonatomic, unsafe_unretained) IBOutlet UIButton *colorButton;


@end

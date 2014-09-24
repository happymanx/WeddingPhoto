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
    UIImage *originalImage;
    UIImageView *happyImageView;
    
    IBOutlet UIScrollView *displayScrollView;
}

- (id)initWithImage:(UIImage *)image;

@end

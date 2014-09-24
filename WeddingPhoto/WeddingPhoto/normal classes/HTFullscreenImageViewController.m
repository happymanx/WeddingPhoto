//
//  HTFullscreenImageViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/25.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTFullscreenImageViewController.h"

@interface HTFullscreenImageViewController ()

@end

@implementation HTFullscreenImageViewController

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithNibName:@"HTFullscreenImageViewController" bundle:nil];
    if (self) {
        originalImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupScrollView];
}

-(void)setupScrollView
{
    [displayScrollView setMaximumZoomScale:5.0];
    [displayScrollView setMinimumZoomScale:1.0];
    
    happyImageView = [[UIImageView alloc] initWithImage:originalImage];
    float ratio = self.view.frame.size.width / happyImageView.frame.size.width;
    happyImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, happyImageView.frame.size.height * ratio);
    happyImageView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    happyImageView.userInteractionEnabled = YES;
    
    [displayScrollView addSubview:happyImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDismiss)];
    [happyImageView addGestureRecognizer:tap];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView subviews][0];
}

- (void) onDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

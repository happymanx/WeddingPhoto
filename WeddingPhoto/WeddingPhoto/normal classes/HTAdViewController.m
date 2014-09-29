//
//  HTAdViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/10.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTAdViewController.h"

@interface HTAdViewController ()

@end

@implementation HTAdViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (id)initWithAdArr:(NSArray *)array adType:(HTAdType)type
{
    self = [super initWithNibName:@"HTAdViewController" bundle:nil];
    if (self) {
        adType = type;
        
        if (adType == HTAdTypeTrial) {
            adTypeTrialArr = array;
            // 測試
            adTypeTrialArr = @[@"a1", @"b2", @"c3"];
        }
        if (adType == HTAdTypeEvent) {
            adTypeEventArr = array;
            // 測試
            adTypeEventArr = @[@"http://www.google.com.tw/", @"https://www.facebook.com/", @"http://www.plurk.com/"];
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSArray *contentArr;
    if (adType == HTAdTypeEvent) {
        contentArr = adTypeEventArr;
    }
    if (adType == HTAdTypeTrial) {
        contentArr = adTypeTrialArr;
    }
    
    // 棄用 Scroll View
//    displayScrollView.contentSize = CGSizeMake(self.view.frame.size.width * [contentArr count], self.view.frame.size.height);
//    displayPageControl.numberOfPages = [contentArr count];
//    
//    for (int i = 0; i < [contentArr count]; i++) {
//        UIImageView *imageView = [[UIImageView alloc] init];
//        imageView.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
//        [imageView addGestureRecognizer:tap];
//        imageView.frame = CGRectMake(self.view.frame.size.width * i, 0, self.view.frame.size.width, self.view.frame.size.height);
//        if (i % 2 == 0) {
//            imageView.backgroundColor = [UIColor greenColor];
//        }
//        else {
//            imageView.backgroundColor = [UIColor blueColor];
//        }
//        [displayScrollView addSubview:imageView];
//    }
    
    // 使用疊起來 Image View
    adImageViewArr = [NSMutableArray array];
    for (int i = 0; i < [contentArr count]; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        if (i % 2 == 0) {
            imageView.backgroundColor = [UIColor greenColor];
        }
        else {
            imageView.backgroundColor = [UIColor yellowColor];
        }
        
        // 貼上關閉按鈕
        UIImage *closeImage = [UIImage imageNamed:@"but_photo_close.png"];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, closeImage.size.width/2, closeImage.size.height/2);
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        closeButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width - closeButton.frame.size.width, 40);
        [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [imageView addSubview:closeButton];
        imageView.userInteractionEnabled = YES;
        
        [self.view addSubview:imageView];
        
        // 手勢點擊
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:tap];
        
        [adImageViewArr addObject:imageView];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ((NSInteger)scrollView.contentOffset.x % (NSInteger)self.view.frame.size.width == 0) {
        displayPageControl.currentPage = (NSInteger)scrollView.contentOffset.x / (NSInteger)self.view.frame.size.width;
        
        selectedIndex = (NSInteger)scrollView.contentOffset.x / (NSInteger)self.view.frame.size.width;
    }
}

#pragma mark - Button Methods

-(IBAction)backButtonClicked:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tapAction:(UITapGestureRecognizer *)tap
{
    if (adType == HTAdTypeEvent) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adTypeEventArr[[adImageViewArr count] - 1]]];
    }
    if (adType == HTAdTypeTrial) {
        // 透過密碼下載
    }
}

-(void)closeButtonClicked:(UIButton *)button
{
    UIImageView *imageView = [adImageViewArr lastObject];
    [imageView removeFromSuperview];
    [adImageViewArr removeLastObject];
    imageView = nil;
    
    if ([adImageViewArr count] == 0) {// 最後一張廣告移除後退出
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end

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
    displayScrollView.contentSize = CGSizeMake(self.view.frame.size.width * [contentArr count], self.view.frame.size.height);
    displayPageControl.numberOfPages = [contentArr count];
    
    for (int i = 0; i < [contentArr count]; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:tap];
        imageView.frame = CGRectMake(self.view.frame.size.width * i, 0, self.view.frame.size.width, self.view.frame.size.height);
        if (i % 2 == 0) {
            imageView.backgroundColor = [UIColor greenColor];
        }
        else {
            imageView.backgroundColor = [UIColor blueColor];
        }
        [displayScrollView addSubview:imageView];
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
    DLog(@"selectedIndex: %li", (long)selectedIndex);
    if (adType == HTAdTypeEvent) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adTypeEventArr[selectedIndex]]];
    }
    if (adType == HTAdTypeTrial) {
        // 透過密碼下載
    }
}
@end

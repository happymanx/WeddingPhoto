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

- (id)initWithAdArr:(NSArray *)array
{
    self = [super initWithNibName:@"HTAdViewController" bundle:nil];
    if (self) {
        adArr = array;
        
        adArr = @[@"1", @"2", @"3"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    displayScrollView.contentSize = CGSizeMake(self.view.frame.size.width * [adArr count], self.view.frame.size.height);
    displayPageControl.numberOfPages = [adArr count];
    
    for (int i = 0; i < [adArr count]; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
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
    }
}

#pragma mark - Button Methods

-(IBAction)backButtonClicked:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

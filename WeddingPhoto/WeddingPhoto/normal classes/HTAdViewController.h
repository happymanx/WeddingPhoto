//
//  HTAdViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/10.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTAdViewController : HTBasicViewController <UIScrollViewDelegate>
{
    NSArray *adTypeTrialArr; // 存密碼，可下載試用
    NSArray *adTypeEventArr; // 存廣告，可點擊跳出
    
    IBOutlet UIScrollView *displayScrollView;
    IBOutlet UIPageControl *displayPageControl;
    
    HTAdType adType;
    NSInteger selectedIndex;
}

- (id)initWithAdArr:(NSArray *)array adType:(HTAdType)type;

@end

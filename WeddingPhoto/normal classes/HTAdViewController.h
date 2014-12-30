//
//  HTAdViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/10.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HTAdViewControllerDelegate <NSObject>

@optional
-(void)removeBlockView;

@end

@interface HTAdViewController : HTBasicViewController <UIScrollViewDelegate>
{
    NSArray *adTypeTrialArr; // 存密碼，可下載試用
    NSMutableArray *adTypeEventArr; // 存廣告，可點擊跳出
    NSArray *adTypeEventAdNameArr; // 存廣告檔名
    
    IBOutlet UIScrollView *displayScrollView;
    IBOutlet UIPageControl *displayPageControl;
    
    HTAdType adType;
    NSInteger selectedIndex;
    
    NSMutableArray *adImageViewArr;
}

@property (nonatomic) id <HTAdViewControllerDelegate> delegate;

- (id)initWithAdArr:(NSArray *)array adType:(HTAdType)type;

@end

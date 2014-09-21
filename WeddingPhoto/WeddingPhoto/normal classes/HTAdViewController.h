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
    NSArray *adArr;
    
    IBOutlet UIScrollView *displayScrollView;
    IBOutlet UIPageControl *displayPageControl;
}

- (id)initWithAdArr:(NSArray *)array;

@end

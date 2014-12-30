//
//  UINavigationController+PopTimes.h
//  WeddingPhoto
//
//  Created by Jason on 2014/10/30.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (popTimes)
- (void) popTwoViewControllersAnimated:(BOOL)animated;
- (void) popThreeViewControllersAnimated:(BOOL)animated;
@end

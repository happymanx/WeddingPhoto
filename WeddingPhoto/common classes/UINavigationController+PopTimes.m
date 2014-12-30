//
//  UINavigationController+PopTimes.m
//  WeddingPhoto
//
//  Created by Jason on 2014/10/30.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "UINavigationController+PopTimes.h"

@implementation UINavigationController (popTimes)

- (void) popTwoViewControllersAnimated:(BOOL)animated{
    [self popViewControllerAnimated:NO];
    [self popViewControllerAnimated:animated];
}

- (void) popThreeViewControllersAnimated:(BOOL)animated{
    [self popViewControllerAnimated:NO];
    [self popViewControllerAnimated:NO];
    [self popViewControllerAnimated:animated];
}

@end

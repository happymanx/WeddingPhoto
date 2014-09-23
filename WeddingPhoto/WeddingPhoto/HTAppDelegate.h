//
//  HTAppDelegate.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/5.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// 讓Youtube全螢幕播放可以旋轉
@property (nonatomic) BOOL fullScreenVideoIsPlaying;

@property (nonatomic, retain) NSString *downloadCode;
@property (nonatomic, retain) NSString *eventName;

+(HTAppDelegate *)sharedDelegate;

@end

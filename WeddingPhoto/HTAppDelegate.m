//
//  HTAppDelegate.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/5.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTAppDelegate.h"
#import "HTMainViewController.h"
#import "HTSplashViewController.h"

@implementation HTAppDelegate

+(HTAppDelegate *)sharedDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [HTFileManager sharedManager];

    HTMainViewController *vc = [[HTMainViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    nc.navigationBarHidden = YES;
    
    // 記錄語言碼
    NSString *languageStr = [[NSLocale preferredLanguages] objectAtIndex:0];
//    NSString *languageStr = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    // 預設為英語
    self.languageCode = @"1";
    if ([languageStr isEqualToString:@"zh-Hant"]) {// 繁中
        self.languageCode = @"2";
    }
    else if ([languageStr isEqualToString:@"zh-Hans"]) {// 簡中
        self.languageCode = @"3";
    }
    else if ([languageStr isEqualToString:@"en"]) {// 英語
        self.languageCode = @"1";
    }
    // 記錄UDID
    self.udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    
    self.window.rootViewController = nc;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // 顯示Splash影像
    HTSplashViewController *vc = [[HTSplashViewController alloc] init];
    [self.window.rootViewController presentViewController:vc animated:NO completion:nil];
    // 檢查事件版本
    [HTNetworkManager checkEventVersion];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.fullScreenVideoIsPlaying) {
        return UIInterfaceOrientationMaskAll;
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end

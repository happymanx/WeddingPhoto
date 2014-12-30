//
//  HTFileManager.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/23.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface HTFileManager : NSObject
{
    MBProgressHUD *frameHUD;
    MBProgressHUD *adHUD;
}

+(HTFileManager *)sharedManager;

+(NSString *)eventsPath;

+(NSString *)documentsPath;

-(NSArray *)listFileAtPath:(NSString *)path;

// 儲存Event的Frame Image
- (void)saveFrameImageWithEventKey:(NSString *)key infoArr:(NSArray *)arr update:(BOOL)update;

// 儲存Event的Ad Image
- (void)saveAdImageWithEventKey:(NSString *)key infoArr:(NSArray *)arr update:(BOOL)update;

@end

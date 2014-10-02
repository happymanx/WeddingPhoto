//
//  HTFileManager.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/23.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTFileManager : NSObject

+(HTFileManager *)sharedManager;

+(NSString *)eventsPath;

+(NSString *)documentsPath;

-(NSArray *)listFileAtPath:(NSString *)path;

// 儲存Event的Frame Image
+ (void)saveFrameImageWithEventKey:(NSString *)key infoArr:(NSArray *)arr;

// 儲存Event的Ad Image
+ (void)saveAdImageWithEventKey:(NSString *)key infoArr:(NSArray *)arr;

@end

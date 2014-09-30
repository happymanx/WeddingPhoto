//
//  HTFileManager.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/23.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTFileManager.h"

@implementation HTFileManager

+(HTFileManager *)sharedManager
{
    static HTFileManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[HTFileManager alloc] init];
        [sharedManager createInitialFolder];
        [sharedManager createTestEventFolder];
    });
    return sharedManager;
}

/*
 一定要先建立資料夾
 */
-(void)createInitialFolder
{
    // Home -> Documents -> Events
    
    // 建立Documents資料夾
    // 建立Events資料夾
    [HTFileManager eventsPath];
}

+(NSString *)eventsPath
{
    NSString *documentsPath = [HTFileManager documentsPath];
    NSString *eventsPath = [documentsPath stringByAppendingPathComponent:@"Events"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:eventsPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:eventsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return eventsPath;
}

+(NSString *)documentsPath
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return documentsPath;
}

-(void)createTestEventFolder
{
//    NSArray *folderNameArr = @[@"Dannys Event1", @"Dannys Event2", @"Dannys Event3"];
    NSArray *folderNameArr = @[];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[HTFileManager eventsPath]]) {
        
        for (int i = 0; i < [folderNameArr count]; i++) {
            NSString *folderPath = [[HTFileManager  eventsPath] stringByAppendingPathComponent:folderNameArr[i]];
            [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
}

-(NSArray *)listFileAtPath:(NSString *)path
{
    //-----> LIST ALL FILES <-----//
    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}

@end

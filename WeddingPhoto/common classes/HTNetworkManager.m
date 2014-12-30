//
//  HTNetworkManager.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/9.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTNetworkManager.h"
#import "AFHTTPRequestOperationManager.h"

@implementation HTNetworkManager

- (id)initWithFinishBlock:(void (^)(NSObject *))finishBlockToRun failBlock:(void (^)(NSString *, NSInteger))failBlockToRun
{
    self = [super init];
    if (self) {
        self.finishBlock = finishBlockToRun;
        self.failBlock = failBlockToRun;
    }
    return self;
}

+ (HTNetworkManager *)requestWithFinishBlock:(void (^)(NSObject *objcet))finishBlockToRun failBlock:(void (^)(NSString *errStr, NSInteger errCode))failBlockToRun
{    
    return [[HTNetworkManager alloc] initWithFinishBlock:finishBlockToRun failBlock:failBlockToRun];
}

-(void)getDownloadKey:(NSString *)codeStr
{
    // 中文需要編碼成有百分比的狀態
    NSString *encodedStr = [codeStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *targetPath = [HTAPISiteBase stringByAppendingPathComponent:@"api_get_download_key1.php?"];
    NSString *finalPath = [targetPath stringByAppendingFormat:@"temp_download_key=%@&language=%@", encodedStr, [HTAppDelegate sharedDelegate].languageCode];
    NSLog(@"finalPath:%@",finalPath);
    [manager POST:finalPath
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              self.finishBlock(responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              self.failBlock(error.description, error.code);
          }];
}

-(void)getProject:(NSString *)keyStr
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *targetPath = [HTAPISiteBase stringByAppendingPathComponent:@"api_project1.php?"];
    NSString *finalPath = [targetPath stringByAppendingFormat:@"download_key=%@&language=%@&user_unique_id=%@", keyStr, [HTAppDelegate sharedDelegate].languageCode, [HTAppDelegate sharedDelegate].udid];
    [manager POST:finalPath
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              self.finishBlock(responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              self.failBlock(error.description, error.code);
          }];
}

-(void)getSharedFile:(NSString *)keyStr
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *targetPath = [HTAPISiteBase stringByAppendingPathComponent:@"api_shared_files1.php?"];
    NSString *finalPath = [targetPath stringByAppendingFormat:@"download_key=%@&language=%@", keyStr, [HTAppDelegate sharedDelegate].languageCode];
    [manager POST:finalPath
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              self.finishBlock(responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              self.failBlock(error.description, error.code);
          }];
}

-(void)getDemoBlockAd
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *targetPath = [HTAPISiteBase stringByAppendingPathComponent:@"api_demo_ads1.php?"];
    NSString *finalPath = [targetPath stringByAppendingFormat:@"language=%@", [HTAppDelegate sharedDelegate].languageCode];
    [manager POST:finalPath
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              self.finishBlock(responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              self.failBlock(error.description, error.code);
          }];
}

-(void)getDemoSectionAd
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *targetPath = [HTAPISiteBase stringByAppendingPathComponent:@"api_demo_ads2.php?"];
    NSString *finalPath = [targetPath stringByAppendingFormat:@"language=%@", [HTAppDelegate sharedDelegate].languageCode];
    [manager POST:finalPath
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              self.finishBlock(responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              self.failBlock(error.description, error.code);
          }];
}

+(void)checkEventVersion
{
    NSArray *fileArr = [[HTFileManager sharedManager] listFileAtPath:[HTFileManager documentsPath]];
    BOOL isDirectory;
    // 檔案名稱即是Key
    for (int i = 0; i < [fileArr count]; i++) {
        NSString *filePath = [[HTFileManager documentsPath] stringByAppendingPathComponent:fileArr[i]];
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        // 非資料夾才去比對JSON檔
        if (!isDirectory) {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSString *targetPath = [HTAPISiteBase stringByAppendingPathComponent:@"api_project1.php?"];
            NSString *finalPath = [targetPath stringByAppendingFormat:@"download_key=%@&language=%@&user_unique_id=%@", fileArr[i], [HTAppDelegate sharedDelegate].languageCode, [HTAppDelegate sharedDelegate].udid];
            [manager POST:finalPath
               parameters:nil
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      DLog(@"responseObject: %@", responseObject);
                      NSDictionary *newDict = (NSDictionary *)responseObject;
                      NSDictionary *oldDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
                      // 如果相框版本不同
                      if ([newDict[@"ImageFileVersion"] integerValue] !=[oldDict[@"ImageFileVersion"] integerValue]) {
                          // 儲存新版JSON檔(取代舊版)
                          [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                          [newDict writeToFile:filePath atomically:YES];
                          // 刪除舊版的相框
                          [[NSFileManager defaultManager] removeItemAtPath:[[[HTFileManager eventsPath] stringByAppendingPathComponent:fileArr[i]] stringByAppendingPathComponent:@"Frames"] error:nil];
                          // 下載新版的相框
                          [[HTFileManager sharedManager] saveFrameImageWithEventKey:[fileArr[i] description] infoArr:newDict[@"ImageFiles"] update:YES];
                      }
                      // 如果廣告版本不同
                      if ([newDict[@"AdFileVersion"] integerValue] != [oldDict[@"AdFileVersion"] integerValue]) {
                          // 儲存新版JSON檔(取代舊版)
                          [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                          [newDict writeToFile:filePath atomically:YES];
                          // 刪除舊版的廣告
                          [[NSFileManager defaultManager] removeItemAtPath:[[[HTFileManager eventsPath] stringByAppendingPathComponent:fileArr[i]] stringByAppendingPathComponent:@"Ads"] error:nil];
                          // 下載新版的廣告
                          [[HTFileManager sharedManager] saveAdImageWithEventKey:[fileArr[i] description] infoArr:newDict[@"AdFiles"] update:YES];
                      }
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      DLog(@"responseObject: %@", error);
                      
                  }];
        }
    }
}

@end

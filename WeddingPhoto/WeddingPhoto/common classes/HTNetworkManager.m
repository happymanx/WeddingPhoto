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
    NSString *finalPath = [targetPath stringByAppendingFormat:@"temp_download_key=%@&language=%@", encodedStr, @"2"];
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
    NSString *finalPath = [targetPath stringByAppendingFormat:@"download_key=%@&language=%@&user_unique_id=%@", keyStr, @"2", @"123"];
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
    NSString *finalPath = [targetPath stringByAppendingFormat:@"download_key=%@&language=%@", keyStr, @"2"];
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

-(void)getDemoAd
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *targetPath = [HTAPISiteBase stringByAppendingPathComponent:@"api_demo_ads1.php?"];
    NSString *finalPath = [targetPath stringByAppendingFormat:@"language=%@", @"2"];
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


@end

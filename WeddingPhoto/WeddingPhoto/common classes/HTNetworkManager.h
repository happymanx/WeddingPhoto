//
//  HTNetworkManager.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/9.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTNetworkManager : NSObject

@property (nonatomic, copy) void (^finishBlock) (NSObject *);
@property (nonatomic, copy) void (^failBlock) (NSString *, NSInteger);

- (id)initWithFinishBlock:(void (^)(NSObject *))finishBlockToRun failBlock:(void (^)(NSString *, NSInteger))failBlockToRun;

+ (HTNetworkManager *)requestWithFinishBlock:(void (^)(NSObject *objcet))finishBlockToRun failBlock:(void (^)(NSString *errStr, NSInteger errCode))failBlockToRun;

@end

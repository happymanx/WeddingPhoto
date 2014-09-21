//
//  HTNetworkManager.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/9.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTNetworkManager.h"

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

@end

//
//  HTConstant.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/9.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef HT_CONSTANT
#define HT_CONSTANT

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

static NSString *const HTAPISiteBase = @"http://www.woshot.com/api/";
//static NSString *const HTAPISiteBase = @"http://www.happymanx.com/api/";

typedef enum {
    HTAdTypeTrial = 0,
    HTAdTypeEvent
} HTAdType;

typedef enum {
    HTCollectionTypeSelfWorkEdit = 0,
    HTCollectionTypeSelfWorkBrowse,
    HTCollectionTypeNetWork
} HTCollectionType;

typedef enum {
    HTFullscreenTypeSelfWork = 0,
    HTFullscreenTypeNetWork
} HTFullscreenType;

#endif

//
//  HTFrameImage.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/18.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface HTFrameImage : NSObject

@property (nonatomic, strong) NSArray *frameArr;// 事件相框群
@property (nonatomic, strong) NSString *framePath;// 相框路徑
@property (nonatomic) BOOL isVertical;// 是否直的

+(HTFrameImage *)sharedInstance;

+(NSArray *)defautFrameArr;

- (UIImage *)returnMixedImage:(UIImage *)image withSize:(CGSize)finalSize;

@end

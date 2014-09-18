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

@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSArray *frameArr;
@property (nonatomic, strong) NSString *frameName;

+(HTFrameImage *)sharedInstance;

+(NSArray *)defautFrameArr;

- (UIImage *)returnMixedImage:(UIImage *)img withSize:(CGSize)finalSize;

@end

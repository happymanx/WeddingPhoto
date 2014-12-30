//
//  HTFrameImage.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/18.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTFrameImage.h"
#import "UIImage+RotationMethods.h"

@implementation HTFrameImage

+(HTFrameImage *)sharedInstance
{
    static HTFrameImage *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HTFrameImage alloc] init];
    });
    return sharedInstance;
}

+(NSArray *)defautFrameArr
{
    return @[@"1.png", @"2.png", @"3.png"];
}

- (UIImage *)returnMixedImage:(UIImage *)image withSize:(CGSize)finalSize
{
    // 相片轉成直立方向
    CGImageRef imageRef = [image CGImage];
    UIImageOrientation orientation;
    // 記錄舊的方向，合成後要轉回去
    UIImageOrientation oldOrientation = UIImageOrientationUp;
    switch (image.imageOrientation) {
        case UIImageOrientationUp:
            orientation = UIImageOrientationRight;
            oldOrientation = UIImageOrientationUp;
            break;
        case UIImageOrientationDown:
            orientation = UIImageOrientationRight;
            oldOrientation = UIImageOrientationDown;
            break;
        case UIImageOrientationLeft:
            orientation = UIImageOrientationRight;
            oldOrientation = UIImageOrientationLeft;
            break;
        case UIImageOrientationRight:
            orientation = UIImageOrientationRight;
            oldOrientation = UIImageOrientationRight;
            break;
            
        default:
            break;
    }
    UIImage *rotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:orientation];
    
    UIImage *frameImage = [UIImage imageWithContentsOfFile:self.framePath];
    
    UIGraphicsBeginImageContext(frameImage.size);
    
#pragma mark - 疊三層（底圖、相片、相框）輸出圖
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameImage.size.width, frameImage.size.height)];
    UIImageView *frameImageView = [[UIImageView alloc] initWithFrame:bottomView.frame];
    frameImageView.contentMode = UIViewContentModeScaleAspectFill;
    UIImageView *RotatedImageView = [[UIImageView alloc] initWithFrame:bottomView.frame];
    RotatedImageView.contentMode = UIViewContentModeScaleAspectFill;
    [frameImageView setImage:frameImage];
    [RotatedImageView setImage:rotatedImage];
    
#pragma mark - 修正前鏡頭莫名的問題
    // 如果是前鏡頭
    if ([HTAppDelegate sharedDelegate].isFromCamera == YES) {
        // 若是橫向影像
        if (oldOrientation == UIImageOrientationDown ||
            oldOrientation == UIImageOrientationUp) {
            // 先旋轉180度
            RotatedImageView.transform = CGAffineTransformMakeRotation(M_PI);
            // 再左右反射
            RotatedImageView.transform = CGAffineTransformMakeScale(-1, 1);
        }
        // 若是直向影像
        else if (oldOrientation == UIImageOrientationRight ||
                 oldOrientation == UIImageOrientationLeft) {
            // 左右反射
            RotatedImageView.transform = CGAffineTransformMakeScale(-1, 1);
        }
    }
    [bottomView addSubview:RotatedImageView];
    [bottomView addSubview:frameImageView];

    [bottomView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *mixedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 將相片方向轉回去
    
    // 根據相框方向
//    CGImageRef imageRefx = [mixedImage CGImage];
    UIImage *rotatedImagex;
    if ([HTFrameImage sharedInstance].isVertical) {
//        rotatedImagex = [UIImage imageWithCGImage:imageRefx scale:1.0 orientation:UIImageOrientationUp];
        rotatedImagex = [mixedImage imageRotatedByDegrees:0];
    }
    else {
//        rotatedImagex = [UIImage imageWithCGImage:imageRefx scale:1.0 orientation:UIImageOrientationLeft];
        rotatedImagex = [mixedImage imageRotatedByDegrees:-90];
    }

    // 根據手機方向（棄用）
//    switch (oldOrientation) {
//        case UIImageOrientationUp:// 左倒
//            rotatedImagex = [UIImage imageWithCGImage:imageRefx scale:1.0 orientation:UIImageOrientationLeft];
//            break;
//        case UIImageOrientationDown:// 右倒
//            rotatedImagex = [UIImage imageWithCGImage:imageRefx scale:1.0 orientation:UIImageOrientationRight];
//            break;
//        case UIImageOrientationLeft:// 倒著
//            rotatedImagex = [UIImage imageWithCGImage:imageRefx scale:1.0 orientation:UIImageOrientationDown];
//            break;
//        case UIImageOrientationRight:// 正著
//            rotatedImagex = [UIImage imageWithCGImage:imageRefx scale:1.0 orientation:UIImageOrientationUp];
//            break;
//        default:
//            // 不可能到這裡
//            break;
//    }
    return rotatedImagex;
}

@end

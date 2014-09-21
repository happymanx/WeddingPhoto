//
//  HTFrameImage.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/18.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTFrameImage.h"

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
    switch (image.imageOrientation) {
        case UIImageOrientationUp:
            orientation = UIImageOrientationRight;
            break;
        case UIImageOrientationDown:
            orientation = UIImageOrientationRight;
            break;
        case UIImageOrientationLeft:
            orientation = UIImageOrientationRight;
            break;
        case UIImageOrientationRight:
            orientation = UIImageOrientationRight;
            break;
            
        default:
            break;
    }
    UIImage *rotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:orientation];
    
    UIImage *frameImage = [UIImage imageNamed:self.frameName];
    
    UIGraphicsBeginImageContext(rotatedImage.size);
    [rotatedImage drawInRect:CGRectMake(0, 0, rotatedImage.size.width, rotatedImage.size.height)];
    [frameImage drawInRect:CGRectMake(0, 0, rotatedImage.size.width, rotatedImage.size.height)];
    UIImage *mixedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return mixedImage;
}
@end

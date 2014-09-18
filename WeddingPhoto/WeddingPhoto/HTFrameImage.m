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

- (UIImage *)returnMixedImage:(UIImage *)img withSize:(CGSize)finalSize
{
    UIImage *frameImage = [UIImage imageNamed:self.frameName];
    
    UIGraphicsBeginImageContext(finalSize);
    [img drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
    [frameImage drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end

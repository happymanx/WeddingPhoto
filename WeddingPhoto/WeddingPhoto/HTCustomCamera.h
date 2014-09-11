//
//  HTCustomCamera.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/11.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "DBCameraView.h"

@interface HTCustomCamera : DBCameraView

@property (nonatomic, strong) UIView *bottomContainerBar;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) CALayer *focusBox, *exposeBox;

- (void) buildInterface;

@end

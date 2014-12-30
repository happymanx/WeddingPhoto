//
//  DBCameraView.m
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraView.h"
#import "DBCameraMacros.h"
#import "UIImage+Crop.h"
#import "UIImage+TintColor.h"

// 我的view controller
#import "HTFrameImage.h"
#import "HTCollectionViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>


#define previewFrameRetina (CGRect){ 0, 0, 320, 380 }
#define previewFrameRetina_4 (CGRect){ 0, 0, 320, 480 }

// pinch
#define MAX_PINCH_SCALE_NUM   3.f
#define MIN_PINCH_SCALE_NUM   1.f

@interface DBCameraView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) CALayer *focusBox, *exposeBox;
@property (nonatomic, strong) UIView *topContainerBar;
@property (nonatomic, strong) UIView *bottomContainerBar;

// pinch
@property (nonatomic, assign) CGFloat preScaleNum;
@property (nonatomic, assign) CGFloat scaleNum;
@end

@implementation DBCameraView
@synthesize tintColor = _tintColor;
@synthesize selectedTintColor = _selectedTintColor;

+ (id) initWithFrame:(CGRect)frame
{
    return [[self alloc] initWithFrame:frame captureSession:nil];
}

+ (DBCameraView *) initWithCaptureSession:(AVCaptureSession *)captureSession
{
    return [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds] captureSession:captureSession];
}

- (id) initWithFrame:(CGRect)frame captureSession:(AVCaptureSession *)captureSession
{
    self = [super initWithFrame:frame];
    
    if ( self ) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
        if ( captureSession ) {
            [_previewLayer setSession:captureSession];
            [_previewLayer setFrame:previewFrameRetina_4];
        } else
            [_previewLayer setFrame:self.bounds];
        
        if ( [_previewLayer respondsToSelector:@selector(connection)] ) {
            if ( [_previewLayer.connection isVideoOrientationSupported] )
                [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
        
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        [self.layer addSublayer:_previewLayer];
        
        self.tintColor = [UIColor whiteColor];
        self.selectedTintColor = [UIColor redColor];
    }
    
    return self;
}

- (void) defaultInterface
{
    UIView *focusView = [[UIView alloc] initWithFrame:self.frame];
    focusView.backgroundColor = [UIColor clearColor];
    [focusView.layer addSublayer:self.focusBox];
    [self addSubview:focusView];
    
    UIView *exposeView = [[UIView alloc] initWithFrame:self.frame];
    exposeView.backgroundColor = [UIColor clearColor];
    [exposeView.layer addSublayer:self.exposeBox];
    [self addSubview:exposeView];
    
#pragma mark - 相框
    NSString *framePath = [[[HTFileManager eventsPath] stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Frames"];
    self.frameArr = [[HTFileManager sharedManager] listFileAtPath:framePath];
    
    
//    self.frameArr = [HTFrameImage defautFrameArr];
    self.frameNumber = 0;
//    [HTFrameImage sharedInstance].frameName = self.frameArr[self.frameNumber];
    
    self.frameImageView = [[UIImageView alloc] initWithFrame:previewFrameRetina_4];
//    self.frameImageView.image = [UIImage imageNamed:self.frameArr[self.frameNumber]];
    NSString *targetPath = [framePath stringByAppendingPathComponent:self.frameArr[self.frameNumber]];
    // 記錄相框路徑，拍照合成用
    [HTFrameImage sharedInstance].framePath = targetPath;
    
    // 記錄直式或橫式
    NSString *eventJSONPath = [[HTFileManager documentsPath] stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:eventJSONPath];
    NSArray *frameInfoArr = dict[@"ImageFiles"];
    if ([frameInfoArr[self.frameNumber][@"Orientation"] isEqualToString:@"VERTICAL"]) {
        [HTFrameImage sharedInstance].isVertical = YES;
    }
    else {
        [HTFrameImage sharedInstance].isVertical = NO;
    }
    
    self.frameImageView.image = [UIImage imageWithContentsOfFile:targetPath];
    self.frameImageView.userInteractionEnabled = YES;
    
    [self addSubview:self.frameImageView];
    
#pragma mark - 左右箭號
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    UIButton *leftArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftArrowButton setImage:[UIImage imageNamed:@"but_left.png"] forState:UIControlStateNormal];
    [leftArrowButton addTarget:self action:@selector(leftButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    leftArrowButton.frame = CGRectMake(0, 0, 30, 44);
    leftArrowButton.center = CGPointMake(15, screenRect.size.height / 2 - 20);
    [self addSubview:leftArrowButton];
    
    UIButton *rightArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightArrowButton setImage:[UIImage imageNamed:@"but_right.png"] forState:UIControlStateNormal];
    [rightArrowButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    rightArrowButton.frame = CGRectMake(0, 0, 30, 44);
    rightArrowButton.center = CGPointMake(screenRect.size.width - 15, screenRect.size.height / 2 - 20);
    [self addSubview:rightArrowButton];
    
//    [self addSubview:self.topContainerBar];
    [self addSubview:self.bottomContainerBar];
    
    [self.bottomContainerBar addSubview:self.cameraButton];
    [self.bottomContainerBar addSubview:self.flashButton];
//    [self.topContainerBar addSubview:self.gridButton];
    
    [self.bottomContainerBar addSubview:self.triggerButton];
    [self addSubview:self.closeButton];
    [self.bottomContainerBar addSubview:self.photoLibraryButton];

    [self createGesture];
}

#pragma mark - Containers

- (UIView *) topContainerBar
{
    if ( !_topContainerBar ) {
        _topContainerBar = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, CGRectGetWidth(self.bounds), CGRectGetMinY(IS_RETINA_4 ? previewFrameRetina_4 : previewFrameRetina) }];
        [_topContainerBar setBackgroundColor:RGBColor(0x000000, 1)];
    }
    return _topContainerBar;
}

- (UIView *) bottomContainerBar
{
    if ( !_bottomContainerBar ) {
        CGFloat newY = CGRectGetMaxY(previewFrameRetina_4);
        if (!IS_RETINA_4) {
            newY = newY - 88;
        }
        _bottomContainerBar = [[UIView alloc] initWithFrame:(CGRect){ 0, newY, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - newY }];
        [_bottomContainerBar setUserInteractionEnabled:YES];
        [_bottomContainerBar setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
    }
    return _bottomContainerBar;
}

#pragma mark - Buttons

- (UIButton *) photoLibraryButton
{
    if ( !_photoLibraryButton ) {
        _photoLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoLibraryButton setBackgroundColor:RGBColor(0xffffff, .1)];
        [_photoLibraryButton.layer setCornerRadius:4];
        [_photoLibraryButton.layer setBorderWidth:2];
        [_photoLibraryButton.layer setBorderColor:RGBColor(0xffffff, 1.).CGColor];
        [_photoLibraryButton setFrame:(CGRect){ 25,  CGRectGetMidY(self.bottomContainerBar.bounds) - 25, 50, 50 }];
        [_photoLibraryButton addTarget:self action:@selector(libraryAction:) forControlEvents:UIControlEventTouchUpInside];

#pragma mark - 讀取最新拍的相片為縮圖
        // 產生另一Image View蓋住原本Photo Library的相片
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _photoLibraryButton.frame.size.width, _photoLibraryButton.frame.size.height)];
        self.thumbnailImageView.backgroundColor = [UIColor grayColor];
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnailImageView.clipsToBounds = YES;
        // 讀取APP中該事件最後一張相片
        // Documents -> Events -> xxx -> Works -> zzz.jpg
        NSString *eventPath = [HTFileManager eventsPath];
        NSString *workPath = [[eventPath stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Works"];
        NSArray *nameArr = [[HTFileManager sharedManager] listFileAtPath:workPath];
        if ([nameArr count] == 0) {
            self.thumbnailImageView.backgroundColor = [UIColor blackColor];
        }
        else {
            NSString *imageName = [workPath stringByAppendingPathComponent:[nameArr lastObject]];
            UIImage *photoImage = [UIImage imageWithContentsOfFile:imageName];
            [self.thumbnailImageView setImage:photoImage];
        }
        self.thumbnailImageView.layer.cornerRadius = 4;
        
        [_photoLibraryButton addSubview:self.thumbnailImageView];
    }
    
    return _photoLibraryButton;
}

- (UIButton *) triggerButton
{
    if ( !_triggerButton ) {
        _triggerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_triggerButton setBackgroundColor:self.tintColor];
        [_triggerButton setImage:[UIImage imageNamed:@"but_photo.png"] forState:UIControlStateNormal];
        [_triggerButton setFrame:(CGRect){ 0, 0, 60, 60 }];
        [_triggerButton.layer setCornerRadius:30.0f];
        [_triggerButton setCenter:(CGPoint){ CGRectGetMidX(self.bottomContainerBar.bounds), CGRectGetMidY(self.bottomContainerBar.bounds) }];
        [_triggerButton addTarget:self action:@selector(triggerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _triggerButton;
}

- (UIButton *) closeButton
{
    if ( !_closeButton ) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setBackgroundColor:[UIColor clearColor]];
        [_closeButton setImage:[UIImage imageNamed:@"but_back.png"] forState:UIControlStateNormal];
        [_closeButton setFrame:(CGRect){ 10, 10, 32, 32 }];
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeButton;
}

- (UIButton *) cameraButton
{
    if ( !_cameraButton ) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraButton setBackgroundColor:[UIColor clearColor]];
        [_cameraButton setImage:[[UIImage imageNamed:@"but_switch.png"] tintImageWithColor:self.tintColor] forState:UIControlStateNormal];
        [_cameraButton setImage:[[UIImage imageNamed:@"but_switch.png"] tintImageWithColor:self.selectedTintColor] forState:UIControlStateSelected];
        [_cameraButton setFrame:(CGRect){ CGRectGetWidth(self.bounds) - 60, CGRectGetMidY(self.bottomContainerBar.bounds) - 30, 40, 30}];
        [_cameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cameraButton;
}

- (UIButton *) flashButton
{
    if ( !_flashButton ) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashButton setBackgroundColor:[UIColor clearColor]];
        [_flashButton setImage:[[UIImage imageNamed:@"but_flash_no.png"] tintImageWithColor:self.tintColor] forState:UIControlStateNormal];
//        [_flashButton setImage:[[UIImage imageNamed:@"but_flash.png"] tintImageWithColor:self.selectedTintColor] forState:UIControlStateSelected];
        [_flashButton setFrame:(CGRect){ CGRectGetWidth(self.bounds) - 55, CGRectGetMidY(self.bottomContainerBar.bounds), 30, 30 }];
        [_flashButton addTarget:self action:@selector(flashTriggerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _flashButton;
}

- (UIButton *) gridButton
{
    if ( !_gridButton ) {
        _gridButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_gridButton setBackgroundColor:[UIColor clearColor]];
        [_gridButton setImage:[[UIImage imageNamed:@"cameraGrid"] tintImageWithColor:self.tintColor] forState:UIControlStateNormal];
        [_gridButton setImage:[[UIImage imageNamed:@"cameraGrid"] tintImageWithColor:self.selectedTintColor] forState:UIControlStateSelected];
        [_gridButton setFrame:(CGRect){ 0, 0, 30, 30 }];
        [_gridButton setCenter:(CGPoint){ CGRectGetMidX(self.topContainerBar.bounds), CGRectGetMidY(self.topContainerBar.bounds) }];
        [_gridButton addTarget:self action:@selector(addGridToCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _gridButton;
}

-(void)leftButtonClicked:(UIButton *)button
{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] init];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self handleSwipe:swipe];
}

-(void)rightButtonClicked:(UIButton *)button
{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] init];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self handleSwipe:swipe];
}

#pragma mark - Focus / Expose Box

- (CALayer *) focusBox
{
    if ( !_focusBox ) {
        _focusBox = [[CALayer alloc] init];
        [_focusBox setCornerRadius:45.0f];
        [_focusBox setBounds:CGRectMake(0.0f, 0.0f, 90, 90)];
        [_focusBox setBorderWidth:5.f];
        [_focusBox setBorderColor:[RGBColor(0xffffff, 1) CGColor]];
        [_focusBox setOpacity:0];
    }
    
    return _focusBox;
}

- (CALayer *) exposeBox
{
    if ( !_exposeBox ) {
        _exposeBox = [[CALayer alloc] init];
        [_exposeBox setCornerRadius:55.0f];
        [_exposeBox setBounds:CGRectMake(0.0f, 0.0f, 110, 110)];
        [_exposeBox setBorderWidth:5.f];
        [_exposeBox setBorderColor:[self.selectedTintColor CGColor]];
        [_exposeBox setOpacity:0];
    }
    
    return _exposeBox;
}

- (void) draw:(CALayer *)layer atPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    if ( remove )
        [layer removeAllAnimations];
    
    if ( [layer animationForKey:@"transform.scale"] == nil && [layer animationForKey:@"opacity"] == nil ) {
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        [layer setPosition:point];
        [CATransaction commit];
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [scale setFromValue:[NSNumber numberWithFloat:1]];
        [scale setToValue:[NSNumber numberWithFloat:0.7]];
        [scale setDuration:0.8];
        [scale setRemovedOnCompletion:YES];
        
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacity setFromValue:[NSNumber numberWithFloat:1]];
        [opacity setToValue:[NSNumber numberWithFloat:0]];
        [opacity setDuration:0.8];
        [opacity setRemovedOnCompletion:YES];
        
        [layer addAnimation:scale forKey:@"transform.scale"];
        [layer addAnimation:opacity forKey:@"opacity"];
    }
}

- (void) drawFocusBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
#pragma mark - 定焦後換最新的相片縮圖
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 讀取APP中該事件最後一張相片
        // Documents -> Events -> xxx -> Works -> zzz.jpg
        NSString *eventPath = [HTFileManager eventsPath];
        NSString *workPath = [[eventPath stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Works"];
        NSArray *nameArr = [[HTFileManager sharedManager] listFileAtPath:workPath];
        if ([nameArr count] == 0) {
            [self.thumbnailImageView setImage:nil];
            self.thumbnailImageView.backgroundColor = [UIColor blackColor];
        }
        else {
            NSString *imageName = [workPath stringByAppendingPathComponent:[nameArr lastObject]];
            UIImage *photoImage = [UIImage imageWithContentsOfFile:imageName];
            [self.thumbnailImageView setImage:photoImage];
        }
    });

    [self draw:_focusBox atPointOfInterest:point andRemove:remove];
}

- (void) drawExposeBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    [self draw:_exposeBox atPointOfInterest:point andRemove:remove];
}

#pragma mark - Gestures

- (void) createGesture
{
    _swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [_swipeLeft setDelaysTouchesEnded:NO];
    [_swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.frameImageView addGestureRecognizer:_swipeLeft];
    
    _swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [_swipeRight setDelaysTouchesEnded:NO];
    [_swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.frameImageView addGestureRecognizer:_swipeRight];

//    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( tapToFocus: )];
//    [_singleTap setDelaysTouchesEnded:NO];
//    [_singleTap setNumberOfTapsRequired:1];
//    [_singleTap setNumberOfTouchesRequired:1];
//    [self addGestureRecognizer:_singleTap];
//    
//    _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( tapToExpose: )];
//    [_doubleTap setDelaysTouchesEnded:NO];
//    [_doubleTap setNumberOfTapsRequired:2];
//    [_doubleTap setNumberOfTouchesRequired:1];
//    [self addGestureRecognizer:_doubleTap];
//    
//    [_singleTap requireGestureRecognizerToFail:_doubleTap];
//    
    _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [_pinch setDelaysTouchesEnded:NO];
    [self addGestureRecognizer:_pinch];
//
//    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector( hanldePanGestureRecognizer: )];
//    [_panGestureRecognizer setDelaysTouchesEnded:NO];
//    [_panGestureRecognizer setMinimumNumberOfTouches:1];
//    [_panGestureRecognizer setMaximumNumberOfTouches:1];
//    [_panGestureRecognizer setDelegate:self];
//    [self addGestureRecognizer:_panGestureRecognizer];
    

}

#pragma mark - Actions

- (void) libraryAction:(UIButton *)button
{
    if ( [_delegate respondsToSelector:@selector(openLibrary)] )
        [_delegate openLibrary];
}

- (void) addGridToCameraAction:(UIButton *)button
{
    if ( [_delegate respondsToSelector:@selector(cameraView:showGridView:)] ) {
        [_delegate cameraView:self showGridView:button.selected];
        [button setSelected:!button.isSelected];
    }
}

- (void) flashTriggerAction:(UIButton *)button
{
    if ( [_delegate respondsToSelector:@selector(triggerFlashForMode:)] ) {
        AVCaptureFlashMode flashMode = AVCaptureFlashModeOn;
        button.tag = (button.tag + 1) % 3;
        if (button.tag == 0) {
            flashMode = AVCaptureFlashModeOff;
            [button setImage:[UIImage imageNamed:@"but_flash_no.png"] forState:UIControlStateNormal];
        }
        if (button.tag == 1) {
            flashMode = AVCaptureFlashModeAuto;
            [button setImage:[UIImage imageNamed:@"but_flash_auto.png"] forState:UIControlStateNormal];
        }
        if (button.tag == 2) {
            flashMode = AVCaptureFlashModeOn;
            [button setImage:[UIImage imageNamed:@"but_flash.png"] forState:UIControlStateNormal];
        }
        
//        [button setSelected:!button.isSelected];
        [_delegate triggerFlashForMode: flashMode];
    }
}

- (void) changeCamera:(UIButton *)button
{
    [button setSelected:!button.isSelected];
    if ( button.isSelected && self.flashButton.isSelected )
        [self flashTriggerAction:self.flashButton];
    [self.flashButton setEnabled:!button.isSelected];
    if ( [self.delegate respondsToSelector:@selector(switchCamera)] )
        [self.delegate switchCamera];
}

- (void) close
{
    if ( [_delegate respondsToSelector:@selector(closeCamera)] )
        [_delegate closeCamera];
}

- (void) triggerAction:(UIButton *)button
{
    if ( [_delegate respondsToSelector:@selector(cameraViewStartRecording)] )
        [_delegate cameraViewStartRecording];
    
#pragma mark - 每拍一張就閃
    UIView *blockView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    blockView.backgroundColor = [UIColor whiteColor];
    [self addSubview:blockView];
    [UIView animateWithDuration:0.5 animations:^{
        blockView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [blockView removeFromSuperview];
    }];

#pragma mark - 拍完之後換最新的相片縮圖
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 讀取APP中該事件最後一張相片
        // Documents -> Events -> xxx -> Works -> zzz.jpg
        NSString *eventPath = [HTFileManager eventsPath];
        NSString *workPath = [[eventPath stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Works"];
        NSArray *nameArr = [[HTFileManager sharedManager] listFileAtPath:workPath];
        if ([nameArr count] == 0) {
            [self.thumbnailImageView setImage:nil];
            self.thumbnailImageView.backgroundColor = [UIColor blackColor];
        }
        else {
            NSString *imageName = [workPath stringByAppendingPathComponent:[nameArr lastObject]];
            UIImage *photoImage = [UIImage imageWithContentsOfFile:imageName];
            [self.thumbnailImageView setImage:photoImage];
        }
    });
}

- (void) tapToFocus:(UIGestureRecognizer *)recognizer
{
    CGPoint tempPoint = (CGPoint)[recognizer locationInView:self];
    if ( [_delegate respondsToSelector:@selector(cameraView:focusAtPoint:)] && CGRectContainsPoint(_previewLayer.frame, tempPoint) ){
        [_delegate cameraView:self focusAtPoint:(CGPoint){ tempPoint.x, tempPoint.y - CGRectGetMinY(_previewLayer.frame) }];
        [self drawFocusBoxAtPointOfInterest:tempPoint andRemove:YES];
    }
}

- (void) tapToExpose:(UIGestureRecognizer *)recognizer
{
    CGPoint tempPoint = (CGPoint)[recognizer locationInView:self];
    if ( [_delegate respondsToSelector:@selector(cameraView:exposeAtPoint:)] && CGRectContainsPoint(_previewLayer.frame, tempPoint) ){
        [_delegate cameraView:self exposeAtPoint:(CGPoint){ tempPoint.x, tempPoint.y - CGRectGetMinY(_previewLayer.frame) }];
        [self drawExposeBoxAtPointOfInterest:tempPoint andRemove:YES];
    }
}

- (void) hanldePanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    BOOL hasFocus = YES;
    if ( [_delegate respondsToSelector:@selector(cameraViewHasFocus)] )
        hasFocus = [_delegate cameraViewHasFocus];
    
    if ( !hasFocus )
        return;
    
    UIGestureRecognizerState state = panGestureRecognizer.state;
    CGPoint touchPoint = [panGestureRecognizer locationInView:self];
    [self draw:_focusBox atPointOfInterest:(CGPoint){ touchPoint.x, touchPoint.y - CGRectGetMinY(_previewLayer.frame) } andRemove:YES];
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
            
            break;
        case UIGestureRecognizerStateChanged: {
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded: {
            [self tapToFocus:panGestureRecognizer];
            break;
        }
        default:
            break;
    }
}

- (void) handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    BOOL allTouchesAreOnThePreviewLayer = YES;
	NSUInteger numTouches = [pinchGestureRecognizer numberOfTouches], i;
	for ( i = 0; i < numTouches; ++i ) {
		CGPoint location = [pinchGestureRecognizer locationOfTouch:i inView:self];
		CGPoint convertedLocation = [_previewLayer convertPoint:location fromLayer:_previewLayer.superlayer];
		if ( ! [_previewLayer containsPoint:convertedLocation] ) {
			allTouchesAreOnThePreviewLayer = NO;
			break;
		}
	}
	
	if ( allTouchesAreOnThePreviewLayer ) {
		_scaleNum = _preScaleNum * pinchGestureRecognizer.scale;
        
        if ( _scaleNum < MIN_PINCH_SCALE_NUM )
            _scaleNum = MIN_PINCH_SCALE_NUM;
        else if ( _scaleNum > MAX_PINCH_SCALE_NUM )
            _scaleNum = MAX_PINCH_SCALE_NUM;
        
        if ( [self.delegate respondsToSelector:@selector(cameraCaptureScale:)] )
            [self.delegate cameraCaptureScale:_scaleNum];
        
        [self doPinch];
	}
    
    if ( [pinchGestureRecognizer state] == UIGestureRecognizerStateEnded ||
        [pinchGestureRecognizer state] == UIGestureRecognizerStateCancelled ||
        [pinchGestureRecognizer state] == UIGestureRecognizerStateFailed) {
        _preScaleNum = _scaleNum;
    }
}

#pragma mark - 左右滑更換相框
-(void)handleSwipe:(UISwipeGestureRecognizer *)recogniser
{
    if (recogniser.direction == UISwipeGestureRecognizerDirectionRight)
    {
        NSLog(@"handleSwipeRight");
        self.frameNumber -= 1;
        if (self.frameNumber < 0) {
            self.frameNumber += [self.frameArr count];
        }
    }
    else if (recogniser.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        NSLog(@"handleSwipeLeft");
        self.frameNumber += 1;
        if (self.frameNumber > [self.frameArr count] - 1) {
            self.frameNumber -= [self.frameArr count];
        }
    }
    self.frameImageView.alpha = 0.0;
    [UIView animateWithDuration:0.7 animations:^{
        self.frameImageView.alpha = 1.0;
        
        NSString *framePath = [[[HTFileManager eventsPath] stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Frames"];
        NSString *targetPath = [framePath stringByAppendingPathComponent:self.frameArr[self.frameNumber]];
        // 記錄相框路徑，拍照合成用
        [HTFrameImage sharedInstance].framePath = targetPath;
        
        // 記錄直式或橫式
        NSString *eventJSONPath = [[HTFileManager documentsPath] stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:eventJSONPath];
        NSArray *frameInfoArr = dict[@"ImageFiles"];
        if ([frameInfoArr[self.frameNumber][@"Orientation"] isEqualToString:@"VERTICAL"]) {
            [HTFrameImage sharedInstance].isVertical = YES;
        }
        else {
            [HTFrameImage sharedInstance].isVertical = NO;
        }

        self.frameImageView.image = [UIImage imageWithContentsOfFile:targetPath];

//        self.frameImageView.image = [UIImage imageNamed:self.frameArr[self.frameNumber]];
//        [HTFrameImage sharedInstance].frameName = self.frameArr[self.frameNumber];
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void) pinchCameraViewWithScalNum:(CGFloat)scale
{
    _scaleNum = scale;
    if ( _scaleNum < MIN_PINCH_SCALE_NUM )
        _scaleNum = MIN_PINCH_SCALE_NUM;
    else if (_scaleNum > MAX_PINCH_SCALE_NUM)
        _scaleNum = MAX_PINCH_SCALE_NUM;
    
    [self doPinch];
    _preScaleNum = scale;
}

- (void) doPinch
{
    if ( [self.delegate respondsToSelector:@selector(cameraMaxScale)] ) {
        CGFloat maxScale = [self.delegate cameraMaxScale];
        if ( _scaleNum > maxScale )
            _scaleNum = maxScale;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [_previewLayer setAffineTransform:CGAffineTransformMakeScale(_scaleNum, _scaleNum)];
        [CATransaction commit];
    }
}

@end
//
//  DBCameraContainerViewController.m
//  DBCamera
//
//  Created by iBo on 06/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraContainerViewController.h"
#import "DBCameraViewController.h"
#import "DBCameraMacros.h"
#import "DBCameraView.h"
#import "HTAdViewController.h"

@interface DBCameraContainerViewController () <DBCameraContainerDelegate> {
    CameraSettingsBlock _settingsBlock;
    BOOL _wasStatusBarHidden;
    BOOL _wasWantsFullScreenLayout;
}
@property (nonatomic, strong) DBCameraViewController *defaultCameraViewController;
@end

@implementation DBCameraContainerViewController
@synthesize tintColor = _tintColor;
@synthesize selectedTintColor = _selectedTintColor;

- (id) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate
{
    return [[DBCameraContainerViewController alloc] initWithDelegate:delegate cameraSettingsBlock:nil];
}

- (id) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate cameraSettingsBlock:(CameraSettingsBlock)block
{
    self = [super init];
    if ( self ) {
        _delegate = delegate;
        _settingsBlock = block;
        
        // 擋住相機螢幕
        blockView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        blockView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:blockView];
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:RGBColor(0x000000, 1)];
    [self addChildViewController:self.defaultCameraViewController];
    [self.view addSubview:self.defaultCameraViewController.view];
    if ( _settingsBlock )
        _settingsBlock(self.cameraViewController.cameraView, self);
    
#pragma mark - 顯示廣告
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 顯示廣告
        adViewController = [[HTAdViewController alloc] initWithAdArr:@[] adType:HTAdTypeEvent];
        adViewController.delegate = self;
        [self.navigationController presentViewController:adViewController animated:NO completion:nil];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 從背景回到前景，要移除黑幕，因廣告消失無法按Ｘ移除
        [blockView removeFromSuperview];
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

#pragma mark - DBCameraContainerDelegate

- (void) backFromController:(id)fromController
{
    [self switchFromController:fromController
                  toController:self.defaultCameraViewController];
}

- (void) switchFromController:(id)fromController toController:(id)controller
{
    [[(UIViewController *)controller view] setAlpha:1];
    [[(UIViewController *)controller view] setTransform:CGAffineTransformMakeScale(1, 1)];
    [self addChildViewController:controller];
    
    __block id blockViewController = fromController;
    
    [self transitionFromViewController:blockViewController
                      toViewController:controller
                              duration:.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^(void){ }
                            completion:^(BOOL finished) {
                                [blockViewController removeFromParentViewController];
                                blockViewController = nil;
                            }];
}

#pragma mark - Properties

- (DBCameraViewController *) defaultCameraViewController
{
    if ( !_defaultCameraViewController ) {
        _defaultCameraViewController = [DBCameraViewController initWithDelegate:_delegate];
        if ( self.tintColor )
            [_defaultCameraViewController setTintColor:self.tintColor];
        if ( self.selectedTintColor )
            [_defaultCameraViewController setSelectedTintColor:self.selectedTintColor];
    }
    
    if ( !self.cameraViewController )
        [self setCameraViewController:_defaultCameraViewController];
    
    return self.cameraViewController;
}

- (void) setCameraViewController:(DBCameraViewController *)cameraViewController
{
    _cameraViewController = cameraViewController;
    [_cameraViewController setIsContained:YES];
    [_cameraViewController setContainerDelegate:self];
    _defaultCameraViewController = nil;
}

#pragma mark - HTAdViewControllerDelegate

-(void)removeBlockView
{
    // 最後一張廣告關掉後移除黑幕
    [blockView removeFromSuperview];
}
@end
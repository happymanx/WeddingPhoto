//
//  DBCameraViewController.m
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraViewController.h"
#import "DBCameraManager.h"
#import "DBCameraView.h"
#import "DBCameraGridView.h"
#import "DBCameraDelegate.h"
#import "DBCameraSegueViewController.h"
#import "DBCameraLibraryViewController.h"
#import "DBLibraryManager.h"
#import "DBMotionManager.h"

#import "UIImage+Crop.h"
#import "DBCameraMacros.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

// 我的view controller
#import "HTFrameImage.h"
#import "HTCollectionViewController.h"
#import "HTEditPhotoViewController.h"
#import "HTFullscreenImageViewController.h"

#ifndef DBCameraLocalizedStrings
#define DBCameraLocalizedStrings(key) \
NSLocalizedStringFromTable(key, @"DBCamera", nil)
#endif

@interface DBCameraViewController () <DBCameraManagerDelegate, DBCameraViewDelegate> {
    BOOL _processingPhoto;
    UIDeviceOrientation _deviceOrientation;
    BOOL wasStatusBarHidden;
    BOOL wasWantsFullScreenLayout;
}

@property (nonatomic, strong) id customCamera;
@property (nonatomic, strong) DBCameraManager *cameraManager;
@end

@implementation DBCameraViewController
@synthesize cameraGridView = _cameraGridView;
@synthesize forceQuadCrop = _forceQuadCrop;
@synthesize tintColor = _tintColor;
@synthesize selectedTintColor = _selectedTintColor;
@synthesize cameraSegueConfigureBlock = _cameraSegueConfigureBlock;

#pragma mark - Life cycle

+ (instancetype) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate
{
    return [[self alloc] initWithDelegate:delegate cameraView:nil];
}

+ (instancetype) init
{
    return [[self alloc] initWithDelegate:nil cameraView:nil];
}

- (instancetype) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate cameraView:(id)camera
{
    self = [super init];

    if ( self ) {
        _processingPhoto = NO;
        _deviceOrientation = UIDeviceOrientationPortrait;
        if ( delegate )
            _delegate = delegate;

        if ( camera )
            [self setCustomCamera:camera];

        [self setUseCameraSegue:YES];

        [self setTintColor:[UIColor whiteColor]];
        [self setSelectedTintColor:[UIColor cyanColor]];
    }

    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view setBackgroundColor:[UIColor blackColor]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];

    NSError *error;
    if ( [self.cameraManager setupSessionWithPreset:AVCaptureSessionPresetPhoto error:&error] ) {
        if ( self.customCamera ) {
            if ( [self.customCamera respondsToSelector:@selector(previewLayer)] ) {
                [(AVCaptureVideoPreviewLayer *)[self.customCamera valueForKey:@"previewLayer"] setSession:self.cameraManager.captureSession];

                if ( [self.customCamera respondsToSelector:@selector(delegate)] )
                    [self.customCamera setValue:self forKey:@"delegate"];
            }

            [self.view addSubview:self.customCamera];
        } else
            [self.view addSubview:self.cameraView];
    }

    id camera =_customCamera ?: _cameraView;
    [camera insertSubview:self.cameraGridView atIndex:1];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.cameraManager performSelector:@selector(startRunning) withObject:nil afterDelay:0.0];
    
    __weak typeof(self) weakSelf = self;
    [[DBMotionManager sharedManager] setMotionRotationHandler:^(UIDeviceOrientation orientation){
        NSLog(@"last orientation %ld", orientation);
        [weakSelf rotationChanged:orientation];
    }];
    [[DBMotionManager sharedManager] startMotionHandler];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ( !self.customCamera )
        [self checkForLibraryImage];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.cameraManager performSelector:@selector(stopRunning) withObject:nil afterDelay:0.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setCameraManager:nil];
}

- (void) checkForLibraryImage
{
    if ( !self.cameraView.photoLibraryButton.isHidden && [NSStringFromClass(self.parentViewController.class) isEqualToString:@"DBCameraContainerViewController"] ) {
        if ( [ALAssetsLibrary authorizationStatus] !=  ALAuthorizationStatusDenied ) {
            __weak DBCameraView *weakCamera = self.cameraView;
            [[DBLibraryManager sharedInstance] loadLastItemWithBlock:^(BOOL success, UIImage *image) {
                [weakCamera.photoLibraryButton setBackgroundImage:image forState:UIControlStateNormal];
            }];
        }
    } else
        [self.cameraView.photoLibraryButton setHidden:YES];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) dismissCamera
{
    if ( _delegate && [_delegate respondsToSelector:@selector(dismissCamera:)] )
        [_delegate dismissCamera:self];
}

- (DBCameraView *) cameraView
{
    if ( !_cameraView ) {
        _cameraView = [DBCameraView initWithCaptureSession:self.cameraManager.captureSession];
        [_cameraView setTintColor:self.tintColor];
        [_cameraView setSelectedTintColor:self.selectedTintColor];
        [_cameraView defaultInterface];
        [_cameraView setDelegate:self];
    }

    return _cameraView;
}

- (DBCameraManager *) cameraManager
{
    if ( !_cameraManager ) {
        _cameraManager = [[DBCameraManager alloc] init];
        [_cameraManager setDelegate:self];
    }

    return _cameraManager;
}

- (DBCameraGridView *) cameraGridView
{
    if ( !_cameraGridView ) {
        DBCameraView *camera =_customCamera ?: _cameraView;
        _cameraGridView = [[DBCameraGridView alloc] initWithFrame:camera.previewLayer.frame];
        [_cameraGridView setNumberOfColumns:2];
        [_cameraGridView setNumberOfRows:2];
        [_cameraGridView setAlpha:0];
    }

    return _cameraGridView;
}

- (void) setCameraGridView:(DBCameraGridView *)cameraGridView
{
    _cameraGridView = cameraGridView;
    __block DBCameraGridView *blockGridView = cameraGridView;
    __weak DBCameraView *camera =_customCamera ?: _cameraView;
    [camera.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ( [obj isKindOfClass:[DBCameraGridView class]] ) {
            [obj removeFromSuperview];
            [camera insertSubview:blockGridView atIndex:1];
            blockGridView = nil;
            *stop = YES;
        }
    }];
}

- (void) rotationChanged:(UIDeviceOrientation) orientation
{
    if ( orientation != UIDeviceOrientationUnknown ||
         orientation != UIDeviceOrientationFaceUp ||
         orientation != UIDeviceOrientationFaceDown ) {
        _deviceOrientation = orientation;
    }
}

- (void) disPlayGridViewToCameraView:(BOOL)show
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.cameraGridView.alpha = (show ? 1.0 : 0.0);
    } completion:NULL];
}

#pragma mark - CameraManagerDelagate

- (void) closeCamera
{
    [self dismissCamera];
}

- (void) switchCamera
{
    if ( [self.cameraManager hasMultipleCameras] )
        [self.cameraManager cameraToggle];
}

- (void) cameraView:(UIView *)camera showGridView:(BOOL)show {
    [self disPlayGridViewToCameraView:!show];
}

- (void) triggerFlashForMode:(AVCaptureFlashMode)flashMode
{
    if ( [self.cameraManager hasFlash] )
        [self.cameraManager setFlashMode:flashMode];
}

- (void) captureImageDidFinish:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
    _processingPhoto = NO;

    NSMutableDictionary *finalMetadata = [NSMutableDictionary dictionaryWithDictionary:metadata];
    finalMetadata[@"DBCameraSource"] = @"Camera";

    // 讓它永遠為真！
    if ( self.useCameraSegue ) {
        if ( [_delegate respondsToSelector:@selector(camera:didFinishWithImage:withMetadata:)] )
            [_delegate camera:self didFinishWithImage:image withMetadata:finalMetadata];
        
        UIImage *mixedImage = [[HTFrameImage sharedInstance] returnMixedImage:image withSize:image.size];
        

#pragma mark - 儲存影像到相簿
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        
//        [library writeImageToSavedPhotosAlbum:[mixedImage CGImage] orientation:(ALAssetOrientation)[mixedImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
//            if (error) {
//                // TODO: error handling
//            } else {
//                // TODO: success handling
//            }
//        }];
#pragma mark - 儲存影像到APP
        // Documents -> Events -> xxx -> Works -> zzz.jpg
        NSString *eventPath = [HTFileManager eventsPath];
        NSString *workPath = [[eventPath stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Works"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:workPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:workPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        NSArray *nameArr = [[HTFileManager sharedManager] listFileAtPath:workPath];
        // 取最後檔名加一當最新檔名
        NSString *lastName;
        if ([nameArr count] == 0) {
            lastName = @"0000.jpg";
        }
        else {
            lastName = nameArr[[nameArr count] - 1];
        }
        NSInteger newNumber = [[[lastName componentsSeparatedByString:@"."] firstObject] integerValue] + 1;
        NSString *targetPath;
        if (newNumber < 10) {
            targetPath = [workPath stringByAppendingPathComponent:[NSString stringWithFormat:@"000%li.jpg", (long)newNumber]];
        }
        else if (newNumber < 100) {
            targetPath = [workPath stringByAppendingPathComponent:[NSString stringWithFormat:@"00%li.jpg", (long)newNumber]];
        }
        else if (newNumber < 1000) {
            targetPath = [workPath stringByAppendingPathComponent:[NSString stringWithFormat:@"0%li.jpg", (long)newNumber]];
        }
        else {
            targetPath = [workPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%li.jpg", (long)newNumber]];
        }
        [UIImageJPEGRepresentation(mixedImage, 0.9) writeToFile:targetPath atomically:YES];

#pragma mark - 儲存到特定相簿
        // 標題從API回傳的檔案中找事件標題
        NSString *eventJSONPath = [[HTFileManager documentsPath] stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName];
        NSDictionary *fileDict = [[NSDictionary alloc] initWithContentsOfFile:eventJSONPath];
        NSString *eventName = fileDict[@"ProjectName"];
        // 找到相簿
        __block ALAssetsGroup* groupToAddTo;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                    usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                        if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:eventName]) {
                                            DLog(@"found album %@", eventName);
                                            groupToAddTo = group;
                                        }
                                    }
                                  failureBlock:^(NSError* error) {
                                      DLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
                                  }];
        // 儲存影像到library，並放置到該事件相簿
        CGImageRef img = [mixedImage CGImage];
        [library writeImageToSavedPhotosAlbum:img
                                     orientation:(ALAssetOrientation)[mixedImage imageOrientation]
                              completionBlock:^(NSURL* assetURL, NSError* error) {
                                  if (error.code == 0) {
                                      DLog(@"saved image completed:\nurl: %@", assetURL);
                                      
                                      // try to get the asset
                                      [library assetForURL:assetURL
                                               resultBlock:^(ALAsset *asset) {
                                                   // assign the photo to the album
                                                   [groupToAddTo addAsset:asset];
                                                   DLog(@"Added %@ to %@", [[asset defaultRepresentation] filename], eventName);
                                               }
                                              failureBlock:^(NSError* error) {
                                                  DLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                                              }];
                                  }
                                  else {
                                      DLog(@"saved image failed.\nerror code %li\n%@", (long)error.code, [error localizedDescription]);
                                  }
                              }];
    } else {
        CGFloat newW = 256.0;
        CGFloat newH = 340.0;

        if ( image.size.width > image.size.height ) {
            newW = 340.0;
            newH = ( newW * image.size.height ) / image.size.width;
        }

        DBCameraSegueViewController *segue = [[DBCameraSegueViewController alloc] initWithImage:image thumb:[UIImage returnImage:image withSize:(CGSize){ newW, newH }]];
        [segue setTintColor:self.tintColor];
        [segue setSelectedTintColor:self.selectedTintColor];
        [segue setForceQuadCrop:_forceQuadCrop];
        [segue enableGestures:YES];
        [segue setDelegate:self.delegate];
        [segue setCapturedImageMetadata:finalMetadata];
        [segue setCameraSegueConfigureBlock:self.cameraSegueConfigureBlock];

        [self.navigationController pushViewController:segue animated:YES];
    }
}

- (void) captureImageFailedWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    });
}

- (void) captureSessionDidStartRunning
{
#pragma mark - 隱藏HUD
    // 藏HUD
    [MBProgressHUD hideHUDForView:[HTAppDelegate sharedDelegate].window animated:YES];
    
    id camera = self.customCamera ?: _cameraView;
    CGRect bounds = [(UIView *)camera bounds];
    CGPoint screenCenter = (CGPoint){ CGRectGetMidX(bounds), CGRectGetMidY(bounds) };
    if ([camera respondsToSelector:@selector(drawFocusBoxAtPointOfInterest:andRemove:)] )
        [camera drawFocusBoxAtPointOfInterest:screenCenter andRemove:NO];
    if ( [camera respondsToSelector:@selector(drawExposeBoxAtPointOfInterest:andRemove:)] )
        [camera drawExposeBoxAtPointOfInterest:screenCenter andRemove:NO];
}

- (void) openLibrary
{
#pragma mark - 開啓自己的作品
//    HTCollectionViewController *vc = [[HTCollectionViewController alloc] initWithWorkArr:@[] collectionType:HTCollectionTypeSelfWork];
//    [self.navigationController pushViewController:vc animated:YES];
    
    // 讀取APP中該事件最後一張相片
    // Documents -> Events -> xxx -> Works -> zzz.jpg
    NSString *eventPath = [HTFileManager eventsPath];
    NSString *workPath = [[eventPath stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Works"];
    NSArray *nameArr = [[HTFileManager sharedManager] listFileAtPath:workPath];
    if ([nameArr count] == 0) {// 相簿中沒相片
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"提醒", nil) message:HTLocalizedString(@"此相簿為空", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"確認", nil) otherButtonTitles:nil, nil];
        [av show];
    }
    else {// 找相簿中最後一張相片
        // 先推相簿來瀏覽(幾乎看不到而閃過)
        {
            HTCollectionViewController *vc = [[HTCollectionViewController alloc] initWithWorkArr:@[] collectionType:HTCollectionTypeSelfWorkEdit];
            
            [self.navigationController pushViewController:vc animated:NO];
        }
        // 再推最後一張相片來編輯
        {
//            NSString *imageName = [workPath stringByAppendingPathComponent:[nameArr lastObject]];
//            UIImage *photoImage = [UIImage imageWithContentsOfFile:imageName];
//            
//            // 儲存相片路徑，之後刪除會用到
//            [HTAppDelegate sharedDelegate].photoPath = imageName;
//            
//            HTEditPhotoViewController *vc = [[HTEditPhotoViewController alloc] initWithImage:photoImage];
//            
//            [self.navigationController pushViewController:vc animated:YES];
            
            // Documents -> Events -> xxx -> Works -> zzz.jpg
            NSString *eventPath = [HTFileManager eventsPath];
            workPath = [[eventPath stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Works"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:workPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:workPath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            // 儲存檔案名稱（非路徑）
            NSArray *itemArr = [[HTFileManager sharedManager] listFileAtPath:workPath];
            HTFullscreenImageViewController *vc = [[HTFullscreenImageViewController alloc] initWithItemArr:itemArr index:[itemArr count] - 1 type:HTFullscreenTypeSelfWork];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }

/*
    if ( [ALAssetsLibrary authorizationStatus] !=  ALAuthorizationStatusDenied ) {
        [UIView animateWithDuration:.3 animations:^{
            [self.view setAlpha:0];
            [self.view setTransform:CGAffineTransformMakeScale(.8, .8)];
        } completion:^(BOOL finished) {
            DBCameraLibraryViewController *library = [[DBCameraLibraryViewController alloc] initWithDelegate:self.containerDelegate];
            [library setTintColor:self.tintColor];
            [library setSelectedTintColor:self.selectedTintColor];
            [library setForceQuadCrop:_forceQuadCrop];
            [library setDelegate:self.delegate];
            [library setUseCameraSegue:self.useCameraSegue];
            [library setCameraSegueConfigureBlock:self.cameraSegueConfigureBlock];
            [library setLibraryMaxImageSize:self.libraryMaxImageSize];
            [self.containerDelegate switchFromController:self toController:library];
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:DBCameraLocalizedStrings(@"general.error.title") message:DBCameraLocalizedStrings(@"pickerimage.nopolicy") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        });
    }
 */
}

#pragma mark - CameraViewDelegate

- (void) cameraViewStartRecording
{
    if ( _processingPhoto )
        return;

    _processingPhoto = YES;

    [self.cameraManager captureImageForDeviceOrientation:_deviceOrientation];
}

- (void) cameraView:(UIView *)camera focusAtPoint:(CGPoint)point
{
    if ( self.cameraManager.videoInput.device.isFocusPointOfInterestSupported ) {
        [self.cameraManager focusAtPoint:[self.cameraManager convertToPointOfInterestFrom:[[(DBCameraView *)camera previewLayer] frame]
                                                                              coordinates:point
                                                                                    layer:[(DBCameraView *)camera previewLayer]]];
    }
}

- (BOOL) cameraViewHasFocus
{
    return self.cameraManager.hasFocus;
}

- (void) cameraView:(UIView *)camera exposeAtPoint:(CGPoint)point
{
    if ( self.cameraManager.videoInput.device.isExposurePointOfInterestSupported ) {
        [self.cameraManager exposureAtPoint:[self.cameraManager convertToPointOfInterestFrom:[[(DBCameraView *)camera previewLayer] frame]
                                                                                 coordinates:point
                                                                                       layer:[(DBCameraView *)camera previewLayer]]];
    }
}

- (CGFloat) cameraMaxScale
{
    return [self.cameraManager cameraMaxScale];
}

- (void) cameraCaptureScale:(CGFloat)scaleNum
{
    [self.cameraManager setCameraMaxScale:scaleNum];
}

#pragma mark - UIApplicationDidEnterBackgroundNotification

- (void) applicationDidEnterBackground:(NSNotification *)notification
{
    id modalViewController = self.presentingViewController;
    if ( modalViewController )
        [self dismissCamera];
}

@end

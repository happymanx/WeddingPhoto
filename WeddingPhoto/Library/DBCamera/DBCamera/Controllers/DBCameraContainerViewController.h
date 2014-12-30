//
//  DBCameraContainerViewController.h
//  DBCamera
//
//  Created by iBo on 06/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraDelegate.h"
#import "UIViewController+UIViewController_FullScreen.h"
#import "HTAdViewController.h"

@class DBCameraView;
@class DBCameraViewController;

/**
 *  The camera settings block
 *
 *  @param cameraView The DBCameraView get from block hanlder
 *  @param container  The container get from block hanlder
 */
typedef void(^CameraSettingsBlock)(DBCameraView *cameraView, id container);

/**
 *  DBCameraContainerViewController
 */
@interface DBCameraContainerViewController : UIViewController <DBCameraViewControllerSettings, HTAdViewControllerDelegate>
{
    HTAdViewController *adViewController;
    
    UIView *blockView;
}
/**
 *  An id object compliant with DBCameraViewControllerDelegate
 */
@property (nonatomic, weak) id <DBCameraViewControllerDelegate> delegate;

/**
 *  A DBCameraViewController that can be set.
 */
@property (nonatomic, strong) DBCameraViewController *cameraViewController;

/**
 *  The init method with a DBCameraViewControllerDelegate
 *
 *  @param delegate The DBCameraViewControllerDelegate
 *
 *  @return A DBCameraContainerViewController
 */
- (id) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate;

/**
 *  The init method with a DBCameraViewControllerDelegate and a CameraSettingsBlock
 *
 *  @param delegate The DBCameraViewControllerDelegate
 *  @param block    The CameraSettingsBlock
 *
 *  @return DBCameraContainerViewController
 */
- (id) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate cameraSettingsBlock:(CameraSettingsBlock)block;
@end
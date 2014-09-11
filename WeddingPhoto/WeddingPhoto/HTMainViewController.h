//
//  HTMainViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/9.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraViewController.h"

@interface HTMainViewController : HTBasicViewController <DBCameraViewControllerDelegate>
{
    IBOutlet UITextField *passwordTextField;
}

@end

//
//  HTMainViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/9.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"


@interface HTMainViewController : HTBasicViewController <DBCameraViewControllerDelegate, UITextFieldDelegate>
{
    IBOutlet UITextField *passwordTextField;
    IBOutlet UIView *codeView;
    IBOutlet UIButton *eventButton;
    IBOutlet UIButton *trialButton;
    IBOutlet UIButton *aboutButton;
    
    IBOutlet NSLayoutConstraint *toButtonConstraint;
    float toButtonConstraintConstant;
}

@end

//
//  HTEditPhotoViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/19.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACEDrawingView.h"


@interface HTEditPhotoViewController : HTBasicViewController <UIActionSheetDelegate, ACEDrawingViewDelegate, UITextViewDelegate, UIAlertViewDelegate>
{
    IBOutlet UIImageView *photoImageView;
    IBOutlet ACEDrawingView *drawingView;
    IBOutlet UIButton *colorButton;
    IBOutlet UIButton *filterButton;
    IBOutlet UIButton *shareButton;
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *cameraButton;
    UIButton *lastFunctionButton;
    
    UIImage *sourceImage;
    UIImage *previewImage;
    
    BOOL isRotated;

    NSInteger selectedFilterIndex;
    
    // Color Button
    IBOutlet UIButton *color1Button;
    IBOutlet UIButton *color2Button;
    IBOutlet UIButton *color3Button;
    IBOutlet UIButton *color4Button;
    IBOutlet UIButton *color5Button;
    IBOutlet UIButton *color6Button;
    IBOutlet UIButton *color7Button;
    IBOutlet UIButton *color8Button;
    IBOutlet UIButton *color9Button;
    IBOutlet UIButton *color10Button;

    IBOutlet UIView *colorView;

    // Size Button
    IBOutlet UIButton *size1Button;
    IBOutlet UIButton *size2Button;
    IBOutlet UIButton *size3Button;
    IBOutlet UIButton *size4Button;
    IBOutlet UIButton *eraserButton;
    
    // Filter Button
    IBOutlet UIButton *filter1Button;
    IBOutlet UIButton *filter2Button;
    IBOutlet UIButton *filter3Button;
    IBOutlet UIButton *filter4Button;
    IBOutlet UIButton *filter5Button;
    IBOutlet UIButton *filter6Button;
    IBOutlet UIButton *filter7Button;
    IBOutlet UIButton *filter8Button;
    IBOutlet UIButton *filter9Button;
    IBOutlet UIButton *filter10Button;
    IBOutlet UIButton *filter11Button;
    IBOutlet UIButton *filter12Button;
    IBOutlet UIButton *filter13Button;
    NSArray *filterButtonArr;

    IBOutlet UIView *filterView;
    IBOutlet UIScrollView *filterScrollView;
    IBOutlet UIView *filterSubView;
    
    IBOutlet UIView *functionView;
}

- (id) initWithImage:(UIImage *)image;

@end

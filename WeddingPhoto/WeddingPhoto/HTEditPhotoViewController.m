//
//  HTEditPhotoViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/19.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTEditPhotoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface HTEditPhotoViewController ()

@end

@implementation HTEditPhotoViewController

- (id) initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        sourceImage = image;
        NSInteger scale = [UIScreen mainScreen].scale;
        previewImage = [self returnPreviewImage:image withSize:CGSizeMake(320 * scale, 480 * scale)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    photoImageView.image = previewImage;
    
    // set the delegate
    self.drawingView.delegate = self;

}

// 回傳預覽相片
- (UIImage *)returnPreviewImage:(UIImage *)img withSize:(CGSize)finalSize
{
    UIGraphicsBeginImageContext(finalSize);
    [img drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Button Methods
-(IBAction)backButtonClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

// actions
- (IBAction)clearViewButtonClicked:(UIButton *)button
{
    [self.drawingView clear];
}

- (IBAction)finishButtonClicked:(UIButton *)button
{
    // 儲存影像到相簿
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    UIImage *finalImage = [self returnFinalImage:photoImageView.image withSize:photoImageView.image.size];
    
    [library writeImageToSavedPhotosAlbum:[finalImage CGImage] orientation:(ALAssetOrientation)[finalImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            // TODO: error handling
        } else {
            // TODO: success handling
        }
    }];
}

// settings
- (IBAction)changeColorButtonClicked:(UIButton *)button
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Selet a color"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Black", @"Red", @"Green", @"Blue", nil];
    
    [actionSheet showInView:self.view];
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            self.drawingView.lineColor = [UIColor blackColor];
            break;
            
        case 1:
            self.drawingView.lineColor = [UIColor redColor];
            break;
            
        case 2:
            self.drawingView.lineColor = [UIColor greenColor];
            break;
            
        case 3:
            self.drawingView.lineColor = [UIColor blueColor];
            break;
    }
}

#pragma mark - ACEDrawing View Delegate

- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool;
{
    
}

- (UIImage *)returnFinalImage:(UIImage *)img withSize:(CGSize)finalSize
{
    UIGraphicsBeginImageContext(finalSize);
    [img drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
    [self.drawingView.image drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

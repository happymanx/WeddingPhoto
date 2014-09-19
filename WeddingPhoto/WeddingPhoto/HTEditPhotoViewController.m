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
    drawingView.delegate = self;
    
    [self setupColorButton];
}

-(void)setupColorButton
{
    color1Button.layer.cornerRadius = color1Button.frame.size.width/2;
    color2Button.layer.cornerRadius = color2Button.frame.size.width/2;
    color3Button.layer.cornerRadius = color3Button.frame.size.width/2;
    color4Button.layer.cornerRadius = color4Button.frame.size.width/2;
    color5Button.layer.cornerRadius = color5Button.frame.size.width/2;
    color6Button.layer.cornerRadius = color6Button.frame.size.width/2;
    color7Button.layer.cornerRadius = color7Button.frame.size.width/2;
    color8Button.layer.cornerRadius = color8Button.frame.size.width/2;
    color9Button.layer.cornerRadius = color9Button.frame.size.width/2;
    color10Button.layer.cornerRadius = color10Button.frame.size.width/2;
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
    [drawingView clear];
}

- (IBAction)finishButtonClicked:(UIButton *)button
{
    // 儲存影像到相簿
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    UIImage *finalImage = [self returnFinalImage:sourceImage withSize:sourceImage.size];
    
    [library writeImageToSavedPhotosAlbum:[finalImage CGImage] orientation:(ALAssetOrientation)[finalImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            // TODO: error handling
        } else {
            // TODO: success handling
            [self backButtonClicked:nil];
        }
    }];
}

// settings
- (IBAction)changeColorButtonClicked:(UIButton *)button
{
    [self.view addSubview:colorView];
    [colorView bringSubviewToFront:drawingView];
}

-(IBAction)colorButtonClicked:(UIButton *)button
{
    drawingView.lineColor = button.backgroundColor;
    [colorView removeFromSuperview];
}

-(void)removeAllToolView
{
    [colorView removeFromSuperview];
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            drawingView.lineColor = [UIColor blackColor];
            break;
            
        case 1:
            drawingView.lineColor = [UIColor redColor];
            break;
            
        case 2:
            drawingView.lineColor = [UIColor greenColor];
            break;
            
        case 3:
            drawingView.lineColor = [UIColor blueColor];
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
    [drawingView.image drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

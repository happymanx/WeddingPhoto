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
    [self removeAllToolView];
    [self.view addSubview:colorView];
    [colorView bringSubviewToFront:drawingView];
}

-(IBAction)colorButtonClicked:(UIButton *)button
{
    drawingView.lineColor = button.backgroundColor;
    [colorView removeFromSuperview];
}

-(IBAction)changeSizeButtonClicked:(UIButton *)button
{
    [self removeAllToolView];
    [self.view addSubview:sizeView];
    [sizeView bringSubviewToFront:drawingView];
}

-(IBAction)sizeButtonClicked:(UIButton *)button
{
    if (button.tag == 0) {// 橡皮擦
        drawingView.drawTool = ACEDrawingToolTypeEraser;
        
        drawingView.lineWidth = 20;
    }
    else {
        drawingView.drawTool = ACEDrawingToolTypePen;
        
        drawingView.lineWidth = button.tag;
    }
    [sizeView removeFromSuperview];
}

-(IBAction)changeFilterButtonClicked:(UIButton *)button
{
    [self removeAllToolView];
    [self.view addSubview:filterView];
    [filterView bringSubviewToFront:drawingView];
    
    filterScrollView.contentSize = filterSubView.frame.size;
    [filterScrollView addSubview:filterSubView];
}

-(IBAction)filterButtonClicked:(UIButton *)button
{
    switch (button.tag) {
        case 1:
            [self filterWithSaturation:0.9 contrast:1.0 brightness:0.0];
            break;
        case 2:
            [self filterWithSaturation:1.0 contrast:0.9 brightness:0.0];
            break;
        case 3:
            [self filterWithSaturation:1.0 contrast:1.0 brightness:0.9];
            break;
        case 4:
            [self filterWithSaturation:1.0 contrast:1.0 brightness:0.5];
            break;
        case 5:
            [self filterWithSaturation:0.5 contrast:1.0 brightness:0.9];
            break;
            
        default:
            break;
    }
    
    [filterView removeFromSuperview];
}

-(void)filterWithSaturation:(float)saturation contrast:(float)contrast brightness:(float)brightness
{
    //  創建基於 GPU 的 CIContext 對象
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName : @"CIColorControls"];
    CIImage *ciSourceImage = [[CIImage alloc] initWithImage:previewImage];
    [filter setValue : ciSourceImage forKey:kCIInputImageKey];
    [filter setValue :[NSNumber numberWithFloat :saturation] forKey:kCIInputSaturationKey];
    [filter setValue :[NSNumber numberWithFloat :contrast] forKey:kCIInputContrastKey];
    [filter setValue :[NSNumber numberWithFloat :brightness] forKey:kCIInputBrightnessKey];
    //  得到過濾後的圖片
    CIImage *outputImage = [filter outputImage];
    
    //  轉換圖片
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImage = [UIImage imageWithCGImage:cgImage];
    
    photoImageView.image = newImage;
    //  釋放 C 對象
    CGImageRelease(cgImage);
}

-(IBAction)editStatementButtonClicked:(UIButton *)button
{
    [self removeAllToolView];
    [self.view addSubview:statementView];
    [statementView bringSubviewToFront:drawingView];
    
    [statementTextView becomeFirstResponder];
}

-(void)removeAllToolView
{
    [colorView removeFromSuperview];
    [sizeView removeFromSuperview];
    [filterView removeFromSuperview];
    [statementView removeFromSuperview];
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

#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self removeAllToolView];
    }
    return YES;
}

@end

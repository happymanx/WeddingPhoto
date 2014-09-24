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
        
        filterParameterArr = @[@[[NSNull null],[NSNull null],[NSNull null]],
                               @[@(1.0),@(1.0),@(0.1)],
                               @[@(1.3),@(1.5),@(0.2)],
                               @[@(1.0),@(1.0),@(0.3)],
                               @[@(0.5),@(1.7),@(0.4)]];
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
#pragma mark - 儲存影像到相簿
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
#pragma mark - 儲存影像到APP
    // Documents -> Events -> xxx -> Works -> zzz.jpg
    NSString *eventPath = [HTFileManager eventsPath];
    NSString *workPath = [[eventPath stringByAppendingPathComponent:[HTAppDelegate sharedDelegate].eventName] stringByAppendingPathComponent:@"Works"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:workPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:workPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSInteger number = [[[HTFileManager sharedManager] listFileAtPath:workPath] count];
    NSString *targetPath = [workPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%li.jpg", (long)number]];
    //        UIImage *img = [UIImage imageNamed:@"HappyMan.jpg"];
    [UIImageJPEGRepresentation(finalImage, 0.9) writeToFile:targetPath atomically:YES];
}

-(IBAction)shareButtonClicked:(UIButton *)button
{
    UIImage *finalImage = [self returnFinalImage:previewImage withSize:previewImage.size];
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:@"和新人合照！", finalImage, nil] applicationActivities:nil];
    [self presentViewController:avc animated:YES completion:nil];
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
    selectedFilterIndex = button.tag;
    
    UIImage *filterImage;
    if (button.tag == 0) {// 不使用濾鏡圖
        filterImage = previewImage;
    }
    else {
        filterImage = [self filterWithImage:previewImage saturation:[filterParameterArr[button.tag][0] floatValue] contrast:[filterParameterArr[button.tag][1] floatValue] brightness:[filterParameterArr[button.tag][2] floatValue]];
    }
    
    photoImageView.image = filterImage;
    
    [filterView removeFromSuperview];
}

-(UIImage *)filterWithImage:(UIImage *)image saturation:(float)saturation contrast:(float)contrast brightness:(float)brightness
{
    //  創建基於 GPU 的 CIContext 對象
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName : @"CIColorControls"];
    CIImage *ciSourceImage = [[CIImage alloc] initWithImage:image];
    [filter setValue : ciSourceImage forKey:kCIInputImageKey];
    [filter setValue :[NSNumber numberWithFloat :saturation] forKey:kCIInputSaturationKey];
    [filter setValue :[NSNumber numberWithFloat :contrast] forKey:kCIInputContrastKey];
    [filter setValue :[NSNumber numberWithFloat :brightness] forKey:kCIInputBrightnessKey];
    //  得到過濾後的圖片
    CIImage *outputImage = [filter outputImage];
    
    //  轉換圖片
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImage = [UIImage imageWithCGImage:cgImage];
    
    //  釋放 C 對象
    CGImageRelease(cgImage);
    
    return newImage;
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
    // 濾鏡合成
    UIImage *filterImage;
    if (selectedFilterIndex == 0) {// 不使用濾鏡圖
        filterImage = img;
    }
    else {
        filterImage =  [self filterWithImage:img saturation:[filterParameterArr[selectedFilterIndex][0] floatValue] contrast:[filterParameterArr[selectedFilterIndex][1] floatValue] brightness:[filterParameterArr[selectedFilterIndex][2] floatValue]];
    }

    UIGraphicsBeginImageContext(finalSize);
    [filterImage drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
    // 繪圖合成
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

//
//  HTEditPhotoViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/19.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTEditPhotoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HTAppDelegate.h"
#import "HTCollectionViewController.h"
#import "UIImage+RotationMethods.h"
#import "UINavigationController+PopTimes.h"
#import "GPUImage.h"

@interface HTEditPhotoViewController ()

@end

@implementation HTEditPhotoViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (id) initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        sourceImage = image;
        NSInteger scale = [UIScreen mainScreen].scale;
        // 寬 > 高，就要旋轉90度
        if (image.size.width > image.size.height) {// 橫式相片
            isRotated = YES;
            previewImage = [self returnPreviewImage:image withSize:CGSizeMake(480 * scale, 320 * scale)];
            previewImage = [previewImage imageRotatedByDegrees:90];
        }
        else {// 直式相片
            isRotated = NO;
            previewImage = [self returnPreviewImage:image withSize:CGSizeMake(320 * scale, 480 * scale)];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    photoImageView.image = previewImage;
    
    // 設定繪圖委託
    drawingView.delegate = self;
    
    [self setupColorButton];
    [self setupFilterButton];
    
    // 預設編輯工具為筆，筆觸大小為5
    drawingView.drawTool = ACEDrawingToolTypePen;
    drawingView.lineWidth = 5;
    drawingView.hidden = YES;
}

-(void)setupColorButton
{
    // 讓色彩群按鈕變圓形
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

-(void)setupFilterButton
{
    [filter1Button setImage:[UIImage imageNamed:@"pic_thumb.png"] forState:UIControlStateNormal];
    filter1Button.layer.cornerRadius = 7.0;
    [filter1Button.layer setMasksToBounds:YES];

    // 彙集所有濾鏡按鈕
    filterButtonArr = @[filter2Button, filter3Button, filter4Button, filter5Button, filter6Button, filter7Button, filter8Button, filter9Button, filter10Button, filter11Button, filter12Button, filter13Button];
    UIButton *button;
    // 濾鏡按鈕圖先以濾鏡處理來顯示
    for (int i = 0; i < [filterButtonArr count]; i++) {
        button = filterButtonArr[i];
        [button setImage:[self filterWithImage:[UIImage imageNamed:@"pic_thumb.png"] index:button.tag] forState:UIControlStateNormal];
        button.layer.cornerRadius = 7.0;
        [button.layer setMasksToBounds:YES];
    }
}

#pragma mark - Button Methods
-(IBAction)cameraButtonClicked:(UIButton *)button
{
    // 記錄最後使用的功能
    lastFunctionButton = cameraButton;

    // 移除所有功能
    [self removeAllToolView];

    [self.navigationController popThreeViewControllersAnimated:YES];
}

-(IBAction)backButtonClicked:(UIButton *)button
{
    [self.navigationController popTwoViewControllersAnimated:YES];
}

- (IBAction)saveButtonClicked:(UIButton *)button
{
    // 記錄最後使用的功能
    lastFunctionButton = saveButton;

    // 移除所有功能
    [self removeAllToolView];
    
    CGSize size;
    size.width = sourceImage.size.width;
    size.height = sourceImage.size.height;

    UIImage *finalImage = [self returnFinalImage:sourceImage withSize:size];
    
    #pragma mark - 儲存影像到相簿
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//
//    [library writeImageToSavedPhotosAlbum:[finalImage CGImage] orientation:(ALAssetOrientation)[finalImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
//        if (error) {
//            // TODO: error handling
//        } else {
//            // TODO: success handling
//            [self backButtonClicked:nil];
//        }
//    }];
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
    [UIImageJPEGRepresentation(finalImage, 0.9) writeToFile:targetPath atomically:YES];
    
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
    CGImageRef img = [finalImage CGImage];
    [library writeImageToSavedPhotosAlbum:img
                              orientation:(ALAssetOrientation)[finalImage imageOrientation]
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
}

-(IBAction)shareButtonClicked:(UIButton *)button
{
    // 記錄最後使用的功能
    lastFunctionButton = shareButton;
    
    // 移除所有功能
    [self removeAllToolView];
    
    CGSize size;
    size.width = sourceImage.size.width;
    size.height = sourceImage.size.height;

    UIImage *finalImage = [self returnFinalImage:sourceImage withSize:size];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:HTLocalizedString(@"哈囉! 這是我用Woshot App所出來拍的照片，快來免費下載使用^^ http://www.woshot.com/app", nil), finalImage, nil] applicationActivities:nil];
    [self presentViewController:avc animated:YES completion:nil];
}

- (IBAction)changeColorButtonClicked:(UIButton *)button
{
    // 顯示drawingView
    drawingView.hidden = NO;

    // 記錄最後使用的功能
//    lastFunctionButton = colorButton;
    
    [self removeAllToolView];
    button.selected = !button.selected;
    if (button.selected == YES) {
        filterButton.selected = NO;
        
        [self.view addSubview:colorView];
        
        colorView.frame = CGRectMake(0, functionView.frame.origin.y - colorView.frame.size.height, colorView.frame.size.width, colorView.frame.size.height);
        
        [colorView bringSubviewToFront:drawingView];
    }
    else {
        [colorView removeFromSuperview];
    }
}

-(IBAction)colorButtonClicked:(UIButton *)button
{
    // 設定繪圖工具為筆
    drawingView.drawTool = ACEDrawingToolTypePen;
    drawingView.lineColor = button.backgroundColor;
    if (lastFunctionButton == eraserButton) {
        // 預設編輯工具為筆，筆觸大小為5
        drawingView.lineWidth = 5;
    }
    else {
    }
    [colorView removeFromSuperview];
}

-(IBAction)sizeButtonClicked:(UIButton *)button
{
    if (button.tag == 0) {// 橡皮擦
        // 記錄最後使用的功能
        lastFunctionButton = eraserButton;
        
        // 設定繪圖工具為橡皮擦
        drawingView.drawTool = ACEDrawingToolTypeEraser;
        
        drawingView.lineWidth = 20;
    }
    else {
        // 設定繪圖工具為筆
        drawingView.drawTool = ACEDrawingToolTypePen;
        
        drawingView.lineWidth = button.tag * 5;
    }
    [colorView removeFromSuperview];
}

-(IBAction)changeFilterButtonClicked:(UIButton *)button
{
    // 記錄最後使用的功能
    lastFunctionButton = filterButton;

    [self removeAllToolView];
    button.selected = !button.selected;
    if (button.selected == YES) {
        colorButton.selected = NO;
        
        [self.view addSubview:filterView];
        
        filterView.frame = CGRectMake(0, functionView.frame.origin.y - filterView.frame.size.height, filterView.frame.size.width, filterView.frame.size.height);
        
        [filterView bringSubviewToFront:drawingView];
        filterScrollView.contentSize = filterSubView.frame.size;
        [filterScrollView addSubview:filterSubView];
    }
    else {
        [filterView removeFromSuperview];
    }
}

-(IBAction)filterButtonClicked:(UIButton *)button
{
    selectedFilterIndex = button.tag;
    
    UIImage *filterImage;
    if (button.tag == 0) {// 不使用濾鏡
        filterImage = previewImage;
    }
    else {// 使用濾鏡
        filterImage = [self filterWithImage:previewImage index:button.tag];
    }
    
    photoImageView.image = filterImage;
}

// 實現濾鏡效果
-(UIImage *)filterWithImage:(UIImage *)image index:(NSInteger)index
{
    // 創建基於 GPU 的 CIContext 對象
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *ciSourceImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter;
    switch (index) {
            case 0:
            
            break;
        case 1:
            filter = [CIFilter filterWithName:@"CIColorControls"];
            [filter setValue:ciSourceImage forKey:kCIInputImageKey];
            [filter setValue:@(1.1) forKey:kCIInputSaturationKey];
            [filter setValue:@(1.1) forKey:kCIInputContrastKey];
            [filter setValue:@(0.0) forKey:kCIInputBrightnessKey];
            break;
        case 2:
            filter = [CIFilter filterWithName:@"CIHueAdjust"];
            [filter setValue:ciSourceImage forKey:kCIInputImageKey];
            [filter setValue:@(0.5) forKey:kCIInputAngleKey];
            break;
        case 3:
            filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
            [filter setValue:ciSourceImage forKey:kCIInputImageKey];
            break;
        case 4:
            filter = [CIFilter filterWithName:@"CIGammaAdjust"];
            [filter setValue:ciSourceImage forKey:kCIInputImageKey];
            [filter setValue:@(0.75) forKey:@"inputPower"];
            break;
        case 5:
            filter = [CIFilter filterWithName:@"CILinearToSRGBToneCurve"];
            [filter setValue:ciSourceImage forKey:kCIInputImageKey];
            break;
        case 6:
            filter = [CIFilter filterWithName:@"CISRGBToneCurveToLinear"];
            [filter setValue:ciSourceImage forKey:kCIInputImageKey];
            break;
        case 7:
            filter = [CIFilter filterWithName:@"CIVibrance"];
            [filter setValue:ciSourceImage forKey:kCIInputImageKey];
            [filter setValue:@(2.5) forKey:@"inputAmount"];
            break;
        case 8:
            filter = [CIFilter filterWithName:@"CIPhotoEffectProcess"];
            [filter setValue:ciSourceImage forKey:kCIInputImageKey];
            break;
        case 9:
            filter = [CIFilter filterWithName:@"CIPhotoEffectFade"];
            [filter setValue:ciSourceImage forKey:kCIInputImageKey];
            break;
        case 10:
            filter = [CIFilter filterWithName:@"CIPhotoEffectTransfer"];
            [filter setValue:ciSourceImage forKey:kCIInputImageKey];
            break;
        case 11:
            filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
            [filter setValue:ciSourceImage forKey:kCIInputImageKey];
            break;
        case 12:
            filter = [CIFilter filterWithName:@"CIVignette"];
            [filter setValue:ciSourceImage forKey:kCIInputImageKey];
            [filter setValue:@(1.9) forKey:kCIInputRadiusKey];
            [filter setValue:@(1.4) forKey:kCIInputIntensityKey];
            break;
        default:
            break;
    }

    // 得到過濾後的圖片
    CIImage *outputImage = [filter outputImage];
    
    // 轉換圖片
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImage = [UIImage imageWithCGImage:cgImage];
    
    // 釋放 C 對象
    CGImageRelease(cgImage);
    
    return newImage;
}

-(void)removeAllToolView
{
    [colorView removeFromSuperview];
    [filterView removeFromSuperview];
    
    colorButton.selected = NO;
    filterButton.selected = NO;
}

#pragma mark - ACEDrawing View Delegate

- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool;
{
    
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

// 回傳最後相片
- (UIImage *)returnFinalImage:(UIImage *)img withSize:(CGSize)finalSize
{
    // 濾鏡合成
    UIImage *filterImage;
    if (selectedFilterIndex == 0) {// 不使用濾鏡
        filterImage = img;
    }
    else {// 使用濾鏡
        filterImage =  [self filterWithImage:img index:selectedFilterIndex];
        
        // 將套濾鏡後相片轉回來
        if (isRotated) {
            filterImage = [filterImage imageRotatedByDegrees:-90];
            // 惡補（不太有道理的做法）
            if (filterImage.size.width < filterImage.size.height) {
                filterImage = [filterImage imageRotatedByDegrees:90];
            }
        }
    }
    
    UIImage *drawingImage = drawingView.image;
    
    // 將繪圖轉回來成橫式
    if (isRotated) {
        drawingImage = [drawingImage imageRotatedByDegrees:-90];
    }
    UIGraphicsBeginImageContext(finalSize);
    // 先畫～套濾鏡後相片
    [filterImage drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
    // 再畫～繪圖合成
    [drawingImage drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end

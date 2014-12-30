//
//  HTFileManager.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/23.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTFileManager.h"
#import "UIImage+RotationMethods.h"

@implementation HTFileManager

+(HTFileManager *)sharedManager
{
    static HTFileManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[HTFileManager alloc] init];
        [sharedManager createInitialFolder];
        [sharedManager createTestEventFolder];
    });
    return sharedManager;
}

/*
 一定要先建立資料夾
 */
-(void)createInitialFolder
{
    // Home -> Documents -> Events
    
    // 建立Documents資料夾
    // 建立Events資料夾
    [HTFileManager eventsPath];
}

+(NSString *)eventsPath
{
    NSString *documentsPath = [HTFileManager documentsPath];
    NSString *eventsPath = [documentsPath stringByAppendingPathComponent:@"Events"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:eventsPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:eventsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return eventsPath;
}

+(NSString *)documentsPath
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return documentsPath;
}

-(void)createTestEventFolder
{
//    NSArray *folderNameArr = @[@"Dannys Event1", @"Dannys Event2", @"Dannys Event3"];
    NSArray *folderNameArr = @[];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[HTFileManager eventsPath]]) {
        
        for (int i = 0; i < [folderNameArr count]; i++) {
            NSString *folderPath = [[HTFileManager  eventsPath] stringByAppendingPathComponent:folderNameArr[i]];
            [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
}

-(NSArray *)listFileAtPath:(NSString *)path
{
    //-----> LIST ALL FILES <-----//
//    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
//        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}

- (void)saveFrameImageWithEventKey:(NSString *)key infoArr:(NSArray *)arr update:(BOOL)update
{
    // 如果陣列為空
    if ([arr count] == 0 || arr == nil) {
        return;
    }
    NSString *projectPath = [[HTFileManager eventsPath] stringByAppendingPathComponent:key];
    NSString *framePath = [projectPath stringByAppendingPathComponent:@"Frames"];
    // 建立Frames資料夾
    if (![[NSFileManager defaultManager] fileExistsAtPath:framePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:framePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    frameHUD = [MBProgressHUD showHUDAddedTo:[HTAppDelegate sharedDelegate].window animated:YES];
    if (update) {
        frameHUD.labelText = HTLocalizedString(@"更新檔案中", nil);
    }
    else {
        frameHUD.labelText = HTLocalizedString(@"下載檔案中", nil);
    }
    for (int i = 0; i < [arr count]; i++) {
        // 記得判斷轉向
        
        NSString *fileURL = arr[i][@"File"];
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:fileURL]];
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Response: %@", responseObject);
            
            UIImage *image = responseObject;
            NSString *targetPath = [framePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%04i.png", i]];
            // 若影像是橫的，就轉成直的！
            if ([arr[i][@"Orientation"] isEqualToString:@"HORIZONTAL"]) {
                image = [image imageRotatedByDegrees:90.0];
            }
            // 因為是透明，所以儲存為PNG檔
            [UIImagePNGRepresentation(image) writeToFile:targetPath atomically:YES];
            if (i == [arr count] - 1) {
                [frameHUD hide:YES];
                // 提示成功訊息
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:HTLocalizedString(@"恭喜", nil) message:HTLocalizedString(@"你成功了！", nil) delegate:nil cancelButtonTitle:HTLocalizedString(@"好", nil) otherButtonTitles:nil, nil];
                [av show];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Image error: %@", error);
            if (i == [arr count] - 1) {
                [MBProgressHUD hideHUDForView:[HTAppDelegate sharedDelegate].window animated:YES];
            }
        }];
        [requestOperation start];
    }
}

- (void)saveAdImageWithEventKey:(NSString *)key infoArr:(NSArray *)arr update:(BOOL)update
{
    // 如果陣列為空
    if ([arr count] == 0 || arr == nil) {
        return;
    }
    NSString *projectPath = [[HTFileManager eventsPath] stringByAppendingPathComponent:key];
    NSString *framePath = [projectPath stringByAppendingPathComponent:@"Ads"];
    // 建立Frames資料夾
    if (![[NSFileManager defaultManager] fileExistsAtPath:framePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:framePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    adHUD = [MBProgressHUD showHUDAddedTo:[HTAppDelegate sharedDelegate].window animated:YES];
    if (update) {
        adHUD.labelText = HTLocalizedString(@"更新檔案中", nil);
    }
    else {
        adHUD.labelText = HTLocalizedString(@"下載檔案中", nil);
    }

    for (int i = 0; i < [arr count]; i++) {
        NSString *fileURL = arr[i][@"File"];
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:fileURL]];
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Response: %@", responseObject);
            UIImage *image = responseObject;
            NSString *targetPath = [framePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%04i.jpg", i]];
            // 因為非透明，所以儲存為JPG檔
            [UIImageJPEGRepresentation(image, 0.9) writeToFile:targetPath atomically:YES];
            if (i == [arr count] - 1) {
                [adHUD hide:YES];
                // 提示成功訊息
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Image error: %@", error);
            if (i == [arr count] - 1) {
                [MBProgressHUD hideHUDForView:[HTAppDelegate sharedDelegate].window animated:YES];
            }
        }];
        [requestOperation start];
    }
}

@end



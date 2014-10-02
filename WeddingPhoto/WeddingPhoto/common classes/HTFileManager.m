//
//  HTFileManager.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/23.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTFileManager.h"

@interface UIImage (RotationMethods)
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
@end

@implementation UIImage (RotationMethods)

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, 2.0);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end

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
    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}

+ (void)saveFrameImageWithEventKey:(NSString *)key infoArr:(NSArray *)arr
{
    NSString *projectPath = [[self eventsPath] stringByAppendingPathComponent:key];
    NSString *framePath = [projectPath stringByAppendingPathComponent:@"Frames"];
    // 建立Frames資料夾
    if (![[NSFileManager defaultManager] fileExistsAtPath:framePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:framePath withIntermediateDirectories:NO attributes:nil error:nil];
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
            NSString *targetPath = [framePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.png", i]];
            // 若影像是橫的，就轉成直的！
            if ([arr[i][@"Orientation"] isEqualToString:@"HORIZONTAL"]) {
                image = [image imageRotatedByDegrees:90.0];
            }
            // 因為是透明，所以儲存為PNG檔
            [UIImagePNGRepresentation(image) writeToFile:targetPath atomically:YES];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Image error: %@", error);
        }];
        [requestOperation start];
    }
}

+ (void)saveAdImageWithEventKey:(NSString *)key infoArr:(NSArray *)arr
{
    NSString *projectPath = [[self eventsPath] stringByAppendingPathComponent:key];
    NSString *framePath = [projectPath stringByAppendingPathComponent:@"Ads"];
    // 建立Frames資料夾
    if (![[NSFileManager defaultManager] fileExistsAtPath:framePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:framePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    for (int i = 0; i < [arr count]; i++) {
        NSString *fileURL = arr[i][@"File"];
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:fileURL]];
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Response: %@", responseObject);
            UIImage *image = responseObject;
            NSString *targetPath = [framePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.jpg", i]];
            // 因為非透明，所以儲存為JPG檔
            [UIImageJPEGRepresentation(image, 0.9) writeToFile:targetPath atomically:YES];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Image error: %@", error);
        }];
        [requestOperation start];
    }
}

@end



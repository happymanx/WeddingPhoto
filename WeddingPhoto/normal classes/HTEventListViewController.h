//
//  HTListViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/10.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"

@interface HTEventListViewController : HTBasicViewController <UITableViewDelegate, UITableViewDataSource, DBCameraViewControllerDelegate, UIAlertViewDelegate>
{
    NSMutableArray *eventArr;
    BOOL isEdit;
    
    IBOutlet UITableView *displayTableView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *editButton;
    
}

- (id)initWithEventArr:(NSArray *)array;

@end

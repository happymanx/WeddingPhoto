//
//  HTListViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/10.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTEventListViewController : HTBasicViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *eventArr;
    BOOL isEdit;
    
    IBOutlet UITableView *displayTableView;
    IBOutlet UIButton *editButtom;
    
}

- (id)initWithEventArr:(NSArray *)array;

@end

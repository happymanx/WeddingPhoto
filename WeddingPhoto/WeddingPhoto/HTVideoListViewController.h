//
//  HTVideoListViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/12.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTVideoListViewController : HTBasicViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *videoArr;

    IBOutlet UITableView *displayTableView;
}

- (id)initWithEventArr:(NSArray *)array;

@end

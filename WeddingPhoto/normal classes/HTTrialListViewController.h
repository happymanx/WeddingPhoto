//
//  HTTrialListViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/22.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTAdViewController.h"

@interface HTTrialListViewController : HTBasicViewController <UITableViewDelegate, UITableViewDataSource, HTAdViewControllerDelegate>
{
    NSArray *trialArr;
    
    IBOutlet UITableView *displayTableView;
    IBOutlet UIButton *backButton;
    HTAdViewController *adViewController;
    
    UIView *blockView;
}

- (id)initWithTrialArr:(NSArray *)array;


@end

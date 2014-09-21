//
//  HTTrialListViewController.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/22.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTTrialListViewController : HTBasicViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *trialArr;
    
    IBOutlet UITableView *displayTableView;
}

- (id)initWithTrialArr:(NSArray *)array;


@end

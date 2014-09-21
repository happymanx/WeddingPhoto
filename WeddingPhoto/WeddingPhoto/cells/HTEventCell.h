//
//  HTEventCell.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/10.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTEventCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, retain) IBOutlet UIButton *deleteButton;

+(HTEventCell *)cell;

@end

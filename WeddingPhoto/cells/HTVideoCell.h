//
//  HTVideoCell.h
//  WeddingPhoto
//
//  Created by Jason on 2014/9/13.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTVideoCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

+(HTVideoCell *)cell;

@end

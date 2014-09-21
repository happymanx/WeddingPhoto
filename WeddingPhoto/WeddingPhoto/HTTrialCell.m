//
//  HTTrialCell.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/22.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTTrialCell.h"

@implementation HTTrialCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(HTTrialCell *)cell
{
    return [[[NSBundle mainBundle] loadNibNamed:@"HTTrialCell" owner:nil options:nil] lastObject];
}
@end

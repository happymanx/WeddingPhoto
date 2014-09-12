//
//  HTVideoCell.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/13.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTVideoCell.h"

@implementation HTVideoCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(HTVideoCell *)cell
{
    return [[[NSBundle mainBundle] loadNibNamed:@"HTVideoCell" owner:nil options:nil] lastObject];
}
@end

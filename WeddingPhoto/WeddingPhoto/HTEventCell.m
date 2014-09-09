//
//  HTEventCell.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/10.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTEventCell.h"

@implementation HTEventCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(HTEventCell *)cell
{
    return [[[NSBundle mainBundle] loadNibNamed:@"HTEventCell" owner:nil options:nil] lastObject];
}
@end

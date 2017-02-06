//
//  CellTradeCategoryCell.m
//  RTradeDemo
//
//  Created by Michael Luo on 10/17/16.
//  Copyright © 2016 administrator. All rights reserved.
//

#import "CellTradeCategoryCell.h"

@implementation CellTradeCategoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    [_checkMark setImage:[UIImage imageNamed:@"IconUnchecked"] forState:UIControlStateNormal];
    [_checkMark setImage:[UIImage imageNamed:@"IconChecked"] forState:UIControlStateSelected];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSLog(@"%li",sender.tag);
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    NSDictionary *userInfo = @{@(sender.tag) : @(sender.selected)
                               };
    [center postNotificationName:@"categorySelected" object:self userInfo:userInfo];
}


@end

//
//  MarketSelectionCell.m
//  RTradeDemo
//
//  Created by iMac on 16/12/28.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "MarketSelectionCell.h"
#import "MarketSelectionModel.h"

@implementation MarketSelectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contractSubcribed.hidden = YES;
    self.addButton.layer.cornerRadius = 15;
    self.addButton.layer.borderWidth = 1.5;
    self.addButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.addButton.layer.masksToBounds = YES;
    self.addButton.hidden = NO;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(MarketSelectionModel *)model{
    _model = model;
    self.contractName.text = _model.contractName;
    self.contractCode.text = _model.contractCode;
    if ([_model.isSubscribed integerValue] == 0) {
        self.contractSubcribed.hidden = YES;
        self.addButton.hidden = NO;
    } else{
        self.contractSubcribed.hidden = NO;
        self.addButton.hidden = YES;
    }
}



@end

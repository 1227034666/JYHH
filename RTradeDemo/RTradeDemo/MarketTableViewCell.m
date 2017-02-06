//
//  MarketTableViewCell.m
//  RTradeDemo
//
//  Created by iMac on 16/12/27.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "MarketTableViewCell.h"
#import "MarketRealTimeModel.h"

@implementation MarketTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userInteractionEnabled = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(MarketRealTimeModel *)model{
    _model = model;
    self.contractName.text = _model.contractName;
    self.contractCode.text = _model.contractCode;
    self.contractPrice.text = _model.contractPrice;
    self.contractUpDownRate.text = _model.contractUpDownRate;
    self.contractWarehoused.text = _model.contractWarehoused;
    
    float _rate = [_model.contractUpDownRate floatValue];
    if (_rate >=0) {
        self.contractUpDownRate.backgroundColor = BGRED_COLOR;
        self.contractUpDownRate.textColor = [UIColor whiteColor];
        self.contractPrice.textColor = BGRED_COLOR;
    } else{
        self.contractUpDownRate.backgroundColor = BGGreen_COLOR;
        self.contractUpDownRate.textColor = [UIColor whiteColor];
        self.contractPrice.textColor = BGGreen_COLOR;
    }
}


@end

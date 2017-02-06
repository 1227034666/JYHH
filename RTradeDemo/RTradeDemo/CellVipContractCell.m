//
//  CellVipContractCell.m
//  RTradeDemo
//
//  Created by administrator on 16/5/12.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "CellVipContractCell.h"
#import "CellVipContractModel.h"

@implementation CellVipContractCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setModel:(CellVipContractModel *)model{
    _model = model;
    self.m_strConCode.text = _model.conCode;
    self.m_strConName.text = _model.conName;
    if ([_model.tradeType isEqualToString:@"1"]) {
        self.m_strTradeType.text = @"多";
        self.m_strTradeType.textColor = BGRED_COLOR;
    } else if ([_model.tradeType isEqualToString:@"2"]){
        self.m_strTradeType.text = @"空";
        self.m_strTradeType.textColor = BGGreen_COLOR;
    }
    self.m_strTradePrice.text = _model.tradePrice;
    self.m_strTradeVolume.text = _model.tradeVolume;
    
    self.m_strHoldTime.text = [TradeUtility parseDateTime:_model.holdTime];
}
@end

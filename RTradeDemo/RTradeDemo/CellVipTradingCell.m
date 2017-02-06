//
//  CellVipTradingCell.m
//  RTradeDemo
//
//  Created by administrator on 16/7/2.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "CellVipTradingCell.h"
#import "LeadTradeInforModel.h"

@implementation CellVipTradingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(LeadTradeInforModel *)model{
    _model = model;
    if ([_model.tradeType isEqualToString:@"1"]) {
        self.m_strTradeType.text = @"多";
        self.m_strTradePrice.textColor = BGRED_COLOR;
        self.m_strTradeType.textColor = BGRED_COLOR;
    } else if ([_model.tradeType isEqualToString:@"2"]){
        self.m_strTradeType.text = @"空";
        self.m_strTradePrice.textColor = BGGreen_COLOR;
        self.m_strTradeType.textColor = BGGreen_COLOR;
    } else if ([_model.tradeType isEqualToString:@"0"]){
        self.m_strTradeType.text = @"平";
        self.m_strTradePrice.textColor = [UIColor blueColor];
        self.m_strTradeType.textColor = [UIColor blueColor];
    }
    self.m_strTradeTime.text = [_model.tradeTime substringWithRange:NSMakeRange(11, 5)];
    self.m_strTradePrice.text = [NSString stringWithFormat:@"%.1f",[_model.tradePrice doubleValue]];
    if ([_model.tradeQty isEqualToString:@"0"]) {
         self.m_strTradeQty.text = @"*";
    } else{
        self.m_strTradeQty.text = _model.tradeQty;
    }
    
    
}



@end

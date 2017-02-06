//
//  CellTradeSortCell.m
//  RTradeDemo
//
//  Created by administrator on 16/6/28.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "CellTradeSortCell.h"

@implementation CellTradeSortCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.m_imgLogo.layer.cornerRadius = 22;
    self.m_imgLogo.layer.masksToBounds = YES;
    self.m_imgLogo.contentMode = UIViewContentModeScaleAspectFit;
    self.m_strContractTags.layer.cornerRadius = 5;
    self.m_strContractTags.layer.masksToBounds = YES;
    self.m_strContractTag1.layer.cornerRadius = 5;
    self.m_strContractTag1.layer.masksToBounds = YES;
    self.m_strContractTag2.layer.cornerRadius = 5;
    self.m_strContractTag2.layer.masksToBounds = YES;
    
    self.addButton.layer.cornerRadius = 15;
    self.addButton.layer.masksToBounds = YES;
    self.addButton.layer.borderWidth = 1.0f;
    self.addButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.addedLabel.hidden = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

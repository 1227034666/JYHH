//
//  CellTradeSortCell.h
//  RTradeDemo
//
//  Created by administrator on 16/6/28.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellTradeSortCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *m_strNickname;
@property (weak, nonatomic) IBOutlet UILabel *m_strContractTags;//合约
@property (strong, nonatomic) IBOutlet UILabel *m_strContractTag1;
@property (strong, nonatomic) IBOutlet UILabel *m_strContractTag2;

@property (weak, nonatomic) IBOutlet UILabel *m_strYieldRate;
@property (weak, nonatomic) IBOutlet UILabel *m_strSortNo;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgLogo;//图像
@property (strong, nonatomic) IBOutlet UILabel *addedLabel;
@property (strong, nonatomic) IBOutlet UIButton *addButton;

@end

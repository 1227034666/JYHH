//
//  CellVipContractCell.h
//  RTradeDemo
//
//  Created by administrator on 16/5/12.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CellVipContractModel;
@interface CellVipContractCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *m_strConCode;
@property (strong, nonatomic) IBOutlet UILabel *m_strConName;
@property (strong, nonatomic) IBOutlet UILabel *m_strTradeType;
@property (strong, nonatomic) IBOutlet UILabel *m_strTradePrice;

@property (strong, nonatomic) IBOutlet UILabel *m_strTradeVolume;


@property (strong, nonatomic) IBOutlet UILabel *m_strHoldTime;
@property (strong, nonatomic) CellVipContractModel *model;

@end

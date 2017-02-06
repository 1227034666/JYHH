//
//  CellVipHistoryCell.h
//  RTradeDemo
//
//  Created by administrator on 16/5/14.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellVipHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *m_strConCode;
@property (weak, nonatomic) IBOutlet UILabel *m_strConName;
@property (weak, nonatomic) IBOutlet UILabel *m_strTradeType; //多空
@property (strong, nonatomic) IBOutlet UILabel *m_strTradePrice;
@property (strong, nonatomic) IBOutlet UILabel *m_strTradeVolume;
@property (weak, nonatomic) IBOutlet UILabel *m_strHoldTime;

@end

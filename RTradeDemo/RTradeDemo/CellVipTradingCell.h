//
//  CellVipTradingCell.h
//  RTradeDemo
//
//  Created by administrator on 16/7/2.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LeadTradeInforModel;
@interface CellVipTradingCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *m_strTradeTime;
@property (strong, nonatomic) IBOutlet UILabel *m_strTradePrice;
@property (strong, nonatomic) IBOutlet UILabel *m_strTradeType;
@property (strong, nonatomic) IBOutlet UILabel *m_strTradeQty;
@property (strong, nonatomic) LeadTradeInforModel *model;
@end

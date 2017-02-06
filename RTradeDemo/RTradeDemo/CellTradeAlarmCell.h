//
//  CellTradeAlarmCell.h
//  RTradeDemo
//
//  Created by administrator on 16/6/28.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellTradeAlarmCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *m_strAlarmType;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgAlarmLogo;
@property (weak, nonatomic) IBOutlet UILabel *m_strLastTime;
@property (weak, nonatomic) IBOutlet UILabel *m_strLastMessage;
@property (weak, nonatomic) IBOutlet UILabel *m_strUnread;

@end

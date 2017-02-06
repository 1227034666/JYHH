//
//  CellAlarmListCell.h
//  RTradeDemo
//
//  Created by administrator on 16/6/29.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellAlarmListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *m_strNickname;
@property (weak, nonatomic) IBOutlet UILabel *m_strMsgTime;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *m_strMsgText;

@end

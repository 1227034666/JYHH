//
//  CellBcastLeadOrderCell.h
//  RTradeDemo
//
//  Created by administrator on 16/8/9.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellBcastLeadOrderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *m_imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *m_strNickname;
@property (weak, nonatomic) IBOutlet UILabel *m_strOrderTime;
@property (weak, nonatomic) IBOutlet UILabel *m_strOrderValue;

@end

//
//  CellVipDiscussCell.h
//  RTradeDemo
//
//  Created by administrator on 16/5/12.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellVipDiscussCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *m_strViewTitle;
@property (strong, nonatomic) IBOutlet UILabel *m_strViewTag;
@property (weak, nonatomic) IBOutlet UILabel *m_strPublishTime;
@property (weak, nonatomic) IBOutlet UILabel *m_strViewContent;

@end

//
//  CellTradeDiscussCell.h
//  RTradeDemo
//
//  Created by administrator on 16/6/23.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CellTradeDiscussModel;
@interface CellTradeDiscussCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *m_strViewTitle;
@property (weak, nonatomic) IBOutlet UILabel *m_strViewTags;
@property (weak, nonatomic) IBOutlet UILabel *m_strViewTime;
@property (weak, nonatomic) IBOutlet UILabel *m_strViewText;
@property (weak, nonatomic) IBOutlet UIImageView *m_strLogo;
@property (weak, nonatomic) IBOutlet UILabel *m_strNickname;
@property (weak, nonatomic) IBOutlet UILabel *m_strVipFlag;
@property (strong, nonatomic) IBOutlet UIImageView *m_strImgView;

//@property (strong, nonatomic)UIImageView *m_strImgView;
@property (strong, nonatomic) CellTradeDiscussModel *model;
@end

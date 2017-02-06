//
//  CellPersonalViewpointCell.h
//  RTradeDemo
//
//  Created by administrator on 16/8/7.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellPersonalViewpointCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *m_strViewTitle;
@property (strong, nonatomic) IBOutlet UILabel *m_strViewTags;
@property (strong, nonatomic) IBOutlet UILabel *m_strPublishTime;
@property (strong, nonatomic) IBOutlet UILabel *m_strViewText;
@property (strong, nonatomic) IBOutlet UIImageView *m_strAvatar;
@property (strong, nonatomic) IBOutlet UILabel *m_strNickName;
@property (strong, nonatomic) IBOutlet UILabel *m_strTradeUser;

@end

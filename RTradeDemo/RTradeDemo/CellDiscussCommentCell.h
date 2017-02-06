//
//  CellDiscussCommentCell.h
//  RTradeDemo
//
//  Created by administrator on 16/6/29.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellDiscussCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *m_strNickname;
@property (weak, nonatomic) IBOutlet UILabel *m_strTags;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *m_strTime;

@property (weak, nonatomic) IBOutlet UILabel *m_strContent;
@end

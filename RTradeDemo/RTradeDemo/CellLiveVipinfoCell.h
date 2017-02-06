//
//  CellLiveVipinfoCell.h
//  RTradeDemo
//
//  Created by administrator on 16/7/2.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CellLiveVipinfoCell : UITableViewCell

//leader info
@property (weak, nonatomic) IBOutlet UILabel *m_strSortNo;
@property (weak, nonatomic) IBOutlet UILabel *m_strConCode;
@property (weak, nonatomic) IBOutlet UILabel *m_strConName;

@property (strong, nonatomic) IBOutlet UILabel *m_strJiuYingLabel;
@property (strong, nonatomic) IBOutlet UIButton *m_strJiuYingBtn;



@property (weak, nonatomic) IBOutlet UILabel *m_strLastPrice;
@property (weak, nonatomic) IBOutlet UILabel *m_strUpDown;
@property (strong, nonatomic) IBOutlet UILabel *m_strSlash;
@property (weak, nonatomic) IBOutlet UILabel *m_strUpDownRate;
//trader winning rate
@property (weak, nonatomic) IBOutlet UILabel *m_strVipYieldRate;
//right view field
@property (strong, nonatomic) IBOutlet UILabel *bidPrice;
@property (strong, nonatomic) IBOutlet UILabel *bidVolume;
@property (strong, nonatomic) IBOutlet UILabel *askPrice;
@property (strong, nonatomic) IBOutlet UILabel *askVolume;
@property (strong, nonatomic) IBOutlet UILabel *openInterest;
@property (strong, nonatomic) IBOutlet UILabel *totalInterest;


//the line above follow


@property (nonatomic, assign) BOOL slideOutAnimationEnabled;
@property (nonatomic, copy) NSDictionary *itemData;

@end

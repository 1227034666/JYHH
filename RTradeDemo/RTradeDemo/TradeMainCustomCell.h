//
//  TradeMainCustomCell.h
//  RTradeDemo
//
//  Created by administrator on 16/5/6.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrokrnSelfSView.h"
@interface TradeMainCustomCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *vipPhoto;
@property (weak, nonatomic) IBOutlet UILabel *vipName;
@property (weak, nonatomic) IBOutlet UILabel *vipTags;
@property (strong, nonatomic) IBOutlet UILabel *vipTag1;
@property (strong, nonatomic) IBOutlet UILabel *vipTag2;

@property (weak, nonatomic) IBOutlet UILabel *vipWatch;
@property (weak, nonatomic) IBOutlet UILabel *vipTradeState;
@property (weak, nonatomic) IBOutlet UIImageView *vipCurl;
//收益率
@property (strong, nonatomic) IBOutlet UILabel *winRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *vipWinRate;
//成功率
@property (strong, nonatomic) IBOutlet UILabel *succRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *vipSuccRate;
//盈利明细
@property (strong, nonatomic) IBOutlet UILabel *maxWinLabel;
@property (weak, nonatomic) IBOutlet UILabel *vipMaxWin;
@property (strong, nonatomic) IBOutlet UILabel *maxLossLabel;
@property (weak, nonatomic) IBOutlet UILabel *vipMaxLoss;
@property (strong, nonatomic) IBOutlet UILabel *tradeNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *vipTradeNum;

@property (strong, nonatomic) BrokrnSelfSView *brokenView;
@property (strong, nonatomic) NSArray *yielddata;
@property (strong, nonatomic) NSArray *contractArray;


//- (void)showContractDataGraph;
-(void)showContractDataGraph:(NSArray *)xArray YArray:(NSArray *)yArray PointArray:(NSArray *)pArray;

@end

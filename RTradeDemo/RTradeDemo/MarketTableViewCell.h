//
//  MarketTableViewCell.h
//  RTradeDemo
//
//  Created by iMac on 16/12/27.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MarketRealTimeModel;
@interface MarketTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *contractName;
@property (strong, nonatomic) IBOutlet UILabel *contractCode;
@property (strong, nonatomic) IBOutlet UILabel *contractPrice;
@property (strong, nonatomic) IBOutlet UILabel *contractUpDownRate;
@property (strong, nonatomic) IBOutlet UILabel *contractWarehoused;
@property (strong, nonatomic) MarketRealTimeModel *model;
@end

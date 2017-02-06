//
//  LiveVipinfoController.h
//  RTradeDemo
//
//  Created by administrator on 16/7/2.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SlideNavigationController.h"
@class MBProgressHUD;
@class MarketModel;
@interface LiveVipinfoController : UITableViewController
{
    MBProgressHUD *_hud;
}

@property (nonatomic, assign) BOOL slideOutAnimationEnabled;
//has bought the contract
@property (nonatomic, assign) BOOL hasBuy;
@property (nonatomic, strong) NSMutableArray *vipcontractData;
@property (nonatomic, copy) NSMutableArray *backUpData;
@property (nonatomic, copy) NSMutableArray *secondBkData;
@property (nonatomic, copy) MarketModel *dataModel;

@end

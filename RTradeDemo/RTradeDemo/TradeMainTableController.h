//
//  TradeMainTableController.h
//  RTradeDemo
//
//  Created by administrator on 16/5/10.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SlideNavigationController.h"
@class MBProgressHUD;
@interface TradeMainTableController : UITableViewController<SlideNavigationControllerDelegate>
{
    MBProgressHUD *_hud;
}

@property (nonatomic, assign) BOOL slideOutAnimationEnabled;
@property (nonatomic, strong) NSMutableDictionary *filterDic;
@end

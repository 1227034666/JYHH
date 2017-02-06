//
//  TradeDiscussController.h
//  RTradeDemo
//
//  Created by administrator on 16/5/6.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
@class MBProgressHUD;
@interface TradeDiscussController : UITableViewController
{
    MBProgressHUD *_hud;
}
@property (nonatomic, assign) BOOL slideOutAnimationEnabled;

@end

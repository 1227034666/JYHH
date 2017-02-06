//
//  LiveVipLivingController.h
//  RTradeDemo
//
//  Created by administrator on 16/7/2.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@class MarketModel;
@interface LiveVipLivingController : UIViewController

@property (nonatomic,copy)MarketModel *model;
@property (nonatomic, assign) BOOL slideOutAnimationEnabled;

@end

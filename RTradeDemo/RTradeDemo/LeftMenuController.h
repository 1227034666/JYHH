//
//  LeftMenuController.h
//  RTradeDemo
//
//  Created by administrator on 16/5/5.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SlideNavigationController.h"

@interface LeftMenuController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL slideOutAnimationEnabled;

@end

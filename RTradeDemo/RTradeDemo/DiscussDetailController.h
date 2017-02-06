//
//  DiscussDetailController.h
//  RTradeDemo
//
//  Created by administrator on 16/6/29.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface DiscussDetailController : UIViewController
@property (nonatomic, assign) BOOL slideOutAnimationEnabled;
@property (nonatomic, copy)NSString *linkURL;//URL for webview
@end

//
//  DiscussPublishController.h
//  RTradeDemo
//
//  Created by administrator on 16/6/29.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
@class MBProgressHUD;

@interface DiscussPublishController : UIViewController{
    MBProgressHUD *_hud;
}

@property (strong, nonatomic) UIImageView *selectImageView;

@end

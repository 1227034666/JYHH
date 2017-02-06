//
//  LiveVipIndexController.h
//  RTradeDemo
//
//  Created by administrator on 16/7/31.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SlideNavigationController.h"
@class LineProgressView;
@interface LiveVipIndexController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *m_strNickname;
@property (weak, nonatomic) IBOutlet UILabel *m_strContracts;
@property (strong, nonatomic) IBOutlet UILabel *m_strContracts1;
@property (strong, nonatomic) IBOutlet UILabel *m_strContracts2;

@property (weak, nonatomic) IBOutlet UILabel *m_strFollowNo;
@property (weak, nonatomic) IBOutlet UILabel *m_strYieldRate;
@property (weak, nonatomic) IBOutlet UILabel *m_strBuyRate;
@property (strong, nonatomic) IBOutlet UILabel *m_strInvestLabel;

@property (strong, nonatomic) IBOutlet UIImageView *vipLogoImgView;



@property (strong, nonatomic) LineProgressView *lineProgressView;
@property (assign,  nonatomic) BOOL slideOutAnimationEnabled;
@end

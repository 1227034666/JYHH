//
//  LiveVipIndexController.m
//  RTradeDemo
//
//  Created by administrator on 16/7/31.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "LiveVipIndexController.h"
#import "TradeUtility.h"
#import "LineProgressView.h"
#import "UIViewExt.h"
//#import "UMSocialUIManager.h"
#import <UMSocialCore/UMSocialCore.h>
#import "UMSocialSinaHandler.h"
#import "ActionSheetView.h"
#import "DiscussPublishController.h"

@interface LiveVipIndexController ()

@end

@implementation LiveVipIndexController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置右键
    [self setRightBarButtons];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;

    NSArray *segmentedArray = [NSArray arrayWithObjects:@"实盘",@"模拟",nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    segmentedControl.frame = CGRectMake(0.0, 0.0, 290, 30.0);
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.tintColor = [UIColor whiteColor];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl addTarget:self  action:@selector(indexDidChangeForSegmentedControl:)
               forControlEvents:UIControlEventValueChanged];
    [self.navigationItem setTitleView:segmentedControl];
    
    self.vipLogoImgView.layer.masksToBounds = YES;
    self.vipLogoImgView.layer.cornerRadius = self.vipLogoImgView.width/2.0f;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(vipLogoTapped)];
    [self.vipLogoImgView addGestureRecognizer:tap];
    
    NSString *vipnickname = [TradeUtility LocalLoadConfigFileByKey:@"vipnickname" defaultvalue:@"0"];
    NSString *vipcontractsv = [TradeUtility LocalLoadConfigFileByKey:@"vipcontracts" defaultvalue:@"0"];
    NSString *vipyieldrate = [TradeUtility LocalLoadConfigFileByKey:@"vipyieldrate" defaultvalue:@"0"];
    NSString *vipbuyrate = [TradeUtility LocalLoadConfigFileByKey:@"vipbuyrate" defaultvalue:@"0"];
    NSString *vipfollowcnt = [TradeUtility LocalLoadConfigFileByKey:@"vipfollowcnt" defaultvalue:@"0"];
    NSString *vipLogoImg= [TradeUtility LocalLoadConfigFileByKey:@"vipavatar" defaultvalue:nil];
    
    self.m_strNickname.text = vipnickname;
    NSArray *contractArr = [vipcontractsv componentsSeparatedByString:@","];
    switch (contractArr.count) {
        case 1:
            self.m_strContracts.hidden = NO;
            self.m_strContracts.text =contractArr[0];
            self.m_strContracts1.hidden = YES;
            self.m_strContracts2.hidden = YES;
            break;
        case 2:
            self.m_strContracts.hidden = NO;
            self.m_strContracts1.hidden = NO;
            self.m_strContracts.text =contractArr[0];
            self.m_strContracts1.text =contractArr[1];
            self.m_strContracts2.hidden = YES;
            break;
        case 3:
            self.m_strContracts.hidden = NO;
            self.m_strContracts1.hidden = NO;
            self.m_strContracts2.hidden = NO;
            self.m_strContracts.text =contractArr[0];
            self.m_strContracts1.text =contractArr[1];
            self.m_strContracts2.text =contractArr[2];
            break;
        default:
            self.m_strContracts.hidden = YES;
            self.m_strContracts1.hidden = YES;
            self.m_strContracts2.hidden = YES;
            break;
    }
    self.m_strFollowNo.text = vipfollowcnt;
    [self.vipLogoImgView sd_setImageWithURL:[NSURL URLWithString:vipLogoImg] placeholderImage:[UIImage imageNamed:@"viplogo.png"]];
//    self.m_strYieldRate.text = vipyieldrate;
    NSLog(@"%@",vipyieldrate);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%",self.m_strYieldRate.text]];
    NSRange yieldRateDot =[self getDotPosition:self.m_strYieldRate.text];
    if (yieldRateDot.length > 0) {
        
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:50] range:NSMakeRange(0, yieldRateDot.location)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(yieldRateDot.location, str.length - yieldRateDot.location)];
    }
    
    self.m_strYieldRate.attributedText= str;
    self.m_strBuyRate.text = vipbuyrate;
    [self addLineProgressView];

}

-(void)setRightBarButtons{
    UIView *rightBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 68, 44)];
    rightBarView.backgroundColor = [UIColor clearColor];
    UIImage *commentImage = [UIImage imageNamed:@"IconComment"];
    UIImage *shareImage = [UIImage imageNamed:@"IconShare"];
    CGSize imageTosize = CGSizeMake(24, 24);
    UIImage *reCommentImage = [self reSizeImage:commentImage toSize:imageTosize];
    UIImage *reShareImage =[self reSizeImage:shareImage toSize:imageTosize];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    
    UIButton *comBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comBtn addTarget:self action:@selector(btnComment) forControlEvents:UIControlEventTouchUpInside];
    [comBtn setImage:reCommentImage forState:UIControlStateNormal];
    [comBtn sizeToFit];
    comBtn.frame = CGRectMake(10, 10, 24, 24);
    [rightBarView addSubview:comBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn addTarget:self action:@selector(btnShare) forControlEvents:UIControlEventTouchUpInside];
    [shareBtn setImage:reShareImage forState:UIControlStateNormal];
    [shareBtn sizeToFit];
    shareBtn.frame = CGRectMake(44, 10, 24, 24);
    [rightBarView addSubview:shareBtn];
    UIBarButtonItem*rightItem=[[UIBarButtonItem alloc]initWithCustomView:rightBarView];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,rightItem,nil];
}

//find dot position
-(NSRange)getDotPosition:(NSString *)labelText{
    NSRange dotRange = [labelText rangeOfString:@"."];
    if (dotRange.location != NSNotFound) {
        return dotRange;
    } else{
        dotRange = NSMakeRange(0, 0);
        return dotRange;
    }
}


-(void)indexDidChangeForSegmentedControl:(UISegmentedControl *)Seg{
    
    NSInteger Index = Seg.selectedSegmentIndex;
    
    NSLog(@"Index %li", (long)Index);
    
    switch (Index) {
            
        case 0:
            
            //实盘
            break;
            
        case 1:
            
            //模拟
            
            break;
            
            
        default:
            
            break;
            
    }
    
}

- (void)addLineProgressView {
//    CGPoint centerP = CGPointMake(_m_strBuyRate.left + _m_strBuyRate.width/2, _m_strBuyRate.top);
//    LineProgressView *lineProgressView = [[LineProgressView alloc] initWithFrame:CGRectMake(centerP.x - 35, centerP.y - 35, 70.0, 70.0)];
    _lineProgressView = [[LineProgressView alloc] initWithFrame:CGRectMake(kScreenWidth - 110, 97, 70.0, 70.0)];

    _lineProgressView.backgroundColor = [UIColor colorWithRed:((216.0) / 255.0) green:((40.0) / 255.0) blue:((61.0) / 255.0) alpha:1.0]
;
    _lineProgressView.delegate = self;
    _lineProgressView.total = (int)[_m_strBuyRate.text floatValue];
    //    lineProgressView.color = RGB(0.0, 124.0, 188.0);
    //    lineProgressView.color = [UIColor blueColor];
    _lineProgressView.radius = 35;
    _lineProgressView.innerRadius = 28;
    _lineProgressView.startAngle = - M_PI /2;
    //    lineProgressView.endAngle = M_PI * 2.28;
    _lineProgressView.animationDuration = 0.5;
    _lineProgressView.layer.shouldRasterize = YES;
//    [self.view addSubview:lineProgressView];
    [self.view insertSubview:_lineProgressView belowSubview:_m_strBuyRate];
    [self.view insertSubview:_m_strInvestLabel aboveSubview:_lineProgressView];
    
    [_lineProgressView setCompleted:1.0*_lineProgressView.total animated:YES];
}
#pragma -mark rightNavBar button
-(void)btnComment{
    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradeActiveController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}

-(void)btnShare{
//    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *tradeFilterViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradeIndexFilterViewController"];
//    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:tradeFilterViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
    __weak typeof(self) weakSelf = self;
    NSArray *titlearr = @[@"新浪微博",@"微信好友",@"微信朋友圈",@"久盈观点"];
    NSArray *imageArr = @[@"sinaweibo",@"wechat",@"wechatquan",@"APP_Share"];
    ActionSheetView *actionsheet = [[ActionSheetView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:@"测试" and:ShowTypeIsShareStyle];
    [actionsheet setBtnClick:^(NSInteger btnTag) {
//  这里面可以加入分享到某个第三方的点击
//  UMSocialPlatformType_Sina,          //新浪
//  UMSocialPlatformType_WechatSession, //微信聊天
//  UMSocialPlatformType_WechatTimeLine,//微信朋友圈
        if (btnTag==0) {
            [weakSelf shareWithPlatformType:UMSocialPlatformType_Sina shareTypeIndex:2];
        }else if (btnTag==1){
            [weakSelf shareWithPlatformType:UMSocialPlatformType_WechatSession shareTypeIndex:2];
        }else if (btnTag==2){
            [weakSelf shareWithPlatformType:UMSocialPlatformType_WechatTimeLine shareTypeIndex:2];
        }else if (btnTag==3){
            NSLog(@"clicked %li",btnTag);
            [weakSelf shareTo91Trade];
            
        }
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:actionsheet];
    
    
    //显示分享面板
//    __weak typeof(self) weakSelf = self;
//    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMShareMenuSelectionView *shareSelectionView, UMSocialPlatformType platformType) {
//        
//        
//        [weakSelf shareWithPlatformType:platformType shareTypeIndex:2];
//    }];
    
}

-(void)shareTo91Trade{
    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DiscussPublishController *DiscussPublishCtr = [mainStoryboard instantiateViewControllerWithIdentifier:@"DiscussPublishController"];
    DiscussPublishCtr.selectImageView.image = [self imageFromView:self.view];
    [[SlideNavigationController sharedInstance] pushToViewController:DiscussPublishCtr withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}

//分享不同的内容到平台platformType
- (void)shareWithPlatformType:(UMSocialPlatformType)platformType shareTypeIndex:(NSInteger)index
{
    
    switch (index) {
            
        case 2:
        {
            [self shareImageAndTextToPlatformType:platformType];
        }
            break;
        default:
            break;
    }
}
//分享图片和文字
- (void)shareImageAndTextToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //设置文本
    messageObject.text = @"社会化组件UShare将各大社交平台接入您的应用，快速武装App。";
    
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
//    shareObject.title =
//    shareObject.descr = 
    //如果有缩略图，则设置缩略图
    shareObject.thumbImage = [UIImage imageNamed:@"icon"];
    shareObject.shareImage = [self imageFromView:self.view];
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                NSLog(@"response message is %@",resp.message);
                //第三方原始返回的数据
                NSLog(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                NSLog(@"response data is %@",data);
            }
        }
        [self alertWithError:error];
    }];
}

- (void)alertWithError:(NSError *)error
{
    NSString *result = nil;
    if (!error) {
        result = [NSString stringWithFormat:@"Share succeed"];
    }
    else{
        if (error) {
            result = [NSString stringWithFormat:@"Share fail with error code: %d\n",(int)error.code];
        }
        else{
            result = [NSString stringWithFormat:@"Share fail"];
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"share"
                                                    message:result
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"sure", @"确定")
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)vipLogoTapped{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradeVipDetailController"];
    
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}



//resize right barButton Item Images
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

// iphone 截屏方法
- (UIImage *)imageFromView:(UIView *)theView{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext: context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


@end

//
//  DiscussDetailController.m
//  RTradeDemo
//
//  Created by administrator on 16/6/29.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "DiscussDetailController.h"
#import "ActionSheetView.h"
#import <UMSocialCore/UMSocialCore.h>
#import "UMSocialSinaHandler.h"

@interface DiscussDetailController ()<UIWebViewDelegate>{
    NSString *_uid;
    NSString *_vipuid;
    NSInteger _attentionType;
    NSString *_webViewURL;
    NSString *_viewTitle;
    NSString *_thumbnail;
}
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet UILabel *userNickname;
@property (strong, nonatomic) IBOutlet UILabel *userTrading;
@property (strong, nonatomic) IBOutlet UIButton *btnSubscribe;
@property (strong, nonatomic) IBOutlet UILabel *contractLb1;
@property (strong, nonatomic) IBOutlet UILabel *contractLb2;
@property (strong, nonatomic) IBOutlet UILabel *contractLb3;
@property (strong, nonatomic) IBOutlet UIWebView *articleWebView;

@end

@implementation DiscussDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _vipuid = [TradeUtility LocalLoadConfigFileByKey:@"vipuid" defaultvalue:@"0"];
    _uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    _viewTitle = [TradeUtility LocalLoadConfigFileByKey:@"viewTitle" defaultvalue:@"0"];
    _thumbnail = [TradeUtility LocalLoadConfigFileByKey:@"thumbnail" defaultvalue:@"0"];
    [self.btnSubscribe setTitle:@"+关注" forState:UIControlStateNormal];
    [self.btnSubscribe setTitle:@"已关注" forState:UIControlStateSelected];
    self.btnSubscribe.selected = NO;
    if ([_vipuid isEqualToString:_uid]) {
        self.btnSubscribe.hidden = YES;
    }
    [self showLeaderUserinfo];
    _webViewURL =[TradeUtility LocalLoadConfigFileByKey:@"linkurl" defaultvalue:@"0"];
    self.articleWebView.delegate = self;
    [self.articleWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&input=1",_webViewURL]]]];
}

- (void)showLeaderUserinfo{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    //    NSString *strURL = [[NSString alloc] initWithFormat:@"http://inf.91trader.com/rtrade/user/getLeaderUserInfo"];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               _vipuid, @"vipUid",
                               _uid, @"uid",
                               nil];
    NSLog(@"postparam=%@",postparam);
    
    //    NSDictionary *retdata = [TradeUtility HTTPSyncPOSTRequest:strURL parameters:postparam];
    [TradeUtility requestWithUrl:@"getLeaderUserInfo" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"retcode=%d",icode);
        if(icode == 0){
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
            NSLog(@"retjson=%@",retjson);
            if(retjson != nil){
                NSDictionary *present_info = [retjson objectForKey:@"leader_uinfo"];
                if(present_info != nil){
                    _attentionType =[[present_info objectForKey:@"attentstate"] integerValue];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (_attentionType == 1) {
                            self.btnSubscribe.selected = YES;
//                            self.btnSubscribe.titleLabel.text =@"已关注";
                        } else{
                            self.btnSubscribe.selected = NO;
                            self.btnSubscribe.titleLabel.text =@"+关注";
                        }
                    });
                    hud.customView = [[UIImageView alloc]init];
                    hud.mode = MBProgressHUDModeCustomView;
                    hud.labelText = @"连接服务器";
                    [hud hide:YES afterDelay:1];
                }
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"vip detail error:%@",error);
    }];
    
}

- (IBAction)btnDoComment:(id)sender {
    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"DiscussCommentController"];
    [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}


- (IBAction)btnDoSubscribe:(UIButton *)sender {
    if (_attentionType == 0) {
        _attentionType =1;
    } else{
        _attentionType =0;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               _uid, @"uid",
                               _vipuid, @"vipUid",
                               @(_attentionType),@"operType",
                               nil];
    NSLog(@"postparam=%@",postparam);
    [TradeUtility requestWithUrl:@"setAttention" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"setAttention retcode=%d",icode);
        if(icode == 0){
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
            NSLog(@"setAttention retjson=%@",retjson);
            
            hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CheckMark"]];
            hud.mode = MBProgressHUDModeCustomView;
            if (_attentionType == 1 ) {
                hud.labelText = @"关注成功";
                
            } else if (_attentionType == 0){
                hud.labelText = @"取消关注成功";
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.btnSubscribe.titleLabel.text isEqualToString:@"+关注"]) {
                    self.btnSubscribe.selected = YES;
//                    self.btnSubscribe.titleLabel.text =@"已关注";
                } else{
//                    self.btnSubscribe.titleLabel.text =@"+关注";
                    self.btnSubscribe.selected = NO;
                }
            });
            [hud hide:YES afterDelay:1];
        } else{
            if (_attentionType == 0) {
                _attentionType =1;
            } else{
                _attentionType =0;
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"discuss detail error:%@",error);
    }];
    
}

- (IBAction)btnDoCollect:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    NSString * _viewid = [TradeUtility LocalLoadConfigFileByKey:@"curViewId" defaultvalue:@"0"];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               _uid, @"uid",
                               _viewid, @"viewId",
                               nil];
    [TradeUtility requestWithUrl:@"putCollect" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"setAttention retcode=%d",icode);
        if(icode == 0){

            hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CheckMark"]];
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"收藏成功";
            [hud hide:YES afterDelay:1];
        }
    } failure:^(NSError *error) {
        NSLog(@"DiscussDetailCtr setAttention error:%@",error);
    }];
}

- (IBAction)btnDoShare:(UIBarButtonItem *)sender {
    __weak typeof(self) weakSelf = self;
    NSArray *titlearr = @[@"新浪微博",@"微信好友",@"微信朋友圈"];
    NSArray *imageArr = @[@"sinaweibo",@"wechat",@"wechatquan"];
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
        }
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:actionsheet];
}


//分享不同的内容到平台platformType
- (void)shareWithPlatformType:(UMSocialPlatformType)platformType shareTypeIndex:(NSInteger)index{
    
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
    if (platformType == UMSocialPlatformType_Sina) {
        UMShareImageObject *shareObject = [[UMShareImageObject alloc]init];
        messageObject.text = [NSString stringWithFormat:@"%@ %@",_viewTitle,_webViewURL];//文本和url放在text里
        if (![_thumbnail isEqualToString:@"0"]) {
            [shareObject setShareImage:_thumbnail];
        } else{
            [shareObject setShareImage:[UIImage imageNamed:@"icon"]];
        }
        messageObject.shareObject = shareObject;
    } else{
    //设置文本
//
    messageObject.text = _viewTitle;//文本和url放在text里
    //创建图片内容对象
        UMShareWebpageObject *shareObject =[UMShareWebpageObject shareObjectWithTitle:_viewTitle descr:@"l来自久盈交易者app" thumImage:_thumbnail];
        shareObject.webpageUrl = _webViewURL;
        messageObject.shareObject = shareObject;
    }
    
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

// iphone 截屏方法
- (UIImage *)imageFromView:(UIView *)theView{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext: context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
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


@end

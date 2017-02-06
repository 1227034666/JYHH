
//  AppDelegate.m
//  RTradeDemo
//  Created by administrator on 16/5/1.
//  Copyright © 2016年 administrator. All rights reserved.

#import "AppDelegate.h"
#import "GuideViewController.h"
#import "SlideNavigationController.h"
#import "LeftMenuController.h"
#import "TradeMainNaviController.h"
#import "TradeMainTableController.h"
#import "UIImageView+WebCache.h"
#import "sys/utsname.h"
#import "WXApi.h"
#import <UMSocialCore/UMSocialCore.h>
//#import "UMShareMenuItem.h"
//#import "UMShareMenuSelectionView.h"
#import "TradeAdvertiseView.h"
#import "JYTabBarViewController.h"

//微信开发者ID
#define URL_APPID @"wxe3c21f345833e6c4"

@interface AppDelegate ()
{
    NSInteger _countSec;
    NSTimer *_countTimer;
//手机型号
    NSString *_phoneModel;
//分辨率
    CGFloat _scale_screen;
    NSString *_scaleInfo;
//手机系统版本
    NSString *_phoneVersion;
//手机号
    NSString *_mobile;
//设备唯一标识符 UUID
    NSString *_IMEI;
//上次获取的url
    NSString *_preURL;
//地理位置  （国际化区域名称）
    NSString *_localPhoneModel;
//当前获得的url
    NSString *_currURL;
    
    UIImageView *_imageV;
}
@property(nonatomic,strong)UIView *lunchView;
@property (strong, nonatomic) UILabel *countLabel;

@end
static AFHTTPSessionManager *manager ;
@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //打开调试日志
    [[UMSocialManager defaultManager] openLog:YES];
    
    // 获取友盟social版本号
    UMSocialLogInfo(@"UMeng social version: %@", [UMSocialGlobal umSocialSDKVersion]);
    
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"57b432afe0f55a9832001a0a"];
    
    // 获取友盟social版本号
    //NSLog(@"UMeng social version: %@", [UMSocialGlobal umSocialSDKVersion]);
    
    //设置微信的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wxe3c21f345833e6c4" appSecret:@"df571378359e63939470f172cfe1d892" redirectURL:@"http://mobile.umeng.com/social"];
    
    //设置新浪的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3921700954"  appSecret:@"04b48b094faeb16683c32669824ebdad" redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
    // 如果不想显示平台下的某些类型，可用以下接口设置
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
//    [self customShare];
    
    //对未安装客户端平台进行隐藏
//    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [TradeUtility LocalInitConfigFile];

    [self.window makeKeyAndVisible];
    //向微信注册应用。
    [WXApi registerApp:@"wxe3c21f345833e6c4" withDescription:@"wechat"];
    
    [self getUserPhoneInfor];
//    [self getSyncWelcomePage];
    
    BOOL flag =[[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"];
    if (flag){
        TradeMainNaviController *navCtr = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"TradeMainNavi"];
        [self.window setRootViewController:navCtr];
        
//        self.window.rootViewController=[[JYTabBarViewController alloc]init];
        
    }else{
        GuideViewController *guideCtr = [[GuideViewController alloc]init];
        self.window.rootViewController = guideCtr;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
/*
    self.lunchView = [[UIView alloc]init];
    _lunchView.backgroundColor = [UIColor greenColor];
    [self.window addSubview:self.lunchView];
    [self.window bringSubviewToFront:self.lunchView];
    self.lunchView.frame = CGRectMake(0, 0, self.window.screen.bounds.size.width, self.window.screen.bounds.size.height);
    
    _imageV = [[UIImageView alloc] initWithFrame:self.lunchView.frame];
    [self.lunchView addSubview:_imageV];
    _preURL = [TradeUtility LocalLoadConfigFileByKey:@"preURL" defaultvalue:@"pre"];
    NSLog(@"preURL:%@",_preURL);
    if ([_preURL isEqualToString:_currURL]) {
        _imageV.image = [self getDocumentImage];
    } else {
        _preURL = _currURL;
//        _currURL =@"http://i.l.inmobicdn.net/banners/FileData/290057e6-a662-411d-86bb-688b3c284460.jpeg";
        _imageV.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_currURL]]];
//        [_imageV sd_setImageWithURL:[NSURL URLWithString:_currURL] placeholderImage:[UIImage imageNamed:@"Launch.png"]];
        UIImage *_img =_imageV.image;
        [self saveImageDocuments:_img];
        [TradeUtility LocalSaveConfigFileByKey:@"preURL" value:_currURL];
    }
    
//  倒计时标签
    _countLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.window.screen.bounds.size.width - 130, 40, 50, 25)];
    _countLabel.textColor =[UIColor whiteColor];
    _countLabel.backgroundColor = [UIColor lightGrayColor];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.font = [UIFont systemFontOfSize:14];
    _countLabel.layer.cornerRadius = 5;
    _countLabel.layer.masksToBounds = YES;
    [self.lunchView addSubview:_countLabel];
    _countSec = 5;
    _countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(removeLunch) userInfo:nil repeats:YES];
*/    
//    本地推送
    CGFloat version = [[UIDevice currentDevice].systemVersion floatValue];
    
    if (version >= 8.0) {
//        通知类型
        UIUserNotificationType type = UIUserNotificationTypeBadge |
        UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        ;
//        创建通知设置
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
//        注册通知权限
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
//    TradeAdvertiseView *advertise = [TradeAdvertiseView loadAdvertiseView];
//    [self.window addSubview:advertise];
    return YES;
}



-(void)removeLunch {
    _countSec--;
    _countLabel.text = [NSString stringWithFormat:@"%lis",_countSec];
//    NSLog(@"%@",_countLabel.text);
    if (_countSec <=0) {
        [_countTimer invalidate];
        [self.lunchView removeFromSuperview];
//        TradeMainTableController *tbCtr =self.mainTbCtl;
//        [tbCtr.tableView reloadData];

    }
}

- (TradeMainTableController *)mainTbCtl{
    UIResponder *responder = self.nextResponder;
    
    do {
        if ([responder isKindOfClass:[TradeMainTableController class]]) {
            
            return (TradeMainTableController *)responder;
        }
        
        responder = responder.nextResponder;
        
    } while (responder!= nil);
    
    
    return nil;
}

-(void)getUserPhoneInfor{
    //手机型号
    _phoneModel =  [self deviceVersion];
    //分辨率
    _scale_screen = [UIScreen mainScreen].scale;
    NSLog(@"分辨率是:%.0f × %.0f", kScreenWidth*_scale_screen ,kScreenHeight*_scale_screen);
    _scaleInfo = [NSString stringWithFormat:@"%.0f x %.0f",kScreenWidth*_scale_screen,kScreenHeight*_scale_screen];
//手机系统版本
    _phoneVersion = [[UIDevice currentDevice] systemVersion];
    //手机号
    //设备唯一标识符 UUID
    _IMEI = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //上次获取的url
    //地理位置  （国际化区域名称）
    _localPhoneModel = [[UIDevice currentDevice] localizedModel];
    NSLog(@"%@",_localPhoneModel);
}

- (NSString*)deviceVersion
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"]) return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"]) return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"]) return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"]) return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"]) return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,3"]) return @"iPhoneSE";
    if ([deviceString isEqualToString:@"iPhone8,4"]) return @"iPhoneSE";
    if ([deviceString isEqualToString:@"iPhone9,1"]) return @"iPhone7";
    if ([deviceString isEqualToString:@"iPhone9,2"]) return @"iPhone7Plus";
    
    return deviceString;
}

-(void)getWelcomePageURL{
//    NSDictionary *postparam = @{@"phoneModel":_phoneModel, @"scaleInfo":_scaleInfo,@"phoneVersion":_phoneVersion,
//                                @"mobile":_mobile,@"identifierStr":_identifierStr,@"localPhoneModel":_localPhoneModel};
    NSDictionary *postparam = @{@"phoneModel":_phoneModel, @"scaleInfo":_scaleInfo,@"phoneVersion":_phoneVersion,@"identifierStr":_IMEI,@"localPhoneModel":_localPhoneModel};
    NSLog(@"postparam=%@",postparam);
    [TradeUtility requestWithUrl:@"getWelcomePage" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        
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
                _currURL = [retjson objectForKey:@"url"];
                                NSLog(@"_preURL:%@",_preURL);
                NSLog(@"_currURL:%@",_currURL);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                });
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

-(void)getSyncWelcomePage{
//    NSString *strURL = [[NSString alloc] initWithFormat:@"http://inf.91trader.com/rtrade/user/getWelcomePage"];
    NSString *_url = @"http://interface.91trader.com/Public/interface.php";
    
    
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"getWelcomePage",@"action",
                              _phoneModel, @"phoneModel",
                               _scaleInfo,@"scaleInfo",
                               _phoneVersion,@"phoneVersion",
                               _IMEI,@"imei",
                               _localPhoneModel,@"localPhoneModel",
                               nil];
    
    
    NSLog(@"postparam=%@",postparam);
    
    NSDictionary *retdata = [TradeUtility HTTPSyncPOSTRequest:_url parameters:postparam];
    
    if(retdata == nil)
    {
        NSLog(@"retdata=%@",retdata);
        [TradeUtility ShowNetworkErrDlg:self];
        return;
    }
    
    NSString *retcode = [retdata objectForKey:@"re_code"];
    int icode = [retcode intValue];
    NSLog(@"retcode=%d",icode);
    if(icode == 0)
    {
        NSDictionary *retjson = [retdata objectForKey:@"re_json"];
        NSLog(@"retjson=%@",retjson);
        if(retjson != nil)
        {
            _currURL = [retjson objectForKey:@"url"];
            NSLog(@"_currURL:%@",_currURL);
        }
    }
}

-(void)saveImageDocuments:(UIImage *)image{
    //拿到图片
    UIImage *imagesave = image;
    NSString *path_sandox = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imagePath = [path_sandox stringByAppendingPathComponent:@"Documents/welcomePage.png"];
    NSLog(@"sandbox:%@",imagePath);
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(imagesave) writeToFile:imagePath atomically:YES];
}
// 读取并存贮到相册
-(UIImage *)getDocumentImage{
    // 读取沙盒路径图片
    NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(),@"welcomePage"];
    
    // 拿到沙盒路径图片
    UIImage *imgFromUrl3=[[UIImage alloc]initWithContentsOfFile:aPath3];
    return imgFromUrl3;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    
    /*! @brief 处理微信通过URL启动App时传递的数据
     *
     * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
     * @param url 微信启动第三方应用时传递过来的URL
     * @param delegate  WXApiDelegate对象，用来接收微信触发的消息。
     * @return 成功返回YES，失败返回NO。
     */
    
    return [WXApi handleOpenURL:url delegate:self];
}


/*! 微信回调，不管是登录还是分享成功与否，都是走这个方法 @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
-(void) onResp:(BaseResp*)resp{
    NSLog(@"resp %d",resp.errCode);
    
    /*
     enum  WXErrCode {
     WXSuccess           = 0,    成功
     WXErrCodeCommon     = -1,  普通错误类型
     WXErrCodeUserCancel = -2,    用户点击取消并返回
     WXErrCodeSentFail   = -3,   发送失败
     WXErrCodeAuthDeny   = -4,    授权失败
     WXErrCodeUnsupport  = -5,   微信不支持
     };
     */
    if ([resp isKindOfClass:[SendAuthResp class]]) {   //授权登录的类。
        if (resp.errCode == 0) {  //成功。
            //这里处理回调的方法 。 通过代理吧对应的登录消息传送过去。
            if ([_wxDelegate respondsToSelector:@selector(loginSuccessByCode:)]) {
                SendAuthResp *resp2 = (SendAuthResp *)resp;
                [_wxDelegate loginSuccessByCode:resp2.code];
            }
        }else{ //失败
            NSLog(@"error %@",resp.errStr);
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:[NSString stringWithFormat:@"reason : %@",resp.errStr] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
    }
}

-(AFHTTPSessionManager *)sharedHTTPSession{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 10;
    });
    return manager;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

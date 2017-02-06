//
//  ViewController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/1.
//  Copyright © 2016年 administrator. All rights reserved.
//  登录界面

#import "ViewController.h"
#import "TradeUtility.h"
#import "sys/utsname.h"
#import "WXApi.h"
#import "AppDelegate.h"
//微信开发者ID
#define URL_APPID @"wxe3c21f345833e6c4"
#define URL_SECRET @"df571378359e63939470f172cfe1d892"
#import "AFNetworking.h"

@interface ViewController ()<UITextFieldDelegate,WXDelegate>
{
    NSInteger _offset;
    NSInteger _checkCodeWaitTime;
    NSTimer *_checkCodeTimer;
    AppDelegate *appdelegate;
    NSString *_wechatOpenID;
}
- (IBAction)doUserLogin:(id)sender;
- (IBAction)doGetCode:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *mTextMobile;
@property (weak, nonatomic) IBOutlet UITextField *mTextCheckcode;
@property (strong, nonatomic) IBOutlet UIButton *mButtonCheckCode;
@property (strong, nonatomic) IBOutlet UIButton *mLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *weChatLoginBtn;
@property (strong, nonatomic) UIButton *cancelButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets=YES;
    self.mTextMobile.text = [TradeUtility LocalLoadConfigFileByKey:@"mobile" defaultvalue:@""];
    self.mTextMobile.delegate = self;
    [self.mTextMobile addTarget:self action:@selector(mobileTextChanged) forControlEvents:UIControlEventEditingChanged];
    self.mTextCheckcode.delegate = self;
    [self.mTextCheckcode addTarget:self action:@selector(checkCodeTextChanged) forControlEvents:UIControlEventEditingChanged];
    
    UIImage *image = [UIImage imageNamed:@"LoginBg"];
    self.view.layer.contents = (id)image.CGImage;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
    self.mButtonCheckCode.layer.cornerRadius = 10;
    self.mLoginButton.userInteractionEnabled = NO;
    [self.mButtonCheckCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    _checkCodeWaitTime = 90;
    
    if (![WXApi isWXAppInstalled]) {
        self.weChatLoginBtn.hidden = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];// 1
    [self.mTextMobile becomeFirstResponder];// 2
}
-(void)dealloc{
    NSLog(@"login dealloc");
}

-(void)mobileTextChanged{
    _mTextMobile.text = _mTextMobile.text;
    if (_mTextMobile.text.length > 0 && _mTextCheckcode.text.length >0) {
        _mLoginButton.userInteractionEnabled = YES;
        _mLoginButton.backgroundColor = [UIColor colorWithRed:216/255.0 green:40/255.0 blue:61/255.0 alpha:1];
    } else {
        _mLoginButton.userInteractionEnabled = NO;
        _mLoginButton.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    }
}
-(void)checkCodeTextChanged{
    _mTextCheckcode.text = _mTextCheckcode.text;
    if (_mTextMobile.text.length > 0 && _mTextCheckcode.text.length >0) {
        _mLoginButton.userInteractionEnabled = YES;
        _mLoginButton.backgroundColor = [UIColor colorWithRed:216/255.0 green:40/255.0 blue:61/255.0 alpha:1];
    }else {
        _mLoginButton.userInteractionEnabled = NO;
        _mLoginButton.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    }
}

- (void)closeKeyboard:(id)sender{
    [self.view endEditing:YES];
    if (_offset < 0) {
        [UIView animateWithDuration:.3 animations:^{
            self.view.transform = CGAffineTransformIdentity;
        }];
    }
}

- (IBAction)doUserLogin:(id)sender {
    [_checkCodeTimer invalidate];
    _checkCodeTimer = nil;
    if (_offset < 0) {
        [UIView animateWithDuration:.3 animations:^{
            self.view.transform = CGAffineTransformIdentity;
        }];
    }
    if (![self validateMobile:_mTextMobile.text]) {
        //初始化提示框；
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"手机号码有误" preferredStyle:  UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击按钮的响应事件；
        }]];
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];
    }
    [self sendReqToServer:1];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    CGRect frame = self.mTextCheckcode.frame;
    _offset = frame.origin.y + 150 - (self.view.frame.size.height - 216.0);//键盘高度216
    if(_offset < 0){
        [UIView animateWithDuration:.3 animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, -_offset);
        }];
    }
//    NSTimeInterval animationDuration = 0.30f;
//    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    float width = self.view.frame.size.width;
//    float height = self.view.frame.size.height;
//    if(offset > 0)
//    {
//        CGRect rect = CGRectMake(0.0f, -offset,width,height);
//        self.view.frame = rect;
//    }
//    [UIView commitAnimations];
}
/*
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    //返回BOOL值，指定是否允许文本字段结束编辑，当编辑结束，文本字段会让出first responder
    
    //要想在用户结束编辑时阻止文本字段消失，可以返回NO
    
    //这对一些文本字段必须始终保持活跃状态的程序很有用，比如即时消息
    
    return NO;  
    
}
 */
//获取验证码按下
- (IBAction)doGetCode:(id)sender {
    
//    NSString *accountid = [TradeUtility LocalLoadConfigFileByKey:@"accountid" defaultvalue:@"0"];
    //设备唯一标识符 UUID
    NSString *_IMEI = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSDictionary *postparam = @{@"imei":_IMEI, @"mobile": self.mTextMobile.text};
    
    NSLog(@"%@",postparam);
    __weak __typeof(self) weakSelf = self;

    [TradeUtility requestWithUrl:@"getCode" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"retcode=%d",icode);
        if(icode != 0){
            NSString *remsg = [retdata objectForKey:@"re_msg"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:remsg preferredStyle:  UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //点击按钮的响应事件；
            }]];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        } else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mButtonCheckCode.userInteractionEnabled = NO;
                self.mButtonCheckCode.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
                _checkCodeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getCodeClicked) userInfo:nil repeats:YES];
            });
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
}

-(void)sendReqToServer:(NSInteger)loginType{
    
    
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    NSString *strURL = [[NSString alloc] initWithFormat:@"http://interface.91trader.com/Public/interface.php"];
    NSDictionary *postparam =nil;
    if (loginType == 0) {
        postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                     @"login",@"action",
                     uid, @"uid",
                     _wechatOpenID, @"openid",
                     @"0",@"type",
                     @"IOS",@"os",
                     @"0",@"mode",
                     nil];
    }
    if (loginType == 1) {
        postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                     @"login",@"action",
                     uid, @"uid",
                     self.mTextMobile.text, @"mobile",
                     _mTextCheckcode.text, @"code",
                     @"1",@"type",
                     @"IOS",@"os",
                     @"0",@"mode",
                     nil];
    }
    
    
    NSLog(@"postparam=%@",postparam);
    
    NSDictionary *retdata = [TradeUtility HTTPSyncPOSTRequest:strURL parameters:postparam];
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
            NSString *ret_uid = [retjson objectForKey:@"uid"];
            NSString *ret_nickname = [retjson objectForKey:@"nickname"];
            NSString *ret_pic = [retjson objectForKey:@"avatar"];
            NSString *ret_isvip = [retjson objectForKey:@"isvip"];
            NSString *ret_futureAcct = [retjson objectForKey:@"username"];
            NSString *ret_future = [retjson objectForKey:@"futurename"];
            int iretuid = [ret_uid intValue];
            NSLog(@"iretuid=%d",iretuid);
            if(iretuid != 0){
                [TradeUtility LocalSaveConfigFileByKey:@"uid" value:ret_uid];
                [TradeUtility LocalSaveConfigFileByKey:@"mobile" value:self.mTextMobile.text];
                if (![ret_isvip isKindOfClass:[NSNull class]]) {
                    [TradeUtility LocalSaveConfigFileByKey:@"isvip" value:ret_isvip];
                }
                if(![ret_nickname isKindOfClass:[NSNull class]]){
                    [TradeUtility LocalSaveConfigFileByKey:@"nickname" value:ret_nickname];
                }
                if (![ret_pic isKindOfClass:[NSNull class]]) {
                    [TradeUtility LocalSaveConfigFileByKey:@"avatar" value:ret_pic];
                }
                if(![ret_future isKindOfClass:[NSNull class]]){
                    [TradeUtility LocalSaveConfigFileByKey:@"futurename" value:ret_future];
                }
                if(![ret_futureAcct isKindOfClass:[NSNull class]]){
                    [TradeUtility LocalSaveConfigFileByKey:@"username" value:ret_futureAcct];
                }
                if ([self.showNextViewCtr isEqualToString:@"LiveVipIndexController"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLoginNotification" object:@{@"showNextCtr":@"1"}];
                } else if ([self.showNextViewCtr isEqualToString:@"PersonalSetVipController"]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"canStartLeadNotification" object:@{@"showNextCtr":@"1"}];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginNotification" object:nil];
            }
        }
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"Modal View done");
        }];
        
        NSString *accountid = [TradeUtility LocalLoadConfigFileByKey:@"accountid" defaultvalue:@"0"];
        int iaccountid = [accountid intValue];
        NSLog(@"********* account id: %i",iaccountid);
        
//        if(iaccountid == 0){
//            //        bind account
//            UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
//            
//            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"RegisterAccountController"];
//            loginViewController.modalTransitionStyle =UIModalTransitionStyleCoverVertical;
//            [appRootVC presentViewController:loginViewController animated:YES completion:^{
//                NSLog(@"Present Modal View");
//            }];
//        }
    }else{
        //初始化提示框；
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"登录失败" preferredStyle:  UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击按钮的响应事件；
        }]];
        
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];
    }
}
//验证码倒计时
-(void)getCodeClicked{
    _checkCodeWaitTime--;

    NSString *btnTitle = [NSString stringWithFormat:@"%lis",_checkCodeWaitTime];
    NSLog(@"%@",btnTitle);
    [_mButtonCheckCode setTitle:btnTitle forState:UIControlStateNormal];
    
    if (_checkCodeWaitTime == 0) {
        [_checkCodeTimer invalidate];
        _mButtonCheckCode.userInteractionEnabled = YES;
        NSString *btnTitle = @"获取验证码";
        [_mButtonCheckCode setTitle:btnTitle forState:UIControlStateNormal];
        _mButtonCheckCode.backgroundColor = [UIColor colorWithRed:216/255.0 green:40/255.0 blue:61/255.0 alpha:1];
        _checkCodeWaitTime = 90;
    }
}

//判断手机号码格式是否正确
-(BOOL)validateMobile:(NSString *)mobile{
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (mobile.length != 11){
        return NO;
    }else{
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else{
            return NO;
        }
    }
}

#pragma mark 微信登录
- (IBAction)weixinLoginAction:(id)sender {
    
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc]init];
        req.scope = @"snsapi_userinfo";
        req.openID = URL_APPID;
        req.state = @"1245";
        appdelegate = [UIApplication sharedApplication].delegate;
        appdelegate.wxDelegate = self;
        
        [WXApi sendReq:req];
    }
}

#pragma mark 微信登录回调。
-(void)loginSuccessByCode:(NSString *)code{
    NSLog(@"code %@",code);
    __weak typeof(*&self) weakSelf = self;
    
    //AFHTTPSessionManager
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AFHTTPSessionManager *manager = [app sharedHTTPSession];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//响应
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json",@"text/plain", nil];
    //通过 appid  secret 认证code . 来发送获取 access_token的请求
    [manager GET:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",URL_APPID,URL_SECRET,code] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"dic %@",dic);
        
        /*
         access_token	接口调用凭证
         expires_in	access_token接口调用凭证超时时间，单位（秒）
         refresh_token	用户刷新access_token
         openid	授权用户唯一标识
         scope	用户授权的作用域，使用逗号（,）分隔
         unionid	 当且仅当该移动应用已获得该用户的userinfo授权时，才会出现该字段
         */
        NSString* accessToken=[dic valueForKey:@"access_token"];
        NSString* openID=[dic valueForKey:@"openid"];
        [weakSelf requestUserInfoByToken:accessToken andOpenid:openID];
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            NSLog(@"Modal View done");
        }];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %@",error.localizedFailureReason);
    }];
}

-(void)requestUserInfoByToken:(NSString *)token andOpenid:(NSString *)openID{
    __weak typeof(*&self) weakSelf = self;
    //AFHTTPSessionManager
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AFHTTPSessionManager *manager = [app sharedHTTPSession];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",token,openID] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        //开发人员拿到相关微信用户信息后， 需要与后台对接，进行登录
        NSLog(@"login success dic  ==== %@",dic);
        _wechatOpenID = dic[@"openid"];
        [weakSelf sendReqToServer:0];
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            NSLog(@"Modal View done");
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %ld",(long)error.code);
    }];
}

- (IBAction)cancelLogin:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

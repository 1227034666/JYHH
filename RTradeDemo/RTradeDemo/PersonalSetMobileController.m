//
//  PersonalSetMobileController.m
//  RTradeDemo
//
//  Created by administrator on 16/8/14.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "PersonalSetMobileController.h"

@interface PersonalSetMobileController ()<UITextFieldDelegate>{
    NSInteger _checkCodeWaitTime;
    NSTimer *_checkCodeTimer;
}

@property (strong, nonatomic) IBOutlet UITextField *mTextMobile;//手机号
@property (strong, nonatomic) IBOutlet UITextField *mTextCheckcode;//验证码
@property (strong, nonatomic) IBOutlet UIButton *mButtonCheckCode;//验证码按钮
@property (strong, nonatomic) IBOutlet UIButton *mLoginButton;//绑定


@end

@implementation PersonalSetMobileController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"手机号绑定";
    _checkCodeWaitTime = 90;
    [self.mButtonCheckCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    self.mTextMobile.text = [TradeUtility LocalLoadConfigFileByKey:@"mobile" defaultvalue:@""];
    self.mTextMobile.delegate = self;
    [self.mTextMobile addTarget:self action:@selector(mobileTextChanged) forControlEvents:UIControlEventEditingChanged];
    self.mTextCheckcode.delegate = self;
    [self.mTextCheckcode addTarget:self action:@selector(checkCodeTextChanged) forControlEvents:UIControlEventEditingChanged];
}

- (IBAction)getCodeBtnAction:(UIButton *)sender {
    
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

- (IBAction)bindPhoneNumAction:(UIButton *)sender {
    [_checkCodeTimer invalidate];
    _checkCodeTimer = nil;
    if (![self validateMobile:_mTextMobile.text]) {
        //初始化提示框；
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"手机号码有误" preferredStyle:  UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击按钮的响应事件；
        }]];
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];
    } else{
        [self bindPhoneNum];
    }

}

-(void)bindPhoneNum{
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    NSString *oldMobile = [TradeUtility LocalLoadConfigFileByKey:@"mobile" defaultvalue:@"0"];
    if ([oldMobile isEqualToString:self.mTextMobile.text]) {
        //初始化提示框；
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"手机号码已绑定" message:nil preferredStyle:  UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击按钮的响应事件；
        }]];
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];
        return;
    }
    
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                     @"login",@"action",
                     uid, @"uid",
                     self.mTextMobile.text, @"mobile",
                     _mTextCheckcode.text, @"code",
                     nil];
    NSLog(@"postparam=%@",postparam);
    [TradeUtility requestWithUrl:@"bindPhoneNum" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
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
                
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"PersonalSetMobile Ctr error:%@",error);
    }];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

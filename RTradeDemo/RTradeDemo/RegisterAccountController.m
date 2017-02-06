//
//  RegisterAccountController.m
//  RTradeDemo
//
//  Created by Michael Luo on 11/3/16.
//  Copyright © 2016 administrator. All rights reserved.
//

#import "RegisterAccountController.h"
#import "TradeUtility.h"
#import "SlideNavigationController.h"
#import "FutureCompanyController.h"
#import "LiveVipLivingController.h"

@interface RegisterAccountController ()
@property (strong, nonatomic) IBOutlet UILabel *accountCompany;
@property (strong, nonatomic) IBOutlet UITextField *accountNumber;
@property (strong, nonatomic) IBOutlet UITextField *accountPwd;
@property (strong, nonatomic) IBOutlet UITextField *verifyNumber;
@property (strong, nonatomic) IBOutlet UILabel *verifyCode;
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;


@end

@implementation RegisterAccountController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _verifyCode.layer.borderWidth = 1;
    _verifyCode.layer.borderColor = [[UIColor grayColor]CGColor];
    UIView *_headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,64)];
    _headView.backgroundColor = BGRED_COLOR;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 30, 120, 24)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"绑定交易账户";
    [_headView addSubview:titleLabel];

    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(kScreenWidth - 95, 30, 90, 24);
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [cancelBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [cancelBtn setTitle:@"暂不绑定" forState:UIControlStateNormal];

    [cancelBtn addTarget:self action:@selector(doGiveupAccount) forControlEvents:UIControlEventTouchUpInside];
    
    [_headView addSubview:cancelBtn];
    self.tableView.tableHeaderView = _headView;
//    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"暂不绑定" style:UIBarButtonItemStyleDone target:self action:@selector(doGiveupAccount)];
//    self.navigationItem.rightBarButtonItem = rightBtn;
    //下面两句是取四位随机数字,但是太简单,一般不要用于验证码
    int number = arc4random() % 8999 + 1000;
    self.verifyCode.text = [NSString stringWithFormat:@"%d",number];
    self.submitBtn.layer.cornerRadius = 10;
    self.submitBtn.layer.masksToBounds = YES;
    [self reloadFutureAccountInfo];
}

-(void)reloadFutureAccountInfo{
    NSString *acctCompany =[TradeUtility LocalLoadConfigFileByKey:@"futurename" defaultvalue:@"0"];
    NSString *acctUserName =[TradeUtility LocalLoadConfigFileByKey:@"username" defaultvalue:@"0"];
    NSString *acctPwd =[TradeUtility LocalLoadConfigFileByKey:@"futurepassword" defaultvalue:@"0"];
    if (![acctCompany isEqualToString:@"0"] && acctCompany.length > 1) {
        self.accountCompany.text = acctCompany;
    }
    if (![acctUserName isEqualToString:@"0"] && acctUserName.length > 1) {
        self.accountNumber.text = acctUserName;
    }
    if (![acctPwd isEqualToString:@"0"] && acctPwd.length > 1) {
        self.accountPwd.text = acctPwd;
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 5;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

        FutureCompanyController *futureCompanyCtr = [mainStoryboard instantiateViewControllerWithIdentifier:@"futureCompanyCtr"];
        
        futureCompanyCtr.companyBlock =^(NSString *text){
            _accountCompany.text = text;
        };
        [self presentModalViewController:futureCompanyCtr animated:YES];
//        [self presentViewController:futureCompanyCtr animated:YES completion:nil];
        
//         UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
//        [appRootVC presentViewController:futureCompanyCtr animated:YES completion:nil];
//        [[SlideNavigationController sharedInstance]pushToViewController:futureCompanyCtr withSlideOutAnimation:_slideOutAnimationEnabled andCompletion:nil];
    }
}

- (IBAction)submitAction:(UIButton *)sender {
    NSString *str;
    if ([[self.accountCompany.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        str =@"请选择开户公司";
        [self showAlertMessage:str];
        return;
    }
    if([[self.accountNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
        str =@"请输入资金账号";
        [self showAlertMessage:str];
        return;
    }
    if([[self.accountPwd.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
        str =@"请输入资金密码";
        [self showAlertMessage:str];
        return;
    }
    if(![[self.verifyNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:self.verifyCode.text]){
        str =@"验证码输入错误";
        [self showAlertMessage:str];
        return;
    }
    
    [self doSumbmission];
    
}

-(void)doSumbmission{
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    
//    NSString *strURL = [[NSString alloc] initWithFormat:@"http://inf.91trader.com/rtrade/user/fixAccount"];
    
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               self.accountCompany.text, @"futureName",
                               self.accountNumber.text, @"username",
                               self.accountPwd.text,@"password",
                               nil];
    
    NSLog(@"postparam=%@",postparam);
    __weak typeof(self) weakSelf = self;
    [TradeUtility requestWithUrl:@"bindFutureAcc" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"bindFutureAcc retcode=%d",icode);
        if(icode == 0){
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
            NSLog(@"retjson=%@",retjson);
            if(retjson != nil ){
                NSString *ret_accountid = [retjson objectForKey:@"accid"];
                int iretaid = [ret_accountid intValue];
                NSLog(@"iretaid=%d",iretaid);
                if(iretaid != 0){
                    [TradeUtility LocalSaveConfigFileByKey:@"accountid" value:ret_accountid];
                    [TradeUtility LocalSaveConfigFileByKey:@"futurename" value:self.accountCompany.text];
                    [TradeUtility LocalSaveConfigFileByKey:@"username" value:self.accountNumber.text];
                    [TradeUtility LocalSaveConfigFileByKey:@"futurepassword" value:self.accountPwd.text];
                    
                    if (_nextViewController != nil) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"FutureLoginNotification" object:@{@"showNextCtr":_nextViewController}];
                        [weakSelf dismissViewControllerAnimated:YES completion:^{
                            NSLog(@"Modal View done");
                        }];
                    } else{
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            }
        }else{
            //初始化提示框；
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"绑定账户失败" preferredStyle:  UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //点击按钮的响应事件；
            }]];
            
            //弹出提示框；
            [self presentViewController:alert animated:true completion:nil];
        }
    } failure:^(NSError *error) {
        NSLog(@"Register Account Error:%@",error);
    }];

}


-(void)showAlertMessage:(NSString *)message{
    
    //初始化提示框；
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"验证码输入有误" preferredStyle:  UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //点击按钮的响应事件；
    }]];
    
    //弹出提示框；
    [self presentViewController:alert animated:true completion:nil];
}

- (void)doGiveupAccount{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Modal View done");
//        if (_nextViewController == nil) {
//            [[SlideNavigationController sharedInstance] popViewControllerAnimated:YES];
//        }
    }];
    
}

@end

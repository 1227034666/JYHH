//
//  PersonalSetVipController.m
//  RTradeDemo
//
//  Created by administrator on 16/6/29.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "PersonalSetVipController.h"
#import "TradeUtility.h"
#import "TradeCategoryViewController.h"
#import "RegisterAccountController.h"
#import "MBProgressHUD.h"
//背景红色
#define BGRED_COLOR [UIColor colorWithRed:216.0/255.0 green:40.0/255.0 blue:61.0/255.0 alpha:1.0]

@interface PersonalSetVipController ()<UITextViewDelegate>{
     UILabel *_textViewPlaceholderLabel;
    NSString *_uid;
}
@property (strong, nonatomic) IBOutlet UISwitch *m_switchStartLead;
@property (strong, nonatomic) IBOutlet UISwitch *m_switchOpen;
@property (strong, nonatomic) IBOutlet UITextView *m_textFieldInvest;
@property (strong, nonatomic) IBOutlet UIButton *m_btnActivate;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *m_labelContract;


@end

@implementation PersonalSetVipController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *skipBtn = [[UIBarButtonItem alloc] initWithTitle:@"跳过" style:UIBarButtonItemStylePlain target:self action:@selector(btnSkip:)];
    [self.navigationItem setRightBarButtonItem:skipBtn];
    self.title = @"发起领单";
    self.m_btnActivate.layer.masksToBounds = YES;
    self.m_btnActivate.layer.cornerRadius = 15;
    _m_textFieldInvest.delegate = self;
    //设置是否可以编辑
    _m_textFieldInvest.editable = YES;
    
    _textViewPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 25)];
    _textViewPlaceholderLabel.text = @"请填写个人投资策略";
    _textViewPlaceholderLabel.textColor = [UIColor grayColor];
    [_m_textFieldInvest addSubview:_textViewPlaceholderLabel];
    _uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    [self getLeaderStatus];
    
}
-(void)getLeaderStatus{
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               _uid, @"uid",
                               nil];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"连接服务器中";
    [TradeUtility requestWithUrl:@"getLeaderstate" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary *)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"getLeaderstate retdata=%@",retdata);
        if(icode == 0){
            
           
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
            if (![retjson isKindOfClass:[NSNull class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([retjson[@"isvip"] isEqualToString:@"1"]) {
                        self.m_switchStartLead.on =YES;
                        self.m_btnActivate.titleLabel.text = @"关闭我的领单";
                        _textViewPlaceholderLabel.hidden = YES;
                    } else{
                         self.m_switchStartLead.on =NO;
                    }
                    if ([retjson[@"vipopenflag"] isEqualToString:@"1"]) {
                        self.m_switchOpen.on = YES;
                    } else{
                        self.m_switchOpen.on = NO;
                    }
                    if (![retjson[@"contracts"] isKindOfClass:[NSNull class]]) {
                        self.m_labelContract.text =retjson[@"contracts"];
                    }
                    if (![retjson[@"strategy"] isKindOfClass:[NSNull class]]) {
                        self.m_textFieldInvest.text = retjson[@"strategy"];
                    }
                    
                });
            }
            hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CheckMark"]];
            [hud hide:YES afterDelay:0.5];
        }
    } failure:^(NSError *error) {
        NSLog(@"personalSetVipController error:%@",error);
    }];

}

- (IBAction)openTradeAmount:(UISwitch *)sender {
    
}

- (IBAction)startLeadBtnAction:(UISwitch *)sender {
    NSLog(@"%@",self.m_textFieldInvest.text);
    if (sender.on && [self.m_textFieldInvest.text length] > 0){
        self.m_btnActivate.backgroundColor = BGRED_COLOR;
        self.m_btnActivate.titleLabel.textColor = [UIColor whiteColor];
    }else{
    
        self.m_btnActivate.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
        self.m_btnActivate.titleLabel.textColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1];
    }
    if (!sender.on) {
        //        领单关闭
        NSString * stateflag = _m_switchStartLead.on ? @"1" :@"-1";
        NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                                   _uid, @"uid",
                                   stateflag, @"stateflag",
                                   nil];
        [self sendRequest:postparam withType:@"关闭领单"];
    }
}


- (IBAction)activateMyLead:(UIButton *)sender {
    [self.m_textFieldInvest resignFirstResponder];
//  公开手数
    NSInteger vipopenflag = _m_switchOpen.on ? 1 :0;
    NSInteger stateflag = _m_switchStartLead.on ? 1 :0;
    NSArray *contractArray;
    if (self.m_labelContract.text.length ==0) {
        contractArray =@[@"全部合约"];
    } else{
        contractArray = [self.m_labelContract.text componentsSeparatedByString:@","];
    }
    NSString *strategyStr = self.m_textFieldInvest.text;
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               _uid, @"uid",
                               @(vipopenflag), @"vipopenflag",
                               contractArray,@"contracts",
                               strategyStr,@"strategy",
                               @(stateflag), @"stateflag",
                               nil];
    NSLog(@"postparam: %@",postparam);
    [self sendRequest:postparam withType:@"开启领单"];
//    NSLog(@"hide contract list: %@",_m_labelContract.text);
}

-(void)sendRequest:(NSDictionary *)paramDic withType:(NSString *)type{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];

    NSLog(@"activedLeaderList postparam: %@",paramDic);
    [TradeUtility requestWithUrl:@"activedLeaderList" httpMethod:@"POST" pramas:[paramDic mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary *)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"activedLeaderList retdata=%@",retdata);
        if(icode == 0){
            
            hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CheckMark"]];
            
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = [NSString stringWithFormat:@"%@成功",type];
            [hud hide:YES afterDelay:1];

            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
            
        } else if(icode == 210){
            //操作失误
            
        }else if(icode == 212){
            //账户信息错
            
        }else if(icode == 214){
            //未绑定
            
        }else if(icode == 221){
            //超时
            
        }
    } failure:^(NSError *error) {
        NSLog(@"personalSetVipController error:%@",error);
    }];
}

-(void)timerAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)btnSkip:(id)sender{
    [[SlideNavigationController sharedInstance] popViewControllerAnimated:YES];
}
-(void)futureAccountError{
    
    UIAlertController * _alert = [UIAlertController alertControllerWithTitle:@"资金账户信息错误" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [_alert addAction:[UIAlertAction actionWithTitle:@"立即绑定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self bindAccount];
    }]];
    [_alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
    [self presentViewController:_alert animated:YES completion:nil];
}

-(void)bindAccount{
    //bind account
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisterAccountController *registerAccountController = [mainStoryboard instantiateViewControllerWithIdentifier:@"RegisterAccountController"];
    registerAccountController.nextViewController = nil;
    registerAccountController.modalTransitionStyle =UIModalTransitionStyleCoverVertical;
    [[SlideNavigationController sharedInstance]presentViewController:registerAccountController animated:YES completion:nil];
}

-(void)showAlertWindow:(NSString *)message{
    UIAlertController * _alert = [UIAlertController alertControllerWithTitle:@"资金账户信息错误" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [_alert addAction:[UIAlertAction actionWithTitle:@"立即绑定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self bindAccount];
    }]];
    [_alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
    [self presentViewController:_alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 5;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2) {
        TradeCategoryViewController *tradeCategoryCtr = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"tradeCategoryCtr"];
        tradeCategoryCtr.categoryBlock =^(NSString *text){
            _m_labelContract.text = text;

        };
        [self.navigationController pushViewController:tradeCategoryCtr animated:YES];
    }
}


- (void)textViewDidChange:(UITextView *)textView {
    NSInteger number = [textView.text length];
    if (number > 0 && self.m_switchStartLead.on) {
        self.m_btnActivate.backgroundColor = BGRED_COLOR;
        self.m_btnActivate.titleLabel.textColor = [UIColor whiteColor];
    } else {
        self.m_btnActivate.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
        self.m_btnActivate.titleLabel.textColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1];
    }
    if (number > 100) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"字符个数不能大于100" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        textView.text = [textView.text substringToIndex:100];
        number = 100;

    }
    self.statusLabel.text = [NSString stringWithFormat:@"%ld/100",(long)number];
}

//设置textView的placeholder
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //[text isEqualToString:@""] 表示输入的是退格键
    if (![text isEqualToString:@""])
    {
        _textViewPlaceholderLabel.hidden = YES;
    }
    
    //range.location == 0 && range.length == 1 表示输入的是第一个字符
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1)
        
    {
        _textViewPlaceholderLabel.hidden = NO;
    }
    return YES;
    
}



@end

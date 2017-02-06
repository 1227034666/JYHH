//
//  RegAccountController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/1.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "RegAccountController.h"
//#import "myCombox.h"
#import "TradeUtility.h"
#import "SlideNavigationController.h"

@interface RegAccountController ()

- (IBAction)doSubmitAccount:(id)sender;
- (IBAction)doGiveupAccount:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *mTextCompany;
@property (weak, nonatomic) IBOutlet UITextField *mTextAccountNmae;
@property (weak, nonatomic) IBOutlet UITextField *mTextAccountPwd;
@property (weak, nonatomic) IBOutlet UITextField *nTextVerifyCode;
@property (strong, nonatomic) IBOutlet UIButton *nTextVerifyNum;

@end

@implementation RegAccountController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NSMutableArray *arrayData=[[NSMutableArray alloc] initWithObjects:@"shaosikang1",@"shaosikang2",@"shaosikang3",@"shaosikang4",@"shaosikang5",@"shaosikang6",@"shaosikang7",@"shaosikang8", nil];
    
//    myCombox *combox=[[myCombox alloc] initWithFrame:CGRectMake(50, 80, 300, 300)];
//    combox.arrayData=arrayData;
//    combox.titleButton.text=@"选择一项";
    //combox.titleButton.textColor=[UIColor blackColor];
//    combox.backgroundColor=[UIColor clearColor];
    //combox.cellColor=[UIColor whiteColor];
    //combox.cellSelectColor=[UIColor whiteColor];
//    combox.cellHeight=30;

//    [combox initWithView];
//    [self.view addSubview:combox];
    
    self.mTextCompany.text = [TradeUtility LocalLoadConfigFileByKey:@"AccountCompany" defaultvalue:@"RohonDemo"];
    self.mTextAccountNmae.text = [TradeUtility LocalLoadConfigFileByKey:@"AccountName" defaultvalue:@"rjhh"];
    self.mTextAccountPwd.text = [TradeUtility LocalLoadConfigFileByKey:@"AccountPwd" defaultvalue:@"888888"];
//    [self.nTextVerifyNum setTintColor:[UIColor blackColor]];
    //设置标题颜色
    [self.nTextVerifyNum setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //设置背景颜色
//    [button setBackgroundColor:[UIColor orangeColor]];
    [self change];
}

- (IBAction)changeVerifyCode:(UIButton *)sender {
    [self change];
}

- (void)change
{
    
    //用了大写字母,自己感觉要比小写好点吧，方法比较笨，嘿嘿
    //    changeArray = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
    //
    //    NSMutableString *getStr = [[NSMutableString alloc] initWithCapacity:5]; //可变字符串，存取得到的随机数
    //
    //    changeString = [[NSMutableString alloc] initWithCapacity:6]; //可变string，最终想要的验证码
    //    for(NSInteger i = 0; i < 4; i++) //得到四个随机字符，取四次，可自己设长度
    //    {
    //        NSInteger index = arc4random() % ([changeArray count] - 1);  //得到数组中随机数的下标
    //        getStr = [changeArray objectAtIndex:index];  //得到数组中随机数，赋给getStr
    //
    //        changeString = (NSMutableString *)[changeString stringByAppendingString:getStr]; //把随机字符加到可变string后面，循环四次后取完
    //    }
    //
    //    _yzmapictures.text = [NSString stringWithFormat:@"  %@",changeString];
    //  yzmapictures.text  = changeString;
    
    //下面两句是取四位随机数字,但是太简单,一般不要用于验证码
    int number = arc4random() % 8999 + 1000;
    [self.nTextVerifyNum setTitle:[NSString stringWithFormat:@"   %d",number] forState:UIControlStateNormal];

}

- (IBAction)doSubmitAccount:(id)sender {
    
    NSString *buttonVerifyNum = [NSString stringWithFormat:@"%@",[_nTextVerifyNum titleForState:UIControlStateNormal]];
    NSString *finalStr = [buttonVerifyNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"button title:%@",finalStr);
    NSLog(@"Input num:%@",_nTextVerifyCode.text);
    if (![_nTextVerifyCode.text isEqualToString:finalStr]) {
        //初始化提示框；
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"验证码输入有误" preferredStyle:  UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击按钮的响应事件；
        }]];
        
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];
        return;
    }
    
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"http://inf.91trader.com/rtrade/user/fixAccount"];
    
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               self.mTextCompany.text, @"company",
                               self.mTextAccountNmae.text, @"username",
                               self.mTextAccountPwd.text,@"password",
                               nil];
    
    NSLog(@"postparam=%@",postparam);
    
    NSDictionary *retdata = [TradeUtility HTTPSyncPOSTRequest:strURL parameters:postparam];
    
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
            NSString *ret_accountid = [retjson objectForKey:@"accountId"];
            int iretaid = [ret_accountid intValue];
            NSLog(@"iretaid=%d",iretaid);
            if(iretaid != 0)
            {
                [TradeUtility LocalSaveConfigFileByKey:@"accountid" value:ret_accountid];
                [TradeUtility LocalSaveConfigFileByKey:@"accountcompany" value:self.mTextCompany.text];
                [TradeUtility LocalSaveConfigFileByKey:@"accountusername" value:self.mTextAccountNmae.text];
                [TradeUtility LocalSaveConfigFileByKey:@"accountpassword" value:self.mTextAccountPwd.text];
            }
        }

        __weak typeof(self) weakSelf = self;
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"Modal View done");
            if ([weakSelf.nextViewController isEqualToString:@"LiveVipLivingController"]) {
                [weakSelf bindAccountDone];
            }
        }];
        
        
    }
    else
    {
        //初始化提示框；
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"绑定账户失败" preferredStyle:  UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击按钮的响应事件；
        }]];
        
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];

    }
}

-(void)bindAccountDone{
    
    NSString *accountid = [TradeUtility LocalLoadConfigFileByKey:@"accountid" defaultvalue:@"0"];
    int iaccountid = [accountid intValue];
    NSLog(@"********* account id: %i",iaccountid);
    
    if(iaccountid > 0){
        [TradeUtility LocalSaveConfigFileByKey:@"curConCode" value:[_itemData objectForKey:@"concode"]];
        [TradeUtility LocalSaveConfigFileByKey:@"curConPrice" value:[_itemData objectForKey:@"convalue"]];
        
        [TradeUtility LocalSaveConfigFileByKey:@"cur_updown" value:[_itemData objectForKey:@"updown"]];
        [TradeUtility LocalSaveConfigFileByKey:@"cur_updownrate" value:[_itemData objectForKey:@"updownrate"]];
        
        [TradeUtility LocalSaveConfigFileByKey:@"cur_avgprice" value:[_itemData objectForKey:@"trade_avgprice"]];
        [TradeUtility LocalSaveConfigFileByKey:@"cur_buyrate" value:[_itemData objectForKey:@"trade_buyrate"]];
        [TradeUtility LocalSaveConfigFileByKey:@"cur_fuying" value:[_itemData objectForKey:@"trade_fuying"]];
        [TradeUtility LocalSaveConfigFileByKey:@"cur_hold_time" value:[_itemData objectForKey:@"hold_time"]];
        [TradeUtility LocalSaveConfigFileByKey:@"cur_trade_type" value:[_itemData objectForKey:@"trade_type"]];
        [TradeUtility LocalSaveConfigFileByKey:@"cur_trade_state" value:[_itemData objectForKey:@"trade_state"]];
        
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"LiveVipLivingController"];
        
        [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
    }
}


- (IBAction)doGiveupAccount:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Modal View done");
    }];
}
@end

//
//  LiveVipLivingController.m
//  RTradeDemo
//
//  Created by administrator on 16/7/2.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "LiveVipLivingController.h"
#import "RegisterAccountController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "GCDAsyncUdpSocket.h"
#import "MarketModel.h"
#import "YYStock.h"
#import "YYLineDataModel.h"
#import "YYTimeLineModel.h"
#import "UIColor+YYStockTheme.h"
#import "YYFiveRecordModel.h"
#import "LiveVipTradingController.h"
#import "LeadTradeModel.h"
#import "YYStockVariable.h"
#import "AppDelegate.h"
#import "UDPManager.h"
//主交易界面

//背景红色

//#define BGGreen_COLOR [UIColor colorWithRed:3.0/255.0 green:152.0/255.0 blue:52.0/255.0 alpha:1.0]
//#define serviceAddress @"139.196.203.229"
//#define servicePort 9050
//#define serviceTradePort 9059

@interface LiveVipLivingController ()<UIScrollViewDelegate,UITextFieldDelegate,GCDAsyncUdpSocketDelegate,YYStockDataSource>{
//    定时器
    NSTimer *_marketTimer;
    NSTimer *_getLeadTimer;

    NSString *_conName;
    NSString *_conCode;
    
    NSInteger _numOfContract;
    NSString *_tradeType;
    NSString *_latestPrice;
    NSString *_offsetFlag;
    NSString *_finalTradeType;
    NSString *_uid;
//    对手价
    double _dealingPrice;
//    开仓均价
    double _openAvgPrice;
//             手数
    NSInteger openVol;
//             合约成数
    NSString *contractVol;

//    GCDAsyncUdpSocket *udpSocket;
//    记录行情数据的时间
    NSDate *_marketDataTime;
    UIButton *_selectedBtn;
    
//    NSMutableDictionary *_marketHistoryData;
    NSString *_preSettlementPrice;
    double _maxTradePrice;
//    行情上一次时间戳
    NSString *_lastTimeStamp;
//    显示实时行情时，判断交易日是否改变
    NSString *_lastActionDay;
//    历史行情最后的自然日
    NSString *_lastHistActionDay;
//    历史行情最后的交易日
    NSString *_lastHistTradeDay;
//    领单者的上次请求时间戳
    NSString *_lastLeadHistTime;
    BOOL _getUserTrade1st;
    
    NSString *_lastMinute;
    NSInteger _lastIndex;
    BOOL _hideTopBar;

    NSString *_vipuid;
    BOOL _loginFutureSuccess;
}

//分时图Model
@property (strong,nonatomic)NSDictionary *leadTradeDic;

/**
 K线数据源
 */
@property (strong, nonatomic) NSMutableDictionary *stockDatadict;
@property (copy, nonatomic) NSArray *stockDataKeyArray;
@property (copy, nonatomic) NSArray *stockTopBarTitleArray;
@property (strong, nonatomic) YYFiveRecordModel *fiveRecordModel;

@property (strong, nonatomic) YYStock *stock;
@property (nonatomic, assign) NSString *stockId;
//折线图
@property (strong, nonatomic) IBOutlet UIView *stockContainerView;
/**
 是否显示五档图
 */
@property (assign, nonatomic) BOOL isShowFiveRecord;

//交易提醒
@property (strong,nonatomic)UILabel *notfiyLabel;
//@property (strong, nonatomic) ARLineChartView *lineChartView;
//lead info
@property (strong, nonatomic) IBOutlet UIView *leadBgView;

@property (strong, nonatomic) IBOutlet UIImageView *leadOtherTrade;
@property (strong, nonatomic) IBOutlet UILabel *m_strLeadTradePrice;//最新交易价
@property (strong, nonatomic) IBOutlet UILabel *m_strTradeType;//交易方向
@property (strong, nonatomic) IBOutlet UILabel *m_strLeadTradeCnt;//交易手数
@property (strong, nonatomic) IBOutlet UILabel *m_strContractState;//开平仓状态
@property (strong, nonatomic) IBOutlet UILabel *m_strLeadTradeTime;

@property (weak, nonatomic) IBOutlet UILabel *m_strLastPrice;//最新价
@property (strong, nonatomic) IBOutlet UILabel *m_strWinLabel;

//my trade details
@property (strong, nonatomic) IBOutlet UILabel *m_strTradeCount;//手数
@property (strong, nonatomic) IBOutlet UILabel *m_strRiskLevel;//风险度
@property (strong, nonatomic) IBOutlet UILabel *m_strUnwind;//平仓盈亏
@property (strong, nonatomic) IBOutlet UILabel *m_strPosiProfit;//持仓盈亏
@property (strong, nonatomic) IBOutlet UILabel *m_strTradeAvailableCnt;//可用资金
@property (strong, nonatomic) IBOutlet UILabel *m_strAvgPrice;//开仓均价

//trading labels
@property (strong, nonatomic) IBOutlet UIButton *btnPlus;
@property (strong, nonatomic) IBOutlet UIButton *btnDown;
@property (strong, nonatomic) IBOutlet UILabel *labelPlus;
@property (strong, nonatomic) IBOutlet UILabel *labelClearUp;
@property (strong, nonatomic) IBOutlet UILabel *buyingPrice;
@property (strong, nonatomic) IBOutlet UILabel *sellingPrice;
@property (strong, nonatomic) IBOutlet UILabel *offeringPriceLeft; //买量
@property (strong, nonatomic) IBOutlet UILabel *offeringPriceRight; //买量

// +/-
@property (strong, nonatomic) IBOutlet UIButton *numPlus;
@property (strong, nonatomic) IBOutlet UIButton *numMinus;
@property (strong, nonatomic) IBOutlet UITextField *numTextField;

@property (strong, nonatomic) IBOutlet UIView *tradingView;
//个人资金帐户信息
@property (strong, nonatomic) IBOutlet UIScrollView *userInforScrollView;
@property (strong, nonatomic) IBOutlet UIView *scrollSubView1;
@property (strong, nonatomic) IBOutlet UIView *scrollSubView2;
@property (strong, nonatomic) IBOutlet UIView *scrollSubView3;
@property (strong, nonatomic) IBOutlet UIView *scrollSubView4;

@property (strong,nonatomic)dispatch_source_t timer;//定时器

@property (strong,nonatomic)NSMutableArray *modelArr;//历史行情数据传入stockModel
//@property (strong,nonatomic)NSMutableDictionary *valueDic;//为展示实时行情
@end

@implementation LiveVipLivingController
    NSArray *condataData;

- (UILabel *)notfiyLabel{
    if ( _notfiyLabel == nil) {
        _notfiyLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, -60, kScreenWidth - 20, 40)];
        _notfiyLabel.backgroundColor = [UIColor whiteColor];
        _notfiyLabel.textColor = [UIColor blackColor];
        _notfiyLabel.textAlignment = NSTextAlignmentLeft;
        _notfiyLabel.font = [UIFont systemFontOfSize:15];
        _notfiyLabel.numberOfLines = 2;
    }
    [self.navigationController.navigationBar addSubview:_notfiyLabel];
    return _notfiyLabel;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _numOfContract = 1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _vipuid = [TradeUtility LocalLoadConfigFileByKey:@"vipuid" defaultvalue:@"0"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets=NO;
    // 向通知中心注册了一条通知 "futureLoginNotification"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(futureLoginNotification:) name:@"FutureLoginNotification" object:nil];
   
    //监听键盘的弹出
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    if ([_vipuid isEqualToString:@"-1"]) {
        //设置右键
        UIView *rightBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
        rightBarView.backgroundColor = [UIColor clearColor];
        UIButton *trashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        trashBtn.selected = NO;
        [trashBtn addTarget:self action:@selector(addedAction:) forControlEvents:UIControlEventTouchUpInside];
        [trashBtn setImage:[UIImage imageNamed:@"IconTrash"] forState:UIControlStateNormal];
        [trashBtn setImage:[UIImage imageNamed:@"IconTrashGray"] forState:UIControlStateSelected];
        trashBtn.frame = CGRectMake(0, 0, 35, 44);
        [rightBarView addSubview:trashBtn];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;
        
        UIImage *whImage = [UIImage imageNamed:@"IconWarehouse"];
        CGSize imageTosize = CGSizeMake(18, 18);
        UIImage *reWHImage = [self reSizeImage:whImage toSize:imageTosize];

        UIButton *warehouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        warehouseBtn.selected = NO;
        [warehouseBtn addTarget:self action:@selector(selfWHAction) forControlEvents:UIControlEventTouchUpInside];
        [warehouseBtn setImage:reWHImage forState:UIControlStateNormal];
        warehouseBtn.frame = CGRectMake(35, 0, 35, 44);
        [rightBarView addSubview:warehouseBtn];
        UIBarButtonItem*rightItem=[[UIBarButtonItem alloc]initWithCustomView:rightBarView];

        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,rightItem,nil];
//        self.navigationItem.rightBarButtonItem = rightBtn;
        self.leadBgView.hidden = YES;
    }
    _numTextField.delegate = self;
    _numTextField.layer.borderWidth = 1;
    _numTextField.width = 110;
    _numTextField.layer.cornerRadius = 5;
    _numTextField.layer.masksToBounds = YES;
    _numTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _numTextField.textColor = [UIColor lightGrayColor];
    _numTextField.textAlignment = NSTextAlignmentCenter;
    _userInforScrollView.delegate = self;
 
    self.scrollSubView1.width = kScreenWidth/3.0;
    self.scrollSubView2.width = kScreenWidth/3.0;
    self.scrollSubView3.width = kScreenWidth/3.0;
    self.scrollSubView4.width = kScreenWidth/3.0;
    _userInforScrollView.contentSize = CGSizeMake(kScreenWidth/3.0 *4 +30, self.userInforScrollView.frame.size.height);
    
    [self setupButtons];
    
    _uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    
//    _marketHistoryData = [NSMutableDictionary dictionary];
    NSString *vipnickname = [TradeUtility LocalLoadConfigFileByKey:@"vipnickname" defaultvalue:@"0"];
    if ([vipnickname isEqualToString:@"0"]) {
        self.title = [NSString stringWithFormat:@"%@",_conName];
    } else{
        self.title = [NSString stringWithFormat:@"%@@%@",_conName,vipnickname];
    }
    condataData = nil;

    _numOfContract = 1;
    openVol=0;
    self.numTextField.text = @"1";
    self.numTextField.inputAccessoryView = [self addToolbar];
    _lastTimeStamp = @"0";
    _lastActionDay = @"0";
    _lastLeadHistTime= @"";
    _lastHistTradeDay=@"0";
    _getUserTrade1st = YES;
//
    [self initStockView];
    
    [self getLeadLatestTrade];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(leadInfoTapped)];
    [self.leadBgView addGestureRecognizer:tap];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"vip living appered");
//    登录期货公司
    [self loginFuture];
    [self subscribeMarket];
    [self sendHeartBeat:NO];
//    获取历史行情数据
    [self getHistoryMarket];
    if (_marketTimer.isValid == NO) {
//        [self subscribeMarket];
        _marketTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
}

-(void)enterForeground{
    NSLog(@"entered foreground");
    //    登录期货公司
    [self loginFuture];
    [self subscribeMarket];
    [self sendHeartBeat:NO];
    //    获取行情数据
    if (_marketTimer.isValid == NO) {
        _marketTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"vip living disappered");
    [self.notfiyLabel removeFromSuperview];
//    NSDictionary *beatDic = @{@"flag":@"1",@"id_list":@"",@"uid":_uid};
//    NSData *beatData = [NSJSONSerialization dataWithJSONObject:beatDic options:NSJSONWritingPrettyPrinted error:nil];
//    [udpSocket sendData:beatData toHost:serviceAddress port:servicePort withTimeout:-1 tag:1];
    //关闭定时器
    if (_marketTimer.isValid == YES) {
        [_marketTimer invalidate];
        _marketTimer = nil;
    }
    if(_timer){
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}


//订阅行情数据
-(void)subscribeMarket{
    UDPManager *udpManager = [UDPManager shareManager];
    [udpManager.udpSocket setDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
//    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSDictionary *marketDic = @{@"flag":@"0",@"id_list":_conCode,@"uid":_uid};
    NSLog(@"subscribeMarket param :%@",marketDic );
    NSLog(@"%@",_conCode);
    NSData *marketData = [NSJSONSerialization dataWithJSONObject:marketDic options:NSJSONWritingPrettyPrinted error:nil];
    [udpManager.udpSocket sendData:marketData toHost:serviceAddress port:servicePort withTimeout:-1 tag:0];
    NSDictionary *tradeBeatDic = @{@"cmd":@"100",@"uid":_uid,@"vip_uid":_vipuid};
    NSData *tradeBeatData = [NSJSONSerialization dataWithJSONObject:tradeBeatDic options:NSJSONWritingPrettyPrinted error:nil];
    [udpManager.udpSocket sendData:tradeBeatData toHost:serviceAddress port:serviceTradePort withTimeout:-1 tag:4];
    
    NSError *error = nil;
    [udpManager.udpSocket beginReceiving:&error];
}

//发心跳
-(void)sendHeartBeat:(BOOL)noDataFlag{
//    __block NSInteger timeout = showTime +1;
//    __block NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    self.timer = timer;
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
//        NSLog(@"heartbeat uid:%@",uid);
//        行情心跳
        UDPManager *udpManager = [UDPManager shareManager];
        [udpManager.udpSocket setDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        NSDictionary *beatDic = @{@"flag":@"2",@"id_list":@"",@"uid":_uid};
        NSData *beatData = [NSJSONSerialization dataWithJSONObject:beatDic options:NSJSONWritingPrettyPrinted error:nil];
        [udpManager.udpSocket sendData:beatData toHost:serviceAddress port:servicePort withTimeout:-1 tag:2];
        
        if (!noDataFlag) {
//        启动交易心跳 / 行情数据没有时不用重发交易心跳
            NSDictionary *tradeBeatDic = @{@"cmd":@"100",@"uid":_uid,@"vip_uid":_vipuid};
            NSData *tradeBeatData = [NSJSONSerialization dataWithJSONObject:tradeBeatDic options:NSJSONWritingPrettyPrinted error:nil];
            [udpManager.udpSocket sendData:tradeBeatData toHost:serviceAddress port:serviceTradePort withTimeout:-1 tag:4];
        }
        dispatch_source_set_cancel_handler(timer, ^{
            NSLog(@"cancel");
        });
    });
    dispatch_resume(timer);
}

-(void)timerAction{
    NSDate *_date = [NSDate date];
    NSTimeInterval secondsInterval= [_date timeIntervalSinceDate:_marketDataTime];
    if (secondsInterval >= 5) {
        [self sendHeartBeat:YES];
//        NSDictionary *beatDic = @{@"flag":@"2",@"id_list":@"",@"uid":_uid};
//        NSLog(@"没5秒发心跳：%@",beatDic);
//        NSData *beatData = [NSJSONSerialization dataWithJSONObject:beatDic options:NSJSONWritingPrettyPrinted error:nil];
//        UDPManager *udpManager = [UDPManager shareManager];
//        [udpManager.udpSocket setDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
//        [udpManager.udpSocket sendData:beatData toHost:serviceAddress port:servicePort withTimeout:-1 tag:2];
//        NSError *error = nil;
//        [udpManager.udpSocket beginReceiving:&error];
        _marketDataTime =_date;
    }
}

#pragma mark -- rightbar action without following Lead
-(void)selfWHAction{
    [TradeUtility LocalSaveConfigFileByKey:@"vipuid" value:_uid];
    [self enterTradeInfor];
}

-(void)addedAction:(UIButton *)btn{
    //初始化提示框；
    if (!btn.selected) {
        btn.selected = YES;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要删除自选合约吗？" message:nil
                                                                preferredStyle:  UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //取消自选；
            [self unsubscribeContract];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //取消；
            btn.selected = NO;
        }]];
        [self presentViewController:alert animated:true completion:nil];
    }
}

-(void)unsubscribeContract{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               _uid, @"uid",
                               _conCode,@"concode",
                               _conName,@"conname",
                               @"-1", @"flag",
                               nil];
    [TradeUtility requestWithUrl:@"subscribe" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"subscript retcode=%d",icode);
        if(icode == 0){
            hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CheckMark"]];
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"删除自选合约成功";
            [hud hide:YES afterDelay:1];
        }
    } failure:^(NSError *error) {
        NSLog(@"getPositionContract error: %@",error);
    }];
}

#pragma mark --- get market history method
-(void)getHistoryMarket{
    NSDictionary *paramDic =@{ @"uid":_uid, @"concode":_conCode,@"num":@"1"};
    [TradeUtility requestWithUrl:@"getHistoryMarket" httpMethod:@"POST" pramas:[paramDic mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary *)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"getHistoryMarket retcode=%d",icode);
        if(icode == 0){
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
//            NSLog(@"%@",retjson);
            NSArray *marketList =[retjson objectForKey:@"marketlist"];
            if (marketList.count > 0) {
                NSRange range = [[marketList firstObject] rangeOfString:@"-"];
                NSRange range1 = [[marketList firstObject]rangeOfString:@".tick"];
                if (range.location != NSNotFound && range1.location != NSNotFound) {
//                    获取昨结价
                    _preSettlementPrice =[[marketList firstObject] substringWithRange:NSMakeRange(range1.location - (range1.location - range.location)+1, (range1.location - range.location)-1)];
                }
                NSString *dayStr = [[marketList lastObject] substringWithRange:NSMakeRange(range.location - 8, 8)];
                _lastHistTradeDay = dayStr;
                [self downloadMarketFiles:[marketList firstObject]];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"getHistoryMarket error:%@",error);
    }];
}

-(void)downloadMarketFiles:(NSString *)urlStr{
//AFHTTPSessionManager
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AFHTTPSessionManager *manager = [app sharedHTTPSession];
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/file0.txt"];
//remove existing file
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        NSString *url1 = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url1]];
        
   NSURLSessionDownloadTask *downTask= [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSString *str = [NSString stringWithContentsOfURL:filePath encoding:NSUTF8StringEncoding error:nil];
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *arr = [str componentsSeparatedByString:@"\n"];

        if (self.modelArr.count > 0) {
            [self.modelArr removeAllObjects];
        }
        for (NSInteger j=0; j< arr.count; j++) {
            if ([arr[j] isEqualToString:@""]) {
                break;
            }
            NSArray *itemArr = [arr[j] componentsSeparatedByString:@","];
            NSString *finalTime=[[itemArr lastObject] substringWithRange:NSMakeRange(0, 4)];
            double _Pri=[[itemArr firstObject] floatValue]/10000;
            double _avgPri = [_preSettlementPrice floatValue]/10000;
            
            NSDictionary *itemDic = @{@"minute":finalTime,@"avgPrice":[NSString stringWithFormat:@"%.2f",_avgPri],@"price":[NSString stringWithFormat:@"%.2f",_Pri],@"volume":@"0"};
            YYTimeLineModel *model = [[YYTimeLineModel alloc]initWithDict:itemDic];
            [self.modelArr addObject: model];
            if (j == arr.count -1) {
                _lastMinute = finalTime;
                _lastHistActionDay = itemArr[1];
            }
        }
        if (self.modelArr.count >0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.stockDatadict setObject:self.modelArr forKey:@"minutes"];
                [self.stock draw];
            });
        }
    }];
    [downTask resume];
}

#pragma mark --- get self trade infor method
-(void)getMyTradeInfo{
    NSDictionary *paramDic =@{ @"uid":_uid, @"instrument":_conCode};
    [TradeUtility requestWithUrl:@"getUserTrade" httpMethod:@"POST" pramas:[paramDic mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary *)result;
//        NSLog(@"getUserTrade retdata=%@",retdata);
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"getUserTrade retcode=%d",icode);
        if(icode == 0){
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
            NSLog(@"getUserTrade retjson=%@",retjson);
//             可用资金
            id funds = [retjson objectForKey:@"availableFund"];
            NSString *availableFund;
            if (funds !=nil && ![funds isKindOfClass:[NSNull class]]) {
                double tempFund= [(NSNumber *)[retjson objectForKey:@"availableFund"] doubleValue];
                availableFund=[NSString stringWithFormat:@"%.0f",tempFund];
            }
//            平仓盈亏
            NSString *posiWin = [NSString stringWithFormat:@"%.2f",[[retjson objectForKey:@"positionWin"]floatValue]];
//             手数
//            NSInteger openVol = 0;
            openVol = 0;
//             合约成数
//            NSString *contractVol;
            NSInteger _vol = 0;
            _openAvgPrice = 0;
            
            NSArray *contractsArray = [retjson objectForKey:@"contracts"];
            for (NSDictionary *dic in contractsArray) {
                if (dic!= nil && [dic isKindOfClass:[NSDictionary class]]) {
                    if ([dic[@"concode"] isEqualToString:_conCode]) {
                        //             手数
                        _vol = [dic[@"offset_volume"] integerValue];
                        openVol += _vol;
                        //             开仓价格
                        _openAvgPrice += [dic[@"transaction_price"] doubleValue] *_vol;
                        //             交易方向
                        _tradeType = dic[@"trade_type"];
                        //             合约成数
                        contractVol = dic[@"trade_multiple"];
                    }
                }
            }
            if (openVol > 0) {
                _openAvgPrice /=openVol;
            } else{
                _openAvgPrice = 0;
            }
            
//            NSLog(@"new _openAvgPrice: %.1f",_openAvgPrice);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (openVol >0) {
                    double posiProfit = 0.0f;//持仓盈亏
                    if ([_tradeType isEqualToString:@"1"]) {      //1 看涨
                        self.labelPlus.text = @"多";
                        self.labelClearUp.text =@"平仓";
                        posiProfit = ([_latestPrice doubleValue] - _openAvgPrice) * [contractVol integerValue] * _openAvgPrice;
                    } else if ([_tradeType isEqualToString:@"2"]) {  //2 看跌
                        self.labelClearUp.text =@"空";
                        self.labelPlus.text =@"平仓";
                        posiProfit = (_openAvgPrice - [_latestPrice doubleValue]) * [contractVol integerValue] * _openAvgPrice;
                    }
                    if (posiProfit < 0){   //持仓盈亏
                        self.m_strPosiProfit.textColor = BGGreen_COLOR;
                    } else{
                        self.m_strPosiProfit.textColor = BGRED_COLOR;
                    }
                    self.m_strPosiProfit.text = [NSString stringWithFormat:@"%.1f",posiProfit];
                    
                    self.m_strTradeCount.text = [NSString stringWithFormat:@"%li",openVol];
                } else if (openVol == 0){
                    self.labelPlus.text = @"多";
                    self.labelClearUp.text =@"空";
                    self.m_strTradeCount.text = @"0";
                    
                    //        空
                    self.btnDown.backgroundColor = [UIColor clearColor];
                    self.labelClearUp.textColor = BGGreen_COLOR;
                    self.sellingPrice.textColor = BGGreen_COLOR;
                    self.offeringPriceRight.textColor = BGGreen_COLOR;
//                    _dealingPrice = [self.buyingPrice.text doubleValue];
                    //        多
                    self.btnPlus.backgroundColor = [UIColor clearColor];
                    self.labelPlus.textColor = BGRED_COLOR;
                    self.buyingPrice.textColor = BGRED_COLOR;
                    self.offeringPriceLeft.textColor = BGRED_COLOR;
                    
                }
                self.m_strAvgPrice.text = [NSString stringWithFormat:@"%.1f",_openAvgPrice];
//                风险度   m
                double riskLevel =0;;
                if ([availableFund floatValue] > 0) {
                    riskLevel = (_openAvgPrice * [contractVol integerValue])/[availableFund floatValue]*100;
                } else if ([availableFund floatValue] < 0){
                    riskLevel = (_openAvgPrice * [contractVol integerValue])/[availableFund floatValue]*100;
                    riskLevel = 100 - riskLevel;
                }
                self.m_strRiskLevel.text =[NSString stringWithFormat:@"%.1f%%",riskLevel];
//                平仓盈亏
                self.m_strUnwind.text = posiWin;
//                可用资金
                self.m_strTradeAvailableCnt.text = availableFund;
                //手数
                self.m_strTradeCount.text = [NSString stringWithFormat:@"%li",openVol];
//                _numOfContract = openVol;

                if (openVol == 0) {
                    _numOfContract = 1;
                    self.numTextField.text = [NSString stringWithFormat:@"%li",_numOfContract];
                }
            });
//---------- insert code
        } else if(icode == 217){
            [self loginFuture];
            if (_loginFutureSuccess ) {
                [self getMyTradeInfo];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"GetUserTrade error:%@",error);
    }];
}

-(void)getLeadLatestTrade{
     NSString *vipuid = [TradeUtility LocalLoadConfigFileByKey:@"vipuid" defaultvalue:@"0"];
     NSDictionary *pramDic = @{@"vipUid":vipuid, @"instrument":_conCode};
     NSLog(@"getLeadLatestTrade param: %@",pramDic);
     [TradeUtility requestWithUrl:@"getLeadLatestTrade" httpMethod:@"POST" pramas:[pramDic mutableCopy] fileData:nil success:^(id result) {
         NSDictionary *retdata = (NSDictionary *)result;
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
             if (![retjson isKindOfClass:[NSNull class]]) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.m_strLeadTradeTime.text = [retjson[@"hold_time"] substringWithRange:NSMakeRange(11, 5)];
                     if([retjson[@"trade_type"] integerValue] == 1){
                         self.m_strTradeType.text = @"开多";
                     } else if([retjson[@"trade_type"] integerValue] == 2){
                         self.m_strTradeType.text = @"开空";
                     }
                     self.m_strLeadTradePrice.text = [NSString stringWithFormat:@"%li",[retjson[@"transaction_price"] integerValue]];
                     self.m_strLeadTradeCnt.text =[NSString stringWithFormat:@"%li",[retjson[@"transaction_volume"] integerValue]];
                 });
             }
         }
     } failure:^(NSError *error) {
         NSLog(@"LatestTrade error:%@",error);
     }];
}

#pragma mark -- +/- number of contract button action
- (IBAction)numberAction:(UIButton *)sender {
    if (sender.tag == 100) {
        self.numPlus.selected = YES;
        self.numMinus.selected = NO;
        _numOfContract ++;
    } else {
        self.numPlus.selected = NO;
        self.numMinus.selected = YES;
        if (_numOfContract >0) {
            _numOfContract --;
        }
    }
    [self checkFunds];
    self.numTextField.text =[NSString stringWithFormat:@"%li",_numOfContract];
}

-(void)checkFunds{
    if ([self.m_strTradeAvailableCnt.text doubleValue] > [_latestPrice doubleValue]) {
        NSInteger numToBuy = [self.m_strTradeAvailableCnt.text doubleValue] / [_latestPrice doubleValue];
        if (numToBuy < _numOfContract) {
            _numOfContract = numToBuy;
        }
    } else{
        _numOfContract = 0;
    }
}

#pragma mark -- submit trading methods
- (IBAction)tradingAction:(UIButton *)sender {
    _selectedBtn = sender;
    if (sender.tag ==  200) {
//        多
        self.btnPlus.backgroundColor = BGRED_COLOR;
        self.labelPlus.textColor = [UIColor whiteColor];
        if ([self.labelPlus.text isEqualToString: @"多"]) {
//            买卖方向 1 买 2 卖
            _tradeType = @"1";
            _offsetFlag = @"1";
            _finalTradeType = @"1";
//            self.labelClearUp.text = @"平仓";
            
        } else if ([self.labelPlus.text isEqualToString: @"平仓"]) {
            _offsetFlag = @"2";
            _finalTradeType = @"";
            if ([_tradeType isEqualToString:@"1"]) {   // buy
                _finalTradeType = @"2";
            } else if ([_tradeType isEqualToString:@"2"]) {   // sell
                _finalTradeType = @"1";
            }
//            self.labelPlus.text =@"多";
        }
        self.buyingPrice.textColor = [UIColor whiteColor];
        self.offeringPriceLeft.textColor = [UIColor whiteColor];
//        空
//        self.btnDown.backgroundColor = [UIColor clearColor];
//        self.labelClearUp.textColor = BGGreen_COLOR;
//        self.sellingPrice.textColor = BGGreen_COLOR;
//        self.offeringPriceRight.textColor = BGGreen_COLOR;
        _dealingPrice = [self.buyingPrice.text doubleValue];
    } else {
        self.btnDown.backgroundColor = BGGreen_COLOR;
        self.labelClearUp.textColor = [UIColor whiteColor];
        if ([self.labelClearUp.text isEqualToString: @"空"]) {
            _tradeType = @"2";
            _offsetFlag = @"1";
            _finalTradeType = @"2";
//            self.labelPlus.text = @"平仓";

        } else if ([self.labelClearUp.text isEqualToString: @"平仓"]) {
            _offsetFlag = @"2";
            if ([_tradeType isEqualToString:@"1"]) {   // buy
                _finalTradeType = @"2";
            } else if ([_tradeType isEqualToString:@"2"]) {   // buy
                _finalTradeType = @"1";
            }
//            self.labelClearUp.text = @"空";
        }
        self.sellingPrice.textColor = [UIColor whiteColor];
        _dealingPrice = [self.sellingPrice.text doubleValue];
        self.offeringPriceRight.textColor = [UIColor whiteColor];
        
//        self.btnPlus.backgroundColor = [UIColor clearColor];
//        self.labelPlus.textColor = BGRED_COLOR;
//        self.buyingPrice.textColor = BGRED_COLOR;
//        self.offeringPriceLeft.textColor = BGRED_COLOR;
    }
    [self submitTrading];
}


-(void)updateTheOtherBtn{

    if (_selectedBtn.tag ==  200) {
//        多
        self.btnPlus.backgroundColor = BGRED_COLOR;
        self.labelPlus.textColor = [UIColor whiteColor];
        if ([self.labelPlus.text isEqualToString: @"多"]) {
//         买卖方向 1 买 2 卖
            self.labelClearUp.text = @"平仓";
        }
//        空
        self.btnDown.backgroundColor = [UIColor clearColor];
        self.labelClearUp.textColor = BGGreen_COLOR;
        self.sellingPrice.textColor = BGGreen_COLOR;
        self.offeringPriceRight.textColor = BGGreen_COLOR;
    } else {
        if ([self.labelClearUp.text isEqualToString: @"空"]) {
            self.labelPlus.text = @"平仓";
        }
        self.btnPlus.backgroundColor = [UIColor clearColor];
        self.labelPlus.textColor = BGRED_COLOR;
        self.buyingPrice.textColor = BGRED_COLOR;
        self.offeringPriceLeft.textColor = BGRED_COLOR;
    }
}
-(void)submitTrading{
    NSString *accountcompany = [TradeUtility LocalLoadConfigFileByKey:@"futurename" defaultvalue:@"0"];
    NSString *_finalVol;
     _finalVol = self.numTextField.text;
    NSString *finalPrice = [NSString stringWithFormat:@"%.2f",_dealingPrice];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               _uid, @"uid",
                               accountcompany, @"company",
                               _conCode, @"instrument",
                               _conName,@"conname",
                               finalPrice, @"price",
                               _finalVol,@"volume",
                               _finalTradeType,@"direction",
                               _offsetFlag,@"offsetFlag",
                               _vipuid,@"vipuid",
                               nil];
    
    NSLog(@"postparam=%@",postparam);
    __weak typeof(self) weakSelf = self;
    [TradeUtility requestWithUrl:@"orderInsert" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary *)result;
//        NSLog(@"orderInsert retdata=%@",retdata);
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
//        NSLog(@"orderInsert retcode=%d",icode);
        if(icode == 0){
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
//            NSLog(@"orderInsert retjson=%@",retjson);
            if(retjson != nil){
                NSInteger successNum =[[retjson objectForKey:@"success"]integerValue];
                NSString *tradeDetails;
                if (successNum > 0) {
                    NSString *tradeDirect;
                    if ([_finalTradeType isEqualToString:@"1"]) {
                        tradeDirect = @"买";
                    }
                    if ([_finalTradeType isEqualToString:@"2"]) {
                        tradeDirect = @"卖";
                    }
                    NSString *offsetValue;
                    if ([_offsetFlag isEqualToString:@"1"]) {
                        offsetValue = @"开";
                    }
                    if ([_offsetFlag isEqualToString:@"2"]) {
                        offsetValue = @"平";
                    }
                    tradeDetails = [NSString stringWithFormat:@"%@%@,以%@价格成交%li手,%@%@",_conName,_conCode,finalPrice,successNum,tradeDirect,offsetValue];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateTheOtherBtn];
                    });
                    
                    [self getMyTradeInfo];
                } else {
                    tradeDetails = @"未成交";
                }
//                NSString *ret_orderid = [retjson objectForKey:@"orderId"];
//                int iretaid = [ret_orderid intValue];
//                NSLog(@"iretaid=%d",iretaid);
//                if(iretaid != 0)
//                {
//                  }
                [self showNotfyView:tradeDetails];
            }
        }else if (icode == 217){
            [self loginFuture];
            if (_loginFutureSuccess) {
                [self submitTrading];
            }
        }else if (icode == 218){
            [self showNotfyView:@"交易失败"];
        }else if (icode == 219){
            [self showNotfyView:@"账户无持仓"];
        } else {
            //初始化提示框；
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:retdata[@"re_msg"] preferredStyle:  UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //点击按钮的响应事件；
            }]];
            //弹出提示框；
            [weakSelf presentViewController:alert animated:true completion:nil];
        }
    } failure:^(NSError *error) {
        NSLog(@"orderInsert error:%@",error);
    }];
}

#pragma mark -- textField delegate Methods
- (UIToolbar *)addToolbar{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 35)];
    toolbar.tintColor = [UIColor blueColor];
    toolbar.backgroundColor = [UIColor lightGrayColor];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(textFieldDone)];
    toolbar.items = @[space, bar];
    return toolbar;
}

- (void)textFieldDone{
    _numOfContract = [self.numTextField.text integerValue];
    [self.numTextField resignFirstResponder];
    [UIView animateWithDuration:.3 animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

- (void)textFieldTextDidChange:(NSNotification *)notification{
    UITextField *textField = notification.object;
    if ([textField.text integerValue] >0) {
        self.numTextField.text = textField.text;
        _numOfContract = [self.numTextField.text integerValue];
    }
//    else {
//        self.numTextField.text = @"1";
//        _numOfContract = [self.numTextField.text integerValue];
//    }
}

#pragma mark -- trading notification method
- (void)showNotfyView:(NSString *)tradeDetails{

    if (tradeDetails == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.notfiyLabel.top = -60;
        if ([tradeDetails isEqualToString:@"交易失败"] ||[tradeDetails isEqualToString:@"未成交"] || [tradeDetails isEqualToString:@"账户无持仓"]) {
            if (_selectedBtn.tag == 200) {
                self.btnPlus.backgroundColor = [UIColor clearColor];
                self.labelPlus.textColor = BGRED_COLOR;
                self.buyingPrice.textColor = BGRED_COLOR;
                self.offeringPriceLeft.textColor = BGRED_COLOR;
            } else {
                //        空
                self.btnDown.backgroundColor = [UIColor clearColor];
                self.labelClearUp.textColor = BGGreen_COLOR;
                self.sellingPrice.textColor = BGGreen_COLOR;
                self.offeringPriceRight.textColor = BGGreen_COLOR;
            }
            self.notfiyLabel.text =[NSString stringWithFormat:@"未成交（%@）",tradeDetails];
        } else{
            self.notfiyLabel.text = [NSString stringWithFormat:@"交易成功（%@）",tradeDetails];
        }
    
        [UIView animateWithDuration:.5 animations:^{
            self.notfiyLabel.transform = CGAffineTransformMakeTranslation(0,55);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:2 delay:1 options:UIViewAnimationOptionTransitionNone animations:^{
                //动画执行结束调用的block
                self.notfiyLabel.transform = CGAffineTransformIdentity;
            } completion:nil];
        }];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    });
}

#pragma mark - LeadTradeInforContoller button method
-(void)leadInfoTapped{
    [self enterTradeInfor];
}
-(void)enterTradeInfor{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LiveVipTradingController *LiveVipTradingCtr= [mainStoryboard instantiateViewControllerWithIdentifier:@"LiveVipTradingController"];
    LiveVipTradingCtr.conCode = _conCode;
    [self.navigationController pushViewController:LiveVipTradingCtr animated:YES];
}


#pragma mark -- UDP delegate methods
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    NSLog(@"Message didConnectToAddress %@",[[NSString alloc]initWithData:address encoding:NSUTF8StringEncoding]);
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    NSLog(@"Message didNotConnect %@",error);
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"Message didNotSendDataWithTag %@",error);
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    _marketDataTime = [NSDate date];
    NSLog(@"Message didReceiveData %@ filterContext is %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding],filterContext);
    id retdata = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    if ([retdata isKindOfClass:[NSDictionary class]]) {
        if ([[retdata objectForKey:@"action"] isEqualToString:@"postOrder"]) {
//            NSLog(@"Message didReceiveData %@ filterContext is %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding],filterContext);
            [self processLeadTrade:retdata[@"data"]];
        } else{
//        NSLog(@"JSON dic data: %@",retdata);
//        [_MarketStream addObject:retdata];
            [self processMarketStream:retdata];
        }
    }

}

-(void)processLeadTrade:(NSDictionary *)tmpDic{

    if ([tmpDic[@"concode"] isEqualToString:_conCode]) {

        NSString *tradeTime = [NSString stringWithFormat:@"%@:%@",[tmpDic[@"trade_time"] substringToIndex:2],[tmpDic[@"trade_time"] substringWithRange:NSMakeRange(3, 2)]];
        NSString *leadTradeDirect;
        if ([tmpDic[@"direction"] integerValue] == 1) {
            leadTradeDirect = @"多";
        } else if ([tmpDic[@"direction"] integerValue] == 2){
            leadTradeDirect = @"空";
        }
        NSString *leadTradeTyp;
        if ([tmpDic[@"transaction_state"] integerValue] == 2) {
            leadTradeTyp = [NSString stringWithFormat:@"开%@",leadTradeDirect];
        } else if ([tmpDic[@"transaction_state"] integerValue] == 4 ||[tmpDic[@"transaction_state"] integerValue] == 5){
            leadTradeTyp = @"平仓";

        }
        NSInteger leadContractVol = [tmpDic[@"total_volume"] integerValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.m_strLeadTradeTime.text =tradeTime;
            self.m_strTradeType.text =leadTradeTyp;
            
            self.m_strLeadTradePrice.text =[NSString stringWithFormat:@"%.1f",[tmpDic[@"transaction_price"] floatValue]];
            self.m_strLeadTradeCnt.text = [NSString stringWithFormat:@"%li", [tmpDic[@"transaction_volume"] integerValue]];
            
            if (leadContractVol == 0) {
                self.m_strContractState.text = @"已平仓";
            } else{
                self.m_strContractState.text = @"持仓中";
            }
            [UIView transitionWithView:self.leadBgView duration:1 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
                [self.leadBgView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
                
            } completion:nil];
    
        });
    } else{
        UIImage *img=[UIImage imageNamed:@"tradeRedIcon"];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.leadOtherTrade.image = img;
        });
    }
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
//    NSLog(@"Message didSendDataWithTag:%ld",tag);
}

-(void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"Message withError %@",error);
}

-(void)processMarketStream:(NSDictionary *)tmpDic{
//    NSDictionary *tmpDic = mktDic;
    NSString *dateStr = [NSString stringWithFormat:@"%@%@",tmpDic[@"nTradeDay"],tmpDic[@"nTime"]];
    //时间戳比较 当前比之前时间数据大 继续做业务 更新业务
    if ([_lastTimeStamp compare:dateStr] == NSOrderedAscending ||[_lastTimeStamp compare:dateStr] == NSOrderedSame) {
        _lastTimeStamp = dateStr;
        _lastActionDay =tmpDic[@"nActionDay"];
    } else {
        //自然日发生改变 则继续处理
        if ([_lastActionDay compare:tmpDic[@"nActionDay"]] == NSOrderedAscending) {
            _lastTimeStamp = dateStr;
            _lastActionDay =tmpDic[@"nActionDay"];
        } else{ //数据来晚了 则丢弃
            return;
        }
    }
    
    if([tmpDic isKindOfClass: [NSDictionary class]] && tmpDic.count >0 ){
        NSMutableDictionary *_valueDic =[NSMutableDictionary dictionary];
        double _tick = [tmpDic[@"tick"] doubleValue]; //保留几位小数
        NSInteger _decNum = 0;
        if (_tick >= 10000) {
            _decNum = 0;
        } else if (_tick >= 1000){
            _decNum = 1;
        } else if (_tick >= 100){
            _decNum = 2;
        } else {
            _decNum = 3;
        }
        //获取最新数据 除以一万 所有都有
        double lastPrice = [tmpDic[@"nPrice"] doubleValue]/10000.0f;
//            NSLog(@"最新:%.2f",lastPrice);
//        NSString *lastNewPrice = [NSString stringWithFormat:@"%.1f",lastPrice];
        NSString *lastNewPrice = [self formatDecimalWithNum:lastPrice decimal:_decNum];
        _latestPrice = lastNewPrice;
        [_valueDic setValue:lastNewPrice forKey:@"lastPrice"];
//              NSLog(@"涨跌：%.2f",lastPrice);
        double _preSettle =[tmpDic[@"PreSettlementPrice"] doubleValue] / 10000.0f;
        double _upDown = lastPrice - _preSettle;
        double _absUpDown = _upDown;
//            NSLog(@"涨跌 : %.2f",_upDown);
        NSString *_upDwn = nil;
        if (_upDown >= 0) {
            _upDwn = [NSString stringWithFormat:@"+%.1f",_upDown];
        }else {
            _absUpDown = -1 * _upDown;
            _upDwn = [NSString stringWithFormat:@"%.1f",_upDown];
        }

        if (_maxTradePrice < _preSettle + _absUpDown) {
            _maxTradePrice = _preSettle + _absUpDown;
//                _maxTradePrice =92530.0f + _absUpDown;
        }
        
        [_valueDic setValue:@(_upDown) forKey:@"updown"];
        //                      涨跌率
        float _upDownRate = 0.0f;
        if (_preSettle > 0) {
            _upDownRate = (lastPrice - _preSettle) / (float)_preSettle *100;
        }
//            NSLog(@"涨跌率 : %.2f",_upDownRate);
        NSString *_upDwnRate = nil;
        if (_upDownRate >= 0 ) {
            _upDwnRate = [NSString stringWithFormat:@"+%.2f%%",_upDownRate];
        }else {
            _upDwnRate = [NSString stringWithFormat:@"%.2f%%",_upDownRate];
        }
        [_valueDic setValue:_upDwnRate forKey:@"updownrate"];
//        bid
//        NSString *bid = [NSString stringWithFormat:@"%.1f", [tmpDic[@"Bid"] longValue]/10000.0f];
        NSString *bid = [self formatDecimalWithNum:[tmpDic[@"Bid"] doubleValue]/10000.0f decimal:_decNum];
        
//            NSLog(@"多：%@",bid);
        [_valueDic setValue:bid forKey:@"Bid"];
//        ask
//        NSString *ask = [NSString stringWithFormat:@"%.1f", [tmpDic[@"Ask"] longValue]/10000.0f];
        NSString *ask = [self formatDecimalWithNum:[tmpDic[@"Ask"] doubleValue]/10000.0f decimal:_decNum];
 
//            NSLog(@"空：%@",bid);
        [_valueDic setValue:ask forKey:@"Ask"];
//        持仓盈亏
        double posiProfit = 0.0f;
        if (_openAvgPrice > 0 ) {
            if ([_tradeType isEqualToString:@"1"]) {  //多
                posiProfit = lastPrice - _openAvgPrice;
            } else if ([_tradeType isEqualToString:@"2"]) {//空
                posiProfit = _openAvgPrice - [_latestPrice doubleValue];
            }
        }
        posiProfit *= openVol * [contractVol floatValue];
        [_valueDic setValue:@(posiProfit) forKey:@"PosiProfit"];
        
        NSString *askVolume = [NSString stringWithFormat:@"%ld", [tmpDic[@"AskVolume"] longValue]];
        [_valueDic setValue:askVolume forKey:@"AskVolume"];
        
        NSString *bidVolume = [NSString stringWithFormat:@"%ld", [tmpDic[@"BidVolume"] longValue]];
        [_valueDic setValue:bidVolume forKey:@"BidVolume"];
        [_valueDic setValue:@(posiProfit) forKey:@"PosiProfit"];
        [self showDataAction:_valueDic];   //回到主线程 更新界面
    
        NSString *newMinute =[tmpDic[@"nTime"] substringToIndex:4];
        if (ABS([newMinute integerValue] - [_lastMinute integerValue]) >= 2 ) { //折线图数据和时实大于2分钟 则重新请求折线图历史数据
            if (!([_lastHistActionDay compare:tmpDic[@"nActionDay"]] == NSOrderedAscending)) {
                [self getHistoryMarket];
            }
        }
        if ([newMinute integerValue] - [_lastMinute integerValue] <=1){//小于一分钟 则要进行显示 画折线图
            _lastHistActionDay =tmpDic[@"nActionDay"];
            NSDictionary *itemDic = @{@"minute":newMinute,@"avgPrice":[NSString stringWithFormat:@"%.2f",_preSettle],@"price":[NSString stringWithFormat:@"%.2f",lastPrice],@"volume":@"0"};
            YYTimeLineModel *model = [[YYTimeLineModel alloc]initWithDict:itemDic];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_lastMinute isEqualToString:newMinute]) {
                    [self.stockDatadict[@"minutes"] removeLastObject];
                }
                [self.stockDatadict[@"minutes"] addObject:model];
                _lastMinute = newMinute;
                [_stock draw];  //重新绘制曲线图
            });
        }
    }
}

-(void)showDataAction:(NSMutableDictionary *)dic{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.buyingPrice.text =dic[@"Ask"];
        self.sellingPrice.text =dic[@"Bid"];
//        if ([dic[@"updown"] rangeOfString:@"-"].location != NSNotFound) {
//        double _upDownNum =[dic[@"updown"] doubleValue];
    
        self.m_strLastPrice.text =dic[@"lastPrice"];
        self.m_strWinLabel.text =[NSString stringWithFormat:@"%.1f/%@", [dic[@"updown"] doubleValue],dic[@"updownrate"]] ;

        if ([dic[@"PosiProfit"] doubleValue] < 0){
            self.m_strPosiProfit.textColor = BGGreen_COLOR;
        } else{
            self.m_strPosiProfit.textColor = BGRED_COLOR;
        }
        self.m_strPosiProfit.text = [NSString stringWithFormat:@"%.1f",[dic[@"PosiProfit"] doubleValue]];
    
        if ([dic[@"updown"] doubleValue] <0){
            [self.m_strWinLabel setTextColor:BGGreen_COLOR];
            [self.m_strLastPrice setTextColor:BGGreen_COLOR];
        } else{
            [self.m_strWinLabel setTextColor:BGRED_COLOR];
            [self.m_strLastPrice setTextColor:BGRED_COLOR];
        }
        self.offeringPriceLeft.text =dic[@"AskVolume"];
        self.offeringPriceRight.text =dic[@"BidVolume"];
    });
    
}
-(NSString *)formatDecimalWithNum:(double)doubleNumber decimal:(NSInteger)decimalNum{
    
//    int decimalNum = 3; //保留的小数位数
//    
//    double doubleNumber = 1.230;
    
//    NSNumberFormatter *nFormat = [[NSNumberFormatter alloc] init];
//    
//    [nFormat setNumberStyle:NSNumberFormatterNoStyle];
//    
//    [nFormat setMaximumFractionDigits:decimalNum];
//    NSLog(@"deciminal: %li result:%@",decimalNum, [nFormat stringFromNumber:@(doubleNumber)]);
    NSString* format = [NSString stringWithFormat:@"%%.%lif",decimalNum];
    NSString* resultStr = [NSString stringWithFormat:format,doubleNumber];
//    NSLog(@"deciminal: %li result:%@",decimalNum, resultStr);
    return resultStr;
}


#pragma mark --- login Future Method
-(void)loginFuture{ //主动登录期货公司账号
    NSDictionary *pramDic = @{@"uid":_uid};
    [TradeUtility requestWithUrl:@"loginFuture" httpMethod:@"POST" pramas:[pramDic mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary *)result;
        NSLog(@"login future retdata=%@",retdata);
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"login future retcode=%d",icode);
        if(icode == 0){
            _loginFutureSuccess = YES;
            [self getMyTradeInfo];
//            [self subscribeMarket];
//            [self sendHeartBeat:NO];
        } else if(icode == 212){
            _loginFutureSuccess = NO;
//            "re_code" = 212;

            [self futureAccountError];
        }else if(icode == 221){
            [self subscribeMarket];
            [self sendHeartBeat:NO];
        }else{
            _loginFutureSuccess = NO;
        }
    } failure:^(NSError *error) {
        NSLog(@"loginFuture error:%@",error);
    }];
}
#pragma mark -- bind future account Methods
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

#pragma mark --- keyboard show method
- (void)keyBoardShow:(NSNotification *)notification{
    //获取键盘的高度
//    NSLog(@"%@",notification.userInfo);
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat height = rect.size.height;
    [self.view bringSubviewToFront:_tradingView];
    _tradingView.backgroundColor = [UIColor blackColor];
    //设置工具栏的
    [UIView animateWithDuration:.3 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, -height);
    }];
}
-(void)setModel:(MarketModel *)model{
    _model = model;
    _conName = _model.conname;
    _conCode = _model.concode;
    _preSettlementPrice = _model.preSettlementPrice;
    _maxTradePrice = [_model.preSettlementPrice doubleValue];
    NSLog(@"con name: %@",_conName);
    NSLog(@"con code: %@",_conCode);
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"notification removed");
}
//resize right barButton Item Images
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

-(void)setupButtons{
    self.btnPlus.layer.cornerRadius = self.btnPlus.width/2.0;
    self.btnPlus.layer.masksToBounds = YES;
    self.btnPlus.layer.borderColor = [[UIColor redColor]CGColor];
    self.btnPlus.layer.borderWidth = 3.0f;
    
    self.btnDown.layer.cornerRadius = self.btnDown.width/2.0;
    self.btnDown.layer.masksToBounds = YES;
    self.btnDown.layer.borderColor = [[UIColor greenColor]CGColor];
    self.btnDown.layer.borderWidth = 3.0f;
    
    self.numPlus.selected = YES;
    [self.numPlus setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.numPlus setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    self.numMinus.selected = NO;
    [self.numMinus setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.numMinus setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
}


#pragma mark - Notification Method
- (void)futureLoginNotification:(NSNotification *)notification{
    NSDictionary * dic = (NSDictionary *)notification.object;
    if ([dic[@"showNextCtr"] isEqualToString:@"1"]){
        if (self.timer == nil) {
            [self subscribeMarket];
            [self sendHeartBeat:NO];
        }
    }
}

#pragma mark --- market methods
- (void)initStockView {
    
    CGRect rect = self.stockContainerView.bounds;
    rect.size.height = kScreenHeight - 228 - 64 - 3;
    if ([_vipuid isEqualToString:@"-1"]) {
       rect.size.height = kScreenHeight - 228 - 64 - 3 +44;
    }
    
    rect.size.width = kScreenWidth;
    YYStock *stock = [[YYStock alloc]initWithFrame:rect dataSource:self];
    _stock = stock;
    stock.mainView.frame = rect;
    [self.stockContainerView addSubview:stock.mainView];
    //添加单击监听
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stock_topBarToggle)];
    tap.numberOfTapsRequired = 1;
    [self.stock.containerView addGestureRecognizer:tap];
    _hideTopBar = NO;
    [self.stock.containerView.subviews setValue:@1 forKey:@"userInteractionEnabled"];
}

-(void)stock_topBarToggle{
    _hideTopBar = !_hideTopBar;
    _stock.topBarHidden = _hideTopBar;
//    NSLog(@"hide: %@",_stock.topBarHidden == 0? @"yes":@"no");
}

#pragma mark --- YYStock delegate methods
/*******************************************股票数据源代理*********************************************/
-(NSArray <NSString *> *) titleItemsOfStock:(YYStock *)stock {
    return self.stockTopBarTitleArray;
}

-(NSArray *) YYStock:(YYStock *)stock stockDatasOfIndex:(NSInteger)index {
    return index < self.stockDataKeyArray.count ? self.stockDatadict[self.stockDataKeyArray[index]] : nil;
}

-(YYStockType)stockTypeOfIndex:(NSInteger)index {
    return index == 0 ? YYStockTypeTimeLine : YYStockTypeLine;
}

- (id<YYStockFiveRecordProtocol>)fiveRecordModelOfIndex:(NSInteger)index {
    return self.fiveRecordModel;
}

- (BOOL)isShowfiveRecordModelOfIndex:(NSInteger)index {
    return self.isShowFiveRecord;
}
/*******************************************getter*********************************************/
- (NSMutableDictionary *)stockDatadict {
    if (!_stockDatadict) {
        _stockDatadict = [NSMutableDictionary dictionary];
    }
    return _stockDatadict;
}

- (NSArray *)stockDataKeyArray {
    if (!_stockDataKeyArray) {
        _stockDataKeyArray = @[@"minutes"];
    }
    return _stockDataKeyArray;
}

- (NSArray *)stockTopBarTitleArray {
    if (!_stockTopBarTitleArray) {
        _stockTopBarTitleArray = @[@"分时图"];
    }
    return _stockTopBarTitleArray;
}

- (NSString *)getMinuteNow {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hhmm";
    return [dateFormatter stringFromDate:[NSDate date]];
}

-(NSDictionary *)leadTradeDic{
    if (_leadTradeDic == nil) {
        _leadTradeDic =[NSDictionary dictionary];
    }
    return _leadTradeDic;
}

//-(NSMutableDictionary *)valueDic{
//    if (_valueDic == nil) {
//        _valueDic =[NSMutableDictionary dictionary];
//    }
//    return _valueDic;
//}

-(NSMutableArray *)modelArr{
    if (_modelArr == nil) {
        _modelArr =[NSMutableArray array];
    }
    return _modelArr;
}

-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];//即使没有显示在window上，也不会自动的将self.view释放。注意跟ios6.0之前的区分
    // Add code to clean up any of your own resources that are no longer necessary.
    // 此处做兼容处理需要加上ios6.0的宏开关，保证是在6.0下使用的,6.0以前屏蔽以下代码，否则会在下面使用self.view时自动加载viewDidUnLoad
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        //需要注意的是self.isViewLoaded是必不可少的，其他方式访问视图会导致它加载，在WWDC视频也忽视这一点。
        if (self.isViewLoaded && !self.view.window)// 是否是正在使用的视图
        {
            // Add code to preserve data stored in the views that might be
            // needed later.
            // Add code to clean up other strong references to the view in
            // the view hierarchy.
            self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
        }
    }
}
@end

//
//  MarketViewController.m
//  RTradeDemo
//
//  Created by iMac on 16/12/26.
//  Copyright © 2016年 administrator. All rights reserved.
// 左侧行情

#import "MarketViewController.h"
#import "MarketTableViewCell.h"
#import "MarketRealTimeModel.h"
#import "MarketSelectionViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "MarketModel.h"
#import "RegisterAccountController.h"
#import "LiveVipLivingController.h"
#import "SlideNavigationController.h"
#import "UDPManager.h"


@interface MarketViewController ()<UITableViewDelegate,UITableViewDataSource,GCDAsyncUdpSocketDelegate>{
    NSTimer *_marketTimer;   //market timer
    NSTimer *_showDataTimer; //data display timer
    NSString *_marketReqString;  //string of contract codes
//    GCDAsyncUdpSocket *udpSocket;
    NSString *_uid;
    NSMutableArray *_MarketStream;  //market data
    NSDictionary *_itemData;       //tableview selected item datasource
    NSMutableDictionary *_contractIndexDic;
    NSMutableDictionary *_contractTimeDic;
    NSString *_preSettlementPrice;   //结算价
    NSInteger _numOfVisiableRow;
}
@property (strong, nonatomic) IBOutlet UIView *searchBarView;
@property (strong, nonatomic) UIButton *searchButton;//搜索框
@property (strong, nonatomic) IBOutlet UITableView *marketTableView;
@property (strong, nonatomic) NSMutableArray *contractArray;
@property (strong, nonatomic) NSMutableArray *contractCodeArray;//backup Array
@property (nonatomic, copy) MarketModel *dataModel;

@end
static NSString * const reuseIdentifier = @"MarketCell";
@implementation MarketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    // Do any additional setup after loading the view.
    self.title=@"自选合约";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets=NO;
    _uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];

    //设置左键
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.marketTableView.delegate = self;
    self.marketTableView.dataSource = self;
    self.marketTableView.rowHeight = 55;
    _numOfVisiableRow  = (kScreenHeight -64 - 44)/55 +1;
      NSLog(@"_numOfVisiableRow :%li",_numOfVisiableRow);
    [self initSearchButton];
    [self loadSubscribedContracts];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    NSLog(@"timer is valid: %@",_marketTimer.isValid ? @"YES":@"NO");
    if (_marketTimer.isValid == NO && _marketReqString !=nil && _marketReqString.length > 0 ) {
        [self subscribeNewMarketData];
        _marketTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
    NSLog(@"MarketViewController appeared");
}

//滑动隐藏导航栏
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //关闭定时器
    if (_marketTimer.isValid == YES) {
        NSLog(@"MarketViewController timer invalidated");
        [_marketTimer invalidate];
        _marketTimer = nil;
    }
    self.navigationController.navigationBar.hidden = NO;
}


-(void)loadSubscribedContracts{
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               nil];
    NSLog(@"postparam=%@",postparam);
    [TradeUtility requestWithUrl:@"getPositionContract" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"getPositionContract retcode=%d",icode);
        NSLog(@"getPositionContract re_json=%@",[retdata objectForKey:@"re_json"]);
        if(icode == 0){
            self.contractArray = [[retdata objectForKey:@"re_json"][@"ins_list"] mutableCopy];
            if (self.contractArray.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.marketTableView reloadData];
                });
                [self getRealTimeData];  //get market data
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"getPositionContract error: %@",error);
    }];
}

-(void)getRealTimeData{
    _marketReqString =nil;
    if (self.contractCodeArray.count >0) {
        [self.contractCodeArray removeAllObjects];
    }
    _contractIndexDic = [NSMutableDictionary dictionary];
    _contractTimeDic = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < self.contractArray.count; i++) {
        NSDictionary *dic =self.contractArray[i];
        //record concode order
        [_contractIndexDic setObject:[NSString stringWithFormat:@"%li",i] forKey:dic[@"concode"]];
        //record the timestamp of the latest market data for each contract
        [_contractTimeDic setObject:[NSString stringWithFormat:@"0"] forKey:dic[@"concode"]];
        [self.contractCodeArray addObject:dic[@"concode"]];
    }

    [self getContractCodeString:0];
    NSLog(@"************ %@",_marketReqString);
  
    
    //订阅行情
    [self subscribeNewMarketData];
//    //发送心跳
    [self timerAction];
//    NSDictionary *beatDic = @{@"flag":@"2",@"id_list":@"",@"uid":_uid};
//    NSData *beatData = [NSJSONSerialization dataWithJSONObject:beatDic options:NSJSONWritingPrettyPrinted error:nil];
//    //    NSLog(@"timer param:%@",[[NSString alloc]initWithData:beatData encoding:NSUTF8StringEncoding]);
//    [udpSocket sendData:beatData toHost:serviceAddress port:servicePort withTimeout:-1 tag:2];
//    _MarketStream = [NSMutableArray array];
//    NSError *error = nil;
//    [udpSocket beginReceiving:&error];
//    
//    _marketTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    //    _showDataTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(showDataAction) userInfo:nil repeats:YES];
}

-(void)subscribeNewMarketData{
    //订阅行情
    NSDictionary *marketDic = @{@"flag":@"0",@"id_list":_marketReqString,@"uid":_uid};
    //    NSDictionary *marketDic = @{@"flag":@"0",@"id_list":@"ni1701",@"uid":_uid};
    NSData *marketData = [NSJSONSerialization dataWithJSONObject:marketDic options:NSJSONWritingPrettyPrinted error:nil];
    UDPManager *udpManager = [UDPManager shareManager];
    [udpManager.udpSocket setDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [udpManager.udpSocket sendData:marketData toHost:serviceAddress port:servicePort withTimeout:-1 tag:0];
    
    NSError *error = nil;
    [udpManager.udpSocket beginReceiving:&error];
}

-(void)timerAction{
    //发送心跳
    NSDictionary *beatDic = @{@"flag":@"2",@"id_list":@"",@"uid":_uid};
    NSData *beatData = [NSJSONSerialization dataWithJSONObject:beatDic options:NSJSONWritingPrettyPrinted error:nil];
    //    NSLog(@"timer param:%@",[[NSString alloc]initWithData:beatData encoding:NSUTF8StringEncoding]);
    UDPManager *udpManager = [UDPManager shareManager];
    [udpManager.udpSocket sendData:beatData toHost:serviceAddress port:servicePort withTimeout:-1 tag:2];
}

-(void)enterForeground{
    if (_marketTimer.isValid == NO && _marketReqString !=nil && _marketReqString.length > 0 ) {
        //订阅行情
        [self subscribeNewMarketData];
        //发送心跳
        _marketTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
}

//setup search button interface
- (void)initSearchButton{
    self.searchButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 8, CGRectGetWidth(self.view.bounds) -30, 28)];
    UILabel *txtLabel = [[UILabel alloc]initWithFrame:self.searchButton.bounds];
    txtLabel.backgroundColor = [UIColor whiteColor];
    txtLabel.textAlignment = NSTextAlignmentCenter;
    txtLabel.font = [UIFont systemFontOfSize:15];
    txtLabel.text = @"输入合约名称或代码检索";
    txtLabel.textColor = [UIColor grayColor];
    txtLabel.layer.cornerRadius = 3;
    txtLabel.layer.masksToBounds = YES;
    [self.searchButton addSubview:txtLabel];
    [self.searchBarView addSubview:self.searchButton];
    [self.searchButton addTarget:self action:@selector(searchBtnAction) forControlEvents:UIControlEventTouchUpInside];
}

-(void)searchBtnAction{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    MarketSelectionViewController *MarketSelectionCtr = [mainStoryboard instantiateViewControllerWithIdentifier:@"MarketSelectionCtr"];
    [self.navigationController pushViewController:MarketSelectionCtr animated:YES];
}
//concatenate ContractCode strings to send heartbeat
-(void)getContractCodeString:(NSInteger)startRowNum{
    NSMutableArray *tmpArray = [NSMutableArray array];
    NSInteger endRow = (startRowNum + _numOfVisiableRow > self.contractCodeArray.count -1) ?  self.contractCodeArray.count -1 : (startRowNum + _numOfVisiableRow);
    for (NSInteger i=startRowNum; i<=endRow; i++) {
        [tmpArray addObject:[self.contractCodeArray objectAtIndex:i]];
    }
    NSSet *set = [NSSet setWithArray:tmpArray];
    NSArray * array2 = [set allObjects];
    _marketReqString = [array2 componentsJoinedByString:@";"];
}

#pragma mark -- TableView delegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.contractArray.count >0) {
        return self.contractArray.count;
    } else{
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MarketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    MarketRealTimeModel *model = [[MarketRealTimeModel alloc]init];
    _itemData = self.contractArray[indexPath.row];
    model.contractName = [_itemData objectForKey:@"conname"];
    model.contractCode = [_itemData objectForKey:@"concode"];
    model.contractPrice = [_itemData objectForKey:@"convalue"];
    model.contractUpDownRate = [_itemData objectForKey:@"updownrate"];
    model.contractWarehoused = [_itemData objectForKey:@"TotalOpenInterest"];

    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [TradeUtility LocalSaveConfigFileByKey:@"vipuid" value:@"-1"];
    [TradeUtility LocalSaveConfigFileByKey:@"vipnickname" value:@"0"];
    _itemData = [self.contractArray objectAtIndex:indexPath.row];
    //    NSLog(@"row selected: %@",_itemData);
    NSString *accountid = [TradeUtility LocalLoadConfigFileByKey:@"accountid" defaultvalue:@"0"];
    int iaccountid = [accountid intValue];
    //    NSLog(@"********* account id: %i",iaccountid);
    if(iaccountid == 0){
        [self bindAccount];
    } else {
        [self bindAccountDone];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"%.2f",scrollView.contentOffset.y);
    if(scrollView.contentOffset.y > 30) {
        NSInteger startRow = scrollView.contentOffset.y / 55;
        [self getContractCodeString:startRow];
        [self subscribeNewMarketData];
        NSLog(@"start row: %li",startRow);
    } else if(scrollView.contentOffset.y < 0) {
        [self getContractCodeString:0];
        [self subscribeNewMarketData];
    }
}

#pragma mark -- Bind future account methods
-(void)bindAccount{
    //bind account
    //    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisterAccountController *registerAccountController = [mainStoryboard instantiateViewControllerWithIdentifier:@"RegisterAccountController"];
    registerAccountController.nextViewController = @"LiveVipLivingController";
    registerAccountController.itemData = _itemData;
    registerAccountController.modalTransitionStyle =UIModalTransitionStyleCoverVertical;
    
    [self.navigationController presentViewController:registerAccountController animated:YES completion:nil];
    //    [appRootVC presentViewController:registerAccountController animated:YES completion:^{
    //        NSLog(@"Present Modal View");
    //    }];
}


-(void)bindAccountDone{
    NSString *accountid = [TradeUtility LocalLoadConfigFileByKey:@"accountid" defaultvalue:@"0"];
    int iaccountid = [accountid intValue];
    NSLog(@"********* account id: %i",iaccountid);
    
    if(iaccountid >= 0){
        _dataModel = [[MarketModel alloc]init];
        _dataModel.concode =[_itemData objectForKey:@"concode"];
        _dataModel.conname =[_itemData objectForKey:@"conname"];
        _dataModel.preSettlementPrice = [_itemData objectForKey:@"PreSettlementPrice"];
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LiveVipLivingController *liveVipLivingViewCtr = [mainStoryboard instantiateViewControllerWithIdentifier:@"LiveVipLivingController"];
        liveVipLivingViewCtr.model = _dataModel;
        [[SlideNavigationController sharedInstance] pushViewController:liveVipLivingViewCtr animated:self.slideOutAnimationEnabled];
    }
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
    
    NSLog(@"Message didReceiveData %@ filterContext is %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding],filterContext);
    id retdata = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    if ([retdata isKindOfClass:[NSArray class]]) {
        //        NSLog(@"JSON array data: %@",retdata);
        NSArray *topLevelArray = retdata;
        NSDictionary *_dic = topLevelArray[0];
        [_MarketStream addObject:_dic];
    } else if ([retdata isKindOfClass:[NSDictionary class]]) {
        //        NSLog(@"JSON dic data: %@",retdata);
        //        [_MarketStream addObject:retdata];
        [self processMarketStream:retdata];
    }
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    //    NSLog(@"Message didSendDataWithTag:%ld",tag);
}

-(void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"Message withError %@",error);
}


-(void)processMarketStream:(NSDictionary *)mktDic{
    NSDictionary *tmpDic = mktDic;
    if([tmpDic isKindOfClass: [NSDictionary class]] && tmpDic.count >0 ){
        double _tick = [tmpDic[@"tick"] doubleValue];
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
        NSString *retConCode = tmpDic[@"ins_id"];
        NSString *dateStr = [NSString stringWithFormat:@"%@%@",tmpDic[@"nTradeDay"],tmpDic[@"nTime"]];
        NSString *tempDate = dateStr;
        
        if ([tempDate compare:[_contractTimeDic objectForKey:retConCode]] == NSOrderedAscending) {
            NSInteger _oldHour =[[[_contractTimeDic objectForKey:retConCode] substringWithRange:NSMakeRange(8, 2)]integerValue];
            NSInteger _newHour =[[tempDate substringWithRange:NSMakeRange(8, 2)]integerValue];
            if (!(_oldHour >= 21 && _oldHour <=23 && _newHour >=00 && _newHour <=15)) {return;}
        }
        [_contractTimeDic setObject:dateStr forKey:retConCode];
        
        NSInteger _index = [[_contractIndexDic objectForKey:retConCode] integerValue];
        
        NSMutableDictionary *valueDic = [NSMutableDictionary dictionary];
        [valueDic setObject:retConCode forKey:@"concode"];
        NSString *_conNM = self.contractArray[_index][@"conname"];
        [valueDic setObject:_conNM forKey:@"conname"];
        double lastPrice = [tmpDic[@"nPrice"] doubleValue];
        NSString *lastNewPrice = [self formatDecimalWithNum:lastPrice/10000.0f decimal:_decNum];
//        [NSString stringWithFormat:@"%.1f",lastPrice/10000.0f];
        [valueDic setValue:lastNewPrice forKey:@"convalue"];
        //            结算价
        double preSettlementPrice = [tmpDic[@"PreSettlementPrice"] doubleValue];
        //                       涨跌
//        double _upDown = (lastPrice - preSettlementPrice) / 10000.0f;
//        //            NSLog(@"涨跌 : %.2f",_upDown);
//        NSString *_upDwn = nil;
//        if (_upDown >= 0) {
//            _upDwn = [NSString stringWithFormat:@"+%.1f",_upDown];
//        }else {
//            _upDwn = [NSString stringWithFormat:@"%.1f",_upDown];
//        }
//        [valueDic setValue:_upDwn forKey:@"updown"];
        //                      涨跌率
        //            NSLog(@"nprice : %.2f",nPrice);
        
        _preSettlementPrice = [NSString stringWithFormat:@"%.1f",preSettlementPrice/10000.0f];
        
        NSString *_upDwnRate = nil;
        if ([tmpDic[@"PreSettlementPrice"] integerValue] > 0) {
            double _upDownRate = (lastPrice - preSettlementPrice) / (double)preSettlementPrice *100;
//            if (_upDownRate < 0) {
//                _upDownRate *= -1;
//            }
            _upDwnRate = [NSString stringWithFormat:@"%.2f%%",_upDownRate];
        } else {
            _upDwnRate = @"0";
        }
        [valueDic setValue:_upDwnRate forKey:@"updownrate"];
        //                      盈利率
        //--->要修改              [valueDic setValue:_upDwnRate forKey:@"updownrate"];
        //                       bid
//        NSString *bid = [NSString stringWithFormat:@"%.1f", [tmpDic[@"Bid"] longValue]/10000.0f];
//        [valueDic setValue:bid forKey:@"Bid"];
//        NSString *bidVolume = [NSString stringWithFormat:@"%ld", [tmpDic[@"BidVolume"] longValue]];
//        [valueDic setValue:bidVolume forKey:@"BidVolume"];
//        //                      ask
//        NSString *ask = [NSString stringWithFormat:@"%.1f", [tmpDic[@"Ask"] longValue]/10000.0f];
//        [valueDic setValue:ask forKey:@"Ask"];
//        NSString *askVolume = [NSString stringWithFormat:@"%ld", [tmpDic[@"AskVolume"] longValue]];
//        [valueDic setValue:askVolume forKey:@"AskVolume"];
        //                      wareHouse
//        NSString *openInterest = [NSString stringWithFormat:@"%ld", [tmpDic[@"OpenInterest"] longValue]];
//        [valueDic setValue:openInterest forKey:@"OpenInterest"];
        NSString *totalInterest = [NSString stringWithFormat:@"%ld", [tmpDic[@"TotalOpenInterest"] longValue]];
        //            NSLog(@"TotalOpenInterest:%@", totalInterest);
        [valueDic setValue:totalInterest forKey:@"TotalOpenInterest"];
        
        [self.contractArray replaceObjectAtIndex:_index withObject:valueDic];
        //            [_backUpData addObject:valueDic];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_index inSection:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.marketTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    //1.根据偏移量判断一下应该显示第几个item
    CGFloat offSetX = targetContentOffset->x;
    if (offSetX > 0) {
        NSLog(@"向下");
    }
    
//    CGFloat itemWidth = 80;
//    
//    //item的宽度+行间距 = 页码的宽度
//    NSInteger pageWidth = itemWidth + 10;
//    
//    //根据偏移量计算是第几页
//    NSInteger pageNum = (offSetX+pageWidth/2)/pageWidth;
//    
//    //2.根据显示的第几个item，从而改变偏移量
//    targetContentOffset->x = pageNum*pageWidth;
    
}

-(NSMutableArray *)contractArray{
    if (_contractArray == nil) {
        _contractArray = [NSMutableArray array];
    }
    return _contractArray;
}


-(NSMutableArray *)contractCodeArray{
    if (_contractCodeArray== nil) {
        _contractCodeArray = [NSMutableArray array];
    }
    return _contractCodeArray;
}

//动态显示小数位数
-(NSString *)formatDecimalWithNum:(double)doubleNumber decimal:(NSInteger)decimalNum{
    NSString* format = [NSString stringWithFormat:@"%%.%lif",decimalNum];
    NSString* resultStr = [NSString stringWithFormat:format,doubleNumber];
    //    NSLog(@"deciminal: %li result:%@",decimalNum, resultStr);
    return resultStr;
}

@end

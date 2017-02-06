//
//  LiveVipinfoController.m
//  RTradeDemo
//
//  Created by administrator on 16/7/2.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "LiveVipinfoController.h"
#import "CellLiveVipinfoCell.h"
#import "LiveVipIndexController.h"
#import "LineProgressView.h"
#import "RegisterAccountController.h"
#import "GCDAsyncUdpSocket.h"
#import "MarketModel.h"
#import "LiveVipLivingController.h"
#import "UDPManager.h"
//领单者持仓合约信息

//#define serviceAddress @"139.196.203.229"
//#define servicePort 9050
////背景红色
//#define BGRED_COLOR [UIColor colorWithRed:216.0/255.0 green:40.0/255.0 blue:61.0/255.0 alpha:1.0]
////背景红色
//#define BGGreen_COLOR [UIColor colorWithRed:3.0/255.0 green:152.0/255.0 blue:52.0/255.0 alpha:1.0]

@interface LiveVipinfoController ()<GCDAsyncUdpSocketDelegate>{
    float _tbHeight;
    float _lineViewHeight;
    NSDictionary *_itemData;
    NSTimer *_marketTimer;
    NSTimer *_receiveDataTimer;
    NSString *_marketReqString;
    BOOL _hasMarket;
    NSMutableArray *_loopArray;
//    GCDAsyncUdpSocket *udpSocket;
    NSString *_uid;
//    刷新表视图索引
    NSInteger _reloadIndex;
    NSMutableArray *_MarketStream;
    NSMutableDictionary *_contractIndexDic;
    NSMutableDictionary *_contractTimeDic;
    NSString *_preSettlementPrice;
    UILabel *updTimeLabel;
}
@end

@implementation LiveVipinfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // 向通知中心注册了一条通知 "futureLoginNotification"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(futureLoginNotification:) name:@"FutureLoginNotification" object:nil];
    NSLog(@"LiveVipInfoController entered");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 38)];
    headView.layer.borderWidth = 1;
    headView.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    headView.backgroundColor = [UIColor whiteColor];
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 70, 38)];
    textLabel.font = [UIFont systemFontOfSize:15];
    textLabel.textColor = [UIColor blackColor];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.text = @"持仓合约";
    [headView addSubview:textLabel];
    
    updTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(85, 9, 180, 20)];
    updTimeLabel.font = [UIFont systemFontOfSize:12];
    updTimeLabel.textColor = [UIColor grayColor];
    updTimeLabel.textAlignment = NSTextAlignmentLeft;
    updTimeLabel.text = @"最后更新：－－";
    [headView addSubview:updTimeLabel];
    self.tableView.tableHeaderView = headView;
    
    self.hasBuy = [[TradeUtility LocalLoadConfigFileByKey:@"hasBuy" defaultvalue:@"0"] boolValue];
    if (!_hasBuy) {
        UIView *maskView = [[UIView alloc]initWithFrame:self.tableView.bounds];
        maskView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:maskView];
    } else {
        _loopArray = [NSMutableArray array];
        _vipcontractData = [[NSMutableArray alloc]init];
        [self showVipContractList];
    }
    
    _tbHeight = self.tableView.bounds.size.height;
    _lineViewHeight = 97;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"timer is valid: %@",_marketTimer.isValid ? @"YES":@"NO");
    if (_marketTimer.isValid == NO  && _marketReqString.length > 0 && _marketReqString !=nil) {
        [self subscribeMarket];//订阅行情
//        NSDictionary *marketDic = @{@"flag":@"0",@"id_list":_marketReqString,@"uid":_uid};
//        //    NSDictionary *marketDic = @{@"flag":@"0",@"id_list":@"ni1701",@"uid":_uid};
//        NSData *marketData = [NSJSONSerialization dataWithJSONObject:marketDic options:NSJSONWritingPrettyPrinted error:nil];
//        [udpSocket sendData:marketData toHost:serviceAddress port:servicePort withTimeout:-1 tag:0];
        //心跳
        _marketTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
    NSLog(@"LiveVipInfoController appeared");
    NSLog(@"%@",_marketReqString);
}

//滑动隐藏导航栏
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //关闭定时器
    if (_marketTimer.isValid == YES) {
//        NSDictionary *beatDic = @{@"flag":@"1",@"id_list":@"",@"uid":_uid};
//        NSData *beatData = [NSJSONSerialization dataWithJSONObject:beatDic options:NSJSONWritingPrettyPrinted error:nil];
//        [udpSocket sendData:beatData toHost:serviceAddress port:servicePort withTimeout:-1 tag:1];
        NSLog(@"liveVipInfo timer invalidated");
        [_marketTimer invalidate];
        _marketTimer = nil;
    }
    self.navigationController.navigationBar.hidden = NO;
}

-(void)enterForeground{
    NSLog(@"entered foreground");
    //订阅行情
    [self subscribeMarket];
    if (_marketTimer.isValid == NO) {
        _marketTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
}

- (void)showVipContractList{
    NSString *vipuid = [TradeUtility LocalLoadConfigFileByKey:@"vipuid" defaultvalue:@"0"];
    NSString *vipaid = [TradeUtility LocalLoadConfigFileByKey:@"vipaid" defaultvalue:@"0"];
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"http://inf.91trader.com/rtrade/user/getLeaderConList"];
    NSLog(@"url request=%@",strURL);
    
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys: vipuid, @"vipUid",vipaid, @"vipAid",nil];
    NSLog(@"postparam=%@",postparam);
    
//    NSDictionary *retdata = [TradeUtility HTTPSyncPOSTRequest:strURL parameters:postparam];
    
    [TradeUtility requestWithUrl:@"getLeaderConList" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary *)result;
//        NSLog(@"getLeaderConList retdata=%@",retdata);
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
            if(![retjson isKindOfClass:[NSNull class]]){
                NSArray *_arr = [retjson objectForKey:@"contract_list"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (_arr.count > 0) {
                        NSDictionary *tmpDict =_arr[0];
                        updTimeLabel.text =[NSString stringWithFormat:@"最后更新：%@",tmpDict[@"hold_time"]];
                        self.vipcontractData = [NSMutableArray arrayWithArray:_arr];
                        [self.tableView reloadData];
                        [self getRealTimeData];
                    }
                });
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"getLeaderConList Error:%@",error);
    }];
}

-(void)getRealTimeData{
    _marketReqString =nil;
    NSMutableArray *arr = [NSMutableArray array];
    _contractIndexDic = [NSMutableDictionary dictionary];
    _contractTimeDic = [NSMutableDictionary dictionary];
    NSString *_lastUpdateTime = @"0";
    for (NSInteger i = 0; i < self.vipcontractData.count; i++) {
        NSDictionary *dic =self.vipcontractData[i];
        [_contractIndexDic setObject:[NSString stringWithFormat:@"%li",i] forKey:dic[@"concode"]];
        [_contractTimeDic setObject:[NSString stringWithFormat:@"0"] forKey:dic[@"concode"]];
        
        if ([_lastUpdateTime compare:dic[@"update_time"]] == NSOrderedAscending) {
            _lastUpdateTime =dic[@"update_time"];
        }
        [arr addObject:dic[@"concode"]];
    }
//    updTimeLabel.text = _lastUpdateTime;
    NSSet *set = [NSSet setWithArray:arr];
    NSArray * array2 = [set allObjects];
    _marketReqString = [array2 componentsJoinedByString:@";"];
//    NSLog(@"************ %@",_marketReqString);
    _uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    _MarketStream = [NSMutableArray array];
    [self subscribeMarket];
//    NSDictionary *marketDic = @{@"flag":@"0",@"id_list":_marketReqString,@"uid":_uid};
////    NSDictionary *marketDic = @{@"flag":@"0",@"id_list":@"ni1701",@"uid":_uid};
//    NSData *marketData = [NSJSONSerialization dataWithJSONObject:marketDic options:NSJSONWritingPrettyPrinted error:nil];
//    [udpSocket sendData:marketData toHost:serviceAddress port:servicePort withTimeout:-1 tag:0];
    [self sendHeartBeat];
//    NSDictionary *beatDic = @{@"flag":@"2",@"id_list":@"",@"uid":_uid};
//    NSData *beatData = [NSJSONSerialization dataWithJSONObject:beatDic options:NSJSONWritingPrettyPrinted error:nil];
//    //    NSLog(@"timer param:%@",[[NSString alloc]initWithData:beatData encoding:NSUTF8StringEncoding]);
//    [udpSocket sendData:beatData toHost:serviceAddress port:servicePort withTimeout:-1 tag:2];

    _marketTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

-(void)showDataAction{
    if ([_MarketStream firstObject] !=nil) {
//        [self processMarketStream];
//        NSLog(@"first object: %@",[_loopArray firstObject]);
        NSArray *_tmpArray = [_loopArray firstObject][@"data"];
        NSDictionary *_dic = [_tmpArray firstObject];
//        NSLog(@"DIC  :%@",_dic);
        NSString *tempConCode =_dic[@"concode"];
//        获取需要刷新的索引
//        NSLog(@"%@",_contractIndexDic);
        _reloadIndex = [_contractIndexDic[tempConCode] integerValue];
        NSLog(@"index :%li",_reloadIndex);
        if (self.vipcontractData !=nil) {
//            NSLog(@"index :%li",_reloadIndex);
//            NSLog(@"the according item: %@", self.vipcontractData[_reloadIndex]);
//            [self.vipcontractData removeObjectAtIndex:_reloadIndex];
            [self.vipcontractData replaceObjectAtIndex:_reloadIndex withObject:_dic];
//            [self.vipcontractData insertObject:_tmpArray atIndex:_reloadIndex];
//            self.vipcontractData[_reloadIndex] = _dic;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_reloadIndex inSection:0];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        }
        [_loopArray removeObjectAtIndex:0];
        [_MarketStream removeObjectAtIndex:0];
    }
}
-(void)timerAction{
    [self sendHeartBeat];
}

//订阅行情
-(void)subscribeMarket{
    NSDictionary *marketDic = @{@"flag":@"0",@"id_list":_marketReqString,@"uid":_uid};
    NSData *marketData = [NSJSONSerialization dataWithJSONObject:marketDic options:NSJSONWritingPrettyPrinted error:nil];
    UDPManager *udpManager = [UDPManager shareManager];
    [udpManager.udpSocket setDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [udpManager.udpSocket sendData:marketData toHost:serviceAddress port:servicePort withTimeout:-1 tag:0];
    
    NSError *error = nil;
    [udpManager.udpSocket beginReceiving:&error];
}
//发送心跳
-(void)sendHeartBeat{
    NSDictionary *beatDic = @{@"flag":@"2",@"id_list":@"",@"uid":_uid};
    NSData *beatData = [NSJSONSerialization dataWithJSONObject:beatDic options:NSJSONWritingPrettyPrinted error:nil];
    UDPManager *udpManager = [UDPManager shareManager];
    [udpManager.udpSocket setDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [udpManager.udpSocket sendData:beatData toHost:serviceAddress port:servicePort withTimeout:-1 tag:2];
}

-(void)dealloc{
    NSLog(@"dealloc:%@",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.vipcontractData.count > 0){
        return self.vipcontractData.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellLiveVipinfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveVipinfoCell" forIndexPath:indexPath];
    if (self.vipcontractData.count ==0) {
        return cell;
    }
    _itemData = [self.vipcontractData objectAtIndex:indexPath.row];
    if (indexPath.row >0) {
        cell.m_strJiuYingBtn.hidden = YES;
        cell.m_strJiuYingLabel.hidden = YES;
        cell.m_strVipYieldRate.hidden = YES;
    } else{
        cell.m_strJiuYingBtn.hidden = NO;
        cell.m_strJiuYingLabel.hidden = NO;
        cell.m_strVipYieldRate.hidden = NO;
    }
    // Configure the cell...
//    NSLog(@"_itemData :%@",_itemData);
    if(_itemData != nil){

        cell.m_strSortNo.text = [ NSString stringWithFormat : @"%ld",(long)indexPath.row+1];
        cell.m_strConCode.text = [ NSString stringWithFormat : @"%@",[_itemData objectForKey:@"concode"]];
        cell.m_strConName.text = [ NSString stringWithFormat : @"%@",[_itemData objectForKey:@"conname"]];
        if (_itemData.count > 4) {
            cell.m_strLastPrice.text = [ NSString stringWithFormat : @"%@",[_itemData objectForKey:@"convalue"]];
            cell.m_strUpDown.text = [ NSString stringWithFormat : @"%@",[_itemData objectForKey:@"updown"]];
            if ([cell.m_strUpDown.text rangeOfString:@"-"].location != NSNotFound) {
                [cell.m_strLastPrice setTextColor:BGGreen_COLOR];
                [cell.m_strUpDown setTextColor:BGGreen_COLOR];
                [cell.m_strUpDownRate setTextColor:BGGreen_COLOR];
                [cell.m_strSlash setTextColor:BGGreen_COLOR];
            } else {
                [cell.m_strLastPrice setTextColor:BGRED_COLOR];
                [cell.m_strUpDown setTextColor:BGRED_COLOR];
                [cell.m_strUpDownRate setTextColor:BGRED_COLOR];
                [cell.m_strSlash setTextColor:BGRED_COLOR];
            }
            cell.m_strUpDownRate.text = [ NSString stringWithFormat : @"%@",[_itemData objectForKey:@"updownrate"]];
            
            cell.bidPrice.text = [_itemData objectForKey:@"Bid"];
            cell.bidVolume.text = [_itemData objectForKey:@"BidVolume"];
            cell.askPrice.text = [_itemData objectForKey:@"Ask"];
            cell.askVolume.text = [_itemData objectForKey:@"AskVolume"];
            
            cell.openInterest.text =[_itemData objectForKey:@"OpenInterest"];
            if ([cell.openInterest.text rangeOfString:@"-"].location != NSNotFound) {
                [cell.openInterest setTextColor:BGGreen_COLOR];
                
            } else {
                [cell.openInterest setTextColor:BGRED_COLOR];
            }
            
            cell.totalInterest.text = [_itemData objectForKey:@"TotalOpenInterest"];
    //**********Testing
            float f_trade_fuying = 12630 / 100;
            NSString *normalText = [ NSString stringWithFormat : @"%.1f%%",f_trade_fuying];
            cell.m_strVipYieldRate.text = normalText;
            cell.itemData = [_vipcontractData objectAtIndex:indexPath.row];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _itemData = [self.vipcontractData objectAtIndex:indexPath.row];
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

- (LiveVipIndexController *)viewCtl{
    UIResponder *responder = self.nextResponder;
    do {
        if ([responder isKindOfClass:[LiveVipIndexController class]]) {
//            NSLog(@"LiveVipIndexController reached");
            return (LiveVipIndexController *)responder;
        }
        responder = responder.nextResponder;
    } while (responder!= nil);
    return nil;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"%.2f",scrollView.contentOffset.y);
    LiveVipIndexController *indexCtr = [self viewCtl];
    if (scrollView.contentOffset.y >= 20) {//如果当前位移大于缓存位移，说明scrollView向下滑动
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:.3 animations:^{
            weakSelf.view.transform = CGAffineTransformMakeTranslation(0, -136);
            indexCtr.view.backgroundColor = [UIColor whiteColor];
            indexCtr.m_strBuyRate.transform = CGAffineTransformMakeTranslation(0, -136);
            indexCtr.m_strInvestLabel.transform = CGAffineTransformMakeTranslation(0, -136);
            indexCtr.m_strContracts.transform = CGAffineTransformMakeTranslation(0, -136);
            indexCtr.m_strContracts1.transform = CGAffineTransformMakeTranslation(0, -136);
            indexCtr.m_strContracts2.transform = CGAffineTransformMakeTranslation(0, -136);
            indexCtr.lineProgressView.transform = CGAffineTransformMakeTranslation(0, -196);
            weakSelf.tableView.height = [UIScreen mainScreen].bounds.size.height - 20;
        }];
    }
    if (scrollView.contentOffset.y <= -20){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:.3 animations:^{
            weakSelf.view.transform = CGAffineTransformIdentity;
            indexCtr.view.backgroundColor = BGRED_COLOR;
            indexCtr.m_strBuyRate.transform = CGAffineTransformIdentity;
            indexCtr.m_strInvestLabel.transform = CGAffineTransformIdentity;
            indexCtr.m_strContracts.transform = CGAffineTransformIdentity;
            indexCtr.m_strContracts1.transform = CGAffineTransformIdentity;
            indexCtr.m_strContracts2.transform = CGAffineTransformIdentity;
            indexCtr.lineProgressView.transform = CGAffineTransformIdentity;
            weakSelf.tableView.height = _tbHeight;
        }];
    }
}

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
        [self.navigationController pushViewController:liveVipLivingViewCtr animated:YES];
    }
}
#pragma mark - Notification
- (void)futureLoginNotification:(NSNotification *)notification{
    NSDictionary * dic = (NSDictionary *)notification.object;
    if ([dic[@"showNextCtr"] isEqualToString:@"LiveVipLivingController"]){
        [self bindAccountDone];
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
    
//    NSLog(@"Message didReceiveData %@ filterContext is %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding],filterContext);
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
//    NSDictionary *retdata = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//    NSDictionary *retjson = [retdata objectForKey:@"data"];
    
//    NSLog(@"ret data=%@",retjson);
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
        _hasMarket = YES;
        _backUpData = [NSMutableArray array];
        NSString *retConCode = tmpDic[@"ins_id"];
        NSString *dateStr = [NSString stringWithFormat:@"%@%@",tmpDic[@"nTradeDay"],tmpDic[@"nTime"]];
        NSString *tempDate = dateStr;
        
        if ([tempDate compare:[_contractTimeDic objectForKey:retConCode]] == NSOrderedAscending) {
            NSInteger _oldHour =[[[_contractTimeDic objectForKey:retConCode] substringWithRange:NSMakeRange(8, 2)]integerValue];
            NSInteger _newHour =[[tempDate substringWithRange:NSMakeRange(8, 2)]integerValue];
            if (!(_oldHour >= 21 && _oldHour <=23 && _newHour >=00 && _newHour <=15)) {
                return;
            }
        }
        [_contractTimeDic setObject:dateStr forKey:retConCode];
        
        NSInteger _index = [[_contractIndexDic objectForKey:retConCode] integerValue];

        NSMutableDictionary *valueDic = [NSMutableDictionary dictionary];
        [valueDic setObject:retConCode forKey:@"concode"];
        NSString *_conNM = self.vipcontractData[_index][@"conname"];
        [valueDic setObject:_conNM forKey:@"conname"];
        double lastPrice = [tmpDic[@"nPrice"] doubleValue];
        NSString *lastNewPrice = [self formatDecimalWithNum:lastPrice/10000.0f decimal:_decNum];
        [valueDic setValue:lastNewPrice forKey:@"convalue"];
//        结算价
        double preSettlementPrice = [tmpDic[@"PreSettlementPrice"] doubleValue];
//         涨跌
        double _upDown = (lastPrice - preSettlementPrice) / 10000.0f;
//        NSLog(@"涨跌 : %.2f",_upDown);
//        NSString *_upDwn = nil;
//        if (_upDown >= 0) {
//            _upDwn = [NSString stringWithFormat:@"+%.1f",_upDown];
//        }else {
//            _upDwn = [NSString stringWithFormat:@"%.1f",_upDown];
//        }
//        NSLog(@"updown str: %@",upDwnStr);
        NSString *upDwnStr = [self formatDecimalWithNum:_upDown decimal:_decNum];
        [valueDic setValue:upDwnStr forKey:@"updown"];
//         涨跌率
//         NSLog(@"nprice : %.2f",nPrice);

        _preSettlementPrice = [NSString stringWithFormat:@"%.1f",preSettlementPrice/10000.0f];

        NSString *_upDwnRate = nil;
        if ([tmpDic[@"PreSettlementPrice"] integerValue] > 0) {
            double _upDownRate = (lastPrice - preSettlementPrice) / (double)preSettlementPrice *100;
            if (_upDownRate < 0) {
                _upDownRate *= -1;
            }
            _upDwnRate = [NSString stringWithFormat:@"%.2f%%",_upDownRate];
        } else {
            _upDwnRate = @"0";
        }
        [valueDic setValue:_upDwnRate forKey:@"updownrate"];
        //                      盈利率
        //--->要修改              [valueDic setValue:_upDwnRate forKey:@"updownrate"];
        //                       bid
        NSString *bid = [self formatDecimalWithNum:[tmpDic[@"Bid"] doubleValue]/10000.0f decimal:_decNum];
        [valueDic setValue:bid forKey:@"Bid"];
        NSString *bidVolume = [NSString stringWithFormat:@"%ld", [tmpDic[@"BidVolume"] longValue]];
        [valueDic setValue:bidVolume forKey:@"BidVolume"];
//        ask
        NSString *ask = [self formatDecimalWithNum:[tmpDic[@"Ask"] doubleValue]/10000.0f decimal:_decNum];
        [valueDic setValue:ask forKey:@"Ask"];
        NSString *askVolume = [NSString stringWithFormat:@"%ld", [tmpDic[@"AskVolume"] longValue]];
        [valueDic setValue:askVolume forKey:@"AskVolume"];
//        wareHouse
        NSString *openInterest = [NSString stringWithFormat:@"%ld", [tmpDic[@"OpenInterest"] longValue]];
        [valueDic setValue:openInterest forKey:@"OpenInterest"];
        NSString *totalInterest = [NSString stringWithFormat:@"%ld", [tmpDic[@"TotalOpenInterest"] longValue]];
        [valueDic setValue:totalInterest forKey:@"TotalOpenInterest"];
        [self.vipcontractData replaceObjectAtIndex:_index withObject:valueDic];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_index inSection:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

//动态显示小数位数
-(NSString *)formatDecimalWithNum:(double)doubleNumber decimal:(NSInteger)decimalNum{
    NSString* format = [NSString stringWithFormat:@"%%.%lif",decimalNum];
    NSString* resultStr = [NSString stringWithFormat:format,doubleNumber];
//    NSLog(@"deciminal: %li result:%@",decimalNum, resultStr);
    return resultStr;
}




@end

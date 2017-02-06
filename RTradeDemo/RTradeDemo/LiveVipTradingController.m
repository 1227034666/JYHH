//
//  LiveVipTradingController.m
//  RTradeDemo
//  主界面 点进去的界面
//  Created by administrator on 16/7/2.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "LiveVipTradingController.h"
#import "CellVipTradingCell.h"
#import "TradeUtility.h"
#import "LeadTradeInforModel.h"


@interface LiveVipTradingController ()
@property (nonatomic,strong)NSMutableDictionary *tradeLiveDic;
@property (nonatomic,strong)NSMutableArray *tradeDateArr;
@end

@implementation LiveVipTradingController


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self showTradeLiveList];
}

- (void)showTradeLiveList{
    NSString *vipuid = [TradeUtility LocalLoadConfigFileByKey:@"vipuid" defaultvalue:@"0"];

    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               vipuid, @"vipUid",
                               self.conCode, @"concode",
                               nil];
    NSLog(@"getLeaderHistory postparam=%@",postparam);
    
    [TradeUtility requestWithUrl:@"getLeaderHistory" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary *)result;
//        NSLog(@"getLeaderHistory retdata=%@",retdata);
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        
        if(icode == 0){
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
            NSLog(@"getLeaderHistory retjson=%@",retjson);
            if([retjson isKindOfClass:[NSDictionary class]] && retjson.count >0){
                NSArray *historyArray =retjson[@"history_list"];
                NSMutableArray *tradeLiveArray = [NSMutableArray array];
                for (NSDictionary *itemDic in historyArray) {
                    if ([itemDic[@"concode"] isEqualToString:self.conCode]) {
                        LeadTradeInforModel *model = [[LeadTradeInforModel alloc]init];
                        model.tradeTime = itemDic[@"hold_time"];
                        model.tradePrice = itemDic[@"trade_avgprice"];
                        model.tradeType = itemDic[@"trade_type"];
                        model.tradeQty = itemDic[@"trade_volume"];
                        
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                        NSDate* inputDate = [formatter dateFromString:itemDic[@"hold_time"]];
                        NSDictionary *dic = @{@"data":model,@"TimeStamp":inputDate};
                        [tradeLiveArray addObject:dic];
                        if (tradeLiveArray.count >1) {
                            NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"TimeStamp" ascending:NO]];
                            [tradeLiveArray sortUsingDescriptors:sortDescriptors];
                        }
                    }
                }
                if (tradeLiveArray.count > 0) {
                    NSString *_lastTimeStamp;
                    NSMutableArray *tempArr = nil;

                    for (NSInteger i=0; i< tradeLiveArray.count; i++) {
                        LeadTradeInforModel *model = tradeLiveArray[i][@"data"];
                        NSLog(@"_lastTimeStamp :%@",_lastTimeStamp);
                        NSLog(@"[model.tradeTime substringToIndex:9]:%@",[model.tradeTime substringToIndex:9]);
                        if (![_lastTimeStamp isEqualToString:[model.tradeTime substringToIndex:10]]) {
                            if (_lastTimeStamp != nil && tempArr !=nil) {
                                [self.tradeDateArr addObject:_lastTimeStamp];
                                [self.tradeLiveDic setObject:tempArr forKey:_lastTimeStamp];
                            }
                            _lastTimeStamp =[model.tradeTime substringToIndex:10];
                            tempArr = [NSMutableArray array];
                        }
                        [tempArr addObject:model];
                    }
                    [self.tradeLiveDic setObject:tempArr forKey:_lastTimeStamp];
                    [self.tradeDateArr addObject:_lastTimeStamp];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
//                tradeLiveData = [retjson objectForKey:@"history_list"];
                NSLog(@"%@",self.tradeDateArr);
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"LiveVipTradingController error%@",error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tradeDateArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key =self.tradeDateArr[section];
    NSArray *sectionArray = [self.tradeLiveDic objectForKey:key];
   return sectionArray.count;
    
}

//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    NSString *key =self.tradeDateArr[section];
//    return [key substringWithRange:NSMakeRange(5, 5)];
//
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellVipTradingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VipTradingCell" forIndexPath:indexPath];
    // Configure the cell...
    if (self.tradeDateArr.count > 0 ) {
        NSString *key = self.tradeDateArr[indexPath.section];
        NSArray *tempArray = [self.tradeLiveDic objectForKey:key];
        if (tempArray.count > 0) {
            LeadTradeInforModel *model =tempArray[indexPath.row];
            cell.model = model;
        }
    }
//    if(tradeLiveData != nil){
//        NSDictionary *itemData = [tradeLiveData objectAtIndex:indexPath.row];
//        cell.m_strTradePrice.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"convalue"]];
//
//        cell.m_strUpdateTime.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"update_time"]];
//        cell.m_strTradeCount.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"trade_volume"]];
//        if([[itemData objectForKey:@"trade_state"] isEqual: @"1"]){
//            cell.m_strTradeType.text = @"开仓";
//            cell.m_strTradeType2.text = @"开仓";
//        }else{
//            cell.m_strTradeType.text = @"平仓";
//            cell.m_strTradeType2.text = @"平仓";
//        }
//        cell.m_strTradeSwitch.tag = indexPath.row;
//        if ([[self.switchOnDic valueForKey:[NSString stringWithFormat:@"%li",indexPath.row]] isEqual: @(1)] ) {
//            cell.m_strTradeSwitch.on = YES;
//        } else {
//            cell.m_strTradeSwitch.on = NO;
//        }
//    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor colorWithRed:221/255.0 green:222/255.0 blue:223/255.0 alpha:1];
    myView.frame =CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 1);

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(tableView.bounds), 30)];
    titleLabel.textColor=[UIColor grayColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString *key =self.tradeDateArr[section];
    titleLabel.text = [key substringWithRange:NSMakeRange(5, 5)];
    [myView addSubview:titleLabel];
    

    return myView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 ){
        return 30;
    }
    return 30;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footer = [[UIView alloc]init];
    footer.frame =CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 1);
    return  footer;
}

-(NSMutableDictionary *)tradeLiveDic{
    if (_tradeLiveDic == nil) {
        _tradeLiveDic = [NSMutableDictionary dictionary];
    }
    return _tradeLiveDic;
}

-(NSMutableArray *)tradeDateArr{
    if (_tradeDateArr == nil) {
        _tradeDateArr = [NSMutableArray array];
    }
    return _tradeDateArr;
}

@end

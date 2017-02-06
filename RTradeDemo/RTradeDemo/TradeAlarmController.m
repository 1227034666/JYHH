//
//  TradeAlarmController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/6.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "TradeAlarmController.h"
#import "CellTradeAlarmCell.h"
#import "TradeUtility.h"

@interface TradeAlarmController ()

@end

@implementation TradeAlarmController

    NSArray *alarmListData;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title=@"提醒";
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    alarmListData = nil;
    
    [self showAlarmList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAlarmList{
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
//    NSString *aid = [TradeUtility LocalLoadConfigFileByKey:@"aid" defaultvalue:@"0"];
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"http://inf.91trader.com/rtrade/user/getMsgTotalList"];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               @"10", @"listCount",
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
            alarmListData = [retjson objectForKey:@"msgtotal_list"];
            
        }
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if(alarmListData != nil)
    {
        return alarmListData.count;
    }
    else
    {
        return 4;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellTradeAlarmCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainAlarmCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if(alarmListData != nil)
    {
        NSDictionary *itemData = [alarmListData objectAtIndex:indexPath.row];
        cell.m_strAlarmType.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"msg_type_title"]];
        cell.m_strLastTime.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"last_time"]];
        cell.m_strLastMessage.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"last_message"]];
        cell.m_strUnread.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"msg_count"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(alarmListData != nil)
    {
        NSDictionary *itemData = [alarmListData objectAtIndex:indexPath.row];
        [TradeUtility LocalSaveConfigFileByKey:@"curMsgTypeId" value:[itemData objectForKey:@"id"]];
    }
    
    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"AlarmListController"];
    [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  AlarmListController.m
//  RTradeDemo
//
//  Created by administrator on 16/6/29.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "AlarmListController.h"
#import "CellAlarmListCell.h"
#import "TradeUtility.h"

@interface AlarmListController ()

@end

@implementation AlarmListController

  NSArray *alarmSubListData;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    alarmSubListData = nil;
    
    [self showAlarmSubList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAlarmSubList
{
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
//    NSString *aid = [TradeUtility LocalLoadConfigFileByKey:@"aid" defaultvalue:@"0"];
    NSString *msgType = [TradeUtility LocalLoadConfigFileByKey:@"curMsgTypeId" defaultvalue:@"0"];
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"http://inf.91trader.com/rtrade/user/getMsgDetailList"];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               msgType, @"msgtypeID",
                               @"0", @"listCount",
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
            alarmSubListData = [retjson objectForKey:@"message_list"];
            
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
    if(alarmSubListData != nil)
    {
        return alarmSubListData.count;
    }
    else
    {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellAlarmListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmListCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if(alarmSubListData != nil)
    {
        NSDictionary *itemData = [alarmSubListData objectAtIndex:indexPath.row];
        cell.m_strNickname.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"msgfrom_nickname"]];
        cell.m_strMsgTime.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"msg_time"]];
        cell.m_strMsgText.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"msg_text"]];

    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

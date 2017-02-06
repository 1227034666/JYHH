//
//  TradeVipHistoryController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/14.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "TradeVipHistoryController.h"
#import "CellVipHistoryCell.h"

@interface TradeVipHistoryController ()

@property(strong,nonatomic)NSArray *tradeData;
@end

@implementation TradeVipHistoryController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self showTradeList];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showTradeList{
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    NSString *vipuid = [TradeUtility LocalLoadConfigFileByKey:@"vipuid" defaultvalue:@"0"];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               vipuid, @"vipUid",
                               nil];
    NSLog(@"postparam=%@",postparam);
    [TradeUtility requestWithUrl:@"getLeaderHistory" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"getLeaderHistory retcode=%d",icode);
        if(icode == 0){
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
            NSLog(@"retjson=%@",retjson);
            if(retjson != nil){
                self.tradeData = [retjson objectForKey:@"history_list"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    } failure:^(NSError *error) {
        
    }];
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if(self.tradeData.count > 0){
        return self.tradeData.count;
    }else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellVipHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VipHistoryCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if(self.tradeData.count >0){
        NSDictionary *itemData = [self.tradeData objectAtIndex:indexPath.row];
        cell.m_strConCode.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"concode"]];
        cell.m_strConName.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"conname"]];
        
//        cell.m_strUseRate.text = [ NSString stringWithFormat : @"%@%%",[itemData objectForKey:@"trade_buyrate"]];
//        cell.m_strFuying.text = [ NSString stringWithFormat : @"%@%%",[itemData objectForKey:@"trade_fuying"]];
//        cell.m_strHoldTime.text = [TradeUtility parseDateTime:[itemData objectForKey:@"hold_time"]];
        cell.m_strHoldTime.text = [itemData objectForKey:@"hold_time"];
        if([[itemData objectForKey:@"trade_type"] isEqual: @"1"]){
            cell.m_strTradeType.text = @"多";
            cell.m_strTradeType.textColor = BGRED_COLOR;
        }else if([[itemData objectForKey:@"trade_type"] isEqual: @"2"]){
            cell.m_strTradeType.text = @"空";
            cell.m_strTradeType.textColor = BGGreen_COLOR;
        }else if([[itemData objectForKey:@"trade_type"] isEqual: @"0"]){
            cell.m_strTradeType.text = @"平仓";
            cell.m_strTradeType.textColor = [UIColor blueColor];
        }
        
        cell.m_strTradePrice.text = [NSString stringWithFormat:@"%.1f",[[itemData objectForKey:@"trade_avgprice"]floatValue]];
        if ([[itemData objectForKey:@"trade_volume"] isEqualToString:@"0"]) {
            cell.m_strTradeVolume.text =@"*";
        } else{
            cell.m_strTradeVolume.text = [NSString stringWithFormat:@"%ld",[[itemData objectForKey:@"trade_volume"]integerValue]];
        }
    }
    
    return cell;
}

-(NSArray *)tradeData{
    if (_tradeData == nil) {
        _tradeData = [NSArray array];
    }
    return _tradeData;
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

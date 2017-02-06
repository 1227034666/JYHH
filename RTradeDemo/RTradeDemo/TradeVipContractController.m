//
//  TradeVipContractController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/12.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "TradeVipContractController.h"
#import "CellVipContractCell.h"
#import "CellVipContractModel.h"

@interface TradeVipContractController ()

@property(strong,nonatomic)NSArray *contractData;

@end

@implementation TradeVipContractController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self showContractList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showContractList{
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    NSString *vipuid = [TradeUtility LocalLoadConfigFileByKey:@"vipuid" defaultvalue:@"0"];
//    NSString *vipaid = [TradeUtility LocalLoadConfigFileByKey:@"vipaid" defaultvalue:@"0"];
    
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               vipuid, @"vipUid",
//                               vipaid, @"vipAid",
                               nil];
    NSLog(@"postparam=%@",postparam);
    
    [TradeUtility requestWithUrl:@"getLeaderConList" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"getLeaderConList retcode=%d",icode);
        if(icode == 0){
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
            NSLog(@"retjson=%@",retjson);
            if(retjson != nil){
                self.contractData = [retjson objectForKey:@"contract_list"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"TradeVipContractCtr getLeaderConList error:%@",error);
    }];
    
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if(self.contractData.count > 0){
        return self.contractData.count;
    }else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellVipContractCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VipContractCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if(self.contractData.count > 0){
        NSDictionary *itemData = [self.contractData objectAtIndex:indexPath.row];
        CellVipContractModel *model = [[CellVipContractModel alloc]init];
        model.conName = [itemData objectForKey:@"conname"];
        model.conCode = [itemData objectForKey:@"concode"];
        model.tradeType = [NSString stringWithFormat:@"%li",[[itemData objectForKey:@"trade_type"]integerValue]];
        model.tradePrice = [NSString stringWithFormat:@"%.1f",[[itemData objectForKey:@"transaction_price"]floatValue]];
        model.tradeVolume = [NSString stringWithFormat:@"%ld",[[itemData objectForKey:@"transaction_volume"]integerValue]];

        model.holdTime =[itemData objectForKey:@"hold_time"];
        cell.model = model;

    }
    
    return cell;
}

-(NSArray *)contractData{
    if (_contractData == nil) {
        _contractData = [NSArray array];
    }
    return _contractData;
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

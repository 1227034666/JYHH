//
//  TradeVipDiscussController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/12.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "TradeVipDiscussController.h"
#import "CellVipDiscussCell.h"

@interface TradeVipDiscussController ()

@property(strong,nonatomic)NSArray *viewVipListData;

@end

@implementation TradeVipDiscussController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showVipViewList];
    
}

- (void)showVipViewList{
    NSString *vipuid = [TradeUtility LocalLoadConfigFileByKey:@"vipuid" defaultvalue:@"0"];
    
//    NSString *strURL = [[NSString alloc] initWithFormat:@"http://inf.91trader.com/rtrade/user/getViewList"];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               vipuid, @"uid",
                               @"0", @"page",
                               nil];
    NSLog(@"getLeaderView postparam=%@",postparam);
    
    [TradeUtility requestWithUrl:@"getLeaderView" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
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
            if(retjson != nil){
                self.viewVipListData = [retjson objectForKey:@"view_list"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"trade vip discuss error:%@",error);
    }];
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if(self.viewVipListData.count > 0){
        return self.viewVipListData.count;
    }else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellVipDiscussCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VipDiscussCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if(self.viewVipListData.count > 0){
        NSDictionary *itemData = [self.viewVipListData objectAtIndex:indexPath.row];
        cell.m_strViewTitle.text = [itemData objectForKey:@"view_title"];
        cell.m_strViewTag.text =[itemData objectForKey:@"view_tags"];
        cell.m_strViewContent.text = [itemData objectForKey:@"view_text"];
        cell.m_strPublishTime.text = [itemData objectForKey:@"publish_time"];
    }
    
    return cell;
}

-(NSArray *)viewVipListData{
    if (_viewVipListData ==nil) {
        _viewVipListData = [NSArray array];
    }
    return _viewVipListData;
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

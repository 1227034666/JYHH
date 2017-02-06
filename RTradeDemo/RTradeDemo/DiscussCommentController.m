//
//  DiscussCommentController.m
//  RTradeDemo
//
//  Created by administrator on 16/6/29.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "DiscussCommentController.h"
#import "CellDiscussCommentCell.h"
#import "TradeUtility.h"

@interface DiscussCommentController ()

@end

@implementation DiscussCommentController
    NSArray *commentListData;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title=@"评论";
    
    UIBarButtonItem *publishBtn = [[UIBarButtonItem alloc] initWithTitle:@"写评论" style:UIBarButtonItemStylePlain target:self action:@selector(btnPublish:)];
    [self.navigationItem setRightBarButtonItem:publishBtn];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    
    
    commentListData = nil;
    
    [self showCommentList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnPublish:(id)sender
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"DiscussAddCommentController"];
    [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}

- (void)showCommentList
{
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    NSString *viewId = [TradeUtility LocalLoadConfigFileByKey:@"curViewId" defaultvalue:@"0"];
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"http://inf.91trader.com/rtrade/user/getCommentList"];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               viewId, @"viewId",
                               @"0", @"listType",
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
            commentListData = [retjson objectForKey:@"comment_list"];
            if(commentListData != nil)
            {
                self.title = [ NSString stringWithFormat : @"%lu条评论",(unsigned long)commentListData.count];
            }
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
    if(commentListData != nil)
    {
        return commentListData.count;
    }
    else
    {
        return 10;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellDiscussCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DiscussCommentCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if(commentListData != nil)
    {
        NSDictionary *itemData = [commentListData objectAtIndex:indexPath.row];
        cell.m_strNickname.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"nickname"]];
        cell.m_strTags.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"contracts"]];
        cell.m_strTime.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"publish_time"]];
        cell.m_strContent.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"view_text"]];
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

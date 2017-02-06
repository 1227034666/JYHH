//
//  TradeSortController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/6.
//  Copyright © 2016年 administrator. All rights reserved.
// 左侧排行

#import "TradeSortController.h"
#import "CellTradeSortCell.h"
#import "TradeUtility.h"

@interface TradeSortController (){
    NSInteger _attentionType;
    NSString *_uid;
    NSString *_vipuid;
}

@property(copy,nonatomic)NSArray *sortData;

@end

@implementation TradeSortController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title=@"排行";
    
    self.view.backgroundColor=[UIColor whiteColor];
    _attentionType = 0;
    _uid= [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
//    [self setupTableHeader];
    [self showSortList];
    

}

-(void)setupTableHeader{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    headView.backgroundColor =[UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1.0f];
    UILabel *userInfoLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth/2, 30)];
    userInfoLbl.textAlignment = NSTextAlignmentCenter;
    userInfoLbl.font = [UIFont systemFontOfSize:15];
    userInfoLbl.textColor = [UIColor lightGrayColor];
    userInfoLbl.text = @"用户信息";
    [headView addSubview:userInfoLbl];
    self.tableView.tableHeaderView = headView;
    
    UIButton *upDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    upDownBtn.frame =CGRectMake(kScreenWidth - 160, 0, 80, 30);
    [upDownBtn setTitle:@"总收益率" forState:UIControlStateNormal];
    upDownBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [upDownBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [headView addSubview:upDownBtn];
    
    UILabel *subscribeLbl = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 80, 0, 80, 30)];
    subscribeLbl.textAlignment = NSTextAlignmentCenter;
    subscribeLbl.font = [UIFont systemFontOfSize:15];
    subscribeLbl.textColor = [UIColor lightGrayColor];
    subscribeLbl.text = @"+关注";
    [headView addSubview:subscribeLbl];

}

- (void)showSortList{
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];

    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               @"0", @"listType",
                               @"10", @"listCount",
                               nil];
    NSLog(@"postparam=%@",postparam);
    
    [TradeUtility requestWithUrl:@"getSortList" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
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
            if(retjson != nil && ![retjson isKindOfClass:[NSNull class]]){
                self.sortData = [retjson objectForKey:@"list"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
 
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"Trade Sort error: %@",error);
    }];
    
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if(self.sortData.count > 0){
        return self.sortData.count;
    }else{
        return 0;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    headView.backgroundColor =[UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1.0f];
    UILabel *userInfoLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth/2, 30)];
    userInfoLbl.textAlignment = NSTextAlignmentCenter;
    userInfoLbl.font = [UIFont systemFontOfSize:15];
    userInfoLbl.textColor = [UIColor lightGrayColor];
    userInfoLbl.text = @"用户信息";
    [headView addSubview:userInfoLbl];
//    self.tableView.tableHeaderView = headView;
    
    UIButton *upDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    upDownBtn.frame =CGRectMake(kScreenWidth - 160, 0, 80, 30);
    [upDownBtn setTitle:@"总收益率" forState:UIControlStateNormal];
    upDownBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [upDownBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [headView addSubview:upDownBtn];
    
    UILabel *subscribeLbl = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 80, 0, 80, 30)];
    subscribeLbl.textAlignment = NSTextAlignmentCenter;
    subscribeLbl.font = [UIFont systemFontOfSize:15];
    subscribeLbl.textColor = [UIColor lightGrayColor];
    subscribeLbl.text = @"+关注";
    [headView addSubview:subscribeLbl];
    return headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellTradeSortCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainSortCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.m_strSortNo.text = [ NSString stringWithFormat : @"%ld",(long)indexPath.row+1];
    if(self.sortData.count > 0)
    {
        NSDictionary *itemData = [self.sortData objectAtIndex:indexPath.row];
        cell.m_strNickname.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"nickname"]];
        if (![[itemData objectForKey:@"avatar"] isKindOfClass:[NSNull class]]) {
            [cell.m_imgLogo sd_setImageWithURL:[NSURL URLWithString:[itemData objectForKey:@"avatar"]] placeholderImage:[UIImage imageNamed:@"Icon.png"]];
        } else{
            cell.m_imgLogo.image = [UIImage imageNamed:@"Icon.png"];
        }
         NSLog(@"%@",[itemData objectForKey:@"contracts"]);
        if (![[itemData objectForKey:@"contracts"] isKindOfClass:[NSNull class]]) {
            NSString *contracts = [itemData objectForKey:@"contracts"];
           
            NSArray *arr = [contracts componentsSeparatedByString:@","];
            
            switch (arr.count) {
                case 0:
                    cell.m_strContractTags.hidden = YES;
                    cell.m_strContractTag1.hidden = YES;
                    cell.m_strContractTag2.hidden = YES;
                    break;
                case 1:
                    cell.m_strContractTags.text = arr[0];
                    cell.m_strContractTag1.hidden = YES;
                    cell.m_strContractTag2.hidden = YES;
                    break;
                case 2:
                    cell.m_strContractTags.text = arr[0];
                    cell.m_strContractTag1.text = arr[1];
                    cell.m_strContractTag2.hidden = YES;
                    break;
                case 3:
                    cell.m_strContractTags.text = arr[0];
                    cell.m_strContractTag1.text = arr[1];
                    cell.m_strContractTag2.text = arr[2];
                    break;
                default:
                    break;
            }
        } else{
            cell.m_strContractTags.hidden = YES;
            cell.m_strContractTag1.hidden = YES;
            cell.m_strContractTag2.hidden = YES;
        }
        if (![[itemData objectForKey:@"yieldrate"] isKindOfClass:[NSNull class]]) {
            
            cell.m_strYieldRate.text = [ NSString stringWithFormat : @"%.2f%%",[[itemData objectForKey:@"yieldrate"] floatValue] * 100];
        }
        cell.addButton.tag = indexPath.row;
        
        [cell.addButton addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        if ([[itemData objectForKey:@"attentstate"] integerValue] == 0) {
            cell.addButton.hidden = NO;
            cell.addedLabel.hidden = YES;
        } else if ([[itemData objectForKey:@"attentstate"] integerValue] == 1) {
            cell.addButton.hidden = YES;
            cell.addedLabel.hidden = NO;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = [self.sortData objectAtIndex: indexPath.row];
    if ([dic[@"uid"] isKindOfClass:[NSNull class]]) {
        return;
    } else{
        
        [TradeUtility LocalSaveConfigFileByKey:@"vipuid" value:dic[@"uid"]];
        [self enterNextViewCtr];
    }
}

-(void)enterNextViewCtr{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradeVipDetailController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}

-(void)addBtnAction:(UIButton *)btn{
    _attentionType = 1;
    NSDictionary *itemDic  = [self.sortData objectAtIndex:btn.tag];
    _vipuid = itemDic[@"uid"];
    if ([_vipuid isKindOfClass:[NSNull class]]) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               _uid, @"uid",
                               _vipuid, @"vipUid",
                               @(_attentionType),@"operType",
                               nil];
    NSLog(@"postparam=%@",postparam);
    [TradeUtility requestWithUrl:@"setAttention" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"setAttention retcode=%d",icode);
        if(icode == 0){
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
            NSLog(@"setAttention retjson=%@",retjson);
            
            hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CheckMark"]];
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"关注成功";
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                CellTradeSortCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.addButton.hidden = YES;
                cell.addedLabel.hidden = NO;
            });
            [hud hide:YES afterDelay:1];
        }
    } failure:^(NSError *error) {
        NSLog(@"vip detail setAttention error:%@",error);
    }];
    
}

-(NSArray *)sortData{
    if (_sortData == nil) {
        _sortData = [NSArray array];
    }
    return _sortData;
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

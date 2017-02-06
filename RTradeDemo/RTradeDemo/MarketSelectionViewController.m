//
//  MarketSelectionViewController.m
//  RTradeDemo
//
//  Created by iMac on 16/12/28.
//  Copyright © 2016年 administrator. All rights reserved.
// 左侧行情 搜索行情合约

#import "MarketSelectionViewController.h"
#import "MarketSelectionCell.h"
#import "TradeUtility.h"
#import "MarketSelectionModel.h"
#import "MBProgressHUD.h"

@interface MarketSelectionViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property(nonatomic, assign) BOOL isSearch;//是否是search状态
@property (strong, nonatomic) IBOutlet UISearchBar *contractSearchBar;
@property (strong, nonatomic) IBOutlet UITableView *contractTblView;
@property (strong, nonatomic) NSMutableArray *contractArray;

@end
static NSString *reuseIdentifier = @"MarketSelectionCell";

@implementation MarketSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"选取合约";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets=NO;
    [self.contractSearchBar becomeFirstResponder];
    self.contractSearchBar.delegate = self;
    self.contractTblView.delegate = self;
    self.contractTblView.dataSource = self;
    
}



#pragma mark -- tableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if (self.contractArray.count > 0) {
        return self.contractArray.count;
    } else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MarketSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (self.contractArray.count > 0) {
        MarketSelectionModel *model = [[MarketSelectionModel alloc]init];
        
        NSDictionary *itemDic = self.contractArray[indexPath.row];
        model.contractName = [itemDic objectForKey:@"conname"];
        model.contractCode = [itemDic objectForKey:@"concode"];
        model.isSubscribed = [itemDic objectForKey:@"issubscribed"];
        cell.model = model;
        cell.addButton.tag = indexPath.row;
        [cell.addButton addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *celled = [tableView cellForRowAtIndexPath:_selIndex];
//    celled.accessoryType = UITableViewCellAccessoryNone;
//    //记录当前选中的位置索引
//    _selIndex = indexPath;
//    //当前选择的打勾
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    _selectedCompanyName = self.companyArray[indexPath.row];
}



#pragma mark searchBarDelegete
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length > 0) {
        NSLog(@"searchText: %@",searchText);
        [self sendSearchRequest:searchText];
    }

}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    self.isSearch = NO;
    
}

-(void)sendSearchRequest:(NSString *)searchStr{
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               searchStr,@"key",
                               nil];
    [TradeUtility requestWithUrl:@"searchContract" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"searchContract retcode=%d",icode);
        if(icode == 0){
            NSLog(@"searchContract re_json %@",[retdata objectForKey:@"re_json"]);
            if (self.contractArray.count > 0) {
                [self.contractArray removeAllObjects];
            }
            self.contractArray = [[retdata objectForKey:@"re_json"][@"ins_list"] mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.contractTblView reloadData];
            });
            
        }
    } failure:^(NSError *error) {
        NSLog(@"searchContract error: %@",error);
    }];
}

-(void)addBtnAction:(UIButton *)btn{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    NSDictionary *itemDic =self.contractArray[btn.tag];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               itemDic[@"concode"],@"concode",
                               itemDic[@"conname"],@"conname",
                               @(1), @"flag",
                               nil];
    [TradeUtility requestWithUrl:@"subscribe" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"subscribe retcode=%d",icode);
        if(icode == 0){
            hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CheckMark"]];
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"添加成功";
            
            NSLog(@"subscribe re_json %@",[retdata objectForKey:@"re_json"]);
            NSMutableDictionary *updateDic = [self.contractArray[btn.tag] mutableCopy];
            NSLog(@"updateDic :%@",updateDic);
            [updateDic setValue:@(1) forKey:@"issubscribed"];
            [self.contractArray replaceObjectAtIndex:btn.tag withObject:updateDic];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.contractTblView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            });
            [hud hide:YES afterDelay:1];
        }
    } failure:^(NSError *error) {
        NSLog(@"subscribe error: %@",error);
    }];
 
}

-(NSMutableArray *)contractArray{
    if (_contractArray == nil) {
        _contractArray = [NSMutableArray array];
    }
    return _contractArray;
}
@end

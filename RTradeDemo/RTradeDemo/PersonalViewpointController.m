//
//  PersonalViewpointController.m
//  RTradeDemo
//
//  Created by administrator on 16/8/7.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "PersonalViewpointController.h"
#import "CellPersonalViewpointCell.h"

@interface PersonalViewpointController (){
    NSString *_uid;
    UISegmentedControl *_segmentedControl;
    MBProgressHUD *_hud;
    
}
@property(strong,nonatomic)NSMutableArray *tableDataArray;
@property(strong,nonatomic)NSMutableArray *pageNumArray;
@end

@implementation PersonalViewpointController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSArray *segmentedArray = [NSArray arrayWithObjects:@"收藏",@"关注",@"我的",nil];
    _segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    _segmentedControl.frame = CGRectMake(0.0, 0.0, 290, 30.0);
    _segmentedControl.selectedSegmentIndex = 1;
    _segmentedControl.tintColor = [UIColor whiteColor];
    _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [_segmentedControl addTarget:self  action:@selector(indexDidChangeForSegmentedControl:)
               forControlEvents:UIControlEventValueChanged];
    //方法1
    //[self.navigationController.navigationBar.topItem setTitleView:segmentedControl];
    //方法2
    [self.navigationItem setTitleView:_segmentedControl];
    _uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    for (int i=0; i<3; i++) {
        NSMutableArray *initArr = [NSMutableArray array];
        [self.tableDataArray addObject:initArr];
    }
    [self showLeaderList:_segmentedControl.selectedSegmentIndex PageNum:0 ReqType:0];
    //下拉刷新
    __weak __typeof(self) weakself = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakself loadNewData];
    }];
    //上拉加载
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)indexDidChangeForSegmentedControl:(UISegmentedControl *)Seg{
    
    NSInteger Index = Seg.selectedSegmentIndex;
    NSInteger _page = [_pageNumArray[Index] integerValue];
    
    NSLog(@"Index %li", Index);
    
    if (_page == 0) {
        [self showLeaderList:Index PageNum:_page ReqType:0];
        //        _pageNumArray[Index] = @(++_page);
    }
    [self.tableView reloadData];
    
}

//下拉刷新的网络请求 ReqType=1
-(void)loadNewData{
    [self showLeaderList:_segmentedControl.selectedSegmentIndex PageNum:0 ReqType:1];
    //关闭刷新
    [self.tableView.mj_header endRefreshing];
}
//上拉加载 ReqType=2
-(void)loadMoreData{
    if (_segmentedControl.selectedSegmentIndex == 1) {
        //关闭刷新
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    NSInteger _page = [_pageNumArray[_segmentedControl.selectedSegmentIndex] integerValue];
    _page++;
    _pageNumArray[_segmentedControl.selectedSegmentIndex] = @(_page);
    [self showLeaderList:_segmentedControl.selectedSegmentIndex PageNum:_page ReqType:2];
    //[[_dataArray objectAtIndex:_segmentedControl.selectedSegmentIndex] addObjectsFromArray:_leaderData];
    //刷新数据
    //[self.tableView reloadData];
    //关闭刷新
    [self.tableView.mj_footer endRefreshing];
    
}

- (void)showLeaderList:(NSInteger)showindex PageNum:(NSInteger)page ReqType:(NSInteger)reqType{
    
    if (reqType != 2) {
        _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];

    //@"action":@"getLeaderList",
    NSMutableDictionary *postparam = [@{@"uid":uid,@"type":@(showindex+1), @"page":[ NSString stringWithFormat : @"%ld",(long)page]} mutableCopy];
    
    NSLog(@"postparam=%@",postparam);


    [TradeUtility requestWithUrl:@"getViewList" httpMethod:@"POST" pramas:postparam fileData:nil success:^(id result) {
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
            //            NSLog(@"retjson=%@",retjson);
            if(retjson != nil && ![retjson isKindOfClass:[NSNull class]]){
                NSArray *_myData = [retjson objectForKey:@"view_list"];
                if (_myData.count > 0) {

                    if ( reqType == 0) {
                        [self.tableDataArray[_segmentedControl.selectedSegmentIndex] removeAllObjects];
                        [self.tableDataArray[_segmentedControl.selectedSegmentIndex] addObjectsFromArray:_myData];
                    } else if (reqType == 1) {
                        [self.tableDataArray[_segmentedControl.selectedSegmentIndex] removeAllObjects];
                        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _myData.count)];
                        [self.tableDataArray[_segmentedControl.selectedSegmentIndex] insertObjects:_myData atIndexes:set];
                    } else if (reqType == 2){
                        [self.tableDataArray[_segmentedControl.selectedSegmentIndex] addObjectsFromArray:_myData];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                    [_hud hide:YES afterDelay:1];
                }
            }
        }else{
            [_hud hide:YES];
            NSInteger _page = [self.pageNumArray[_segmentedControl.selectedSegmentIndex] integerValue];
            
            if (_page > 0) {
                _page--;
            }
            self.pageNumArray[_segmentedControl.selectedSegmentIndex] = @(_page);
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
}



#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if([self.tableDataArray objectAtIndex:_segmentedControl.selectedSegmentIndex] != nil){
        NSArray *tmpArr =[self.tableDataArray objectAtIndex:_segmentedControl.selectedSegmentIndex];
        return tmpArr.count;
    }else{
        return 0;
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellPersonalViewpointCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellPersonalViewpointCell" forIndexPath:indexPath];
    if(self.tableDataArray[_segmentedControl.selectedSegmentIndex] != nil){
        NSArray *tmpArr =[self.tableDataArray objectAtIndex:_segmentedControl.selectedSegmentIndex];
        NSDictionary *itemData = [tmpArr objectAtIndex:indexPath.row];
        cell.m_strViewTitle.text =[itemData objectForKey:@"view_title"];
        cell.m_strViewTags.text =[itemData objectForKey:@"view_tags"];
        cell.m_strPublishTime.text =[itemData objectForKey:@"publish_time"];
        cell.m_strViewText.text =[itemData objectForKey:@"view_text"];
        [cell.m_strAvatar sd_setImageWithURL:[NSURL URLWithString:[itemData objectForKey:@"avatar"]] placeholderImage:[UIImage imageNamed:@"AppIcon"]];
        cell.m_strNickName.text =[itemData objectForKey:@"nickname"];
        
        if (_segmentedControl.selectedSegmentIndex == 2) {
            cell.m_strAvatar.hidden = YES;
            cell.m_strNickName.hidden = YES;
            cell.m_strTradeUser.hidden = YES;
      
        } else{
            cell.m_strAvatar.hidden = NO;
            cell.m_strNickName.hidden = NO;
            cell.m_strTradeUser.hidden = NO;
      
        }
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_segmentedControl.selectedSegmentIndex == 2) {
        return 100;
    } else{
        return 140;
    }
}
-(NSMutableArray *)tableDataArray{
    if (_tableDataArray == nil) {
        _tableDataArray = [NSMutableArray array];
    }
    return _tableDataArray;
}
-(NSMutableArray *)pageNumArray{
    if (_pageNumArray == nil) {
        _pageNumArray = [NSMutableArray arrayWithObjects:@(0),@(0),@(0), nil];
    }
    return _pageNumArray;
}


@end

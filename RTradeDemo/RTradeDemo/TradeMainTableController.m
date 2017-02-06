//
//  TradeMainTableController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/10.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "TradeMainTableController.h"
#import "TradeMainCustomCell.h"
#import "LeftMenuController.h"
#import "TradeVipDetailController.h"
#import "TradeIndexFilterViewController.h"
#import "UIImageView+WebCache.h"
#import "ViewController.h"

@interface TradeMainTableController (){
    BOOL _isClick;
//    UIImageView *_imageView;
    UISegmentedControl *_segmentedControl;
    NSMutableArray *_pageNumArray;

    NSMutableArray *_leaderData;
    UIView *_maskView;
}

@property (strong,nonatomic)NSMutableArray *dataArray;


@end

@implementation TradeMainTableController

//-(NSMutableArray*)dataArray{
//    if (_dataArray ==nil) {
//        for (int i=0; i<3; i++) {
//            NSMutableArray *initArr = [NSMutableArray array];
//            [_dataArray addObject:initArr];
//        }
//    }
//    return _dataArray;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    LeftMenuController *leftController=[[LeftMenuController alloc]init];
    [SlideNavigationController sharedInstance].leftMenu = leftController;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
    //set NavigationBar 背景颜色&title 颜色

    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:216/255.0 green:40/255.0 blue:61/255.0 alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    // 向通知中心注册了一条通知 "ChangeLabelTextNotification"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginNotification:) name:@"DidLoginNotification" object:nil];

    NSArray *segmentedArray = [NSArray arrayWithObjects:@"关注",@"热门",@"最新",nil];
    
    _dataArray = [NSMutableArray array];
    
    for (int i=0; i<3; i++) {
        NSMutableArray *initArr = [NSMutableArray array];
        [_dataArray addObject:initArr];
    }
    
    _pageNumArray = [NSMutableArray arrayWithObjects:@(0),@(0),@(0), nil];
    _segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    _segmentedControl.frame = CGRectMake(0.0, 0.0, 290, 30.0);
    _segmentedControl.selectedSegmentIndex = 1;
    _segmentedControl.tintColor = [UIColor whiteColor];
    _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [_segmentedControl addTarget:self  action:@selector(indexDidChangeForSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    //方法1
    //[self.navigationController.navigationBar.topItem setTitleView:segmentedControl];
    //方法2
    [self.navigationItem setTitleView:_segmentedControl];
    
    //设置左键
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //设置右键
    UIView *rightBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 68, 44)];
    rightBarView.backgroundColor = [UIColor clearColor];
    UIImage *actImage = [UIImage imageNamed:@"IconActivity"];
    UIImage *filterImage = [UIImage imageNamed:@"IconFilter"];
    CGSize imageTosize = CGSizeMake(24, 24);
    UIImage *reActImage = [self reSizeImage:actImage toSize:imageTosize];
    UIImage *reFilterImage =[self reSizeImage:filterImage toSize:imageTosize];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    
    UIButton *actBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [actBtn addTarget:self action:@selector(btnActivity) forControlEvents:UIControlEventTouchUpInside];
    [actBtn setImage:reActImage forState:UIControlStateNormal];
    [actBtn sizeToFit];
    actBtn.frame = CGRectMake(10, 10, 24, 24);
    [rightBarView addSubview:actBtn];
    
    UIButton *filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterBtn addTarget:self action:@selector(btnFilter) forControlEvents:UIControlEventTouchUpInside];
    [filterBtn setImage:reFilterImage forState:UIControlStateNormal];
    [filterBtn sizeToFit];
    filterBtn.frame = CGRectMake(44, 10, 24, 24);
    [rightBarView addSubview:filterBtn];
    UIBarButtonItem*rightItem=[[UIBarButtonItem alloc]initWithCustomView:rightBarView];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,rightItem,nil];

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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.tableView reloadData];
//    [self showLeaderList:_segmentedControl.selectedSegmentIndex PageNum:0 ReqType:0];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
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
    _leaderData = [NSMutableArray array];
    if (reqType != 2) {
        _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//        _hud.dimBackground = YES;
    }
    
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    NSString *aid = [TradeUtility LocalLoadConfigFileByKey:@"accountid" defaultvalue:@"0"];
//@"action":@"getLeaderList",
    NSMutableDictionary *postparam = [@{@"uid":uid, @"aid":aid,@"listType":[ NSString stringWithFormat : @"%ld",(long)showindex], @"page":[ NSString stringWithFormat : @"%ld",(long)page]} mutableCopy];
    
    if (self.filterDic !=nil) {
        NSString *_sortKey = [self.filterDic objectForKey:@"sortKey"];
        NSString *_tradestate = [self.filterDic objectForKey:@"tradestate"];
        NSArray *_contracts = [self.filterDic objectForKey:@"contracts"];
        NSArray * _filters;
        if (_contracts !=nil) {
            _filters = _contracts;
        }
        if (_sortKey !=nil ) {
            [postparam setObject:_sortKey forKey:@"sortKey"];
        }
        NSMutableDictionary *_tmpDic = [NSMutableDictionary dictionary];
        if (_tradestate !=nil) {
            [_tmpDic setObject:_tradestate forKey:@"tradestate"];
        }
        if (_filters != nil) {
            [_tmpDic setObject:_filters forKey:@"contracts"];
        }
        if (_tmpDic.count > 0) {
            [postparam setObject:_tmpDic forKey:@"filter"];
        }
    }
    NSLog(@"postparam=%@",postparam);
    __weak typeof(self)weakSelf = self;

    [TradeUtility requestWithUrl:@"getLeaderList" httpMethod:@"POST" pramas:postparam fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
//        NSLog(@"retcode=%d",icode);
        if(icode == 0){
            if (reqType != 2) {
                [_hud hide:YES];
            }
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
//            NSLog(@"retjson=%@",retjson);
            if(retjson != nil && ![retjson isKindOfClass:[NSNull class]]){
                _leaderData = [retjson objectForKey:@"leader_list"];
                if (_leaderData.count > 0) {
                    _maskView.hidden = YES;
                    if (_segmentedControl.selectedSegmentIndex == 1 || reqType == 0) {
                        [_dataArray[_segmentedControl.selectedSegmentIndex] removeAllObjects];
                        [_dataArray[_segmentedControl.selectedSegmentIndex] addObjectsFromArray:_leaderData];
                    }
                    if (reqType == 1) {
                        [_dataArray[_segmentedControl.selectedSegmentIndex] removeAllObjects];
                        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _leaderData.count)];
                        [_dataArray[_segmentedControl.selectedSegmentIndex] insertObjects:_leaderData atIndexes:set];
                    } else if (reqType == 2){
//                        NSDictionary *itemArr = _dataArray[_segmentedControl.selectedSegmentIndex];
                        
                        [_dataArray[_segmentedControl.selectedSegmentIndex] addObjectsFromArray:_leaderData];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }
        }else{
            if (reqType != 2) {
                [_hud hide:YES];
            }
            NSInteger _page = [_pageNumArray[_segmentedControl.selectedSegmentIndex] integerValue];
            if (_segmentedControl.selectedSegmentIndex == 0 && _page == 0){
                if (_maskView == nil) {
                    [weakSelf setupMaskView];
                    
                } else {
                    [weakSelf.view bringSubviewToFront:_maskView];
                }
                _maskView.hidden = NO;
            }
            
            if (_page > 0) {
                _page--;
            }
            _pageNumArray[_segmentedControl.selectedSegmentIndex] = @(_page);
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
}

-(void)setupMaskView{
    _maskView = [[UIView alloc]initWithFrame:self.view.bounds];
    //                        _maskView.userInteractionEnabled = NO;
    _maskView.backgroundColor = [UIColor lightGrayColor];
    
    UIImageView *_maskImgView = [[UIImageView alloc]initWithFrame:CGRectMake(125, 180, 100, 75)];
    _maskImgView.image = [UIImage imageNamed:@"IconUserGroup"];
    _maskImgView.contentMode = UIViewContentModeScaleAspectFit;
    CGPoint _centerPoint =_maskImgView.center;
    _centerPoint.x = self.view.center.x;
    _maskImgView.center = _centerPoint;
    [_maskView addSubview:_maskImgView];
    
    NSString *_hintNoDataStr = @"您还没有添加关注的用户";
    NSDictionary *attrs1=@{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    CGSize noDataSize = [_hintNoDataStr boundingRectWithSize:CGSizeMake(MAXFLOAT, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs1 context:nil].size;
    UILabel *_hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, _maskImgView.bottom + 20, noDataSize.width + 10, 40)];
    _hintLabel.font = [UIFont systemFontOfSize:14];
    _hintLabel.textAlignment = NSTextAlignmentCenter;
    _hintLabel.text = @"您还没有添加关注的用户";
    _hintLabel.textColor = [UIColor grayColor];
    _centerPoint = _hintLabel.center;
    _centerPoint.x = self.view.center.x;
    _hintLabel.center = _centerPoint;
    [_maskView addSubview:_hintLabel];
    
    NSString *_hintToHotStr = @"去看看当前领单直播的大咖";
    NSDictionary *attrs2=@{NSFontAttributeName:[UIFont systemFontOfSize:16]};
    CGSize textSize = [_hintToHotStr boundingRectWithSize:CGSizeMake(MAXFLOAT, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs2 context:nil].size;
    UIButton *_toHotPageBtn = [[UIButton alloc]initWithFrame:CGRectMake(40, _hintLabel.bottom + 40, textSize.width + 40, 44)];
    _toHotPageBtn.layer.masksToBounds = YES;
    _toHotPageBtn.layer.cornerRadius = 15;
    _toHotPageBtn.userInteractionEnabled = YES;
    [_toHotPageBtn setTitle:_hintToHotStr forState:UIControlStateNormal];
    _toHotPageBtn.backgroundColor = BGRED_COLOR;
    _centerPoint = _toHotPageBtn.center;
    _centerPoint.x = self.view.center.x;
    _toHotPageBtn.center = _centerPoint;
    [_maskView addSubview:_toHotPageBtn];
    [_toHotPageBtn addTarget:self action:@selector(toHotPageAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_maskView];
}

-(void)toHotPageAction{
    _segmentedControl.selectedSegmentIndex = 1;
    _maskView.hidden = YES;
    [self.tableView reloadData];
}

-(void)indexDidChangeForSegmentedControl:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSInteger _page = [_pageNumArray[Index] integerValue];
    NSLog(@"Index %li", (long)Index);
    if (Index != 0 && _maskView.isHidden == NO) {
        _maskView.hidden = YES;
    }
//    switch (Index) {
//        case 0:
//            //关注
//            [self showLeaderList:0 PageNum:_page];
//            break;
//        case 1:
//            //热门
//            [self showLeaderList:1 PageNum:_page];
//            break;
//        case 2:
//            //最新
//            [self showLeaderList:2 PageNum:_page];
//            break;
//        default:
//            break;
//    }
    NSLog(@"%li",_page);
    if (_page == 0) {
        [self showLeaderList:Index PageNum:_page ReqType:0];
//        _pageNumArray[Index] = @(++_page);
    }
    [self.tableView reloadData];
    
}



- (void)doLogin:(id)sender{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ViewController"];
    loginViewController.modalTransitionStyle =
    UIModalTransitionStyleCoverVertical;
    [self presentViewController:loginViewController animated:YES completion:^{
        NSLog(@"Present Modal View");
    }];
}

//resize right barButton Item Images
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

-(void)btnActivity{

    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *tradeActiveCtr = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradeActiveController"];
    [self.navigationController pushViewController:tradeActiveCtr animated:YES];
    
    
}

-(void)btnFilter{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TradeIndexFilterViewController *tradeFilterViewCtr = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradeIndexFilterViewController"];
    __weak typeof(self) weakSelf = self;
    tradeFilterViewCtr.allFilterBlock = ^(NSMutableDictionary *dict){
        _filterDic = dict;
        [weakSelf loadNewData];
    };
    [self.navigationController pushViewController:tradeFilterViewCtr animated:YES];

}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu{
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if([_dataArray objectAtIndex:_segmentedControl.selectedSegmentIndex] != nil){
        NSArray *tmpArr =[_dataArray objectAtIndex:_segmentedControl.selectedSegmentIndex];
        return tmpArr.count;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //cell = [[TradeMainCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    // Configure the cell...
    if(_dataArray[_segmentedControl.selectedSegmentIndex] != nil){
        TradeMainCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        NSArray *tmpArr =[_dataArray objectAtIndex:_segmentedControl.selectedSegmentIndex];
        
        NSDictionary *itemData = [tmpArr objectAtIndex:indexPath.row];
//      pic
        NSString *_imgUrl = [itemData objectForKey:@"avatar"];
        
        if (![_imgUrl isKindOfClass:[NSNull class]]) {
            
            [cell.vipPhoto sd_setImageWithURL:[NSURL URLWithString:_imgUrl] placeholderImage:[UIImage imageNamed:@"viplogo.png"]];
        } else{
            [cell.vipPhoto setImage:[UIImage imageNamed:@"viplogo.png"]];
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapVipImgAction:)];
        [cell.vipPhoto addGestureRecognizer:tap];
//      contracts
        NSString *_contractString = [itemData objectForKey:@"contracts"];

        NSArray *_contractArr = nil;
        if (![_contractString isKindOfClass:[NSNull class]] && _contractString.length > 0) {
            _contractArr =[_contractString componentsSeparatedByString:@","];
        }
        cell.contractArray = _contractArr;
        cell.vipWatch.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"attentcnt"]];
        if([[itemData objectForKey:@"tradestate"]  isEqual: @"1"]){
            cell.vipTradeState.text = @"交易中";
        }else{
            cell.vipTradeState.text = @"暂停交易";
        }
//总收益率
//        NSString *yieldrate = [itemData objectForKey:@"yieldrate"];
//        float f_yieldrate = [yieldrate floatValue] / 100;
//－－－－－－－－>将会更新
        NSArray *yieldRateArr = [itemData objectForKey:@"yieldrate"];
//        NSLog(@"yieldRateArr %@",yieldRateArr);
        NSDictionary *yieldRateDic =[yieldRateArr firstObject];
        NSArray *yieldKeys =[yieldRateDic allKeys];
        NSString *yieldLabelTxt = yieldKeys[0];
        float f_yieldrate =[[yieldRateDic valueForKey:yieldLabelTxt] floatValue]*100;
        cell.winRateLabel.text =yieldLabelTxt;
        cell.vipWinRate.text = [ NSString stringWithFormat : @"%.2f%%",f_yieldrate];
//
//成功率
//－－－－－－－－>将会更新
        NSArray *vipSuccRateArr = [itemData objectForKey:@"succrate"];
        NSDictionary *succRateDic =[vipSuccRateArr firstObject];
        NSArray *succRateKeys =[succRateDic allKeys];
        NSString *succRateTxt = succRateKeys[0];
        float f_succRate =[[succRateDic valueForKey:succRateTxt] floatValue] *100;
        cell.succRateLabel.text =succRateTxt;
        cell.vipSuccRate.text = [ NSString stringWithFormat : @"%.2f%%",f_succRate];
//        cell.vipSuccRate.text = [ NSString stringWithFormat : @"%@%%",[itemData objectForKey:@"succrate"]];
//当日盈利率
//－－－－－－－－>将会更新
        NSArray *dayGetRateArr = [itemData objectForKey:@"daygetrate"];
        NSDictionary *dayGetRateDic =[dayGetRateArr firstObject];
        NSArray *dayGetRateKeys =[dayGetRateDic allKeys];
        NSString *dayGetRateTxt = dayGetRateKeys[0];
        float f_daygetrate =[[dayGetRateDic valueForKey:dayGetRateTxt] floatValue]*100;
        cell.maxWinLabel.text =dayGetRateTxt;
//
//        NSString *maxgetrate = [itemData objectForKey:@"maxgetrate"];
//        float f_maxgetrate = [maxgetrate floatValue] / 100;
        cell.vipMaxWin.text = [ NSString stringWithFormat : @"%.2f%%",f_daygetrate];
//最大回撤率
//－－－－－－－－>将会更新
        NSArray *maxRetreatRateArr = [itemData objectForKey:@"maxretreatrate"];
        NSDictionary *maxRetreatRateDic =[maxRetreatRateArr firstObject];
        NSArray *maxRetreatRateKeys =[maxRetreatRateDic allKeys];
        NSString *maxRetreatRateTxt = maxRetreatRateKeys[0];
        float f_maxretreatrate =[[maxRetreatRateDic valueForKey:maxRetreatRateTxt] floatValue]*100;
        cell.maxLossLabel.text =maxRetreatRateTxt;
//
//        NSString *maxlossrate = [itemData objectForKey:@"maxlossrate"];
//        float f_maxlossrate = [maxlossrate floatValue] / 100;
        cell.vipMaxLoss.text = [ NSString stringWithFormat : @"%.2f%%",f_maxretreatrate];
//最大回撤率
//－－－－－－－－>将会更新
        NSArray *vipTradeNumArr = [itemData objectForKey:@"tradenum"];
        NSDictionary *vipTradeNumDic =[vipTradeNumArr firstObject];
        NSArray *vipTradeNumKeys =[vipTradeNumDic allKeys];
        NSString *vipTradeNumTxt = vipTradeNumKeys[0];
        NSInteger f_vipTradeNum =[[vipTradeNumDic valueForKey:vipTradeNumTxt] integerValue];
        cell.tradeNumLabel.text =vipTradeNumTxt;
//
        cell.vipTradeNum.text = [NSString stringWithFormat : @"%li",f_vipTradeNum];
//        cell.vipTradeNum.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"tradenum"]];
        
        
//领单者名称
        cell.vipName.text = [ NSString stringWithFormat : @"%@",[itemData objectForKey:@"nickname"]];
        cell.vipPhoto.tag = indexPath.row;
//      收益率曲线
        cell.yielddata = [itemData objectForKey:@"tradefigure"];
//        NSLog(@"********cell.yielddata=%@",cell.yielddata);
        
//        [cell showContractDataGraph];
        return cell;
    }else{
        return nil;
//        cell.vipName.text = @"我是大牛";
    }
//    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *tmpArr =[_dataArray objectAtIndex:_segmentedControl.selectedSegmentIndex];
    NSDictionary *itemData = [tmpArr objectAtIndex:indexPath.row];
    [TradeUtility LocalSaveConfigFileByKey:@"vipuid" value:[itemData objectForKey:@"uid"]];
    [TradeUtility LocalSaveConfigFileByKey:@"vipaid" value:[itemData objectForKey:@"id"]];
    [TradeUtility LocalSaveConfigFileByKey:@"vipavatar" value:[itemData objectForKey:@"avatar"]];
    
    [TradeUtility LocalSaveConfigFileByKey:@"vipnickname" value:[itemData objectForKey:@"nickname"]];
    [TradeUtility LocalSaveConfigFileByKey:@"vipcontracts" value:[itemData objectForKey:@"contracts"]];
    
    NSArray *yieldRateArr = [itemData objectForKey:@"yieldrate"];
    NSDictionary *yieldRateDic =[yieldRateArr firstObject];
    NSArray *yieldKeys =[yieldRateDic allKeys];
    NSString *yieldLabelTxt = yieldKeys[0];
    float f_yieldrate =[[yieldRateDic valueForKey:yieldLabelTxt] floatValue]/100;
    [TradeUtility LocalSaveConfigFileByKey:@"vipyieldrate" value:[NSString stringWithFormat:@"%.2f",f_yieldrate]];
    
    NSArray *vipSuccRateArr = [itemData objectForKey:@"succrate"];
    NSDictionary *succRateDic =[vipSuccRateArr firstObject];
    NSArray *succRateKeys =[succRateDic allKeys];
    NSString *succRateTxt = succRateKeys[0];
    float f_succRate =[[succRateDic valueForKey:succRateTxt] floatValue]/100;
    [TradeUtility LocalSaveConfigFileByKey:@"vipbuyrate" value:[NSString stringWithFormat:@"%.2f",f_succRate]];
    [TradeUtility LocalSaveConfigFileByKey:@"vipfollowcnt" value:[itemData objectForKey:@"followcnt"]];
    //    [TradeUtility LocalSaveConfigFileByKey:@"hasBuy" value:[itemData objectForKey:@"hasbuy"]];
    [TradeUtility LocalSaveConfigFileByKey:@"hasBuy" value:@"1"];
    [self loginFunc];
    

}

-(void)loginFunc{
    
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    int intuid = [uid intValue];
    //  if not logged in
    if(intuid <= 0){
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ViewController"];
//      show next view controler( vip index controller)
        loginViewController.showNextViewCtr = @"LiveVipIndexController";
        loginViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [[SlideNavigationController sharedInstance]presentViewController:loginViewController animated:YES completion:nil];

    } else{
        [self enterNextViewCtr];
    }
}

-(void)TapVipImgAction:(UITapGestureRecognizer *)tap{
    NSArray *tmpArr =[_dataArray objectAtIndex:_segmentedControl.selectedSegmentIndex];
    
    NSDictionary *itemData = [tmpArr objectAtIndex:tap.view.tag];
    if(itemData != nil){
        [TradeUtility LocalSaveConfigFileByKey:@"vipuid" value:[itemData objectForKey:@"uid"]];
        [TradeUtility LocalSaveConfigFileByKey:@"vipaid" value:[itemData objectForKey:@"id"]];
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradeVipDetailController"];
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
    }
}

#pragma mark - Notification
- (void)didLoginNotification:(NSNotification *)notification{
    NSDictionary * dic = (NSDictionary *)notification.object;
    if ([dic[@"showNextCtr"] isEqualToString:@"1"]){
        [self enterNextViewCtr];
    }
}

-(void)enterNextViewCtr{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *liveVipIndexController = [mainStoryboard instantiateViewControllerWithIdentifier:@"LiveVipIndexController"];
    [[SlideNavigationController sharedInstance] pushViewController:liveVipIndexController animated:YES];
//    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:liveVipIndexController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}

//set filter fields
//-(void)setFilterDic:(NSMutableDictionary *)filterDic{
//    _filterDic = filterDic;
//    NSLog(@"_filterDic:%@",_filterDic);
//    if (_filterDic) {
//        [self showLeaderList:_segmentedControl.selectedSegmentIndex PageNum:0 ReqType:0];
//    }
//}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidLoginNotification" object:nil];
}

@end

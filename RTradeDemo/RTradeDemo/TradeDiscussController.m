//
//  TradeDiscussController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/6.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "TradeDiscussController.h"
#import "CellTradeDiscussCell.h"
#import "CellTradeDiscussModel.h"
#import "TradeUtility.h"
#import "MBProgressHUD.h"


@interface TradeDiscussController (){
    NSInteger _page;
}
@property(nonatomic,strong)NSMutableArray *viewListData;

@end

@implementation TradeDiscussController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title=@"观点";
    
    //self.view.backgroundColor=[UIColor whiteColor];
    UIImage *image = [UIImage imageNamed:@"IconSearch"];
    UIImage *image2 = [UIImage imageNamed:@"IconWrite"];
    
    UIBarButtonItem *searchBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(btnSearch:)];
    UIBarButtonItem *publishBtn = [[UIBarButtonItem alloc] initWithImage:image2 style:UIBarButtonItemStylePlain target:self action:@selector(btnPublish:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:publishBtn,searchBtn,nil]];
    
    //设置左键
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _page = 0;
    [self showViewList];
    //下拉刷新
    __weak __typeof(self) weakself = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakself loadNewData];
    }];
    //上拉加载
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [self.tableView reloadData];

}

//下拉刷新的网络请求 ReqType=1
-(void)loadNewData{
    _page = 0;
    [self showViewList];
    //关闭刷新
    [self.tableView.mj_header endRefreshing];
}
//上拉加载 ReqType=2
-(void)loadMoreData{
    _page++;
    [self showViewList];
    //刷新数据
    //[self.tableView reloadData];
    //关闭刷新
    [self.tableView.mj_footer endRefreshing];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)showViewList{
//    _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    _hud.dimBackground = YES;
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    
//    NSString *strURL = [[NSString alloc] initWithFormat:@"http://inf.91trader.com/rtrade/user/getViewList"];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               @(_page),@"page",
                               uid, @"uid",
                               nil];
    NSLog(@"postparam=%@",postparam);
    
    [TradeUtility requestWithUrl:@"getViewList" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
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
                if (_page ==0) {
                    if (self.viewListData.count > 0) {
                        [self.viewListData removeAllObjects];
                    }
                    self.viewListData = [[retjson objectForKey:@"view_list"] mutableCopy];
                } else {
                    [self.viewListData addObjectsFromArray:[retjson objectForKey:@"view_list"]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
//                [_hud hide:YES afterDelay:1];
            }
        }if(icode == 202){
            if (_page >0) {
                _page--;
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"DiscussCtr: %@",error);
    }];
}


-(void)btnSearch:(id)sender{
//    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"DiscussSearchController"];
    [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}

-(void)btnPublish:(id)sender{
    
//    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"DiscussPublishController"];
    [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.viewListData != nil){
        return self.viewListData.count;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellTradeDiscussCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainDiscussCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if(self.viewListData != nil){
        NSDictionary *itemData = [self.viewListData objectAtIndex:indexPath.row];

        CellTradeDiscussModel *model = [[CellTradeDiscussModel alloc]init];
        model.m_strLogo = [itemData objectForKey:@"avatar"];
        model.m_strNickname = [itemData objectForKey:@"nickname"];
        model.m_strViewTitle = [itemData objectForKey:@"view_title"];
        model.m_strViewTags = [itemData objectForKey:@"view_tags"];
        model.m_strViewText = [itemData objectForKey:@"view_text"];
        model.m_strViewTime = [itemData objectForKey:@"publish_time"];
        //获取小图
        if (![[itemData objectForKey:@"thumbnail"] isKindOfClass:[NSNull class]]) {
            model.m_strImgView = [itemData objectForKey:@"thumbnail"];
        } else{
            model.m_strImgView = @"";
        }
        cell.model = model;
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *viewText;
    float textHeight;
    CGSize imgHeight = CGSizeMake(0, 0);
    if(self.viewListData != nil){
        NSDictionary *itemData = [self.viewListData objectAtIndex:indexPath.row];
        viewText = [itemData objectForKey:@"view_text"];
        textHeight= [TradeUtility getTextHeight:13 width:kScreenWidth text:viewText];
        if (![[itemData objectForKey:@"thumbnail"] isKindOfClass:[NSNull class]]) {
//            NSString *photoURL = [itemData objectForKey:@"thumbnail"];
            imgHeight = CGSizeMake(100, 100);
        }
//        NSString *photoURL = [itemData objectForKey:@"thumbnail"];
//        if (photoURL.length > 0) {
//            imgHeight = CGSizeMake(80, 80);
//        }
    }
//    NSLog(@"cell height %.2f",98 + textHeight + 5 +imgHeight.height);
    return 86 + textHeight + 5 +imgHeight.height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.viewListData != nil)
    {
        NSDictionary *itemData = [self.viewListData objectAtIndex:indexPath.row];
        [TradeUtility LocalSaveConfigFileByKey:@"curViewId" value:[itemData objectForKey:@"id"]];
        [TradeUtility LocalSaveConfigFileByKey:@"vipuid" value:[itemData objectForKey:@"uid"]];
        [TradeUtility LocalSaveConfigFileByKey:@"linkurl" value:[itemData objectForKey:@"linkurl"]];
        [TradeUtility LocalSaveConfigFileByKey:@"viewTitle" value:[itemData objectForKey:@"view_title"]];
        if (![[itemData objectForKey:@"thumbnail"] isKindOfClass:[NSNull class]]) {
             [TradeUtility LocalSaveConfigFileByKey:@"thumbnail" value:[itemData objectForKey:@"thumbnail"]];
        } else{
            [TradeUtility LocalSaveConfigFileByKey:@"thumbnail" value:@"0"];
        }
    }
    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"DiscussDetailController"];
    [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}

-(NSMutableArray *)viewListData{
    if (_viewListData == nil) {
        _viewListData = [NSMutableArray array];
    }
    return _viewListData;
}

@end

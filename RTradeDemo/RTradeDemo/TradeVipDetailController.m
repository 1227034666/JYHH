//
//  TradeVipDetailController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/11.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "TradeVipDetailController.h"
#import "TradeVipPresentController.h"
#import "TradeVipDiscussController.h"
#import "TradeVipContractController.h"
#import "TradeVipHistoryController.h"
// 发起领单

@interface TradeVipDetailController (){
    NSString *_uid;
    NSString *_vipuid;
    NSInteger _attentionType;
    
}

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property NSUInteger pageIndex;
@property int first_change;
@property int last_change;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mSegmentedControl;
- (IBAction)onSegmentedControlChange:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *m_strNickname;
@property (weak, nonatomic) IBOutlet UILabel *m_strContracts;//合约名称
@property (strong, nonatomic) IBOutlet UILabel *m_strContracts1;
@property (strong, nonatomic) IBOutlet UILabel *m_strContracts2;

@property (weak, nonatomic) IBOutlet UILabel *m_strRegTime;//加入时间
@property (weak, nonatomic) IBOutlet UILabel *m_strWatchCount;
@property (weak, nonatomic) IBOutlet UILabel *m_strWinSort;//收益排名
@property (weak, nonatomic) IBOutlet UILabel *m_strWinRate;//总收益
@property (weak, nonatomic) IBOutlet UILabel *m_strSuccRate;//成功率
@property (weak, nonatomic) IBOutlet UILabel *m_strMaxWin;
@property (weak, nonatomic) IBOutlet UILabel *m_strMaxLoss;
@property (weak, nonatomic) IBOutlet UILabel *m_strTradeCount;

@end

@implementation TradeVipDetailController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title=@"";
    _vipuid = [TradeUtility LocalLoadConfigFileByKey:@"vipuid" defaultvalue:@"0"];
    _uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    //self.view.backgroundColor=[UIColor whiteColor];
    if (![_vipuid isEqualToString:_uid]) {
        UIBarButtonItem *watchBtn = [[UIBarButtonItem alloc] initWithTitle:@"＋关注" style:UIBarButtonItemStylePlain target:self action:@selector(btnWatch:)];
        [self.navigationItem setRightBarButtonItem:watchBtn];
    }
    self.m_imgLogo.layer.masksToBounds = YES;
    self.m_imgLogo.layer.cornerRadius = self.m_imgLogo.width /2.0f;
    
    self.pageTitles = @[@"表现", @"观点", @"持仓", @"历史"];
    self.pageIndex = 0;
    self.first_change = 0;
    self.last_change = 0;
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    TradeVipPresentController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, self.mSegmentedControl.frame.origin.y+self.mSegmentedControl.frame.size.height+40, self.view.frame.size.width, self.view.frame.size.height - self.mSegmentedControl.frame.origin.y);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self showLeaderUserinfo];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLeaderUserinfo{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    NSString *strURL = [[NSString alloc] initWithFormat:@"http://inf.91trader.com/rtrade/user/getLeaderUserInfo"];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               _vipuid, @"vipUid",
                               _uid, @"uid",
                               nil];
    NSLog(@"postparam=%@",postparam);
    
//    NSDictionary *retdata = [TradeUtility HTTPSyncPOSTRequest:strURL parameters:postparam];
    [TradeUtility requestWithUrl:@"getLeaderUserInfo" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
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
                NSDictionary *present_info = [retjson objectForKey:@"leader_uinfo"];
                if(present_info != nil){
                    _attentionType =[[present_info objectForKey:@"attentstate"] integerValue];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (_attentionType == 1) {
                            [self.navigationItem.rightBarButtonItem setTitle:@"已关注"];
                        } else{
                            [self.navigationItem.rightBarButtonItem setTitle:@"+关注"];
                        }
                        self.m_strNickname.text = [ NSString stringWithFormat : @"%@",[present_info objectForKey:@"nickname"]];
                        if (![[present_info objectForKey:@"contracts"] isKindOfClass:[NSNull class]]) {
                             NSArray *contractArr =[[present_info objectForKey:@"contracts"] componentsSeparatedByString:@","];
                            switch (contractArr.count) {
                                case 0:
                                    self.m_strContracts.hidden = YES;
                                    self.m_strContracts1.hidden = YES;
                                    self.m_strContracts2.hidden = YES;
                                    break;
                                case 1:
                                    self.m_strContracts.text = contractArr[0];
                                    self.m_strContracts1.hidden = YES;
                                    self.m_strContracts2.hidden = YES;
                                    break;
                                case 2:
                                    self.m_strContracts.text = contractArr[0];
                                    self.m_strContracts1.text = contractArr[1];
                                    self.m_strContracts2.hidden = YES;
                                    break;
                                case 3:
                                    self.m_strContracts.text = contractArr[0];
                                    self.m_strContracts1.text = contractArr[1];
                                    self.m_strContracts2.text = contractArr[2];
                                    break;
                                default:
                                    break;
                            }
                            
                        } else{
                            self.m_strContracts.hidden = YES;
                            self.m_strContracts1.hidden = YES;
                            self.m_strContracts2.hidden = YES;
                        }
                        self.m_strWatchCount.text = [ NSString stringWithFormat : @"%@人关注",[present_info objectForKey:@"attentcnt"]];
                        if (![[present_info objectForKey:@"avatar"] isKindOfClass:[NSNull class]]) {
                            [self.m_imgLogo sd_setImageWithURL:[NSURL URLWithString:[present_info objectForKey:@"avatar"]]];
                        } else{
                            self.m_imgLogo.image = [UIImage imageNamed:@"viplogo.png"];
                        }
                        NSString *yieldrate = [present_info objectForKey:@"yieldrate"];
                        float f_yieldrate = [yieldrate floatValue];
                        self.m_strWinRate.text = [ NSString stringWithFormat : @"%.2f%%",f_yieldrate];
                        self.m_strSuccRate.text = [ NSString stringWithFormat : @"%.2f%%",[[present_info objectForKey:@"succrate"]floatValue]];
                        
                        NSString *maxgetrate = [present_info objectForKey:@"maxgetrate"];
                        float f_maxgetrate = [maxgetrate floatValue];
                        self.m_strMaxWin.text = [ NSString stringWithFormat : @"%.2f",f_maxgetrate];
                        
                        NSString *maxlossrate = [present_info objectForKey:@"maxlossrate"];
                        float f_maxlossrate = [maxlossrate floatValue];
                        self.m_strMaxLoss.text = [ NSString stringWithFormat : @"%.2f",f_maxlossrate];
                        
                        self.m_strTradeCount.text = [ NSString stringWithFormat : @"%@",[present_info objectForKey:@"tradenum"]];
                        
                        self.m_strWinSort.text = [NSString stringWithFormat : @"%@",[present_info objectForKey:@"sortyield"]];
                        NSString *create_time = [present_info objectForKey:@"create_time"];
                        self.m_strRegTime.text = [TradeUtility parseDateTime:create_time];
                        
                    });
                    hud.customView = [[UIImageView alloc]init];
                    hud.mode = MBProgressHUDModeCustomView;
                    hud.labelText = @"连接服务器";
                    [hud hide:YES afterDelay:1];
                }
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"vip detail error:%@",error);
    }];
    
}

-(void)btnWatch:(id)sender{
    if (_attentionType == 0) {
        _attentionType =1;
    } else{
        _attentionType =0;
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
            if (_attentionType == 1 ) {
                hud.labelText = @"关注成功";

            } else if (_attentionType == 0){
                hud.labelText = @"取消关注成功";
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"+关注"]) {
                    [self.navigationItem.rightBarButtonItem setTitle:@"已关注"];
                } else{
                    [self.navigationItem.rightBarButtonItem setTitle:@"+关注"];
                }
            });
            [hud hide:YES afterDelay:1];
        } else{
            if (_attentionType == 0) {
                _attentionType =1;
            } else{
                _attentionType =0;
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"vip detail setAttention error:%@",error);
    }];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index == [self.pageTitles count])) {
        return nil;
    }
    
    
    
    // Create a new view controller and pass suitable data.
    if(index == 0)
    {
        TradeVipPresentController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TradeVipPresentController"];
        self.pageIndex = index;
    
        return pageContentViewController;
    }
    else if(index == 1)
    {
 
        TradeVipDiscussController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TradeVipDiscussController"];
        self.pageIndex = index;
        
        return pageContentViewController;
    }
    else if(index == 2)
    {
       
        TradeVipContractController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TradeVipContractController"];
        self.pageIndex = index;
        
        return pageContentViewController;
    }
    else
    {
        
        TradeVipHistoryController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TradeVipHistoryController"];
        self.pageIndex = index;
        
        return pageContentViewController;
    }
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    return nil;
    
    NSUInteger index = self.pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    if(self.first_change == 1)
    {
        return nil;
    }
    
    if(index == 3)
    {
        self.last_change = 1;
    }
    else
    {
        self.last_change = 0;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    return nil;
        NSUInteger index = self.pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    if(self.last_change == 1)
    {
        return nil;
    }
    
    if(index == 0)
    {
        self.first_change = 1;
    }
    else
    {
        self.first_change = 0;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onSegmentedControlChange:(id)sender {
    NSInteger Index = [sender selectedSegmentIndex];
    
    NSLog(@"Index %i", Index);
    
    switch (Index) {
            
        case 0:
            
            //表现
        {
            [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            self.pageIndex = 0;
        }

            break;
            
        case 1:
            //观点
            {
                [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self viewControllerAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
                self.pageIndex = 1;
            }
            break;
            
        case 2:
            
            //持仓
        {
            [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self viewControllerAtIndex:2]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            self.pageIndex = 2;
        }

            break;
            
        case 3:
        {
            [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self viewControllerAtIndex:3]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            self.pageIndex = 3;
        }

            //历史
            
            break;
            
        default:
            
            break;
            
    }

    
}
@end

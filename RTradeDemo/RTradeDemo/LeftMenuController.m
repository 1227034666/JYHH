//
//  LeftMenuController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/5.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "LeftMenuController.h"
#import "TradeDiscussController.h"
#import "TradeSortController.h"
#import "TradeActiveController.h"
#import "TradeAlarmController.h"
#import "ViewController.h"

@interface LeftMenuController (){
    NSString *_nickName;
    UIImageView *headImgView;
    UILabel *nickNameLbl;
    NSString *_uid;
}
@property(nonatomic,strong)UITableView *tableView;
@property(strong,nonatomic) NSArray *listData;
@property(strong,nonatomic) NSArray *menuIcon;

@end

@implementation LeftMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userPrivacyNotification) name:@"userPrivacyNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutNotification) name:@"logoutNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginNotification) name:@"loginNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterStartLead) name:@"canStartLeadNotification" object:nil];
    NSLog(@"LiveVipInfoController entered");
    _uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];

    [self ininLoadTable];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUserPicNickname];
}

-(void)logoutNotification{
    [self setUserPicNickname];
}
-(void)loginNotification{
    [self setUserPicNickname];
}
-(void)setUserPicNickname{
    NSString *avatar = [TradeUtility LocalLoadConfigFileByKey:@"avatar" defaultvalue:@"0"];
    if ([avatar isEqualToString:@"0"]) {
        headImgView.image =[UIImage imageNamed:@"Icon.png"];
    } else{
        [headImgView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"Icon.png"]];
    }
    _nickName = [TradeUtility LocalLoadConfigFileByKey:@"nickname" defaultvalue:@"0"];
    if ([_nickName isEqualToString:@"0"]) {
        nickNameLbl.text =@"点击登录";
    } else{
        nickNameLbl.text = _nickName;
    }
    _uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
}

-(void)ininLoadTable{
    self.view.backgroundColor = [UIColor blackColor];
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(20, 0, 400, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = ([UIScreen mainScreen].bounds.size.height -150)/8.0f;
    
    [self setupHeadView];
    [self.view addSubview:self.tableView];
    
    self.listData=[[NSArray alloc] initWithObjects:@"观点",@"排行",@"活动",@"提醒",@"发起领单",@"行情", nil];
    self.menuIcon=[[NSArray alloc] initWithObjects:@"MenuView",@"MenuRank",@"MenuActivity",@"MenuMessage",@"MenuVipFlag",@"MenuTrade", nil];
}

-(void)setupHeadView{
    UIView *headView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 270, 120)];
    headView.backgroundColor = [UIColor clearColor];
    
    headImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 40, 60, 60)];
    headImgView.layer.masksToBounds = YES;
    headImgView.layer.cornerRadius = 30.0f;
    headImgView.contentMode = UIViewContentModeScaleAspectFit;
    
    [headView addSubview:headImgView];
    nickNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(70, 60, 100, 20)];
    nickNameLbl.textColor = [UIColor whiteColor];
    nickNameLbl.textAlignment = NSTextAlignmentLeft;
    nickNameLbl.font = [UIFont systemFontOfSize:15];
    
    [headView addSubview:nickNameLbl];
    UILabel *arrowLbl = [[UILabel alloc]initWithFrame:CGRectMake(200, 60, 10, 20)];
    arrowLbl.textColor = [UIColor whiteColor];
    arrowLbl.textAlignment = NSTextAlignmentLeft;
    arrowLbl.font = [UIFont systemFontOfSize:18];
    arrowLbl.text = @">";
    [headView addSubview:arrowLbl];
    self.tableView.tableHeaderView = headView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapHeadViewAction)];
    [headView addGestureRecognizer:tap];
    
}

-(void)TapHeadViewAction{
    if ([_uid isEqualToString:@"0"]) {
        //未登录
        UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ViewController"];
        loginViewController.modalTransitionStyle =
        UIModalTransitionStyleCoverVertical;
        [appRootVC presentViewController:loginViewController animated:YES completion:^{
            NSLog(@"Present Modal View");
        }];
    } else {
        //已登录
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradePersonalController"];
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listData.count;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
//    view.backgroundColor = [UIColor blackColor];
//    return view;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 20;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text=self.listData[indexPath.row];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor blackColor];
    cell.imageView.image = [UIImage imageNamed:self.menuIcon[indexPath.row]];
    
    return cell;
}

//跳转
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UIViewController *vc ;
    
    switch (indexPath.row){
        case 0:{
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradeDiscussController"];
            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
        }
        break;
        case 1:{
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradeSortController"];
            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
        }
        break;
        case 2:{
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradeActiveController"];
            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
        }
        break;
        case 3:{
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradeAlarmController"];
            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
        }
        break;
        case 4:{
    
            if ([_uid isEqualToString:@"0"]) {
                //登录
                [self loginFunc];
            } else{
                [self enterStartLead];
            }
        }
            break;
//        case 5:
//            //vc = [[OneViewController alloc]init];
//        {
//            UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
//            
//            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ViewController"];
//            loginViewController.modalTransitionStyle =
//            UIModalTransitionStyleCoverVertical;
//            [appRootVC presentViewController:loginViewController animated:YES completion:^{
//                NSLog(@"Present Modal View");
//            }];
//        }
//            break;
        case 5:
            //vc = [[OneViewController alloc]init];
        {            
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *MarketViewCtr = [mainStoryboard instantiateViewControllerWithIdentifier:@"MarketViewCtr"];
            MarketViewCtr.modalTransitionStyle =
            UIModalTransitionStyleCoverVertical;
            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:MarketViewCtr withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
        }
            break;
        case 6:
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
            return;
            break;
    }
    
    //[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
    //                                                         withSlideOutAnimation:self.slideOutAnimationEnabled
    //                                                                 andCompletion:nil];
}

-(void)loginFunc{
    int intuid = [_uid intValue];
    //  if not logged in
    if(intuid <= 0){
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ViewController"];
        //      show next view controler( vip index controller)
        loginViewController.showNextViewCtr = @"PersonalSetVipController";
        loginViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [[SlideNavigationController sharedInstance]presentViewController:loginViewController animated:YES completion:nil];
    }
}

-(void)enterStartLead{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PersonalSetVipController"];
    [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
    _uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
}


#pragma mark - Notification
- (void)userPrivacyNotification{
    [self setUserPicNickname];
}

-(void)dealloc{
    NSLog(@"dealloc:%@",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"userPrivacyNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"logoutNotification" object:nil];
}

@end

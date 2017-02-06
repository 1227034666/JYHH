//
//  TradePersonalController.m
//  RTradeDemo
//
//  Created by administrator on 16/6/29.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "TradePersonalController.h"
#import "TradeUtility.h"

@interface TradePersonalController ()
@property (weak, nonatomic) IBOutlet UILabel *m_strNickname;
@property (strong, nonatomic) IBOutlet UILabel *m_strContractNum;
@property (strong, nonatomic) IBOutlet UILabel *m_strBindStatus;
@property (strong, nonatomic) IBOutlet UIImageView *userImgView;
@property (strong, nonatomic) IBOutlet UIButton *logoutBtn;

@end

@implementation TradePersonalController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logoutBtn.layer.cornerRadius = 10;
    self.logoutBtn.layer.masksToBounds = YES;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    UIBarButtonItem *settingBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(btnSetting:)];
    UIButton *settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsBtn setImage:[UIImage imageNamed:@"IconSettings"] forState:UIControlStateNormal];
    [settingsBtn sizeToFit];
    settingsBtn.frame = CGRectMake(5, 5, 30, 30);
    [settingsBtn addTarget:self action:@selector(btnSetting:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem*rightItem=[[UIBarButtonItem alloc]initWithCustomView:settingsBtn];
//    UIBarButtonItem *settingBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IconSettings"] style:UIBarButtonItemStylePlain target:self action:@selector(btnSetting:)];
    [self.navigationItem setRightBarButtonItem:rightItem];
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //设置左键
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.userImgView.layer.cornerRadius = 34.0f;
    self.userImgView.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnSetUserInfo)];
    [self.userImgView addGestureRecognizer:tap];
    [self showPersonalUserinfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPersonalUserinfo{
    
    NSString *acctCompany =[TradeUtility LocalLoadConfigFileByKey:@"futurename" defaultvalue:@"0"];
    
    if (![acctCompany isEqualToString:@"0"] && acctCompany.length > 0) {
        self.m_strBindStatus.text = acctCompany;
    } else{
        self.m_strBindStatus.text = @"未绑定";
        return;
    }
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               nil];
    NSLog(@"postparam=%@",postparam);
    
//    NSDictionary *retdata = [TradeUtility HTTPSyncPOSTRequest:strURL parameters:postparam];
    [TradeUtility requestWithUrl:@"getContractNum" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary *)result;
        NSLog(@"getContractNum retdata=%@",retdata);
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
                
                NSInteger numOfContract = [retjson[@"num"] integerValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.m_strContractNum.text = [NSString stringWithFormat:@"%li个合约进行中",numOfContract];
                });
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"tradePersonalController error: %@",error);
    }];
    
}

-(void)btnSetting:(id)sender{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PersonalSettingController"];
    [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *nickname = [TradeUtility LocalLoadConfigFileByKey:@"nickname" defaultvalue:@"0"];
    self.m_strNickname.text = nickname;
    NSString *picURL =[TradeUtility LocalLoadConfigFileByKey:@"avatar" defaultvalue:@"0"];
    self.userImgView.contentMode = UIViewContentModeScaleAspectFit;
    if ([picURL isEqualToString:@"0"]) {
        self.userImgView.image = [UIImage imageNamed:@"Icon.png"];
    } else{
        [self.userImgView sd_setImageWithURL:[NSURL URLWithString:picURL] placeholderImage:[UIImage imageNamed:@"Icon.png"]];
    }
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath=%ld",(long)indexPath.row);
    
    if(indexPath.section == 0){
        
    }else if(indexPath.section == 1){
        if(indexPath.row == 0){
            NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
            NSString *aid = [TradeUtility LocalLoadConfigFileByKey:@"accountid" defaultvalue:@"0"];
            
            [TradeUtility LocalSaveConfigFileByKey:@"vipuid" value:uid];
            [TradeUtility LocalSaveConfigFileByKey:@"vipaid" value:aid];
            
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradeVipDetailController"];
            
            [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
        }else if(indexPath.row == 1){
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"RegisterAccountController"];
            [[SlideNavigationController sharedInstance] presentViewController:loginViewController animated:YES completion:nil];
        }
    }else if(indexPath.section == 2){
        if(indexPath.row == 0){
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PersonalViewpointController"];
            [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
        }else if(indexPath.row == 1) {
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PersonalViewpointController"];
            [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
        }
    }else if(indexPath.section == 3){
        if(indexPath.row == 0){
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PersonalTermsController"];
            [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
        }
    }else if(indexPath.section == 4){
        if(indexPath.row == 0){
            NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",@"862160753260"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }else if(indexPath.row == 1){
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PersonalFeedbackController"];
            [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
        }
    }
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

-(void)btnSetUserInfo{
//    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PersonalSetPrivacyController"];
    [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}

- (IBAction)logoutBtnAction:(id)sender {
    [TradeUtility LocalDeleteConfigFile];
    [TradeUtility LocalInitConfigFile];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logoutNotification" object:nil];
    [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
}


@end

//
//  TradeActiveController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/6.
//  Copyright © 2016年 administrator. All rights reserved.
//  活动页面

#import "TradeActiveController.h"

@interface TradeActiveController ()
@property(copy,nonatomic)NSArray *activityData;

@end

@implementation TradeActiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title=@"活动";
    
    self.view.backgroundColor=[UIColor whiteColor];
    [self showActivityList];
}

-(void)showActivityList{
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys: uid, @"uid", nil];
    NSLog(@"postparam=%@", postparam);
    
    [TradeUtility requestWithUrl:@"getActivityList" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
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
                self.activityData = [retjson objectForKey:@"activity_list"];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.tableView reloadData];
//                });
                
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"Trade Sort error: %@",error);
    }];
    
}
    

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)activityData{
    if (_activityData == nil) {
        _activityData = [NSArray array];
    }
    return _activityData;
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

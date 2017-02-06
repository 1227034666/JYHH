//
//  TradeVipPresentController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/12.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "TradeVipPresentController.h"
#import "BrokrnSelfSView.h"

@interface TradeVipPresentController ()
@property (weak, nonatomic) IBOutlet UILabel *m_strStrategy;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgCurl;
@property (weak, nonatomic) IBOutlet UILabel *m_strAvgTradeTime;
@property (weak, nonatomic) IBOutlet UILabel *m_strLeastTradeTime;
@property (weak, nonatomic) IBOutlet UILabel *m_strMaxGet;
@property (weak, nonatomic) IBOutlet UILabel *m_strWinRadio;
@property (weak, nonatomic) IBOutlet UILabel *m_strMaxSuccRate;
@property (weak, nonatomic) IBOutlet UILabel *m_strMaxLostRate;

@property (strong, nonatomic) NSArray *yielddata;
@property (strong, nonatomic) BrokrnSelfSView *brokenView;

@end

@implementation TradeVipPresentController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.yielddata = nil;
    
    [self showLeaderPresent];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLeaderPresent{
    
    NSString *vipuid = [TradeUtility LocalLoadConfigFileByKey:@"vipuid" defaultvalue:@"0"];
    NSString *vipaid = [TradeUtility LocalLoadConfigFileByKey:@"vipaid" defaultvalue:@"0"];
    
//    NSString *strURL = [[NSString alloc] initWithFormat:@"http://inf.91trader.com/rtrade/user/getLeaderPresent"];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               vipuid, @"vipUid",
                               vipaid, @"vipAid",
                               nil];
    NSLog(@"getLeaderPresent postparam=%@",postparam);
    [TradeUtility requestWithUrl:@"getLeaderPresent" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:nil success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"getLeaderPresent retcode=%d",icode);
        if(icode == 0){
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
//            NSLog(@"retjson=%@",retjson);
            if(retjson != nil){
                NSDictionary *present_info = [retjson objectForKey:@"present_info"];
                if(present_info != nil){
                    dispatch_async(dispatch_get_main_queue(), ^{
                    
                        NSString *str_strategy = [present_info objectForKey:@"strategy"];
                        
                        if((NSNull *)str_strategy != [NSNull null]){
                            if((str_strategy != nil)&&([str_strategy length]>0)&&([str_strategy length]<100)){
                                self.m_strStrategy.text = [present_info objectForKey:@"strategy"];
                            }else{
                                self.m_strStrategy.text = @"什么也没留下";
                            }
                        }
                        
                        NSString *avgtradetime = [present_info objectForKey:@"avgtradetime"];
                        int f_avgtradetime = [avgtradetime intValue] / 60;
                        self.m_strAvgTradeTime.text = [ NSString stringWithFormat : @"平均交易时间：%d分钟",f_avgtradetime];
                        
                        NSString *mintradetime = [present_info objectForKey:@"mintradetime"];
                        int f_amintradetime = [mintradetime intValue];
                        self.m_strLeastTradeTime.text = [ NSString stringWithFormat : @"最短交易时间：%d秒",f_amintradetime];
                        self.m_strMaxGet.text = [ NSString stringWithFormat : @"最大持仓单数：%@",[present_info objectForKey:@"maxconnum"]];
                        self.m_strWinRadio.text = [ NSString stringWithFormat : @"胜出交易/占比：%@/%@%%",[present_info objectForKey:@"succtrade"],[present_info objectForKey:@"succtraderatio"]];
                        
                        NSString *maxgetrate = [present_info objectForKey:@"maxgetrate"];
                        float f_maxgetrate = [maxgetrate floatValue] / 100;
                        self.m_strMaxSuccRate.text = [ NSString stringWithFormat : @"最大盈利率：%.2f%%",f_maxgetrate];
                        
                        NSString *maxlossrate = [present_info objectForKey:@"maxlossrate"];
                        float f_maxlossrate = [maxlossrate floatValue] / 100;
                        self.m_strMaxLostRate.text = [ NSString stringWithFormat : @"最大亏损率：%.2f%%",f_maxlossrate];
                        
                        self.yielddata = [present_info objectForKey:@"tradefigure"];
                        [self showContractDataGraph];
                    });
                }
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"trade vip present error:%@",error);
    }];
}

- (void)showContractDataGraph{
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:self.yielddata];
    NSMutableArray *xArr = [NSMutableArray arrayWithCapacity:tmpArr.count];
    NSMutableArray *yArr = [NSMutableArray arrayWithCapacity:tmpArr.count];
    NSMutableArray *pointArr = [NSMutableArray arrayWithCapacity:tmpArr.count];
    
    if(tmpArr != nil)
    {
        if ([tmpArr count]>1) {
            NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"yieldday" ascending:YES]];
            [tmpArr sortUsingDescriptors:sortDescriptors];
        }
//        NSLog(@"tmpArr :%@",tmpArr);
        double yMin = 0;
        double yMax = 0;
        for (int i=0; i< tmpArr.count; i++) {
            NSString *dateStr= tmpArr[i][@"yieldday"];
            NSString *finalDate = [NSString stringWithFormat:@"%@.%@",[dateStr substringWithRange:NSMakeRange(0, 4)],[dateStr substringWithRange:NSMakeRange(4, 2)]];
            [xArr addObject:finalDate];
            NSString *yieldRate = tmpArr[i][@"yieldrate"];
            [pointArr addObject:yieldRate];
            double yRate = [tmpArr[i][@"yieldrate"] doubleValue];
            if (yRate > yMax) {
                yMax = yRate;
            }
            
            if (yRate < yMin) {
                yMin = yRate;
            }
            
            if (yMin +10 > yMax) {
                yMax = yMin + 10;
            }
        }
        yMin-=10;
        double diff = (yMax - yMin)/5.0f;
        
        for (NSInteger i=0; i<6; i++) {
            NSString *str = [NSString stringWithFormat:@"%.1f",yMin + i*diff];
            [yArr addObject:str];
        }
    }
    
    //    NSLog(@"%@",xArr);
    //    NSLog(@"%@",yArr);
    //    NSLog(@"%@",pointArr);
    [self showContractDataGraph:[xArr copy] YArray:[yArr copy] PointArray:[pointArr copy]];
    
}

- (void)showContractDataGraph:(NSArray *)xArray YArray:(NSArray *)yArray PointArray:(NSArray *)pArray{
    if (pArray.count == 0) {
        return;
    }
    //    CGRect rect = CGRectMake(self.contentView.frame.origin.x+20, self.contentView.frame.origin.y+61,
    //                             self.contentView.frame.size.width,
    //                             self.contentView.frame.size.height - 125)
    
    //    self.brokenView.unitxArray = @[@"2",@"4",@"6",@"8",@"10",@"12"];
    //    self.brokenView.unityArray = @[@"0",@"10",@"20",@"30",@"40",@"50",@"60"];
    //    self.brokenView.pointArray = @[@"31",@"51",@"42",@"59",@"47",@"40"];
    [self.brokenView clearScreen];
    self.brokenView.unitxArray = [xArray mutableCopy];
    self.brokenView.unityArray = [yArray mutableCopy];
    self.brokenView.pointArray = [pArray mutableCopy];
    
}

-(BrokrnSelfSView*)brokenView{
    if (_brokenView == nil) {
//        CGRect rect = CGRectMake(self.m_imgCurl.frame.origin.x, self.m_imgCurl.frame.origin.y,
//                                 self.m_imgCurl.frame.size.width,
//                                 self.m_imgCurl.frame.size.height);
        
        _brokenView = [[BrokrnSelfSView alloc]initWithFrame:self.m_imgCurl.bounds];
        _brokenView.userInteractionEnabled = NO;
        [self.m_imgCurl addSubview:_brokenView];
    }
    return _brokenView;
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

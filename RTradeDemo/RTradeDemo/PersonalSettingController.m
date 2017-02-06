//
//  PersonalSettingController.m
//  RTradeDemo
//
//  Created by administrator on 16/6/29.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "PersonalSettingController.h"
#import "TradeUtility.h"

@interface PersonalSettingController ()
@property (weak, nonatomic) IBOutlet UILabel *m_strIsVipText;
@property (weak, nonatomic) IBOutlet UILabel *cacheVolumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *appVersionNumber;

@end

@implementation PersonalSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString * isvip = [TradeUtility LocalLoadConfigFileByKey:@"isvip" defaultvalue:@"0"];
    
    if([isvip isEqualToString:@"0"]){
        self.m_strIsVipText.text = @"未开启";
    }else{
        self.m_strIsVipText.text = @"已开启";
    }
    self.cacheVolumnLabel.text = [self getCacheSize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSString *isvip = [TradeUtility LocalLoadConfigFileByKey:@"isvip" defaultvalue:@"0"];
    if([isvip isEqualToString:@"0"])
    {
        self.m_strIsVipText.text = @"未开启";
    }
    else
    {
        self.m_strIsVipText.text = @"已开启";
    }
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath=%ld",(long)indexPath.row);
    
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            //set isvip
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PersonalSetVipController"];
            [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
        }
    }
    else if(indexPath.section == 1){
         if(indexPath.row == 1){
             UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PersonalSetAlarmController"];
             [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
         }
    }
    else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"是否清除缓存?" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *cacheFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
                if ([fileManager fileExistsAtPath:cacheFilePath]) {
                    NSArray *childerFiles=[fileManager subpathsAtPath:cacheFilePath];
                    for (NSString *fileName in childerFiles) {
                        //如有需要，加入条件，过滤掉不想删除的文件
                        NSString *absolutePath=[cacheFilePath stringByAppendingPathComponent:fileName];
                        [fileManager removeItemAtPath:absolutePath error:nil];
                    }
                }
//                [[SDImageCache sharedImageCache] cleanDisk];
//                [fileManager removeItemAtPath:cacheFilePath error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.cacheVolumnLabel.text = self.getCacheSize;
                });
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

//get cache size
-(NSString *)getCacheSize{
    
    long long sumSize =0;
    
    NSString * cacheFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator * fileEnumerator = [fileManager enumeratorAtPath:cacheFilePath];
    
    for (NSString *subPath in fileEnumerator) {
        NSString *filePath = [cacheFilePath stringByAppendingPathComponent:subPath];
        long long fileSize = [[fileManager attributesOfItemAtPath:filePath error:nil]fileSize];
        sumSize += fileSize;
    }
    NSLog(@"size : %lld",sumSize);
    float size_m = sumSize/(1024*1024);
    return [NSString stringWithFormat:@"%.2fM",size_m];
}



@end

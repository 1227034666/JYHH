//
//  CommonSetTextController.m
//  RTradeDemo
//
//  Created by administrator on 16/7/8.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "CommonSetTextController.h"
#import "TradeUtility.h"

@interface CommonSetTextController ()
@property (weak, nonatomic) IBOutlet UITextView *m_strSettingText;
@property (weak, nonatomic) IBOutlet UILabel *m_strSettingTips;

@end

@implementation CommonSetTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *settingOperType = [TradeUtility LocalLoadConfigFileByKey:@"settingOperType" defaultvalue:@"0"];
    NSString *settingOperParam = [TradeUtility LocalLoadConfigFileByKey:@"settingOperParam" defaultvalue:@"0"];
    
    if([settingOperType  isEqual: @"nickname"])
    {
        self.title = @"设置昵称";
        self.m_strSettingText.text = settingOperParam;
        self.m_strSettingTips.text = @"(请输入不超过20字内容)";
    }
    
    UIBarButtonItem *publishBtn = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(btnPublish:)];
    [self.navigationItem setRightBarButtonItem:publishBtn];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnPublish:(id)sender
{
    [TradeUtility LocalSaveConfigFileByKey:@"nickname" value:self.m_strSettingText.text];
    
    [[self navigationController] popViewControllerAnimated:YES];
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

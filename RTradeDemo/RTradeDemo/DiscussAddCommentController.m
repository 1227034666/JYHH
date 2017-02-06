//
//  DiscussAddCommentController.m
//  RTradeDemo
//
//  Created by administrator on 16/6/29.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "DiscussAddCommentController.h"
#import "TradeUtility.h"

@interface DiscussAddCommentController ()
@property (weak, nonatomic) IBOutlet UITextView *m_strCommentText;

@end

@implementation DiscussAddCommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *publishBtn = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(btnPublish:)];
    [self.navigationItem setRightBarButtonItem:publishBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnPublish:(id)sender
{
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    NSString *viewId = [TradeUtility LocalLoadConfigFileByKey:@"curViewId" defaultvalue:@"0"];
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"http://inf.91trader.com/rtrade/user/publishComment"];
    
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               viewId, @"viewId",
                               self.m_strCommentText.text, @"commentText",
                               nil];
    
    NSLog(@"postparam=%@",postparam);
    
    NSDictionary *retdata = [TradeUtility HTTPSyncPOSTRequest:strURL parameters:postparam];
    
    if(retdata == nil)
    {
        NSLog(@"retdata=%@",retdata);
        [TradeUtility ShowNetworkErrDlg:self];
        return;
    }
    
    NSString *retcode = [retdata objectForKey:@"re_code"];
    int icode = [retcode intValue];
    NSLog(@"retcode=%d",icode);
    if(icode == 0)
    {
        NSDictionary *retjson = [retdata objectForKey:@"re_json"];
        NSLog(@"retjson=%@",retjson);
        if(retjson != nil)
        {
            NSString *ret_commentid = [retjson objectForKey:@"commentId"];
            int iretuid = [ret_commentid intValue];
            NSLog(@"iretcommentid=%d",iretuid);
            
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"Modal View done");
        }];
        
    }
    else
    {
        //初始化提示框；
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"发表评论失败" preferredStyle:  UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击按钮的响应事件；
        }]];
        
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];
        
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

@end

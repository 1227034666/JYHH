//
//  TradeMainController.m
//  RTradeDemo
//
//  Created by administrator on 16/5/3.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "TradeMainController.h"
#import "TradeMainCustomCell.h"

@interface TradeMainController ()

@end

@implementation TradeMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    
    //self.title=@"首页";
    
    //自定义右键按钮组
/*    UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    [tools setTintColor:[self.navigationController.navigationBar tintColor]];
    [tools setAlpha:[self.navigationController.navigationBar alpha]];
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:4];
    
    UIBarButtonItem *anotherButton1 = [[UIBarButtonItem alloc] initWithTitle:@"关注" style:UITabBarSystemItemContacts target:self action:@selector(getVIPList:)];
    
    UIBarButtonItem *anotherButton2 = [[UIBarButtonItem alloc] initWithTitle:@"热门" style:UITabBarSystemItemContacts target:self action:@selector(getVIPList:)];
    
    UIBarButtonItem *anotherButton3 = [[UIBarButtonItem alloc] initWithTitle:@"最新" style:UITabBarSystemItemContacts target:self action:@selector(getVIPList:)];
    
    UIBarButtonItem *anotherButton4 = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UITabBarSystemItemContacts target:self action:@selector(doLogin:)];
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithTitle:@"          " style: UITabBarSystemItemContacts target:nil action:nil];
    
    UIBarButtonItem *flexItem1 = [[UIBarButtonItem alloc] initWithTitle:@"  " style: UITabBarSystemItemContacts target:nil action:nil];
    
    //[buttons addObject:flexItem];
    [buttons addObject:anotherButton1];
    
    [buttons addObject:flexItem1];
    [buttons addObject:anotherButton2];
    
    [buttons addObject:flexItem1];
    [buttons addObject:anotherButton3];
    
    [buttons addObject:flexItem];
    
    [buttons addObject:anotherButton4];
    
    [tools setItems:buttons animated:NO];
    
    UIBarButtonItem *myBtn = [[UIBarButtonItem alloc] initWithCustomView:tools];
    [SlideNavigationController sharedInstance].rightBarButtonItem = myBtn;

 */
    
    //设置分段菜单
    NSArray *segmentedArray = [NSArray arrayWithObjects:@"关注",@"热门",@"最新",nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    segmentedControl.frame = CGRectMake(0.0, 0.0, 290, 30.0);
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.tintColor = [UIColor grayColor];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl addTarget:self  action:@selector(indexDidChangeForSegmentedControl:)
               forControlEvents:UIControlEventValueChanged];
    //方法1
    //[self.navigationController.navigationBar.topItem setTitleView:segmentedControl];
    //方法2
    [self.navigationItem setTitleView:segmentedControl];
    
    //设置右键菜单
    
    
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)indexDidChangeForSegmentedControl:(UISegmentedControl *)Seg{
    
    NSInteger Index = Seg.selectedSegmentIndex;
    
    NSLog(@"Index %i", Index);
    
    switch (Index) {
            
        case 0:
            
            //关注
            
            break;
            
        case 1:
            
            //热门
            
            break;
            
        case 2:
            
            //最新
            
            break;
            
        default:
            
            break;
            
    }
    
}

- (void)getVIPList:(id)sender
{
    
}

- (void)doLogin:(id)sender
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ViewController"];
    loginViewController.modalTransitionStyle =
    UIModalTransitionStyleCoverVertical;
    [self presentViewController:loginViewController animated:YES completion:^{
        NSLog(@"Present Modal View");
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return YES;
}



@end

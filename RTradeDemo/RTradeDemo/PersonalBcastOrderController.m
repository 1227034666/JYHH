//
//  PersonalBcastOrderController.m
//  RTradeDemo
//
//  Created by administrator on 16/8/7.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "PersonalBcastOrderController.h"
#import "BcastLeadOrderController.h"
#import "BcastFollowOrderController.h"

@interface PersonalBcastOrderController ()
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property NSUInteger pageIndex;
- (IBAction)doLeading:(id)sender;
- (IBAction)doFollow:(id)sender;

@end

@implementation PersonalBcastOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.automaticallyAdjustsScrollViewInsets=YES;
    self.title = @"直播订单";
    
    self.pageTitles = @[@"领单订单", @"跟单订单"];
    self.pageIndex = 0;
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BcastPageViewController"];
    self.pageViewController.dataSource = self;
    
    BcastLeadOrderController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 100);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    
    UIBarButtonItem *publishBtn = [[UIBarButtonItem alloc] initWithTitle:@"提现" style:UIBarButtonItemStylePlain target:self action:@selector(btnLoadCash:)];
    [self.navigationItem setRightBarButtonItem:publishBtn];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnLoadCash:(id)sender
{

}

-(void)btnFollowHistory:(id)sender
{
    
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index == [self.pageTitles count])) {
        return nil;
    }
    
    
    
    // Create a new view controller and pass suitable data.
    if(index == 0)
    {
        BcastLeadOrderController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BcastLeadOrderController"];
        self.pageIndex = index;
        
        return pageContentViewController;
    }
    else
    {
        
        BcastFollowOrderController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BcastFollowOrderController"];
        self.pageIndex = index;
        
        return pageContentViewController;
    }
    
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    return nil;
    
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    return nil;
    
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

- (IBAction)doLeading:(id)sender {
    
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageIndex = 0;
    
    UIBarButtonItem *publishBtn = [[UIBarButtonItem alloc] initWithTitle:@"提现" style:UIBarButtonItemStylePlain target:self action:@selector(btnLoadCash:)];
    [self.navigationItem setRightBarButtonItem:publishBtn];
}

- (IBAction)doFollow:(id)sender {
    
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self viewControllerAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageIndex = 1;
    
    UIBarButtonItem *publishBtn = [[UIBarButtonItem alloc] initWithTitle:@"历史" style:UIBarButtonItemStylePlain target:self action:@selector(btnFollowHistory:)];
    [self.navigationItem setRightBarButtonItem:publishBtn];
}
@end

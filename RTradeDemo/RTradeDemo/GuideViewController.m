//
//  GuideViewController.m
//  RTradeDemo
//
//  Created by Michael Luo on 10/10/16.
//  Copyright © 2016 administrator. All rights reserved.
// 引导页界面

#import "GuideViewController.h"
#import "TradeMainNaviController.h"
#import "AppDelegate.h"
#import "UIViewExt.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation GuideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
    [self setupContent];
    [self setupScrollView];
    [self setupScrollViewContent];
    [self setupPageControl];
}

#pragma mark - setup part.
- (void)setupContent
{
    self.images = [NSMutableArray arrayWithArray:@[@"Guide1", @"Guide2", @"Guide3"]];
}

- (void)setupScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 20)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(kScreenWidth * self.images.count, kScreenHeight - 20);
    [self.view addSubview:self.scrollView];
}

- (void)setupScrollViewContent
{
    for (NSInteger i = 0; i < self.images.count; i++)
    {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i * kScreenWidth, 0, kScreenWidth, kScreenHeight-20)];
        iv.userInteractionEnabled = YES;
        iv.image = [UIImage imageNamed:self.images[i]];
        
        [self.scrollView addSubview:iv];
        if (i == self.images.count - 1) {
            UIButton *startBtn = [[UIButton alloc]initWithFrame:CGRectMake(iv.left +kScreenWidth/2 -70, kScreenHeight/2 - 70, 140, 45)];
            startBtn.backgroundColor =[UIColor colorWithRed:216/255.0 green:40/255.0 blue:61/255.0 alpha:1];
            startBtn.layer.cornerRadius = 10;
            [startBtn setTitle:@"立即开启" forState:UIControlStateNormal];
            [startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [startBtn addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:startBtn];
        }
    }
}

-(void)btnClicked{
  
    TradeMainNaviController *navCtr = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"TradeMainNavi"];
    [UIView transitionWithView:self.view.window duration:.3 options:UIViewAnimationOptionTransitionNone animations:^{
        [UIApplication sharedApplication].keyWindow.rootViewController = navCtr;
//        self.view.window.rootViewController = tabBarCtr;
    } completion:nil];
    
    
}

-(void)setupPageControl{
    
    //2:创建pageCtr
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth,30)];
    
    //属性
    self.pageControl.numberOfPages = self.images.count;
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.currentPageIndicatorTintColor  = [UIColor blackColor];
    //添加值改变的方法
    [self.pageControl addTarget:self action:@selector(pageCtrAction) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageControl];
    
}

- (void)pageCtrAction{
    
    //获取当前的pageCtr.currentPage 当前页数
    CGPoint point = CGPointMake(self.pageControl.currentPage * kScreenWidth, 0);
    self.scrollView.contentOffset = point;
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = scrollView.contentOffset.x / kScreenWidth;
}

@end

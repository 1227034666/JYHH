//
//  JYTabBarViewController.m
//  RJTrader
//
//  Created by iMac on 17/2/4.
//  Copyright © 2017年 administrator. All rights reserved.

#import "JYTabBarViewController.h"
#import "JYHomePageViewController.h"
#import "JYMarketListViewController.h"
#import "JYFindViewController.h"
#import "JYPersonHomeViewController.h"

#import "JYNavigationViewController.h"

@interface JYTabBarViewController ()

@end

@implementation JYTabBarViewController


+(void)load{
    
    UITabBarItem *item=[UITabBarItem appearanceWhenContainedIn:self, nil];
    
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:JYColor(48, 170, 68, 1),NSFontAttributeName:Font(30)} forState:UIControlStateSelected];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAllChildViewController];
    
    self.selectedIndex = 0;
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex{
    
    [super setSelectedIndex:selectedIndex];
    [JYUserDefaults setObject:@(selectedIndex + 1) forKey:@"lastTabbarSelectedIndex"];
    [JYUserDefaults synchronize];
}

- (void)setupAllChildViewController{
    
    JYHomePageViewController *homeVc = [[JYHomePageViewController alloc] init];
    [self addChildViewControllerWithVc:homeVc originalImage:@"orderClass_tabbar_deselect" selectedImageName:@"orderClass_tabbar_select" title:@"首页"];
    
    JYMarketListViewController *marketListVc = [[JYMarketListViewController alloc] init];
    [self addChildViewControllerWithVc:marketListVc originalImage:@"theme_tabbar_deselect" selectedImageName:@"theme_tabbar_select" title:@"行情"];
    
    
    
    
    
    JYFindViewController *findVc = [[JYFindViewController alloc] init];
    [self addChildViewControllerWithVc:findVc originalImage:@"experienceCourse_tabbar_deselect" selectedImageName:@"experienceCourse_tabbar_select" title:@"发现"];
    
    JYPersonHomeViewController *personHomeVc = [[JYPersonHomeViewController alloc] init];
    [self addChildViewControllerWithVc:personHomeVc originalImage:@"theme_tabbar_deselect" selectedImageName:@"theme_tabbar_select" title:@"我的"];
}

-(void)addChildViewControllerWithVc:(UIViewController *)Vc originalImage:(NSString *)imageName selectedImageName:(NSString *)selectedImageName title:(NSString *)title{
    
    Vc.title = title;
    
//    Vc.tabBarItem.image=[UIImage orignalImageWithName:imageName];
//    
//    Vc.tabBarItem.selectedImage =[UIImage orignalImageWithName:selectedImageName];
    
    Vc.tabBarItem.image=[UIImage imageNamed:imageName];
    Vc.tabBarItem.selectedImage =[UIImage imageNamed:selectedImageName];
    JYNavigationViewController *Nav=[[JYNavigationViewController alloc]initWithRootViewController:Vc];
    [self addChildViewController:Nav];
}

@end

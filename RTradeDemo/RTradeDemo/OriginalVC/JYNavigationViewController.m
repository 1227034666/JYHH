//
//  JYNavigationViewController.m
//  RJTrader
//
//  Created by iMac on 17/2/4.
//  Copyright © 2017年 administrator. All rights reserved.
//

#import "JYNavigationViewController.h"

@interface JYNavigationViewController ()<UIGestureRecognizerDelegate>

@end

@implementation JYNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self.interactivePopGestureRecognizer.delegate action:@selector(handleNavigationTransition:)];
    
    [self.view addGestureRecognizer:pan];
    pan.delegate = self;
    self.interactivePopGestureRecognizer.enabled = NO;
    self.navigationBarHidden = YES;
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if (self.childViewControllers.count > 0) {
        
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    UIViewController *Vc = [self.childViewControllers lastObject];
    NSArray *arr = @[
//                     NSClassFromString(@"CCSubmitOrderViewController"),  设置触发返回手势的内容
                    
                     ];
    
    if ([arr containsObject:[Vc class]]) {
        return NO;
    }
    return self.childViewControllers.count > 1;
}


-(void)back{
    
    [self popViewControllerAnimated:YES];
    
}


@end

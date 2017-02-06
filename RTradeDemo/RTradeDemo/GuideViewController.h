//
//  GuideViewController.h
//  RTradeDemo
//
//  Created by Michael Luo on 10/10/16.
//  Copyright © 2016 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *images;

@end

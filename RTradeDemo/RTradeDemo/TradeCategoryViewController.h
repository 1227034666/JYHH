//
//  TradeCategoryViewController.h
//  RTradeDemo
//
//  Created by Michael Luo on 10/17/16.
//  Copyright © 2016 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CategoryBlock)(NSString *);

@class MBProgressHUD;
@interface TradeCategoryViewController : UITableViewController<UISearchBarDelegate>
{
    MBProgressHUD *_hud;
}
@property (nonatomic, strong) UISearchBar *searchBar;//搜索框
@property(nonatomic, assign) BOOL isSearch;//是否是search状态
@property (nonatomic,strong)CategoryBlock categoryBlock;
@end

//
//  FutureCompanyController.h
//  RTradeDemo
//
//  Created by Michael Luo on 11/3/16.
//  Copyright © 2016 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CompanyBlock)(NSString *);
@class MBProgressHUD;

@interface FutureCompanyController : UITableViewController{
    MBProgressHUD *_hud;
}
@property (nonatomic, strong) UISearchBar *searchBar;//搜索框
@property(nonatomic, assign) BOOL isSearch;//是否是search状态
@property (nonatomic,strong)CompanyBlock companyBlock;
@property (nonatomic, assign) BOOL slideOutAnimationEnabled;
@end

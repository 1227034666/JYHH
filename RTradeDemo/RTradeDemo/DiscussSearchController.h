//
//  DiscussSearchController.h
//  RTradeDemo
//
//  Created by administrator on 16/6/28.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscussSearchController : UITableViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) BOOL slideOutAnimationEnabled;
@end

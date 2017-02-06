//
//  TradeIndexFilterViewController.h
//  RTradeDemo
//
//  Created by Michael Luo on 9/28/16.
//  Copyright © 2016 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^AllFilterBlock)(NSMutableDictionary *);

@interface TradeIndexFilterViewController : UITableViewController

@property (nonatomic, assign) BOOL slideOutAnimationEnabled;

@property (nonatomic,strong)AllFilterBlock allFilterBlock;

@end

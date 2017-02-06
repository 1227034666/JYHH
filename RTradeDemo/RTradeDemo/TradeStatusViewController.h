//
//  TradeStatusViewController.h
//  RTradeDemo
//
//  Created by Michael Luo on 9/28/16.
//  Copyright © 2016 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^MyBlock)(NSString *);

@interface TradeStatusViewController : UITableViewController

@property (nonatomic,strong)MyBlock filterBlock;
@end

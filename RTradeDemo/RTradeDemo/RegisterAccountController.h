//
//  RegisterAccountController.h
//  RTradeDemo
//
//  Created by Michael Luo on 11/3/16.
//  Copyright © 2016 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterAccountController : UITableViewController
@property (nonatomic, copy) NSDictionary *itemData;
@property (nonatomic,strong) NSString *nextViewController;
@property (nonatomic, assign) BOOL slideOutAnimationEnabled;
@end

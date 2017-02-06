//
//  RegAccountController.h
//  RTradeDemo
//
//  Created by administrator on 16/5/1.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RegAccountController : UIViewController
@property (nonatomic, copy) NSDictionary *itemData;
@property (nonatomic,strong) NSString *nextViewController;
@property (nonatomic, assign) BOOL slideOutAnimationEnabled;
- (IBAction)doSubmitAccount:(id)sender;

@end

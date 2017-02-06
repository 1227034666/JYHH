//
//  AppDelegate.h
//  RTradeDemo
//
//  Created by administrator on 16/5/1.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WXDelegate <NSObject>

-(void)loginSuccessByCode:(NSString *)code;
//-(void)shareSuccessByCode:(int) code;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, weak) id<WXDelegate> wxDelegate;

-(AFHTTPSessionManager *)sharedHTTPSession;


@end


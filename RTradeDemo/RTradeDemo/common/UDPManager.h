//
//  UDPManager.h
//  RJTrader
//
//  Created by iMac on 17/1/19.
//  Copyright © 2017年 administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCDAsyncUdpSocket;
@interface UDPManager : NSObject

+ (instancetype)shareManager;

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;

@end

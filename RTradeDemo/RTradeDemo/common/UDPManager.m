//
//  UDPManager.m
//  RJTrader
//
//  Created by iMac on 17/1/19.
//  Copyright © 2017年 administrator. All rights reserved.
//

#import "UDPManager.h"
#import "GCDAsyncUdpSocket.h"

@implementation UDPManager


+ (instancetype)shareManager{
    
    static UDPManager *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc]init];
    });
    return instance;
}

-(instancetype)init{
    if (self = [super init]) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] init];
    }
    return self;
}


@end

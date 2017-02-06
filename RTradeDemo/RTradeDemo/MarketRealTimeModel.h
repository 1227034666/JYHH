//
//  MarketRealTimeModel.h
//  RTradeDemo
//
//  Created by iMac on 16/12/27.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarketRealTimeModel : NSObject

@property (strong, nonatomic) NSString *contractName;
@property (strong, nonatomic) NSString *contractCode;
@property (strong, nonatomic) NSString *contractPrice;
@property (strong, nonatomic) NSString *contractUpDownRate;
@property (strong, nonatomic) NSString *contractWarehoused;

@end

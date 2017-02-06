//
//  MarketSelectionModel.h
//  RTradeDemo
//
//  Created by iMac on 16/12/28.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarketSelectionModel : NSObject

@property (strong, nonatomic) NSString *contractName;
@property (strong, nonatomic) NSString *contractCode;
@property (assign, nonatomic) NSNumber *isSubscribed;

@end

//
//  CellVipContractModel.h
//  RTradeDemo
//
//  Created by iMac on 17/1/4.
//  Copyright © 2017年 administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellVipContractModel : NSObject
@property (strong, nonatomic) NSString *conCode;
@property (strong, nonatomic) NSString *conName;
@property (strong, nonatomic) NSString *tradeType;
@property (strong, nonatomic) NSString *tradePrice;
@property (strong, nonatomic) NSString *tradeVolume;
@property (strong, nonatomic) NSString *holdTime;
@end

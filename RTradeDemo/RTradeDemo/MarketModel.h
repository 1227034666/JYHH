//
//  MarketModel.h
//  RTradeDemo
//
//  Created by iMac on 16/11/23.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarketModel : NSObject
@property(nonatomic,copy)NSString *Ask;  //卖价
@property(nonatomic,copy)NSString *AskVolume;
@property(nonatomic,copy)NSString *Bid;  //买价
@property(nonatomic,copy)NSString *BidVolume;
@property(nonatomic,copy)NSString *OpenInterest;   //当日持仓
@property(nonatomic,copy)NSString *TotalOpenInterest;
@property(nonatomic,copy)NSString *concode; //合约号码
@property(nonatomic,copy)NSString *conname; //合约名称
@property(nonatomic,copy)NSString *convalue;  //最新价
@property(nonatomic,copy)NSString *updown;  //涨跌
@property(nonatomic,copy)NSString *updownrate;
@property(nonatomic,copy)NSString *preSettlementPrice;

@end

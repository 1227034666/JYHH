//
//  LeadTradeModel.h
//  RTradeDemo
//
//  Created by iMac on 16/12/26.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeadTradeModel : NSObject

@property(nonatomic,copy)NSString *transaction_price; //价格
@property(nonatomic,copy)NSString *transaction_volume;  //手数
@property(nonatomic,copy)NSString *concode;
@property(nonatomic,copy)NSString *direction;    //1多空2
@property(nonatomic,copy)NSString *transaction_state;  //2开 4，5平仓
@property(nonatomic,copy)NSString *trade_date;  //时间
@property(nonatomic,copy)NSString *trade_time;


@end

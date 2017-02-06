//
//  LeadTradeInforModel.h
//  RTradeDemo
//
//  Created by iMac on 16/12/21.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeadTradeInforModel : NSObject
@property(nonatomic,copy)NSString *tradeTime;  //时间
@property(nonatomic,copy)NSString *tradePrice; //价格
@property(nonatomic,copy)NSString *tradeType;  //买卖
@property(nonatomic,copy)NSString *tradeQty;   //手数
@end

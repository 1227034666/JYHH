//
//  MAline.h
//  YYStock  ( https://github.com/yate1996 )
//
//  Created by yate1996 on 16/10/8.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAline : UIView

//在折线图上添加圆圈和提示标签
@property(nonatomic,strong)NSArray * pointsArray;
- (instancetype)initWithContext:(CGContextRef)context;

- (void)drawWithColor:(UIColor *)lineColor maPositions:(NSArray *)maPositions;

- (void)drawWithColor:(UIColor *)lineColor dotPositions:(NSArray *)dotPositions;

@end

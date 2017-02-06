//
//  YYStockScrollView.m
//  YYStock  ( https://github.com/yate1996 )
//
//  Created by yate1996 on 16/10/7.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import "YYStockScrollView.h"
#import "UIColor+YYStockTheme.h"
#import "YYStockVariable.h"
#import "Masonry.h"
@implementation YYStockScrollView


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.isShowBgLine) {
        [self drawBgLines];
    }
}

- (void)drawBgLines {
    if (self.stockType == YYStockTypeLine) {
        //单纯的画了一下背景线
        CGContextRef ctx = UIGraphicsGetCurrentContext();
//        CGContextSetStrokeColorWithColor(ctx, [UIColor YYStock_bgLineColor].CGColor);
        CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
        CGContextSetLineWidth(ctx, 0.5);
        CGFloat unitHeight = (self.frame.size.height*0.9)/6;
        
        const CGPoint line1[] = {CGPointMake(0, 1),CGPointMake(self.contentSize.width, 1)};
        const CGPoint line2[] = {CGPointMake(0, unitHeight),CGPointMake(self.contentSize.width, unitHeight)};
        const CGPoint line3[] = {CGPointMake(0, unitHeight*2),CGPointMake(self.contentSize.width, unitHeight*2)};
        const CGPoint line4[] = {CGPointMake(0, unitHeight*3),CGPointMake(self.contentSize.width, unitHeight*3)};
        const CGPoint line5[] = {CGPointMake(0, unitHeight*4),CGPointMake(self.contentSize.width, unitHeight*4)};
        const CGPoint line6[] = {CGPointMake(0, unitHeight*5),CGPointMake(self.contentSize.width, unitHeight*5)};
        const CGPoint line7[] = {CGPointMake(0, unitHeight*6),CGPointMake(self.contentSize.width, unitHeight*6)};
//        const CGPoint line6[] = {CGPointMake(0, self.frame.size.height * (1 - [YYStockVariable volumeViewRadio]) ),CGPointMake(self.contentSize.width, self.frame.size.height * (1 - [YYStockVariable volumeViewRadio]))};
        
        CGContextStrokeLineSegments(ctx, line1, 2);
        CGContextStrokeLineSegments(ctx, line2, 2);
        CGContextStrokeLineSegments(ctx, line3, 2);
        CGContextStrokeLineSegments(ctx, line4, 2);
        CGContextStrokeLineSegments(ctx, line5, 2);
        CGContextStrokeLineSegments(ctx, line6, 2);
        CGContextStrokeLineSegments(ctx, line7, 2);
    }
//
    if (self.stockType == YYStockTypeTimeLine) {
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
//        CGContextSetStrokeColorWithColor(ctx, [UIColor YYStock_averageTimeLineColor].CGColor);
        CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
        CGFloat lengths[] = {3,3};
        CGContextSetLineDash(ctx, 0, lengths, 1);
        CGContextSetLineWidth(ctx, 1.5);
        CGFloat unitHeight = (self.frame.size.height*[YYStockVariable lineMainViewRadio] - 15)/2;
        const CGPoint line1[] = {CGPointMake(0, unitHeight),CGPointMake(self.frame.size.width, unitHeight)};
        CGContextStrokeLineSegments(ctx, line1, 1);
        
        //////////////// 画横向分割线 ///////////////////////
        CGContextRef ctx1 = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(ctx1, [UIColor whiteColor].CGColor);
        CGFloat separateMargin = (self.frame.size.height -15) / 6;
        for (int i = 0; i < 7; i++) {
            if (i != 3) {
                
                [self drawLine:ctx1
                    startPoint:CGPointMake(0, self.frame.size.height -15  - i *(separateMargin))
                      endPoint:CGPointMake(0+self.frame.size.width, self.frame.size.height -15  - (i) *(separateMargin))
                     lineColor:[UIColor whiteColor]
                     lineWidth:.1];
                    }
        }
    }
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        [self addSubview:_contentView];
//        _contentView.frame = self.bounds;
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _contentView;
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
//    CGRect rect = self.bounds;
//    CGSize size = contentSize;
//    rect.size.width = size.width;
//    _contentView.frame = rect;
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self);
        make.width.equalTo(@(contentSize.width));
        make.height.equalTo(self);
    }];

}

- (void)drawLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor lineWidth:(CGFloat)width {
    
    CGContextSetShouldAntialias(context, YES ); //抗锯齿
    CGColorSpaceRef Linecolorspace1 = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, Linecolorspace1);
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    CGColorSpaceRelease(Linecolorspace1);
}

-(void)setSelfRect:(CGRect)selfRect{
    self.frame = selfRect;
}

@end

//
//  MAline.m
//  YYStock  ( https://github.com/yate1996 )
//
//  Created by yate1996 on 16/10/8.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import "MAline.h"
#import "YYStockConstant.h"

@interface MAline()
/**
 绘制上下文
 */
@property (nonatomic, assign) CGContextRef context;

@property (nonatomic, strong) NSArray *MAPositions;
@property (nonatomic, strong) NSArray *dotPositions;

@property (nonatomic, strong) UIColor *lineColor;
@end

@implementation MAline

/**
 *  根据context初始化画线
 */
- (instancetype)initWithContext:(CGContextRef)context
{
    self = [super init];
    if(self)
    {
        self.context = context;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect: rect];

}

- (void)drawWithColor:(UIColor *)lineColor maPositions:(NSArray *)maPositions{
    _MAPositions = maPositions;
    _lineColor = lineColor;
    
    if(!self.context || !self.MAPositions) {
        return;
    }
    
    CGContextSetStrokeColorWithColor(self.context, self.lineColor.CGColor);
    
    CGContextSetLineWidth(self.context, YYStockMALineLineWidth);
    
    CGPoint firstPoint = [self.MAPositions.firstObject CGPointValue];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, firstPoint.x, firstPoint.y);
    
    for (NSInteger idx = 1; idx < self.MAPositions.count ; idx++)
    {
        CGPoint point = [self.MAPositions[idx] CGPointValue];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    
    CGContextStrokePath(self.context);
    
    
}

- (void)drawWithColor:(UIColor *)dotColor dotPositions:(NSArray *)dotPositions{
    _dotPositions =dotPositions;
    if (_dotPositions != nil) {
        for (NSInteger i=0; i<_dotPositions.count; i++) {
            CGPoint dotPoint =[_dotPositions[i] CGPointValue];
            [self drawPoint:self.context point:dotPoint color:dotColor];
        }
    }
}

-(void)drawPoint:(CGContextRef)context point:(CGPoint)point color:(UIColor *)color{
    
    CGContextSetShouldAntialias(context, YES ); //抗锯齿
    CGColorSpaceRef Pointcolorspace1 = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, Pointcolorspace1);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, point.x,point.y);
    CGContextAddArc(context, point.x, point.y, 2, 0, 360, 0);
    CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    CGColorSpaceRelease(Pointcolorspace1);
}

@end

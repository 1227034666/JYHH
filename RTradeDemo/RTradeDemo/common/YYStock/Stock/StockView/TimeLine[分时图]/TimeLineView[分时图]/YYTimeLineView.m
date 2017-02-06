//
//  YYTimeLineView.m
//  YYStock  ( https://github.com/yate1996 )
//
//  Created by yate1996 on 16/10/5.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import "YYTimeLineView.h"
#import "YYStockConstant.h"
#import "YYStockVariable.h"
#import "UIColor+YYStockTheme.h"

@interface YYTimeLineView()
{
    CGContextRef ctx;
}
@property (nonatomic, strong) NSMutableArray *drawPositionModels;
@property (nonatomic, strong) NSMutableArray *verticalLineArray;

@end

@implementation YYTimeLineView



- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    ctx = UIGraphicsGetCurrentContext();
    if (!self.drawPositionModels) {
        return;
    }

    CGContextSetLineWidth(ctx, YYStockTimeLineWidth);
    CGPoint firstPoint = [self.drawPositionModels.firstObject CGPointValue];
    
    if (isnan(firstPoint.x) || isnan(firstPoint.y)) {
        return;
    }
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    
    //画分时线
//    CGContextSetStrokeColorWithColor(ctx, [UIColor YYStock_TimeLineColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextMoveToPoint(ctx, firstPoint.x, firstPoint.y);
    for (NSInteger idx = 1; idx < self.drawPositionModels.count ; idx++)
    {
        CGPoint point = [self.drawPositionModels[idx] CGPointValue];
        CGContextAddLineToPoint(ctx, point.x, point.y);
    }
    
    CGContextStrokePath(ctx);
    
    if (self.verticalLineArray.count >0) {
        for (NSInteger i=0; i<self.verticalLineArray.count; i++) {
            CGFloat point=[self.verticalLineArray[i] floatValue];
            [self drawLineAtPoint:point];
        }
        
    }
    
//    CGContextSetFillColorWithColor(ctx, [UIColor YYStock_timeLineBgColor].CGColor);
//    CGPoint lastPoint = [self.drawPositionModels.lastObject CGPointValue];
    
    //画背景色
//    CGContextMoveToPoint(ctx, firstPoint.x, firstPoint.y);
//    for (NSInteger idx = 1; idx < self.drawPositionModels.count ; idx++)
//    {
//        CGPoint point = [self.drawPositionModels[idx] CGPointValue];
//        CGContextAddLineToPoint(ctx, point.x, point.y);
//    }
//    CGContextAddLineToPoint(ctx, lastPoint.x, CGRectGetMaxY(self.frame));
//    CGContextAddLineToPoint(ctx, firstPoint.x, CGRectGetMaxY(self.frame));
//    CGContextClosePath(ctx);
//    CGContextFillPath(ctx);
}

- (NSArray *)drawViewWithXPosition:(CGFloat)xPosition drawModels:(NSArray <id<YYStockTimeLineProtocol>>*)drawLineModels  maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue  {
    NSAssert(drawLineModels, @"数据源不能为空");
    if (self.verticalLineArray.count >0) {
        [self.verticalLineArray removeAllObjects];
    }
    //转换为实际坐标
    [self convertToPositionModelsWithXPosition:xPosition drawLineModels:drawLineModels maxValue:maxValue minValue:minValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
    return [self.drawPositionModels copy];
}

- (NSArray *)convertToPositionModelsWithXPosition:(CGFloat)startX drawLineModels:(NSArray <id<YYStockTimeLineProtocol>>*)drawLineModels  maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue {
    if (!drawLineModels) return nil;

        CGFloat minY = YYStockLineMainViewMinY;
        CGFloat maxY = self.frame.size.height - YYStockLineMainViewMinY;
        CGFloat unitValue = (maxValue - minValue)/(maxY - minY);
        [self.drawPositionModels removeAllObjects];
        [drawLineModels enumerateObjectsUsingBlock:^(id<YYStockTimeLineProtocol>  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGFloat xPosition = startX + idx * ([YYStockVariable timeLineVolumeWidth] + YYStockTimeLineViewVolumeGap);
            CGPoint pricePoint = CGPointMake(xPosition, ABS(maxY - (model.Price.floatValue - minValue)/unitValue));
            [self.drawPositionModels addObject:[NSValue valueWithCGPoint:pricePoint]];
            if ([model.TimeDesc isEqualToString:@"9:00"] ||[model.TimeDesc isEqualToString:@"11:30"]) {
                [self.verticalLineArray addObject:@(xPosition)];
            }
         }];
        return self.drawPositionModels ;
    
}
- (NSMutableArray *)drawPositionModels {
    if (!_drawPositionModels) {
        _drawPositionModels = [NSMutableArray array];
    }
    return _drawPositionModels;
}

- (NSMutableArray *)verticalLineArray{
    if (!_verticalLineArray) {
        _verticalLineArray = [NSMutableArray array];
    }
    return _verticalLineArray;
}

-(void)drawLineAtPoint:(CGFloat)point{
    CGContextSetShouldAntialias(ctx, YES ); //抗锯齿
    CGColorSpaceRef Linecolorspace1 = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(ctx, Linecolorspace1);
    CGContextSetLineWidth(ctx, 0.2);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextMoveToPoint(ctx, point, 0);
    CGContextAddLineToPoint(ctx, point, self.frame.size.height);
    CGContextStrokePath(ctx);
    CGColorSpaceRelease(Linecolorspace1);
}


@end

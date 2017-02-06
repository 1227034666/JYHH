//
//  YYKlineView.m
//  YYStock  ( https://github.com/yate1996 )
//
//  Created by yate1996 on 16/10/6.
//  Copyright © 2016年 yate1996. All rights reserved.
//  绘制蜡烛和左边的数值

#import "YYKline.h"
#import "MAline.h"
#import "YYKlineView.h"
#import "YYStockVariable.h"
#import "YYStockConstant.h"
#import "UIColor+YYStockTheme.h"
#import "YYLinePositionModel.h"
@interface YYKlineView()
{
    CGFloat minVal;
    CGFloat maxVal;
    CGFloat startXPosition;
    CGContextRef ctx;
    MAline * maLine;
    
}

@property (nonatomic, strong) NSMutableArray *drawPositionModels;

@property (nonatomic, strong) NSMutableArray *MA5Positions;

@property (nonatomic, strong) NSMutableArray *MA10Positions;

@property (nonatomic, strong) NSMutableArray *MA20Positions;

@property (nonatomic, strong) NSMutableArray *posiArr;

@property (nonatomic, strong) NSMutableArray *dotArr;
/**
 时间字典
 */
@property (nonatomic,strong)NSMutableDictionary *timeIndexDic;



@end

@implementation YYKlineView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    ctx = UIGraphicsGetCurrentContext();
    if (!self.drawPositionModels) {
        return;
    }
    
//    YYKline *line = [[YYKline alloc]initWithContext:ctx];

    if(self.posiArr.count > 0) {
        [self.posiArr removeAllObjects];
    }

    [self.drawPositionModels enumerateObjectsUsingBlock:^(YYLinePositionModel  *_Nonnull pModel, NSUInteger idx, BOOL * _Nonnull stop) {
         [self.posiArr addObject:[NSValue valueWithCGPoint:pModel.ClosePoint]];
//        line.kLinePositionModel = pModel;
//        [line draw];
    }];
    maLine = [[MAline alloc]initWithContext:ctx];
    if(self.posiArr.count > 0) {
//        NSLog(@"%li",self.posiArr.count);
        
        [maLine drawWithColor:[UIColor whiteColor] maPositions:self.posiArr];
     

//        [maLine drawWithColor:[UIColor YYStock_MA5LineColor] maPositions:self.posiArr];
    }
    
    if (self.dotArr.count > 0) {
        [maLine drawWithColor:[UIColor greenColor] dotPositions:self.dotArr];
//        [self drawPoints];
    }
//    if(self.MA5Positions.count > 0) {
//        MAline *ma5Line = [[MAline alloc]initWithContext:ctx];
//        [ma5Line drawWithColor:[UIColor YYStock_MA5LineColor] maPositions:self.MA5Positions];
//         [ma5Line drawWithColor:[UIColor whiteColor] maPositions:self.MA5Positions];
//    }
    
//    if(self.MA10Positions.count > 0) {
//        MAline *ma10Line = [[MAline alloc]initWithContext:ctx];
//        [ma10Line drawWithColor:[UIColor YYStock_MA10LineColor] maPositions:self.MA10Positions];
//    }
//    
//    if(self.MA20Positions.count > 0) {
//        MAline *ma20Line = [[MAline alloc]initWithContext:ctx];
//        [ma20Line drawWithColor:[UIColor YYStock_MA20LineColor] maPositions:self.MA20Positions];
//    }
    
}

- (NSArray *)drawViewWithXPosition:(CGFloat)xPosition drawModels:(NSMutableArray <id<YYLineDataModelProtocol>>*)drawLineModels  maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue {
    NSAssert(drawLineModels, @"数据源不能为空");
    minValue = minValue;
    maxVal= maxValue;
    startXPosition = xPosition;
    //转换为实际坐标
    [self convertToPositionModelsWithXPosition:xPosition drawLineModels:drawLineModels maxValue:maxValue minValue:minValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
    return [self.drawPositionModels copy];
}

- (NSArray *)convertToPositionModelsWithXPosition:(CGFloat)startX drawLineModels:(NSArray <id<YYLineDataModelProtocol>>*)drawLineModels  maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue {
    if (!drawLineModels) return nil;
    
    [self.drawPositionModels removeAllObjects];
    CGFloat minY = YYStockLineMainViewMinY;
    CGFloat maxY = self.frame.size.height - YYStockLineMainViewMinY;
    CGFloat unitValue = (maxValue - minValue)/(maxY - minY);
    if (self.dotArr.count > 0) {
        [self.dotArr removeAllObjects];
    }
    
    [drawLineModels enumerateObjectsUsingBlock:^(id<YYLineDataModelProtocol>  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [self.timeIndexDic setObject:@(idx) forKey:model.DayDatail];
        CGFloat xPosition = startX + idx * ([YYStockVariable lineWidth] + [YYStockVariable lineGap]);
        CGPoint highPoint = CGPointMake(xPosition, ABS(maxY - (model.High.floatValue - minValue)/unitValue));
        CGPoint lowPoint = CGPointMake(xPosition, ABS(maxY - (model.Low.floatValue - minValue)/unitValue));
        CGPoint openPoint = CGPointMake(xPosition, ABS(maxY - (model.Open.floatValue - minValue)/unitValue));
        CGFloat closePointY = ABS(maxY - (model.Close.floatValue - minValue)/unitValue);
        
        //格式化openPoint和closePointY
        if(ABS(closePointY - openPoint.y) < YYStockLineMinWidth) {
            if(openPoint.y > closePointY) {
                openPoint.y = closePointY + YYStockLineMinWidth;
            } else if(openPoint.y < closePointY) {
                closePointY = openPoint.y + YYStockLineMinWidth;
            } else {
                if(idx > 0) {
                    id<YYLineDataModelProtocol> preKLineModel = drawLineModels[idx-1];
                    if(model.Open.floatValue > preKLineModel.Close.floatValue) {
                        openPoint.y = closePointY + YYStockLineMinWidth;
                    } else {
                        closePointY = openPoint.y + YYStockLineMinWidth;
                    }
                } else if(idx+1 < drawLineModels.count) {
                    //idx==0即第一个时
                    id<YYLineDataModelProtocol> subKLineModel = drawLineModels[idx+1];
                    if(model.Close.floatValue < subKLineModel.Open.floatValue) {
                        openPoint.y = closePointY + YYStockLineMinWidth;
                    } else {
                        closePointY = openPoint.y + YYStockLineMinWidth;
                    }
                }
            }
        }
        CGPoint closePoint = CGPointMake(xPosition, closePointY);
//        if ([model.DayDatail isEqualToString:@"2016-12-19 09:47"]) {
//            NSLog(@"dot on line price: %.2f",model.Close.floatValue);
//            NSLog(@"dot on line x: %.2f, y :%.2f",closePoint.x,closePoint.y);
//        }
        YYLinePositionModel *positionModel = [YYLinePositionModel modelWithOpen:openPoint close:closePoint high:highPoint low:lowPoint];
        [self.drawPositionModels addObject:positionModel];
        
        for (NSDictionary *dic in self.pointsArray) {
            if ([model.DayDatail isEqualToString:dic[@"day"]]) {
                NSLog(@"model.Close.floatValue %.2f",model.Close.floatValue);
                NSLog(@"model y : %.2f",closePointY);
                CGFloat dotY = ([dic[@"close"] floatValue] *closePointY)/model.Close.floatValue;
                CGPoint dotPoint =CGPointMake(xPosition, dotY);
                NSLog(@"green dot price : %@",dic[@"close"]);
                NSLog(@"green dot y : %.2f",dotY);
                [self.dotArr addObject:[NSValue valueWithCGPoint:dotPoint]];
                
//                [self drawPoint:ctx point:dotPoint color:[UIColor greenColor]];
                
            }
        }
        if (self.dotArr.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setNeedsDisplay];
//
//                [maLine drawWithColor:[UIColor greenColor] dotPositions:self.dotArr];
            });
        }
        
//        if (model.MA5.floatValue > 0.f) {
//            [self.MA5Positions addObject: [NSValue valueWithCGPoint:CGPointMake(xPosition, ABS(maxY - (model.MA5.floatValue - minValue)/unitValue))]];
//        }
//        if (model.MA10.floatValue > 0.f) {
//            [self.MA10Positions addObject: [NSValue valueWithCGPoint:CGPointMake(xPosition, ABS(maxY - (model.MA10.floatValue - minValue)/unitValue))]];
//        }
//        if (model.MA20.floatValue > 0.f) {
//            [self.MA20Positions addObject: [NSValue valueWithCGPoint:CGPointMake(xPosition, ABS(maxY - (model.MA20.floatValue - minValue)/unitValue))]];
//        }
    }];
    
    return self.drawPositionModels ;
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


//在折线图上添加圆圈和提示标签
-(void)setPointsArray:(NSMutableArray *)pointsArray{
   _pointsArray = pointsArray;
}


- (NSMutableArray *)drawPositionModels {
    if (!_drawPositionModels) {
        _drawPositionModels = [NSMutableArray array];
    }
    return _drawPositionModels;
}
- (NSMutableArray *)posiArr {
    if (!_posiArr) {
        _posiArr = [NSMutableArray array];
    }
    return _posiArr;
}

- (NSMutableArray *)dotArr {
    if (_dotArr == nil) {
        _dotArr = [NSMutableArray array];
    }
    return _dotArr;
}

- (NSMutableArray *)MA5Positions {
    if (!_MA5Positions) {
        _MA5Positions = [NSMutableArray array];
    }
    return _MA5Positions;
}

- (NSMutableArray *)MA10Positions {
    if (!_MA10Positions) {
        _MA10Positions = [NSMutableArray array];
    }
    return _MA10Positions;
}

- (NSMutableArray *)MA20Positions {
    if (!_MA20Positions) {
        _MA20Positions = [NSMutableArray array];
    }
    return _MA20Positions;
}
-(NSMutableDictionary*)timeIndexDic{
    if (_timeIndexDic == nil) {
        _timeIndexDic = [NSMutableDictionary dictionary];
    }
    return _timeIndexDic;
}

@end

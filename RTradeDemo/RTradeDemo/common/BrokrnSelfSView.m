//
//  BrokrnSelfSView.m
//  Data
//
//  Created by hipiao on 16/9/1.
//  Copyright © 2016年 James. All rights reserved.
//  首页曲线图

#import "BrokrnSelfSView.h"


#define LINE_COLOR [UIColor colorWithRed:12.0/255.0 green:125.0/255.0 blue:234.0/255.0 alpha:1.0]
//背景红色
#define FILL_COLOR [UIColor colorWithRed:165.0/255.0 green:212.0/255.0 blue:249.0/255.0 alpha:1.0]
@implementation BrokrnSelfSView

- (id)initWithFrame:(CGRect)frame
{
    self= [super initWithFrame:frame];
    if(self) {
        
        [self selfViewSetting];
        //        [self createUi];
        
    }
    
    return self;
}

-(void)selfViewSetting{
    
    self.AllWidth  = self.frame.size.width;
    self.AllHeight = self.frame.size.height;
    self.backgroundColor = [UIColor whiteColor];
    self.coorColor       = [UIColor lightGrayColor];
    self.lineColor       = LINE_COLOR;
    self.coorLineColor   = [UIColor lightGrayColor];
    self.startPointx = CGPointMake(30, self.AllHeight-15);//x轴
    self.endPointx   = CGPointMake(self.AllWidth-40, self.AllHeight-15);
    self.startPointy = CGPointMake(30, self.AllHeight-15);//y轴
    self.endPointy   = CGPointMake(30, 0);
    
}
- (void)drawRect:(CGRect)rect
{
    
    self.everHeight = [[self.unityArray objectAtIndex:1] floatValue]-[[self.unityArray objectAtIndex:0] floatValue];
    
    //    /*---------------------------虚线--------------------------------*/
    CGContextRef contextAxesy = UIGraphicsGetCurrentContext();
    //设置线条样式
    CGContextSetLineCap(contextAxesy, kCGLineCapButt);
    
    CGContextBeginPath(contextAxesy);
    CGContextSetLineWidth(contextAxesy,1);//线宽度
    CGContextSetStrokeColorWithColor(contextAxesy,self.coorColor.CGColor);
    //    CGFloat lengthsAxesy[] = {4,2};//先画4个点再画2个点
    //    CGContextSetLineDash(contextAxesy,0, lengthsAxesy,2);//代表虚线
    for (int i = 0; i<self.unityArray.count; i++) {
        if (i != 0) {
            CGContextMoveToPoint(contextAxesy,self.startPointx.x, self.AllHeight -15-i*(self.AllHeight-15)/self.unityArray.count);
            CGContextAddLineToPoint(contextAxesy,self.AllWidth - 40,self.AllHeight-15-i*(self.AllHeight-15)/self.unityArray.count);
        }
    }
    CGContextStrokePath(contextAxesy);
    //    CGContextClosePath(contextAxesy);
    
    
    //    /*---------------------------坐标单位--------------------------------*/
    for (int i = 0; i<self.unitxArray.count; i++) {
        if (i>0 && [self.unitxArray[i] isEqualToString:self.unitxArray[i-1]]) {
            continue;
        }
        NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:8]};
        CGSize labelSize = [self.unitxArray[i] sizeWithAttributes:attr];
        UILabel * lbX = [[UILabel alloc]initWithFrame:CGRectMake(0,0, labelSize.width, 15)];
        lbX.tag = 100+i;
        lbX.font = [UIFont systemFontOfSize:8];
        lbX.textColor = [UIColor grayColor];
        lbX.center = CGPointMake(30+ lbX.bounds.size.width/2 + i*(self.AllWidth-70)/self.pointArray.count , self.AllHeight-7.5);
        lbX.text = [self.unitxArray objectAtIndex:i];
        [lbX setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:lbX];
    }
    //
    for (int i = 0; i<self.unityArray.count; i++) {
        //        if (i !=0) {
        NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:8]};
        CGSize labelSize = [self.unityArray[i] sizeWithAttributes:attr];
        UILabel * lbY = [[UILabel alloc]initWithFrame:CGRectMake(0, self.AllHeight-15-i*(self.AllHeight-15)/self.unityArray.count -7.5, labelSize.width, 15)];
        lbY.tag = 500 +i;
        lbY.font = [UIFont systemFontOfSize:8];
        lbY.textColor = [UIColor grayColor];
        [lbY setTextAlignment:NSTextAlignmentCenter];
        lbY.text = [self.unityArray objectAtIndex:i];
        [self addSubview:lbY];
        //        }
    }
    
    //
    //    /*---------------------------平均值--------------------------------*/
//    CGContextRef contextAverage = UIGraphicsGetCurrentContext();
//    //设置线条样式
//    CGContextSetLineCap(contextAverage, kCGLineCapButt);
//    
//    CGContextBeginPath(contextAverage);
//    CGContextSetLineWidth(contextAverage,1);//线宽度
//    CGContextSetStrokeColorWithColor(contextAverage,[UIColor redColor].CGColor);
//    CGFloat lengthsAverage[] = {4,2};//先画4个点再画2个点
//    CGContextSetLineDash(contextAverage,0, lengthsAverage,2);//代表虚线
//    
//    float average = 0.0;
//    for (int i = 0; i<self.pointArray.count; i++) {
//        average = average +[[self.pointArray objectAtIndex:i] intValue];
//    }
//    
//    float avy = self.AllHeight-15-((average-[self.unityArray[0] floatValue])/self.pointArray.count)*(self.AllHeight-15)/self.unityArray.count/self.everHeight;
//    CGContextMoveToPoint(contextAverage,30,avy);
//    CGContextAddLineToPoint(contextAverage,(self.AllWidth-40),avy);
    
    //    CGContextMoveToPoint(contextAverage, (30+self.AllWidth+10),avy-5);//起点
    //    CGContextAddLineToPoint(contextAverage,(30+self.AllWidth+20),avy);
    //    CGContextAddLineToPoint(contextAverage, (30+self.AllWidth+10),avy+5);
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//    });
//    
//    CGContextStrokePath(contextAverage);
    //    CGContextClosePath(contextAverage);
    
//    UILabel * lbAverage = [[UILabel alloc]initWithFrame:CGRectMake(self.AllWidth+20, avy-30, 50, 20)];
//    lbAverage.font = [UIFont systemFontOfSize:14];
//    lbAverage.text = [NSString stringWithFormat:@"%.2f",average/self.pointArray.count];
//    [self addSubview:lbAverage];
    
    //    /*--------------------------数据点--------------------------------    */
    //    for (int i = 0; i<self.pointArray.count; i++) {
    //        UILabel * lbData = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 20, 20)];
    //        lbData.center = CGPointMake( 50+i*(self.AllWidth+20)/self.pointArray.count, self.AllHeight-[[self.pointArray objectAtIndex:i] intValue]*(self.AllHeight-100)/self.unityArray.count/self.everHeight);
    //        lbData.font = [UIFont systemFontOfSize:14];
    //        [lbData setTextAlignment:NSTextAlignmentRight];
    //        lbData.text = [self.pointArray objectAtIndex:i];
    //        lbData.backgroundColor = self.lineColor;
    //        [lbData sizeToFit];
    //        [self addSubview:lbData];
    //    }
    
    CGContextRef contextData1 = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(contextData1,self.lineColor.CGColor);//设置颜色
    
    CGFloat lengthsData1[] = {4,0};//先画4个点再画2个点
    CGContextSetLineDash(contextData1,0, lengthsData1,2);//代表虚线
    
    CGContextSetLineWidth(contextData1, 2.0);
    //总高度-剩下的高度
    CGFloat floatY0 = self.AllHeight-15-([[self.pointArray objectAtIndex:0] floatValue] -[self.unityArray[0] floatValue])*(self.AllHeight-15)/self.unityArray.count/self.everHeight;
    CGContextMoveToPoint(contextData1, 30, floatY0);//起始点
    
    for (int i = 0; i<self.pointArray.count; i++) {
        if (i !=0) {
            CGFloat X = (self.AllWidth-70)/(float)(self.pointArray.count-1);
            CGFloat floatX = 30+i*X;
            CGFloat floatY = self.AllHeight-15-([[self.pointArray objectAtIndex:i] floatValue]-[self.unityArray[0] floatValue])*(self.AllHeight-15)/self.unityArray.count/self.everHeight;
            CGContextAddCurveToPoint(contextData1, floatX-X*2/3, floatY0, floatX-X*1/3, floatY, floatX, floatY);//控制点1  控制点2  数据点
            floatY0 = self.AllHeight-15-([[self.pointArray objectAtIndex:i] floatValue]-[self.unityArray[0] floatValue])*(self.AllHeight-15)/self.unityArray.count/self.everHeight;
        }
    }

    CGContextStrokePath(contextData1);
    
    //    /*---------------------------填充颜色--------------------------------*/
    
    CGContextRef contextFull = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(contextFull,[UIColor clearColor].CGColor);//设置颜色
    CGContextSetLineWidth(contextFull, 2.0);
    //总高度-剩下的高度
    CGFloat floatY00 = self.AllHeight-15-([[self.pointArray objectAtIndex:0] floatValue] -[self.unityArray[0] floatValue])*(self.AllHeight-15)/self.unityArray.count/self.everHeight;
    CGContextMoveToPoint(contextFull, self.startPointx.x,self.startPointx.y);//起始点
    CGContextAddLineToPoint(contextFull, 30, floatY00);
    CGFloat floatX=0;
    CGFloat floatY=0;
    for (int i = 0; i<self.pointArray.count; i++) {
        if (i !=0) {
            CGFloat X = (self.AllWidth-70)/(float)(self.pointArray.count-1);
            floatX = 30+i*X;
            floatY = self.AllHeight-15-([[self.pointArray objectAtIndex:i] floatValue]-[self.unityArray[0] floatValue])*(self.AllHeight-15)/self.unityArray.count/self.everHeight;
            CGContextAddCurveToPoint(contextData1, floatX-X*2/3, floatY00, floatX-X*1/3, floatY, floatX, floatY);//控制点1  控制点2  数据点
            floatY00 = self.AllHeight-15-([[self.pointArray objectAtIndex:i] floatValue]-[self.unityArray[0] floatValue])*(self.AllHeight-15)/self.unityArray.count/self.everHeight;
        }
    }
    CGContextAddLineToPoint(contextFull, floatX, _endPointx.y);

    
    CGContextSetFillColorWithColor(contextFull, [FILL_COLOR colorWithAlphaComponent:0.3].CGColor);//填充颜色
    CGContextDrawPath(contextFull, kCGPathFillStroke);//进行颜色填充
    CGContextStrokePath(contextFull);
//
    
}

-(void)clearScreen{
    for (UIView *itemView in self.subviews) {
        
        if ([itemView isKindOfClass:[UILabel class]] &&(itemView.tag /100 == 1 || itemView.tag/100 == 5)) {
            [itemView removeFromSuperview];
        }
    }
    
    [_pointArray removeLastObject];
    [_unitxArray removeLastObject];
    [_unityArray removeLastObject];
    [self setNeedsDisplay];
}

-(NSMutableArray *)pointArray{
    if (_pointArray == nil) {
        _pointArray = [NSMutableArray array];
    }
    return _pointArray;
}
-(NSMutableArray *)unitxArray{
    if (_unitxArray == nil) {
        
        _unitxArray = [NSMutableArray array];
    }
    return _unitxArray;
}
-(NSMutableArray *)unityArray{
    if (_unityArray == nil) {
        
        _unityArray = [NSMutableArray array];
    }
    return _unityArray;
}


@end

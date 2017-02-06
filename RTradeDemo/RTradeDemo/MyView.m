//
//  MyView.m
//  SliderDraw
//
//  Created by Mac on 16/12/20.
//  Copyright © 2016年. All rights reserved.
//

#import "MyView.h"

@implementation MyView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [self _drawCircle];
    
}

-(void)_drawCircle{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPath];

//    [path moveToPoint:CGPointMake(150, 150)];
//    [path addLineToPoint:CGPointMake(250, 150)];
    
    CGFloat endAng =M_PI*2.0* _end + -M_PI_2;
    CGPoint center = CGPointMake(40, 40);
    [path addArcWithCenter:center radius:30 startAngle:-M_PI_2 endAngle:endAng clockwise:YES];
    
    [path addLineToPoint:center];
    [path closePath];
    [[UIColor whiteColor] setFill];
    
//    [[UIColor redColor] setStroke];
//    CGContextSetLineWidth(context, 2);
    CGContextAddPath(context, path.CGPath);
    [[UIColor darkGrayColor] setStroke];
    CGContextDrawPath(context, kCGPathFillStroke);
    
//    CGContextStrokePath(context);
    
}

-(void)setEnd:(CGFloat)end{
    _end = end;
    [self setNeedsDisplay];
}

@end

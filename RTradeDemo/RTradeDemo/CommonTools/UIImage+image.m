//
//  UIImage+image.m
//  RJTrader
//
//  Created by iMac on 17/2/4.
//  Copyright © 2017年 administrator. All rights reserved.
//

#import "UIImage+image.h"

@implementation UIImage (image)


+(instancetype)orignalImageWithName:(NSString *)imageName{
    
    UIImage *image=[UIImage imageNamed:imageName];
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
}
+ (instancetype)imageWithColor:(UIColor *)color{
    
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return theImage;
    
}

@end

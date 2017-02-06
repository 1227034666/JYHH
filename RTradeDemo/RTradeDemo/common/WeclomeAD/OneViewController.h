//
//  OneViewController.h
//  广告demo
//
//  Created by Jarlen Huang on 16/5/31.
//  Copyright © 2016年 Jarlen Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneViewController : UIViewController
/**
 *   block
 */
@property(nonatomic,copy)void(^myBlock)(BOOL isClick);
@end

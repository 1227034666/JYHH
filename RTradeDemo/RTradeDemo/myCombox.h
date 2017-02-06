//
//  myCombox.h
//  view
//
//  Created by ren on 14-7-28.
//  Copyright (c) 2014年 ren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegAccountController.h"

@protocol myComboxDelegate <NSObject>

@optional

-(void)myComboxCellTouchDwon:(UILabel *)label;

@end

@interface myCombox : UIView <UIGestureRecognizerDelegate>
{
    UILabel *tempLabel;
}
@property (nonatomic,retain) UIColor *cellColor;
@property (nonatomic,retain) UIColor *cellSelectColor;
@property (nonatomic,retain) NSMutableArray *arrayData;
@property (nonatomic,retain) UILabel *titleButton;
@property (nonatomic,retain) UITextView *textView;
@property (nonatomic) float titleHeight,cellHeight;
@property (nonatomic) int cellNumber;
@property (nonatomic) UITapGestureRecognizer *singleTapTitle;
@property (nonatomic) UITapGestureRecognizer *singleTap;


@property (nonatomic,retain) id<myComboxDelegate> delegate;

-(void)initWithView;

@end

//
//  myCombox.m
//  view
//
//  Created by ren on 14-7-28.
//  Copyright (c) 2014年 ren. All rights reserved.
//

#import "myCombox.h"

@implementation myCombox

@synthesize arrayData;
@synthesize titleButton;
@synthesize textView;
@synthesize cellColor;
@synthesize cellSelectColor;
@synthesize titleHeight,cellHeight;
@synthesize cellNumber;
@synthesize delegate;

@synthesize singleTapTitle;
@synthesize singleTap;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        arrayData=[[NSMutableArray alloc] initWithObjects:@"示例1",@"示例2",@"示例3",@"示例4",@"示例5",@"示例6",@"示例7", nil];
        cellColor=[UIColor lightGrayColor];
        cellSelectColor=[UIColor grayColor];
        titleHeight=40;
        cellHeight=40;
        cellNumber=4;
        
//        //---------用法-----------
//        NSMutableArray *arrayData=[[NSMutableArray alloc] initWithObjects:@"shaosikang1",@"shaosikang2",@"shaosikang3",@"shaosikang4",@"shaosikang5",@"shaosikang6",@"shaosikang7",@"shaosikang8", nil];
//        
//        myCombox *combox=[[myCombox alloc] initWithFrame:CGRectMake(30, 300, 120, 200)];
//        combox.arrayData=arrayData;
//        combox.titleButton.text=@"shaosikang";
//        combox.titleButton.textColor=[UIColor blueColor];
//        combox.backgroundColor=[UIColor clearColor];
//        combox.cellColor=[UIColor brownColor];
//        combox.cellSelectColor=[UIColor purpleColor];
//        combox.cellHeight=30;
//        [combox initWithView];
//        [self.view addSubview:combox];
//
    }
    return self;
}

-(void)initWithView
{
    
    titleButton=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, titleHeight)];
    titleButton.text=@"选择开户公司";
    titleButton.textColor=[UIColor blueColor];
    titleButton.backgroundColor=cellSelectColor;
    titleButton.textAlignment=NSTextAlignmentCenter;
    [titleButton setUserInteractionEnabled:YES];
    singleTapTitle =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(press:)];
    
    singleTapTitle.numberOfTouchesRequired = 1;
    
    [singleTapTitle setDelaysTouchesBegan:TRUE];
    
    [singleTapTitle setDelaysTouchesEnded:TRUE];
    
    [singleTapTitle setCancelsTouchesInView:TRUE];
    
    singleTapTitle.delegate = self;

    [titleButton addGestureRecognizer:singleTapTitle];
    [self addSubview:titleButton];
    
    textView=[[UITextView alloc] initWithFrame:CGRectMake(0, titleHeight, self.frame.size.width, 0)];
    textView.text=@"";
    textView.editable=NO;
    textView.backgroundColor=cellColor;
    [self addSubview:textView];

    for(int i=0;i<[arrayData count];i++ )
    {
        UILabel *textViewLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,i*cellHeight, textView.frame.size.width, cellHeight)];
        textViewLabel.text=[arrayData objectAtIndex:i];
        textViewLabel.textAlignment=NSTextAlignmentCenter;
        textViewLabel.backgroundColor=cellColor;
        [textViewLabel setUserInteractionEnabled:YES];
        singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewLabelPress:)];
        
        singleTap.delegate = self;
        
        [textViewLabel addGestureRecognizer:singleTap];
        singleTap.view.tag=i+1;
        [textView addSubview:textViewLabel];
        
        UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0,i*cellHeight , textView.frame.size.width, 0.5)];
        line.backgroundColor=cellSelectColor;
        [textView addSubview:line];
        
        for(int j=0;j<(int)(cellHeight/12);j++)
        {
            textView.text=[textView.text stringByAppendingString:@"\n"];
        }
        
    }

}


-(void)press:(id)sender
{
    if(textView.frame.size.height<1)
    {
        tempLabel.backgroundColor=cellColor;
        
        [UIView beginAnimations:nil context:nil]; //标记动画的开始
        //持续时间
        [UIView setAnimationDuration:0.3f];  //动画的持续时间
        
        textView.frame=CGRectMake(0, titleHeight, self.frame.size.width, cellNumber*cellHeight);
        
        [UIView commitAnimations];//标记动画的结束
        
    }
    else
    {
        
        [UIView beginAnimations:nil context:nil]; //标记动画的开始
        //持续时间
        [UIView setAnimationDuration:0.3f];  //动画的持续时间
        
        textView.frame=CGRectMake(0, titleHeight, self.frame.size.width, 0);
        
        [UIView commitAnimations];//标记动画的结束
    }
}

-(void)textViewLabelPress:(id)sender
{
    UITapGestureRecognizer *gestureRecognizer=((UITapGestureRecognizer *)sender);
    int tag=gestureRecognizer.view.tag-1;
    titleButton.text=[arrayData objectAtIndex:tag];
    
    tempLabel=(UILabel *)([[[gestureRecognizer view] superview] viewWithTag:(tag+1)]);
    tempLabel.backgroundColor=cellSelectColor;
    

    [self performSelector:@selector(press:) withObject:sender];
    
    [[self delegate] myComboxCellTouchDwon:tempLabel];  //**********在点击cell后实现委托方法***********
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    
    if([touch.view isKindOfClass:[UILabel class]])
        
        return YES;
    
    else
        
        return NO;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

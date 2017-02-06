//
//  PersonalFeedbackController.m
//  RTradeDemo
//
//  Created by administrator on 16/8/7.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "PersonalFeedbackController.h"

@interface PersonalFeedbackController ()<UITextViewDelegate>{
    UILabel *_textViewPlaceholderLabel;
}
@property (strong, nonatomic) IBOutlet UITextView *opinionTextView;
@property (strong, nonatomic) IBOutlet UILabel *numOfWords;

@end

@implementation PersonalFeedbackController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"意见反馈";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UIBarButtonItem *publishBtn = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(btnPublish:)];
    [self.navigationItem setRightBarButtonItem:publishBtn];
    self.opinionTextView.delegate = self;
    
    //  在UITextView上加上一个UILabel
    _textViewPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 160, 25)];
    _textViewPlaceholderLabel.text = @"请输入您的反馈意见";
    _textViewPlaceholderLabel.textColor = [UIColor grayColor];
    [self.opinionTextView addSubview:_textViewPlaceholderLabel];
    //弹出键盘
    [self.opinionTextView becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnPublish:(id)sender
{
    
}


#pragma mark ---------UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    NSInteger number = [textView.text length];
    if (number > 1000) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"字符个数不能大于1000" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        textView.text = [textView.text substringToIndex:1000];
        number = 1000;
        
    }
    self.numOfWords.text = [NSString stringWithFormat:@"%ld/1000字",(long)number];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //[text isEqualToString:@""] 表示输入的是退格键
    if (![text isEqualToString:@""])
    {
        _textViewPlaceholderLabel.hidden = YES;
    }
    
    //range.location == 0 && range.length == 1 表示输入的是第一个字符
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1)
        
    {
        _textViewPlaceholderLabel.hidden = NO;
    }
    
//    if ([text isEqualToString:@"\n"]) {
//        [self keyboardHide];
//        return NO;
//    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

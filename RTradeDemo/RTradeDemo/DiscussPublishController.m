//
//  DiscussPublishController.m
//  RTradeDemo
//
//  Created by administrator on 16/6/29.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "DiscussPublishController.h"
#import "TradeUtility.h"
#import "UIViewExt.h"
#import "MBProgressHUD.h"

@interface DiscussPublishController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate>{
    NSString *_viewTags;
    UILabel *_textViewPlaceholderLabel;
    UIBarButtonItem *_publishBtn;
}
@property (weak, nonatomic) IBOutlet UITextField *m_strViewTitle;
@property (strong, nonatomic) IBOutlet UIButton *picButton;
@property (strong, nonatomic) IBOutlet UITextView *m_strViewText;

@property (strong, nonatomic) IBOutlet UIButton *marketBtn;
@property (strong, nonatomic) IBOutlet UIButton *strategy;



@end

@implementation DiscussPublishController

- (UIImageView *)selectImageView{
    
    if (_selectImageView == nil) {
        _selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 100, 100)];
        
        _selectImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _selectImageView.clipsToBounds = YES;
        _selectImageView.bottom = _picButton.bottom;
        _selectImageView.hidden = NO;
        
        [self.view addSubview:_selectImageView];
    }
    return _selectImageView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"发表观点";
    _viewTags = nil;
    _publishBtn = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(publishBtn:)];
    [self.navigationItem setRightBarButtonItem:_publishBtn];
    [self.marketBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.marketBtn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    self.marketBtn.selected = NO;
    [self.strategy setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.strategy setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    self.strategy.selected = NO;
    
    _m_strViewText.delegate = self;
    
//  在UITextView上加上一个UILabel
    _textViewPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 150, 25)];
    _textViewPlaceholderLabel.text = @"请输入观点内容";
    _textViewPlaceholderLabel.textColor = [UIColor grayColor];
    [_m_strViewText addSubview:_textViewPlaceholderLabel];

    //1.监听键盘的弹出
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //弹出键盘
    [_m_strViewTitle becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyBoardShow:(NSNotification *)notification{
    //获取键盘的高度
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat height = rect.size.height;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.3 animations:^{
        //设置输入框的高度
        _m_strViewText.height = kScreenHeight - height - _m_strViewText.top;
        //设置拍照按钮
        _picButton.transform = CGAffineTransformMakeTranslation(0, - height + 20);
        weakSelf.selectImageView.bottom = _picButton.bottom;
    }];
}

- (IBAction)tagAction:(UIButton *)sender {
//    [_m_strViewTitle resignFirstResponder];
    [_m_strViewTitle resignFirstResponder];
    [_m_strViewText becomeFirstResponder];
    if (sender.tag == 3000) {
        _marketBtn.selected = YES;
        _strategy.selected = NO;
        _viewTags = @"行情";
    } else {
        _marketBtn.selected = NO;
        _strategy.selected = YES;
        _viewTags = @"策略";
    }
}

-(void)keyboardHide{
    [_m_strViewText resignFirstResponder];

    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.1 animations:^{
        
        //设置输入框的高度
        _m_strViewText.height = kScreenHeight - _m_strViewText.top;
        //设置拍照按钮
        _picButton.transform = CGAffineTransformIdentity;
        weakSelf.selectImageView.bottom = _picButton.bottom;
    }];
}

-(void)publishBtn:(id)sender{
    _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    _hud.dimBackground = YES;
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               self.m_strViewTitle.text, @"viewTitle",
                               _viewTags, @"viewTags",
                            self.m_strViewText.text,@"viewText",
                               nil];
    NSLog(@"postparam=%@",postparam);
    NSData *picData = UIImageJPEGRepresentation(self.selectImageView.image, 0.7);

    NSMutableDictionary *picDict = nil;
    if (picData != nil) {
        picDict = [@{@"photo":picData} mutableCopy];
    }
    [TradeUtility requestWithUrl:@"publishView" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:picDict success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        if(retdata == nil){
            NSLog(@"retdata=%@",retdata);
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"retcode=%d",icode);
        if(icode == 0){
            _hud.hidden = YES;
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
            NSLog(@"retjson=%@",retjson);
            if(retjson != nil){
                NSString *ret_viewid = [retjson objectForKey:@"viewId"];
                int iretuid = [ret_viewid intValue];
                NSLog(@"iretviewid=%d",iretuid);
            }
            //初始化提示框；
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"发表观点成功" preferredStyle:  UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //点击按钮的响应事件；
                [[self navigationController] popViewControllerAnimated:YES];
            }]];
            //弹出提示框；
            [self presentViewController:alert animated:true completion:nil];
        }else{
            _hud.hidden = YES;
            //初始化提示框；
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"发表观点失败" preferredStyle:  UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //点击按钮的响应事件；
            }]];
            
            //弹出提示框；
            [self presentViewController:alert animated:true completion:nil];
        }
    } failure:^(NSError *error) {
        NSLog(@"publish view%@",error);
    }];
}
- (IBAction)picAction:(UIButton *)sender {
    [self keyboardHide];
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从手机选取图片", nil];
    
    [sheet showInView:self.view];
}

#pragma mark ---------UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //弹出系统的相册
    UIImagePickerController *imagePickCtrl = [[UIImagePickerController alloc]init];
    if (buttonIndex ==0 ) {
        imagePickCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if (buttonIndex ==1 ){
        imagePickCtrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePickCtrl.delegate = self;
    if([[[UIDevice
          currentDevice] systemVersion] floatValue]>=8.0) {
        self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    [self presentViewController:imagePickCtrl animated:YES completion:nil];
}
#pragma mark ------imagePickCtrlDelagate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    //取得用户选择的照片
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *image= info[UIImagePickerControllerOriginalImage];
    
    self.selectImageView.image = image;
    self.selectImageView.hidden = NO;
}
#pragma mark ---------UITextViewDelegate
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
    
    if ([text isEqualToString:@"\n"]) {
        [self keyboardHide];
        return NO;
    }
    return YES;
}


@end

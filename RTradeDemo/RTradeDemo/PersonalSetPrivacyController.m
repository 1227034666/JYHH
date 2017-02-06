//
//  PersonalSetPrivacyController.m
//  RTradeDemo
//
//  Created by administrator on 16/6/29.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "PersonalSetPrivacyController.h"
#import "TradeUtility.h"
#import "UIImageView+WebCache.h"

@interface PersonalSetPrivacyController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    MBProgressHUD *_hud;
}
@property (weak, nonatomic) IBOutlet UILabel *m_strNickName;
@property (weak, nonatomic) IBOutlet UILabel *m_strMobilePhone;
@property (weak, nonatomic) IBOutlet UILabel *m_strWeixin;
@property (weak, nonatomic) IBOutlet UILabel *m_strWeibo;
@property (strong, nonatomic) IBOutlet UIImageView *m_userPhoto;

@end

@implementation PersonalSetPrivacyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *publishBtn = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(btnPublish:)];
    [self.navigationItem setRightBarButtonItem:publishBtn];
    
    NSString *mobile = [TradeUtility LocalLoadConfigFileByKey:@"mobile" defaultvalue:@"0"];
    NSString *nickname = [TradeUtility LocalLoadConfigFileByKey:@"nickname" defaultvalue:@"0"];
    NSString *picURL = [TradeUtility LocalLoadConfigFileByKey:@"avatar" defaultvalue:@"0"];
    self.m_strMobilePhone.text = mobile;
    self.m_strNickName.text = nickname;
    
    self.m_userPhoto.layer.cornerRadius = 20.0f;
    self.m_userPhoto.layer.masksToBounds = YES;
    self.m_userPhoto.contentMode = UIViewContentModeScaleAspectFit;
    if (![picURL isEqualToString:@"0"]) {
        
        [self.m_userPhoto sd_setImageWithURL:[NSURL URLWithString:picURL]];
    } else{
        self.m_userPhoto.image = [UIImage imageNamed:@"Icon.png"];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectUserPhoto)];
    [self.m_userPhoto addGestureRecognizer:tap];
    
}


#pragma mark -- set privacy method
-(void)btnPublish:(id)sender{
    
    NSString *uid = [TradeUtility LocalLoadConfigFileByKey:@"uid" defaultvalue:@"0"];
    NSData *picData = UIImageJPEGRepresentation(self.m_userPhoto.image, 0.7);
    NSMutableDictionary *picDict = nil;
    if (picData != nil) {
        picDict = [@{@"photo":picData} mutableCopy];
    }
    NSDictionary *postparam = [NSDictionary dictionaryWithObjectsAndKeys:
                               uid, @"uid",
                               self.m_strNickName.text, @"nickname",
                               self.m_strMobilePhone.text, @"mobile",
                               self.m_strWeixin.text,@"wxaccount",
                               nil];
    NSLog(@"postparam=%@",postparam);
    _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [TradeUtility requestWithUrl:@"setUserPersonal" httpMethod:@"POST" pramas:[postparam mutableCopy] fileData:picDict success:^(id result) {
        NSDictionary *retdata = (NSDictionary*)result;
        NSLog(@"setUserPersonal retdata=%@",retdata);
        if(retdata == nil){
            [TradeUtility ShowNetworkErrDlg:self];
            return;
        }
        NSString *retcode = [retdata objectForKey:@"re_code"];
        int icode = [retcode intValue];
        NSLog(@"setUserPersonal retcode=%d",icode);
        if(icode == 0){
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
            NSLog(@"setAttention retjson=%@",retjson);
            if(![retjson isKindOfClass:[NSNull class]] && retjson.count > 0){
                NSString *avatar = retjson[@"avatar"];
                [TradeUtility LocalSaveConfigFileByKey:@"avatar" value:avatar];
                [TradeUtility LocalSaveConfigFileByKey:@"nickname" value:self.m_strNickName.text];
                [TradeUtility LocalSaveConfigFileByKey:@"mobile" value:self.m_strMobilePhone.text];
                [TradeUtility LocalSaveConfigFileByKey:@"wxaccount" value:self.m_strWeixin.text];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"userPrivacyNotification" object:nil];
            }
            _hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CheckMark"]];
            _hud.mode = MBProgressHUDModeCustomView;
            _hud.labelText = @"提交成功";
        }else{
            _hud.mode = MBProgressHUDModeCustomView;
            _hud.labelText = @"提交失败";
        }
        [_hud hide:YES afterDelay:1];
    } failure:^(NSError *error) {
        NSLog(@"publish view%@",error);
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    NSString *mobile = [TradeUtility LocalLoadConfigFileByKey:@"mobile" defaultvalue:@"0"];
    NSString *nickname = [TradeUtility LocalLoadConfigFileByKey:@"nickname" defaultvalue:@"0"];
    self.m_strMobilePhone.text = mobile;
    self.m_strNickName.text = nickname;
}

-(void)selectUserPhoto{
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *phone = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectImage:UIImagePickerControllerSourceTypeCamera andPrompt:@"相机"];
        
    }];
    UIAlertAction *systemAlbum = [UIAlertAction actionWithTitle:@"从相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectImage:UIImagePickerControllerSourceTypePhotoLibrary andPrompt:@"相册"];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertVc addAction:phone];
    [alertVc addAction:systemAlbum];
    [alertVc addAction:cancelAction];
    [self presentViewController:alertVc animated:YES completion:^{
    }];
    
}

- (void) selectImage:(UIImagePickerControllerSourceType )type andPrompt:(NSString *) prompt{
    if([UIImagePickerController isSourceTypeAvailable:type]) {
        UIImagePickerController *pickerVc = [[UIImagePickerController alloc]init];
        pickerVc.delegate = self;
        pickerVc.allowsEditing = YES;
        pickerVc.sourceType = type;
        pickerVc.mediaTypes = @[@"public.image"];
        [self presentViewController:pickerVc animated:YES completion:^{
        }];
    }else{
        NSString *str = [NSString stringWithFormat:@"请在iPhone的\"设置->隐私->%@\"选项中,允许\"久盈交易者\"访问您的%@.",prompt,prompt];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"权限受限" message:str delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark  -UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image ) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    self.m_userPhoto.image = [self circleImage:image withParam:0];
    self.m_userPhoto.contentMode = UIViewContentModeScaleAspectFit;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath=%ld",(long)indexPath.row);
    
    if(indexPath.row == 1)
    {
        //set nickname
        [TradeUtility LocalSaveConfigFileByKey:@"settingOperType" value:@"nickname"];
        [TradeUtility LocalSaveConfigFileByKey:@"settingOperParam" value:self.m_strNickName.text];
        
//        UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"CommonSetTextController"];
        [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];

    }
    else if(indexPath.row == 2)
    {
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PersonalSetMobileController"];
        [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
    }
}


-(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset {
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    //圆的边框宽度为0.5，颜色为灰色
    
    CGContextSetLineWidth(context,0.5f);
    
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset *2.0f, image.size.height - inset *2.0f);
    //    CGRect rect = CGRectMake(0, 0, inset *1.0f, inset *1.0f);
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextClip(context);
    
    //在圆区域内画出image原图
    
    [image drawInRect:rect];
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextStrokePath(context);
    
    //生成新的image
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newimg;
    
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

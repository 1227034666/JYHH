//
//  FutureCompanyController.m
//  RTradeDemo
//
//  Created by Michael Luo on 11/3/16.
//  Copyright © 2016 administrator. All rights reserved.
//

#import "FutureCompanyController.h"
#import "MBProgressHUD.h"
#import "TradeUtility.h"
#import "SlideNavigationController.h"
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

@interface FutureCompanyController ()<UISearchBarDelegate>{
    NSString *_selectedCompanyName;
    UIView *_headView;
}

@property(nonatomic,strong)NSMutableArray *companyArray;//数据源
@property(nonatomic,strong)NSMutableArray *backupArray;//数据源
@property (assign, nonatomic) NSIndexPath *selIndex;//单选，当前选中的行

@end
static NSString * const reuseIdentifier = @"CompanyCell";
@implementation FutureCompanyController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    _companyArray = [NSMutableArray array];
    _backupArray = [NSMutableArray array];
    [self getCompanylist];
    
    
    _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,64 + 44)];
    UIView *_bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,64)];
    _headView.backgroundColor = [UIColor whiteColor];
    _bgView.backgroundColor = BGRED_COLOR;
    [_headView addSubview:_bgView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 30, 120, 24)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"选择开户公司";
    [_bgView addSubview:titleLabel];
    
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(5, 30, 60, 24);
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [cancelBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
     [_headView addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelAccount) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(kScreenWidth - 65, 30, 60, 24);
    doneBtn.backgroundColor = [UIColor clearColor];
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [doneBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [doneBtn setTitle:@"确定" forState:UIControlStateNormal];
    
    [doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_headView addSubview:doneBtn];
    self.tableView.tableHeaderView = _headView;
    [self initSearchBar];
//    [self.tableView setEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getCompanylist{
//    _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    _hud.dimBackground = YES;
    
    [TradeUtility requestWithUrl:@"getFutureList" httpMethod:@"POST" pramas:nil fileData:nil success:^(id result) {
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
            NSDictionary *retjson = [retdata objectForKey:@"re_json"];
            NSLog(@"retjson=%@",retjson);
            if(retjson != nil && ![retjson isKindOfClass:[NSNull class]]){
                NSArray *futureList = retjson[@"futureList"];
                for (NSString *item in futureList) {
                    NSLog(@"Future company: %@",item);
                    [_companyArray addObject:item];
                    [_backupArray addObject:item];
                }
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.tableView reloadData];
//                });
//                [_hud hide:YES];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

-(void)cancelAccount{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)doneAction{
    
    self.companyBlock(_selectedCompanyName);
    [self dismissViewControllerAnimated:YES completion:nil];
    [[SlideNavigationController sharedInstance]popViewControllerAnimated:YES];
//    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Initialization

- (void)initSearchBar
{
    if (IOS_VERSION >= 7.0) {
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 65, CGRectGetWidth(self.view.bounds), 44)];
    }else{
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 65, CGRectGetWidth(self.view.bounds), 44)];
    }
    
    self.searchBar.barStyle     = UIBarStyleDefault;
    self.searchBar.translucent  = YES;
    self.searchBar.delegate     = self;
    self.searchBar.placeholder  = @"输入期货公司名称检索";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    [_headView addSubview:_searchBar];
    self.tableView.tableHeaderView = _headView;
    
    //    [self.view addSubview:self.searchBar];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if (self.companyArray == nil) {
        return 0;
    } else {
        return self.companyArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.textLabel.text=self.companyArray[indexPath.row];
    //    cell.textLabel.text= [NSString stringWithFormat:@"%ld", indexPath.row];
    
    // Configure the cell...
    if (_selIndex == indexPath) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *celled = [tableView cellForRowAtIndexPath:_selIndex];
    celled.accessoryType = UITableViewCellAccessoryNone;
    //记录当前选中的位置索引
    _selIndex = indexPath;
    //当前选择的打勾
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _selectedCompanyName = self.companyArray[indexPath.row];
}



#pragma mark searchBarDelegete
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSMutableArray *tmpArray =[NSMutableArray array];
    if (searchText.length == 0) {
        self.isSearch = NO;
        if (self.companyArray.count > 0) {
            [self.companyArray removeAllObjects];
        }
        
        [self.tableView reloadData];
        
    }else{
        self.isSearch = YES;
        self.companyArray = self.backupArray;
        for (NSString *str in _companyArray) {
            //汉字转拼音，比较排序时候用
            NSMutableString *ms = [[NSMutableString alloc] initWithString:str];
            NSString * chinesePinyin;
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
            }
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
                chinesePinyin = ms;
            }
            
            NSRange chinese = [str rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange  letters = [chinesePinyin rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (chinese.location != NSNotFound) {
                [tmpArray addObject:str];
            }else if (letters.location != NSNotFound){
                [tmpArray addObject:str];
            }
            
            self.companyArray = tmpArray;
            [self.tableView reloadData];
        }
        
    }
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.isSearch = NO;
    
}

@end

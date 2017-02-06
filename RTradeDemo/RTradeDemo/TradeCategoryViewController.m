//
//  TradeCategoryViewController.m
//  RTradeDemo
//
//  Created by Michael Luo on 10/17/16.
//  Copyright © 2016 administrator. All rights reserved.
//

#import "TradeCategoryViewController.h"
#import "CellTradeCategoryCell.h"
#import "TradeUtility.h"
#import "MBProgressHUD.h"
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

@interface TradeCategoryViewController ()
{
    UITextField *_searchField;
}

@property(nonatomic,strong)NSMutableArray *categoryArray;//数据源
@property(nonatomic,strong)NSMutableArray *backupArray;//数据源backup

@property (nonatomic,strong)NSMutableArray *selectorPatnArray;//存放选中数据

@end
static NSString * const reuseIdentifier = @"CategoryCell";

@implementation TradeCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self getContractlist];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = rightBtn;

    
    UIView *_headView = [[UIView alloc]initWithFrame:CGRectMake(-2, 0, [UIScreen mainScreen].bounds.size.width+3,44)];
    UIImageView *searchImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 24, 24)];
    searchImgView.image = [UIImage imageNamed:@"IconSearch"];
    _headView.layer.borderWidth =1;
    _headView.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    [_headView addSubview:searchImgView];
    [self initSearchBar];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    [self.tableView setEditing:YES];
/*
    _searchField = [[UITextField alloc]initWithFrame:CGRectMake(30, 5, [UIScreen mainScreen].bounds.size.width - 40, 34)];
    
    _searchField.placeholder = @"输入合约品种名称检索";
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
   _searchField.font = [UIFont systemFontOfSize:15];
   _searchField.textColor = [UIColor lightGrayColor];
    [_searchField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_headView addSubview:_searchField];
    _searchField.delegate = self;
*/
//    self.tableView.tableHeaderView = _headView;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryAction:) name:@"categorySelected" object:nil];

//    self.navigationItem.rightBarButtonItem
    //添加数据源
//    for (int i = 0; i < 10; i++) {
//        NSString *str = [NSString stringWithFormat:@"第%d行",i + 1];
//        NSString *copyStr = str;
//        [self.categoryArray addObject:str];
//        [self.backupArray addObject:copyStr];
//    }
    
    [self.tableView setEditing:YES];
    
    
}

-(void)getContractlist{
    _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    _hud.dimBackground = YES;
    
    [TradeUtility requestWithUrl:@"getContractList" httpMethod:@"POST" pramas:nil fileData:nil success:^(id result) {
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
            if(retjson != nil){
                NSArray *retArray = [retjson objectForKey:@"contract_list"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (NSDictionary *dic in retArray) {
                        NSString *contractName = dic[@"conname"];
                        [self.categoryArray addObject:contractName];
                        [self.backupArray addObject:contractName];
                    }
                    [self.tableView reloadData];
                });
                [_hud hide:YES];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];

}

-(void)doneAction{

    NSString *blockText = [_selectorPatnArray componentsJoinedByString:@","];
    self.categoryBlock(blockText);

    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Initialization

- (void)initSearchBar
{
    if (IOS_VERSION >= 7.0) {
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    }else{
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    }
    
    self.searchBar.barStyle     = UIBarStyleDefault;
    self.searchBar.translucent  = YES;
    self.searchBar.delegate     = self;
    self.searchBar.placeholder  = @"输入合约品种名称检索";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.tableView.tableHeaderView = self.searchBar;
    
//    [self.view addSubview:self.searchBar];
}

//接收到通知调用的方法
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.categoryArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    CellTradeCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.textLabel.text=self.categoryArray[indexPath.row];
//    cell.textLabel.text= [NSString stringWithFormat:@"%ld", indexPath.row];
    
    // Configure the cell...
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 返回多选样式
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int arrayLength = [self.selectorPatnArray count];
    NSLog(@"%i",arrayLength);
    if (arrayLength >2) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        //初始化提示框；
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"投资品种选择不能超过三种" preferredStyle:  UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击按钮的响应事件；
        }]];
        
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];

        
    } else{
        //选中数据
        [self.selectorPatnArray addObject:self.categoryArray[indexPath.row]];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //从选中中取消
    if (self.selectorPatnArray.count > 0) {
        
        [self.selectorPatnArray removeObject:self.categoryArray[indexPath.row]];
    }
    
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
    
}

#pragma mark searchBarDelegete
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSMutableArray *tmpArray =[NSMutableArray array];
    if (searchText.length == 0) {
        self.isSearch = NO;
        self.categoryArray = self.backupArray;
        [self.tableView reloadData];

    }else{
        self.isSearch = YES;
        for (NSString *str in _categoryArray) {
            
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
            
            self.categoryArray = tmpArray;
            [self.tableView reloadData];
        }
        
    }
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.isSearch = NO;
    
}

#pragma mark -懒加载
-(NSMutableArray *)categoryArray{
    if (!_categoryArray) {
        _categoryArray = [NSMutableArray array];
    }
    return _categoryArray;
}

-(NSMutableArray *)selectorPatnArray{
    if (!_selectorPatnArray) {
        _selectorPatnArray = [NSMutableArray array];
    }
    return _selectorPatnArray;
}


-(NSMutableArray *)backupArray{
    if (!_backupArray) {
        _backupArray = [NSMutableArray array];
    }
    return _backupArray;
}
/*
#pragma mark -textField delegate Method
-(void)textFieldDidChange :(UITextField *)theTextField{
    NSLog( @"text changed: %@", _searchField);
    NSString *str1 =_searchField.text;
    NSMutableArray *tmpArr =[NSMutableArray array];
    if (str1.length !=0) {
        for (NSString *str in _categoryArray) {
            if ([str rangeOfString:str1].location != NSNotFound) {
                [tmpArr addObject:str];
            }
            self.categoryArray = tmpArr;
            [self.tableView reloadData];
        }
    } else {
        self.categoryArray = self.backupArray;
        [self.tableView reloadData];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *newValue = [_searchField.text mutableCopy];
    [newValue replaceCharactersInRange:range withString:string];
    if ([newValue length] != 0) {
        NSMutableArray *tmpArr =[NSMutableArray array];
        for (NSString *str in _categoryArray) {
            if ([str rangeOfString:newValue].location != NSNotFound) {
                [tmpArr addObject:str];
            }
            self.categoryArray = tmpArr;
            [self.tableView reloadData];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    self.categoryArray = self.backupArray;
    [self.tableView reloadData];
    
    return YES;
}

*/



@end

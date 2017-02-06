//
//  TradeIndexFilterViewController.m
//  RTradeDemo
//
//  Created by Luo on 9/28/16.
//  Copyright © 2016 administrator. All rights reserved.
//

#import "TradeIndexFilterViewController.h"
#import "TradeStatusViewController.h"
#import "TradeCategoryViewController.h"
#import "LeftMenuController.h"
#import "TradeMainTableController.h"
//背景红色
#define BGRED_COLOR [UIColor colorWithRed:216.0/255.0 green:40.0/255.0 blue:61.0/255.0 alpha:1.0]

@interface TradeIndexFilterViewController ()
{
    NSString *_sortFiled;
}
@property (strong,nonatomic)NSMutableDictionary *sortKeyDic;
@property (strong, nonatomic) IBOutlet UILabel *tradeLabel;
@property (strong, nonatomic) IBOutlet UIButton *totalRevenue;
@property (strong, nonatomic) IBOutlet UIButton *currentDayRevenue;

@property (strong, nonatomic) IBOutlet UIButton *minLoss;
@property (strong, nonatomic) IBOutlet UIButton *winDays;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
//按钮选中,中间值
@property (nonatomic,strong) UIButton *selectedBtn;

@end

@implementation TradeIndexFilterViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"排序筛选";
    _sortKeyDic = [[NSMutableDictionary alloc]init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction)];
    rightBtn.tintColor = [UIColor redColor];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    
    self.totalRevenue.layer.borderWidth = 1;
    self.totalRevenue.layer.cornerRadius = 10;
    self.totalRevenue.layer.masksToBounds = YES;
    self.totalRevenue.layer.borderColor = [[UIColor blackColor] CGColor];
    self.totalRevenue.selected = NO;
//    [self.totalRevenue addTarget:self action:@selector(sortButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.currentDayRevenue.layer.borderWidth = 1;
    self.currentDayRevenue.layer.cornerRadius = 10;
    self.currentDayRevenue.layer.masksToBounds = YES;
    self.currentDayRevenue.layer.borderColor = [[UIColor blackColor] CGColor];
    self.currentDayRevenue.selected = NO;
//    [self.totalRevenue addTarget:self action:@selector(sortButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.minLoss.layer.borderWidth = 1;
    self.minLoss.layer.cornerRadius = 10;
    self.minLoss.layer.masksToBounds = YES;
    self.minLoss.layer.borderColor = [[UIColor blackColor] CGColor];
    self.minLoss.selected = NO;
//    [self.totalRevenue addTarget:self action:@selector(sortButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.winDays.layer.borderWidth = 1;
    self.winDays.layer.cornerRadius = 10;
    self.winDays.layer.masksToBounds = YES;
    self.winDays.layer.borderColor = [[UIColor blackColor] CGColor];
    self.winDays.selected = NO;
//    [self.totalRevenue addTarget:self action:@selector(sortButton:) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil]];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = BGRED_COLOR;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
}


-(void)doneAction{
    
    if ([_tradeLabel.text isEqualToString:@"全部"]) {
        [self.sortKeyDic setValue:@"0" forKey:@"tradestate"];
    }
    if ([_tradeLabel.text isEqualToString:@"交易中"]) {
        [self.sortKeyDic setValue:@"1" forKey:@"tradestate"];
    }
    if (_categoryLabel.text.length !=0 && ![_categoryLabel.text isEqualToString:@"--"]) {
        NSArray *tmpArr = [_categoryLabel.text componentsSeparatedByString:@","];
        [self.sortKeyDic setValue:tmpArr forKey:@"contracts"];
    }
    self.allFilterBlock(_sortKeyDic);
    [self.navigationController popViewControllerAnimated:YES];
//    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    TradeMainTableController *tradeMainTableCtr = [mainStoryboard instantiateViewControllerWithIdentifier:@"TradeMainTableCtr"];
//    
//    tradeMainTableCtr.filterDic = self.sortKeyDic;
//    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:tradeMainTableCtr withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}
- (IBAction)sortButton:(UIButton *)sender {
    
    if (sender!= self.selectedBtn) {
        if (self.selectedBtn !=nil) {
            self.selectedBtn.backgroundColor = [UIColor clearColor];
            [self.selectedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.selectedBtn.layer.borderColor = [[UIColor blackColor]CGColor];
            [self.sortKeyDic setValue:nil forKey:@"sortKey"];
//            [self.sortKeyDic setValue:nil forKey:[NSString stringWithFormat:@"%li", self.selectedBtn.tag]];
        }
        self.selectedBtn.selected = NO;
        sender.selected = YES;
        self.selectedBtn = sender;
        self.selectedBtn.tag = sender.tag;
        sender.backgroundColor = [UIColor redColor];
        sender.layer.borderColor = [[UIColor redColor]CGColor];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        NSString *tagValue = [NSString stringWithFormat:@"%li",sender.tag % 200];
        [self.sortKeyDic setValue:tagValue forKey:@"sortKey"];
//        [self.sortKeyDic setValue:sender.titleLabel.text forKey:[NSString stringWithFormat:@"%li", sender.tag]];
    }else{
        self.selectedBtn.selected = YES;
    }
    NSLog(@"%@",self.sortKeyDic);
}



#pragma mark - Table view delegate method

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        
        UIView* myView = [[UIView alloc] init];
        myView.frame =CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 30);
        UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 20, 20)];
        imgView.image =[UIImage imageNamed:@"IconSort"];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [myView addSubview:imgView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 40, 20)];
        titleLabel.font =[UIFont systemFontOfSize:14];
        titleLabel.backgroundColor = [UIColor clearColor];

        titleLabel.text = @"排序";
        [myView addSubview:titleLabel];
        return myView;
    } else{
        UIView* myView1 = [[UIView alloc] init];
        myView1.frame =CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 30);
        UIImageView * imgView1 = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 20, 20)];
        imgView1.image =[UIImage imageNamed:@"IconFilterBlack"];
        imgView1.contentMode = UIViewContentModeScaleAspectFit;
        [myView1 addSubview:imgView1];
        
        UILabel *titleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 40, 20)];
        titleLabel1.font =[UIFont systemFontOfSize:14];
        titleLabel1.backgroundColor = [UIColor clearColor];

        titleLabel1.text = @"筛选";
        [myView1 addSubview:titleLabel1];
        return myView1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 ){
        return 30;
    }
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footer = [[UIView alloc]init];
    footer.frame =CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 1);
    return  footer;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            TradeStatusViewController *tradeStatusCtr = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"tradeStatusCtr"];
            tradeStatusCtr.filterBlock = ^(NSString *text){
                _tradeLabel.text = text;
                NSLog(@"tradeLabel %@",_tradeLabel.text);
            };
            [self.navigationController pushViewController:tradeStatusCtr animated:YES];
        }
        
        if (indexPath.row == 1) {
            TradeCategoryViewController *tradeCategoryCtr = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"tradeCategoryCtr"];
            tradeCategoryCtr.categoryBlock =^(NSString *text){
                _categoryLabel.text = text;
            };

            [self.navigationController pushViewController:tradeCategoryCtr animated:YES];
        }
    }
    
}



@end

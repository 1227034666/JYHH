//
//  TradeStatusViewController.m
//  RTradeDemo
//
//  Created by Michael Luo on 9/28/16.
//  Copyright © 2016 administrator. All rights reserved.
//

#import "TradeStatusViewController.h"
#import "TradeIndexFilterViewController.h"

@interface TradeStatusViewController ()
@property (strong, nonatomic) IBOutlet UIButton *allButton;
@property (strong, nonatomic) IBOutlet UIButton *tradingButton;

@end

@implementation TradeStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    self.allButton.selected = YES;
    self.tradingButton.selected = NO;
    [_allButton setImage:[UIImage imageNamed:@"BtnSelect"] forState:UIControlStateSelected];
    [_tradingButton setImage:[UIImage imageNamed:@"BtnSelect"] forState:UIControlStateSelected];
}

-(void)doneAction{
    NSString *_filterText;
    if (_allButton.selected) {
//     default all tranz
        self.filterBlock(@"全部");
    } else{
//      in trading
        self.filterBlock(@"交易中");
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)buttonAction:(UIButton *)sender {
 
    if (sender.tag == 100){
        _allButton.selected = YES;
        _tradingButton.selected = NO;
    }
}

- (IBAction)tradingBtnAction:(UIButton *)sender {
    if (sender.tag == 101) {
        _allButton.selected = NO;
        _tradingButton.selected = YES;
    }
}

#pragma mark - Table view data source


/*
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

//
//  MarketSelectionCell.h
//  RTradeDemo
//
//  Created by iMac on 16/12/28.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MarketSelectionModel;

@interface MarketSelectionCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *contractName;
@property (strong, nonatomic) IBOutlet UILabel *contractCode;
@property (strong, nonatomic) IBOutlet UILabel *contractSubcribed;
@property (strong, nonatomic) IBOutlet UIButton *addButton;

@property (strong, nonatomic) MarketSelectionModel *model;

@end

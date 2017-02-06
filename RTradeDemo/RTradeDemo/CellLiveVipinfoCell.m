//
//  CellLiveVipinfoCell.m
//  RTradeDemo
//
//  Created by administrator on 16/7/2.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "CellLiveVipinfoCell.h"
#import "TradeUtility.h"
#import "SlideNavigationController.h"
#import "RegisterAccountController.h"
#import "UIViewExt.h"


@implementation CellLiveVipinfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    _hasFollowInfo = NO;
//    self.m_btnFollow.layer.borderWidth = 1;
//    self.m_btnFollow.layer.borderColor = [UIColor redColor].CGColor;
//    if (!_hasFollowInfo) {
//        self.m_viewFollow.hidden = YES;
//        self.m_lineAboveFollow.hidden = YES;
//    }
//    [self createTranzButton];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)setItemData:(NSDictionary *)itemData{
    _itemData = itemData;
}



-(void)trancBtnAction:(UIButton *)button{
    
}

- (IBAction)followTransaction:(UIButton *)sender {
    
//    NSString *accountid = [TradeUtility LocalLoadConfigFileByKey:@"accountid" defaultvalue:@"0"];
//    int iaccountid = [accountid intValue];
//    NSLog(@"********* account id: %i",iaccountid);
//    if(iaccountid == 0)
//    {
//        [self bindAccount];
//    } else {
//        [self bindAccountDone];
//    }
    
}

-(void)bindAccount{
    
    //bind account
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisterAccountController *registerAccountController = [mainStoryboard instantiateViewControllerWithIdentifier:@"RegisterAccountController"];
    registerAccountController.nextViewController = @"LiveVipLivingController";
    registerAccountController.itemData = _itemData;
    registerAccountController.modalTransitionStyle =UIModalTransitionStyleCoverVertical;
    [appRootVC presentViewController:registerAccountController animated:YES completion:^{
        NSLog(@"Present Modal View");
    }];
    
    
}


-(void)bindAccountDone{
    
    NSString *accountid = [TradeUtility LocalLoadConfigFileByKey:@"accountid" defaultvalue:@"0"];
    int iaccountid = [accountid intValue];
    NSLog(@"********* account id: %i",iaccountid);
    
    if(iaccountid > 0){
        [TradeUtility LocalSaveConfigFileByKey:@"curConCode" value:[_itemData objectForKey:@"concode"]];
        [TradeUtility LocalSaveConfigFileByKey:@"curConPrice" value:[_itemData objectForKey:@"convalue"]];
        
        [TradeUtility LocalSaveConfigFileByKey:@"cur_updown" value:[_itemData objectForKey:@"updown"]];
        [TradeUtility LocalSaveConfigFileByKey:@"cur_updownrate" value:[_itemData objectForKey:@"updownrate"]];
        
        [TradeUtility LocalSaveConfigFileByKey:@"cur_avgprice" value:[_itemData objectForKey:@"trade_avgprice"]];
        [TradeUtility LocalSaveConfigFileByKey:@"cur_buyrate" value:[_itemData objectForKey:@"trade_buyrate"]];
        [TradeUtility LocalSaveConfigFileByKey:@"cur_fuying" value:[_itemData objectForKey:@"trade_fuying"]];
        [TradeUtility LocalSaveConfigFileByKey:@"cur_hold_time" value:[_itemData objectForKey:@"hold_time"]];
        [TradeUtility LocalSaveConfigFileByKey:@"cur_trade_type" value:[_itemData objectForKey:@"trade_type"]];
        [TradeUtility LocalSaveConfigFileByKey:@"cur_trade_state" value:[_itemData objectForKey:@"trade_state"]];
        
//        UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"LiveVipLivingController"];
        
        [[SlideNavigationController sharedInstance] pushToViewController:loginViewController withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
    }
}

/*

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint locationP = [touch locationInView:self];
    CGPoint point = [self convertPoint:locationP toView:_leadGroupView];
    BOOL inside = NO;
    inside = [_leadGroupView pointInside:point withEvent:event];
    
    if (inside) {
        
        NSLog(@"touched row: %li",_leadGroupView.tag);
        NSString *accountid = [TradeUtility LocalLoadConfigFileByKey:@"accountid" defaultvalue:@"0"];
        int iaccountid = [accountid intValue];
        NSLog(@"********* account id: %i",iaccountid);
        if(iaccountid == 0)
        {
            [self bindAccount];
        } else {
            [self bindAccountDone];
        }
        
    }
}

 */
@end

//
//  TradeAdvertiseView.m
//  RTradeDemo
//
//  Created by Michael Luo on 11/5/16.
//  Copyright © 2016 administrator. All rights reserved.
//

#import "TradeAdvertiseView.h"
#import "TradeUtility.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
static NSInteger showTime = 3;

@interface TradeAdvertiseView()
@property (strong, nonatomic) IBOutlet UIImageView *backView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong,nonatomic)dispatch_source_t timer;
@end

@implementation TradeAdvertiseView
+(instancetype)loadAdvertiseView{
    return [[[NSBundle mainBundle] loadNibNamed:@"TradeAdvertiseView" owner:self options:nil]lastObject];
}

-(void)awakeFromNib{
    self.frame = [UIScreen mainScreen].bounds;
    
    [self showAdvertise];
    [self doneAd];
    [self startTimer];
    
}
-(void)showAdvertise{
    NSString *filePath = [NSString stringWithFormat:@"adImage"];
    UIImage *lastCacheImage = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:filePath];
    if (lastCacheImage) {
        self.backView.image = lastCacheImage;
    } else {
        self.hidden = YES;
    }
}

-(void)doneAd{
    [TradeUtility requestAdvertiseWithSuccess:^(id result) {
        NSDictionary *adDic = (NSDictionary *)result;
        NSString *adUrl =adDic[@"pic"];
        NSURL *imgURL = [NSURL URLWithString:adUrl];
        [[SDWebImageManager sharedManager]loadImageWithURL:imgURL options:SDWebImageAvoidAutoSetImage progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
            [[NSUserDefaults standardUserDefaults] setObject:adUrl forKey:@"adImage"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            NSLog(@"advertise pic downloaded successfully");
        }];
    } failure:^(NSError *error) {
        NSLog(@"advertise error:@%@",error);
    }];
}
-(void)startTimer{
    __block NSInteger timeout = showTime +1;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    self.timer = timer;
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (timeout <= 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismiss];
            
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.timeLabel.text = [NSString stringWithFormat:@"跳过%zd",timeout];
                 });
            timeout --;
        }
    });
    dispatch_resume(timer);
}

-(void)dismiss{
    [UIView animateWithDuration:.5 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end

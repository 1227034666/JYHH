//
//  CellTradeDiscussCell.m
//  RTradeDemo
//
//  Created by administrator on 16/6/23.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "CellTradeDiscussCell.h"
#import "CellTradeDiscussModel.h"
#import "MyView.h"

@implementation CellTradeDiscussCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(CellTradeDiscussModel *)model{
    _model = model;
    if (_model.m_strLogo.length > 0) {
        [self.m_strLogo sd_setImageWithURL:[NSURL URLWithString:_model.m_strLogo]];
    } else{
        self.m_strLogo.image = [TradeUtility reSizeImage:[UIImage imageNamed:@"Icon.png"] toSize:self.m_strLogo.frame.size];
    }
    self.m_strNickname.text = _model.m_strNickname;
    self.m_strViewTitle.text = _model.m_strViewTitle;
    self.m_strViewTags.text = _model.m_strViewTags;
    self.m_strViewText.text = _model.m_strViewText;
    self.m_strViewTime.text = _model.m_strViewTime;
    float textHeight = [TradeUtility getTextHeight:13 width:kScreenWidth text:_model.m_strViewText];
    
    if (_model.m_strImgView.length > 0) {
        self.m_strImgView.hidden = NO;
        self.m_strImgView.frame = CGRectMake(10, 98 + textHeight +5, 100, 100);
        NSURL *imgURL = [NSURL URLWithString:_model.m_strImgView];
        self.m_strImgView.contentMode = UIViewContentModeScaleAspectFill;
        self.m_strImgView.clipsToBounds = YES;
        
        [self.m_strImgView sd_setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"AppIcon"] options:SDWebImageRetryFailed];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
        [self.m_strImgView addGestureRecognizer:tap];
    } else{
        self.m_strImgView.size = CGSizeZero;
        self.m_strImgView.hidden = YES;
    }
}

-(void)tapAction{

    UIImageView *bigImgView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    bigImgView.backgroundColor = [UIColor grayColor];
    bigImgView.userInteractionEnabled = YES;
    NSString *bigPhotoUrl = _model.m_strImgView;
    bigImgView.contentMode = UIViewContentModeScaleAspectFit;
    [bigImgView setTag:0];
    NSString *bigURL =[bigPhotoUrl stringByReplacingOccurrencesOfString:@"small" withString:@"big"];
//    NSLog(@"bigPhotoUrl %@",bigURL);

    [bigImgView sd_setImageWithURL:[NSURL URLWithString:bigURL] placeholderImage:nil options:SDWebImageRetryFailed];

    [[UIApplication sharedApplication].keyWindow addSubview:bigImgView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapBigImgAction:)];
    [bigImgView addGestureRecognizer:tap];
}

-(void)TapBigImgAction:(UITapGestureRecognizer *)tap{

    //原始imageview
    UIImageView *bigImgView = [tap.view viewWithTag:0];
    [UIView animateWithDuration:0.4 animations:^{
        //完成后操作->将背景视图删掉
        [bigImgView removeFromSuperview];
            } completion:^(BOOL finished) {
    }];
}

//-(UIImageView *)m_strImgView{
//    _m_strImgView = [[UIImageView alloc]initWithFrame:CGRectZero];
//    _m_strImgView.contentMode = UIViewContentModeScaleAspectFill;
//    _m_strImgView.backgroundColor = [UIColor lightGrayColor];
//
//    _m_strImgView.clipsToBounds = YES;
//    //给图片添加手势
//    _m_strImgView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
//    [_m_strImgView addGestureRecognizer:tap];
//    [self.contentView addSubview:_m_strImgView];
//    return _m_strImgView;
//}

@end

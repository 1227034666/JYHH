//
//  YYStockView_TimeLine.m
//  YYStock  ( https://github.com/yate1996 )
//
//  Created by yate1996 on 16/10/10.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import "YYStockView_TimeLine.h"
#import "YYTimeLineView.h"
#import "YYTimeLineVolumeView.h"
#import "Masonry.h"
#import "YYStockConstant.h"
#import "YYStockVariable.h"
#import "UIColor+YYStockTheme.h"
#import "YYStockScrollView.h"
#import "YYTimeLineMaskView.h"
#import "YYFiveRecordView.h"
#import "YYLineDataModel.h"
//@interface YYStockView_TimeLine()<UITableViewDelegate, UIScrollViewDelegate>
@interface YYStockView_TimeLine()< UIScrollViewDelegate>
@property (nonatomic, strong) YYStockScrollView *stockScrollView;

/**
 分时线部分
 */
@property (nonatomic, strong) YYTimeLineView *timeLineView;

/**
 成交量部分
 */
@property (nonatomic, strong) YYTimeLineVolumeView *volumeView;

/**
 是否显示五档图
 */
@property (nonatomic, assign) BOOL isShowFiveRecord;

/**
 五档图
 */
@property (nonatomic, strong) YYFiveRecordView *fiveRecordView;

/**
 五档数据
 */
@property (nonatomic, strong) id<YYStockFiveRecordProtocol> fiveRecordModel;

/**
 当前绘制在屏幕上的数据源数组
 */
@property (atomic, strong) NSArray <id<YYStockTimeLineProtocol>>*drawLineModels;

/**
 当前绘制在屏幕上的数据源位置数组
 */
@property (nonatomic, copy) NSArray <NSValue *>*drawLinePositionModels;

/**
 长按时出现的遮罩View
 */
@property (nonatomic, strong) YYTimeLineMaskView *maskView;

/**
 时间字典
 */
@property (nonatomic,strong)NSMutableDictionary *timeIndexDic;


@end

@implementation YYStockView_TimeLine
{
#pragma mark - 页面上显示的数据
    //图表最大的价格
    CGFloat maxValue;
    //图表最小的价格
    CGFloat minValue;
    //图表最大的成交量
//    CGFloat volumeValue;
    //当前长按选中的model
    id<YYStockTimeLineProtocol> selectedModel;
    
    CGContextRef ctx;
    
}

/**
 构造器
 
 @param timeLineModels 数据源
 @param isShowFiveRecord 是否显示五档数据
 @param fiveRecordModel 五档数据源
 
 @return YYStockView_TimeLine对象
 */
- (instancetype)initWithTimeLineModels:(NSArray <id<YYStockTimeLineProtocol>>*) timeLineModels isShowFiveRecord:(BOOL)isShowFiveRecord fiveRecordModel:(id<YYStockFiveRecordProtocol>)fiveRecordModel rect:(CGRect)rect{
    self = [super init];
    if (self) {
        self.frame = rect;
        self.backgroundColor = [UIColor redColor];
        self.pointsArray =[NSArray array];
        _drawLineModels = timeLineModels;
        
        if (isShowFiveRecord) {
            _isShowFiveRecord = isShowFiveRecord;
            _fiveRecordModel = fiveRecordModel;
        }

        [self initUI];
        self.stockScrollView.userInteractionEnabled = YES;
        self.userInteractionEnabled = YES;
    }
    return self;
}

/**
 重绘视图
 
 @param timeLineModels  分时线数据源
 @param fiveRecordModel 五档数据源
 */
- (void)reDrawWithTimeLineModels:(NSArray <id<YYStockTimeLineProtocol>>*) timeLineModels isShowFiveRecord:(BOOL)isShowFiveRecord fiveRecordModel:(id<YYStockFiveRecordProtocol>)fiveRecordModel {
    _drawLineModels = timeLineModels;
    [_drawLineModels enumerateObjectsUsingBlock:^(id<YYStockTimeLineProtocol>  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
//            NSLog(@"idx : %@",model.TimeDesc);
            self.marketStartMinute = model.TimeDesc;
        }
        [self.timeIndexDic setObject:@(idx) forKey:model.TimeDesc];
    }];
//    NSLog(@"%@",self.timeIndexDic);
    _fiveRecordModel = fiveRecordModel;
    _isShowFiveRecord = isShowFiveRecord;
    [self layoutIfNeeded];
    [self updateScrollViewContentWidth];
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    ctx = UIGraphicsGetCurrentContext();
    if (self.drawLineModels.count > 0) {
        if (!self.maskView || self.maskView.isHidden) {
            //更新绘制的数据源
            [self updateDrawModels];
            //绘制K线上部分
            self.drawLinePositionModels = [self.timeLineView drawViewWithXPosition:0 drawModels:self.drawLineModels maxValue:maxValue minValue:minValue];
            //绘制成交量
            [self.volumeView drawViewWithXPosition:0 drawModels:self.drawLineModels];
            //更新背景线
            self.stockScrollView.isShowBgLine = YES;
            [self.stockScrollView setNeedsDisplay];
            //更新五档图
//            if (self.isShowFiveRecord) {
//                [self.fiveRecordView reDrawWithFiveRecordModel:self.fiveRecordModel];
//            }
            
        }
        if (self.pointsArray.count > 0) {
            [self drawPoints];
        }
        //绘制左侧文字部分
        [self drawLeftRightDesc];
    }
}


- (void)showTouchView:(NSSet<UITouch *> *)touches {
    static CGFloat oldPositionX = 0;
    CGPoint location = [touches.anyObject locationInView:self.stockScrollView];
    if (location.x < 0 || location.x > self.stockScrollView.contentSize.width) return;
    if(ABS(oldPositionX - location.x) < ([YYStockVariable timeLineVolumeWidth]+ YYStockTimeLineViewVolumeGap)/2) return;
    
    oldPositionX = location.x;
    NSInteger startIndex = (NSInteger)(oldPositionX / (YYStockTimeLineViewVolumeGap + [YYStockVariable timeLineVolumeWidth]));
    
    if (startIndex < 0) startIndex = 0;
    if (startIndex >= self.drawLineModels.count) startIndex = self.drawLineModels.count - 1;
    
    if (!self.maskView) {
        _maskView = [YYTimeLineMaskView new];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.frame = self.bounds;
        [self addSubview:_maskView];
    } else {
        self.maskView.hidden = NO;
    }
    
    selectedModel = self.drawLineModels[startIndex];
    self.maskView.selectedModel = self.drawLineModels[startIndex];
    self.maskView.selectedPoint = [self.drawLinePositionModels[startIndex] CGPointValue];
    self.maskView.stockScrollView = self.stockScrollView;
    [self setNeedsDisplay];
    [self.maskView setNeedsDisplay];
    if (self.delegate && [self.delegate respondsToSelector:@selector(YYStockView: selectedModel:)]) {
        [self.delegate YYStockView:self selectedModel:selectedModel];
    }
}

/**
 初始化子View
 */
- (void)initUI {
    
    //加载StockScrollView
    [self initUI_stockScrollView];
    
    //加载TimeLineView
    _timeLineView = [YYTimeLineView new];
    _timeLineView.backgroundColor = [UIColor clearColor];
//    _timeLineView.backgroundColor = [UIColor redColor];
    CGRect rect= _stockScrollView.bounds;
    rect.size.height -=15;
//    rect.size.width -=15;
    _timeLineView.frame = rect;
    [_stockScrollView.contentView addSubview:_timeLineView];
    
//    [_timeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.equalTo(_stockScrollView.contentView);
//        make.height.equalTo(_stockScrollView.contentView).multipliedBy([YYStockVariable lineMainViewRadio]);
//        make.width.equalTo(_stockScrollView).offset(-10);
//
//    }];
//    
//    加载VolumeView
    _volumeView = [YYTimeLineVolumeView new];
    _volumeView.backgroundColor = [UIColor clearColor];
//    _volumeView.backgroundColor = [UIColor purpleColor];
    CGRect rect1 = CGRectMake(0, _stockScrollView.bounds.size.height - 15, _stockScrollView.bounds.size.width, 15);
    _volumeView.frame = rect1;
    [_stockScrollView.contentView addSubview:_volumeView];
//
//    [_volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(_stockScrollView.contentView);
//        make.top.equalTo(_timeLineView.mas_bottom);
//        make.height.equalTo(_stockScrollView.contentView).multipliedBy(1-[YYStockVariable lineMainViewRadio]);
//    }];
}

- (void)initUI_stockScrollView {
    _stockScrollView = [YYStockScrollView new];
    _stockScrollView.stockType = YYStockTypeTimeLine;
//    _stockScrollView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    _stockScrollView.backgroundColor = [UIColor clearColor];
    _stockScrollView.showsHorizontalScrollIndicator = YES;
    _stockScrollView.delegate = self;
    CGRect rect = self.frame;
    rect.origin.x = 5;
    rect.size.width =[UIScreen mainScreen].bounds.size.width-10;
    _stockScrollView.selfRect = rect;
    [self addSubview:_stockScrollView];

    //长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(event_longPressAction:)];
    [_stockScrollView addGestureRecognizer:longPress];
    
}
/**
 绘制左边的价格部分
 */
- (void)drawLeftRightDesc {
    
//    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:9],NSForegroundColorAttributeName:[UIColor YYStock_topBarNormalTextColor]};
     NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:9],NSForegroundColorAttributeName:[UIColor redColor]};
    CGSize textSize = [self rectOfNSString:[NSString stringWithFormat:@"%.2f",(maxValue + minValue)/6.f] attribute:attribute].size;
    CGFloat unit = (self.stockScrollView.frame.size.height * [YYStockVariable lineMainViewRadio]-15) / 6.f;
    CGFloat unitValue = (maxValue - minValue)/6.f;
//    NSLog(@"maxValue %.2f",maxValue);
//    NSLog(@"minValue %.2f",minValue);
//    NSLog(@"unitValue %.2f",unitValue);
//    CGFloat leftGap = YYStockTimeLineViewLeftGap + 3;
    CGFloat leftGap = 0;
    CGFloat topOffset = -textSize.height/2.f;
    
    CGFloat creasePercent = (maxValue / ((maxValue + minValue)/2.f)) * 100 - 100;
    CGFloat unitPercent = creasePercent /3.f;
//    NSLog(@"%.2f",creasePercent);
    if (isnan(creasePercent) || creasePercent == INFINITY) {
        creasePercent = 0.00;
    }
    //顶部间距
    for (int i = 0; i < 7; i++) {
        if (i==3) {
            attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:9],NSForegroundColorAttributeName:[UIColor whiteColor]};
        }
        if (i>3) {
            attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:9],NSForegroundColorAttributeName:[UIColor greenColor]};
            
        }
        NSString *text = [NSString stringWithFormat:@"%.2f",maxValue - unitValue * i];
//        CGPoint leftDrawPoint = CGPointMake(leftGap , unit * i + YYStockScrollViewTopGap - textSize.height/2.f + topOffset);
        float _y =0;
        if (unit * i - textSize.height/2.f + topOffset > 0) {
            _y = unit * i - textSize.height/2.f + topOffset;
        }
        CGPoint leftDrawPoint = CGPointMake(leftGap , _y);
        [text drawAtPoint:leftDrawPoint withAttributes:attribute];
        
        NSString *text2 = [NSString stringWithFormat:@"%.2f%%",creasePercent - unitPercent * i];
  
        CGSize textSize2 = [self rectOfNSString:text2 attribute:attribute].size;
//        CGPoint rightDrawPoint = CGPointMake(CGRectGetMaxX(self.stockScrollView.frame) - textSize2.width - 30, unit * i + YYStockScrollViewTopGap - textSize.height/2.f + topOffset);
        CGPoint rightDrawPoint = CGPointMake(CGRectGetMaxX(self.stockScrollView.frame) - textSize2.width, _y);
        
        [text2 drawAtPoint:rightDrawPoint withAttributes:attribute];
    }
    
//    CGFloat volume =  [[[self.drawLineModels valueForKeyPath:@"Volume"] valueForKeyPath:@"@max.floatValue"] floatValue];
//    volumeValue = volume;
//    
//    //尝试转为万手
//    CGFloat wVolume = volume/10000.f;
//    NSString *text, *descText;
//    if (wVolume > 1) {
//        //尝试转为亿手
//        CGFloat yVolume = wVolume/10000.f;
//        if (yVolume > 1) {
//            text = [NSString stringWithFormat:@"%.2f",yVolume];
//            descText = @"亿手";
//        } else {
//            text = [NSString stringWithFormat:@"%.2f",wVolume];
//            descText = @"万手";
//        }
//    } else {
//        text = [NSString stringWithFormat:@"%.2f",volume];
//        descText = @"手";
//    }
//    [text drawInRect:CGRectMake(leftGap, YYStockScrollViewTopGap + self.stockScrollView.frame.size.height * (1 - [YYStockVariable volumeViewRadio]), 60, 20) withAttributes:attribute];
//    [descText drawInRect:CGRectMake(leftGap, YYStockScrollViewTopGap + 15 + self.stockScrollView.frame.size.height * (1 - [YYStockVariable volumeViewRadio]), 60, 20) withAttributes:attribute];
}

-(void)drawPoints{
    
    CGFloat minY = YYStockLineMainViewMinY;
    CGFloat maxY = _timeLineView.frame.size.height - YYStockLineMainViewMinY;
    CGFloat unitValue = (maxValue - minValue)/(maxY - minY);

    [_pointsArray enumerateObjectsUsingBlock:^(id<YYStockTimeLineProtocol>  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![[self.timeIndexDic allKeys] containsObject: model.TimeDesc]) {
            return;
        }
        NSInteger index = [[self.timeIndexDic objectForKey: model.TimeDesc] integerValue];
//        NSLog(@"model.TimeDesc :%@, index :%li",model.TimeDesc,index);
        CGFloat xPosition = 5 + index * ([YYStockVariable timeLineVolumeWidth] + YYStockTimeLineViewVolumeGap);
        CGPoint pricePoint = CGPointMake(xPosition, ABS(maxY - (model.Price.floatValue - minValue)/unitValue));
        NSInteger tradeType = [model.Volume integerValue];
        UIColor *pointColor;
        switch (tradeType) {
            case 0:
                pointColor = [UIColor YYStock_MA5LineColor];
                break;
            case 1:
                pointColor = [UIColor redColor];
                break;
            case 2:
                pointColor = [UIColor greenColor];
                break;
            default:
                break;
        }
        [self drawPoint:ctx point:pricePoint color:pointColor];
    }];

}

/**
 更新需要绘制的数据源
 */
- (void)updateDrawModels {
    
    //更新最大值最小值-价格
    CGFloat average = [self.drawLineModels.firstObject AvgPrice];
//    NSArray *tmp = [NSArray arrayWithArray:self.drawLineModels];
    maxValue = [[[self.drawLineModels valueForKeyPath:@"Price"] valueForKeyPath:@"@max.floatValue"] floatValue];
    minValue = [[[self.drawLineModels valueForKeyPath:@"Price"] valueForKeyPath:@"@min.floatValue"] floatValue];
//    maxValue = [[[tmp valueForKeyPath:@"Price"] valueForKeyPath:@"@max.floatValue"] floatValue];
//    minValue = [[[tmp valueForKeyPath:@"Price"] valueForKeyPath:@"@min.floatValue"] floatValue];
    if (ABS(maxValue - average) > ABS(average - minValue)) {
        minValue = 2 * average - maxValue;
    } else {
        maxValue = 2 * average - minValue;
    }
}

- (void)updateScrollViewContentWidth {

    //更新scrollview的contentsize
    self.stockScrollView.contentSize = self.stockScrollView.bounds.size;
    //9:30-11:30/13:00-15:00一共240分钟
    NSInteger minCount = 240;
    if ([[self.marketStartMinute substringToIndex:2] integerValue] >15 && [[self.marketStartMinute substringToIndex:2] integerValue] <=21) {
        minCount = 570;
    }
//    [YYStockVariable setTimeLineVolumeWidth:((self.stockScrollView.bounds.size.width - (minCount - 1) * YYStockTimeLineViewVolumeGap) / minCount)];
//    NSLog(@"screenwidth:%.1f",kScreenWidth);
    if (minCount < 250) {
        if (kScreenWidth <321) {
            [YYStockVariable setTimeLineVolumeWidth:1.2];
        } else if (kScreenWidth <376) {
            [YYStockVariable setTimeLineVolumeWidth:1.4];
        } else {
            [YYStockVariable setTimeLineVolumeWidth:1.6];
        }
    } else{
        if (kScreenWidth <321) {
           [YYStockVariable setTimeLineVolumeWidth:0.75];
        } else if (kScreenWidth <376) {
            [YYStockVariable setTimeLineVolumeWidth:0.75];
        } else {
            [YYStockVariable setTimeLineVolumeWidth:0.9];
        }
        
    }
//    NSLog(@"YYStockVariable timeLineVolumeWidth: %.2f", [YYStockVariable timeLineVolumeWidth]);

}


///******************************UITableViewDelegate*********************************/
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return section == 1 ? 5:0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (section == 1) {
//        UIView *view = [UIView new];
//
//        UIView *lineView = [UIView new];
////        lineView.backgroundColor = [UIColor YYStock_bgLineColor];
//        lineView.backgroundColor = [UIColor purpleColor];
//        [view addSubview:lineView];
////        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
////            make.edges.equalTo(view).insets(UIEdgeInsetsMake(2, 0, 2, 0));
////        }];
//
//        return view;
//    } else {
//        return nil;
//    }
//}

- (void)event_longPressAction:(UILongPressGestureRecognizer *)longPress {
    static CGFloat oldPositionX = 0;
    if(UIGestureRecognizerStateChanged == longPress.state || UIGestureRecognizerStateBegan == longPress.state) {
        CGPoint location = [longPress locationInView:self.stockScrollView];
        if (location.x < 0 || location.x > self.stockScrollView.contentSize.width) return;
//        NSLog(@"ABS(oldPositionX - location.x) :%.2f",ABS(oldPositionX - location.x));
//        NSLog(@"[YYStockVariable lineGap])/2   :%.2f",(YYStockTimeLineViewVolumeGap + [YYStockVariable timeLineVolumeWidth])/2);
//        if(ABS(oldPositionX - location.x) < ([YYStockVariable lineWidth] + [YYStockVariable lineGap])/2) return;
        if(ABS(oldPositionX - location.x) < (YYStockTimeLineViewVolumeGap + [YYStockVariable timeLineVolumeWidth])/2) return;
        
        //暂停滑动
        oldPositionX = location.x;
//        NSInteger startIndex = (NSInteger)(oldPositionX / (YYStockTimeLineViewVolumeGap + [YYStockVariable timeLineVolumeWidth]));
        NSInteger startIndex = (NSInteger)(oldPositionX / (YYStockTimeLineViewVolumeGap + [YYStockVariable timeLineVolumeWidth]));
//        NSInteger startIndex = (NSInteger)((oldPositionX - [self xPosition]) / ([YYStockVariable lineGap] + [YYStockVariable lineWidth]));
        if (startIndex < 0) startIndex = 0;
        if (startIndex >= self.drawLineModels.count) startIndex = self.drawLineModels.count - 1;
        
        if (!self.maskView) {
            _maskView = [YYTimeLineMaskView new];
            _maskView.backgroundColor = [UIColor clearColor];
            [self addSubview:_maskView];
            _maskView.frame = self.bounds;
//            [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.edges.equalTo(self);
//            }];
        } else {
            self.maskView.hidden = NO;
        }
        
        selectedModel = self.drawLineModels[startIndex];
        self.maskView.selectedModel = self.drawLineModels[startIndex];
        self.maskView.selectedPoint = [self.drawLinePositionModels[startIndex] CGPointValue];
        self.maskView.stockScrollView = self.stockScrollView;
        [self setNeedsDisplay];
        [self.maskView setNeedsDisplay];
        if (self.delegate && [self.delegate respondsToSelector:@selector(YYStockView: selectedModel:)]) {
            [self.delegate YYStockView:self selectedModel:selectedModel];
        }
    }
    
    if(longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled || longPress.state == UIGestureRecognizerStateFailed)
    {
        //恢复scrollView的滑动
        selectedModel = self.drawLineModels.lastObject;
        [self setNeedsDisplay];
        self.maskView.hidden = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(YYStockView: selectedModel:)]) {
            [self.delegate YYStockView:self selectedModel:nil];
        }
    }
}


- (CGRect)rectOfNSString:(NSString *)string attribute:(NSDictionary *)attribute {
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                       options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading
                                    attributes:attribute
                                       context:nil];
    return rect;
}

//在折线图上添加圆圈和提示标签
-(void)setPointsArray:(NSArray<id<YYStockTimeLineProtocol>> *)pointsArray{
    _pointsArray = pointsArray;
    [self setNeedsDisplay];
}

-(NSMutableDictionary*)timeIndexDic{
    if (_timeIndexDic == nil) {
        _timeIndexDic = [NSMutableDictionary dictionary];
    }
    return _timeIndexDic;
}


-(void)drawPoint:(CGContextRef)context point:(CGPoint)point color:(UIColor *)color{
    
    CGContextSetShouldAntialias(context, YES ); //抗锯齿
    CGColorSpaceRef Pointcolorspace1 = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, Pointcolorspace1);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, point.x,point.y);
    CGContextAddArc(context, point.x, point.y, 2, 0, 360, 0);
    CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    CGColorSpaceRelease(Pointcolorspace1);
}

//-(void)setMarketStartMinute:(NSString *)marketStartMinute{
//    _marketStartMinute = marketStartMinute;
//    [self updateScrollViewContentWidth];
//    [self setNeedsDisplay];
//}

@end

//
//  YYStock.m
//  YYStock  ( https://github.com/yate1996 )
//
//  Created by yate1996 on 16/10/5.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import "YYStock.h"
#import "YYTopBarView.h"
#import "YYStockConstant.h"
#import "YYStockView_Kline.h"
#import "YYStockView_TimeLine.h"
#import "UIColor+YYStockTheme.h"
#import "YYStockViewMaskView.h"
#import "YYStockVariable.h"

@interface YYStock()<YYTopBarViewDelegate, YYStockViewLongPressProtocol, YYStockViewTimeLinePressProtocol>
//@interface YYStock()<YYTopBarViewDelegate, YYStockViewTimeLinePressProtocol>
/**
 *  数据源
 */
@property (nonatomic, weak) id<YYStockDataSource> dataSource;



/**
 长按时出现的遮罩View
 */
@property (nonatomic, strong) YYStockViewMaskView *maskView;

@property (nonatomic, strong) NSMutableArray <__kindof UIView *>*stockViewArray;

@end

@implementation YYStock

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id)dataSource {
    self = [super init];
    if (self) {
        self.dataSource = dataSource;
        self.mainView = [[UIView alloc] initWithFrame:frame];
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self initUI_TopBarView];
    [self initUI_StockContainerView];
    [self.mainView bringSubviewToFront:_topBarView];
}

- (void)initUI_TopBarView {
    CGRect rect = self.mainView.bounds;
    rect.size.height = 35;
    rect.size.width = [UIScreen mainScreen].bounds.size.width;
    _topBarView = [[YYTopBarView alloc]initWithItems:[self.dataSource titleItemsOfStock:self] distributionStyle:YYTopBarDistributionStyleInScreen];

    [self.mainView addSubview:_topBarView];
    _topBarView.frame = rect;
    _topBarView.delegate = self;
}

- (void)initUI_StockContainerView {
    self.stockViewArray = [NSMutableArray array];
    CGRect rect = self.mainView.bounds;
//    rect.origin.y += 41;
    self.containerView = [[UIView alloc]initWithFrame:rect];

    [self.mainView addSubview:self.containerView];

    for (int i = 0; i < [[self.dataSource titleItemsOfStock:self] count]; i++) {
        UIView *stockView;
        rect.origin.y = 0;
        
        if ([self.dataSource stockTypeOfIndex:i] == YYStockTypeTimeLine) {
            //判断是否加载五档图
//            if ([self.dataSource respondsToSelector:@selector(isShowfiveRecordModelOfIndex:)]) {
//                stockView =  [[YYStockView_TimeLine alloc]initWithTimeLineModels:[self.dataSource YYStock:self stockDatasOfIndex:i] isShowFiveRecord:  [self.dataSource isShowfiveRecordModelOfIndex:self.currentIndex] fiveRecordModel:[self.dataSource fiveRecordModelOfIndex:i]];
//            } else {
                stockView =  [[YYStockView_TimeLine alloc]initWithTimeLineModels:[self.dataSource YYStock:self stockDatasOfIndex:i] isShowFiveRecord: NO fiveRecordModel:[self.dataSource fiveRecordModelOfIndex:i] rect:rect];
                stockView.backgroundColor = [UIColor blackColor];
//            }
            ((YYStockView_TimeLine *)stockView).delegate = self;
        } else {
            stockView =  [[YYStockView_Kline alloc]initWithLineModels:[self.dataSource YYStock:self stockDatasOfIndex:i]];
//            stockView = [[UIView alloc]init];
            ((YYStockView_Kline *)stockView).delegate = self;
            stockView.hidden = YES;
            stockView.backgroundColor = [UIColor blackColor];
//            stockView.backgroundColor = [UIColor YYStock_bgColor];
        }
//
        stockView.frame = rect;

        [self.containerView addSubview:stockView];
        
//        [stockView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.containerView);
//        }];
        [self.stockViewArray addObject:stockView];
    }
}

/**
 绘制
 */
- (void)draw {
    //更新数据
    NSInteger index = self.currentIndex;
    if ([self.stockViewArray[index] isKindOfClass:[YYStockView_Kline class]]) {
        YYStockView_Kline *stockView = (YYStockView_Kline *)(self.stockViewArray[index]);
        [stockView reDrawWithLineModels:[self.dataSource YYStock:self stockDatasOfIndex:index]];
        
    }
    if ([self.stockViewArray[index] isKindOfClass:[YYStockView_TimeLine class]]) {
        YYStockView_TimeLine *stockView = (YYStockView_TimeLine *)(self.stockViewArray[index]);
//        if ([self.dataSource respondsToSelector:@selector(isShowfiveRecordModelOfIndex:)]) {
//            [stockView reDrawWithTimeLineModels:[self.dataSource YYStock:self stockDatasOfIndex:index] isShowFiveRecord:[self.dataSource isShowfiveRecordModelOfIndex:0] fiveRecordModel:[self.dataSource fiveRecordModelOfIndex:index]];
//        } else {
        [stockView reDrawWithTimeLineModels:[self.dataSource YYStock:self stockDatasOfIndex:index] isShowFiveRecord:NO fiveRecordModel:nil];
//        stockView.marketStartMinute = _mktBeginTime;
//         NSLog(@"_mktBeginTime %@",_mktBeginTime);
//        }
    }
}

/**
 topBarView代理
 
 @param topBarView topBarView
 @param index      选中index
 */
- (void)YYTopBarView:(YYTopBarView *)topBarView didSelectedIndex:(NSInteger)index {
    self.stockViewArray[self.currentIndex].hidden = YES;
    self.stockViewArray[index].hidden = NO;
    self.currentIndex = index;
    [self draw];
}


/**
 StockView_Kline代理
 此处Kline和TimeLine都走这一个代理
 @param stockView YYStockView_Kline
 @param model     选中的数据源 若为nil表示取消绘制
 */
- (void)YYStockView:(YYStockView_Kline *)stockView selectedModel:(id<YYLineDataModelProtocol>)model {
    if (model == nil) {
        self.maskView.hidden = YES;
    } else {
        if (!self.maskView) {
            CGRect rect =self.topBarView.bounds;
            _maskView = [YYStockViewMaskView new];
            _maskView.backgroundColor = [UIColor clearColor];
            [self.mainView addSubview:_maskView];
            _maskView.frame = rect;
        } else {
            self.maskView.hidden = NO;
        }
        if ([stockView isKindOfClass:[YYStockView_Kline class]]) {
            self.maskView.stockType = YYStockTypeLine;
        } else {
            self.maskView.stockType = YYStockTypeTimeLine;
        }
        self.maskView.selectedModel = model;
        [self.maskView setNeedsDisplay];
    }
}

//在折线图上添加圆圈和提示标签
-(void)setPointsArray:(NSArray *)pointsArray{
    NSInteger index = self.currentIndex;
    if (index ==0 ) {
        if ([self.stockViewArray[index] isKindOfClass:[YYStockView_TimeLine class]]) {
            YYStockView_TimeLine *stockView = (YYStockView_TimeLine *)(self.stockViewArray[index]);
            stockView.pointsArray = pointsArray;
        }
//    } else if (index == 1){
//        if ([self.stockViewArray[index] isKindOfClass:[YYStockView_Kline class]]) {
//            YYStockView_Kline *stockView = (YYStockView_Kline *)(self.stockViewArray[index]);
//            stockView.pointsArray = pointsArray;
//        }
    }
}

-(void)setTopBarHidden:(BOOL)topBarHidden{
    _topBarView.isHidden = topBarHidden;
}
@end

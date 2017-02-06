//
//  TradeMainCustomCell.m
//  RTradeDemo
//
//  Created by administrator on 16/5/6.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import "TradeMainCustomCell.h"
#import "UIViewExt.h"

@implementation TradeMainCustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.vipPhoto.layer.masksToBounds = YES;
    self.vipPhoto.layer.cornerRadius = self.vipPhoto.width/2.0f;
    self.vipPhoto.contentMode = UIViewContentModeScaleAspectFit;
    
    self.vipTradeState.layer.cornerRadius = 10;
    self.vipTradeState.layer.masksToBounds = YES;
    self.vipTradeState.layer.borderColor = [[UIColor redColor] CGColor];
    self.vipTradeState.layer.borderWidth = 3;
//    [self showContractDataGraph];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

      //不清楚高度则先添加基本得内部所有子控件
        //[self setData];
//        NSLog(@"inityielddata=%@",self.yielddata);
    }

    return self;
}

- (void)showContractDataGraph:(NSArray *)xArray YArray:(NSArray *)yArray PointArray:(NSArray *)pArray{
//    CGRect rect = CGRectMake(self.contentView.frame.origin.x+20, self.contentView.frame.origin.y+61,
//                             self.contentView.frame.size.width,
//                             self.contentView.frame.size.height - 125)
   
    //    self.brokenView.unitxArray = @[@"2",@"4",@"6",@"8",@"10",@"12"];
    //    self.brokenView.unityArray = @[@"0",@"10",@"20",@"30",@"40",@"50",@"60"];
    //    self.brokenView.pointArray = @[@"31",@"51",@"42",@"59",@"47",@"40"];
    [self.brokenView clearScreen];
    self.brokenView.unitxArray = [xArray mutableCopy];
    self.brokenView.unityArray = [yArray mutableCopy];
    self.brokenView.pointArray = [pArray mutableCopy];
}

/*
- (void)showContractDataGraph
{
    //************* Test: Create Data Source *************
    NSMutableArray *dataSource = [NSMutableArray array];
    double distanceMin = 0, distanceMax = 100;
    double altitudeMin = 5.0, altitudeMax = 50;
    double speedMin = 0.5, speedMax = 15;
    
    srand(time(NULL)); //Random seed
    
    NSLog(@"yielddata=%@",self.yielddata);
    if(self.yielddata != nil)
    {
        for (int i=0; i< self.yielddata.count; i++) {
        
            NSDictionary *itemData = [self.yielddata objectAtIndex:i];
        
            RLLineChartItem *item = [[RLLineChartItem alloc] init];
            double randVal;
        
            randVal = [[itemData valueForKey:@"yieldday"] intValue];
            item.xValue = randVal - 20160000;
        
            randVal = [[itemData valueForKey:@"yieldrate"] intValue] / 100;//rand() /((double)(RAND_MAX)/priceMax) + priceMin;
            item.y1Value = randVal;
        
            randVal = [[itemData valueForKey:@"yieldrate"] intValue] / 100;//rand() /((double)(RAND_MAX)/priceMax2) + priceMin2;
            item.y2Value = randVal;
        
            NSLog(@"Random: item.xValue=%.2lf, item.y1Value=%.2lf, item.y2Value=%.2lf", item.xValue, item.y1Value, item.y2Value);
            [dataSource addObject:item];
        }
    }
    //************ End Test *********************
    
    ////////////// Create Line Chart //////////////////////////
    CGRect rect = CGRectMake(self.contentView.frame.origin.x+20, self.contentView.frame.origin.y+100,
                             self.contentView.frame.size.width - 20,
                             self.contentView.frame.size.height - 60);
    NSLog(@"rect(%.2f,%.2f,%.2f,%.2f)",self.contentView.frame.origin.x,self.contentView.frame.origin.y,self.contentView.frame.size.width,self.contentView.frame.size.height);
    NSLog(@"rect(%.2f,%.2f,%.2f,%.2f)",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    self.lineChartView = [[ARLineChartView alloc] initWithFrame:rect dataSource:dataSource xTitle:@"" y1Title:@"" y2Title:@"" desc1:@"" desc2:@""];
    //self.lineChartView = [[ARLineChartView alloc] initWithFrame:rect dataSource:dataSource xTitle:@"Kilometre" y1Title:@"Altitude (meters)" y2Title:@"Speed (km/h)" desc1:@"Altitude" desc2:@"Speed"];
    //[self.backgroundView addSubview:self.lineChartView];
    self.backgroundView = self.lineChartView;
}

 */
-(void)setContractArray:(NSArray *)contractArray{
    _contractArray = contractArray;
    if (![_contractArray isKindOfClass:[NSNull class]] && _contractArray.count > 0) {
        switch (_contractArray.count) {
            case 1:
                _vipTags.text = _contractArray[0];
                _vipTag1.hidden = YES;
                _vipTag2.hidden = YES;
                break;
            case 2:
                _vipTags.text = _contractArray[0];
                _vipTag1.text = _contractArray[1];
                _vipTag2.hidden = YES;
                break;
            case 3:
                _vipTags.text = _contractArray[0];
                _vipTag1.text = _contractArray[1];
                _vipTag2.text = _contractArray[2];
                break;
            default:
                break;
        }
    } else {
        _vipTags.hidden = YES;
        _vipTag1.hidden = YES;
        _vipTag2.hidden = YES;
    }
}


-(void)setYielddata:(NSArray *)yielddata{
    _yielddata = yielddata;
    //    NSLog(@"%@",_yielddata);
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:_yielddata];
    NSMutableArray *xArr = [NSMutableArray arrayWithCapacity:tmpArr.count];
    NSMutableArray *yArr = [NSMutableArray arrayWithCapacity:tmpArr.count];
    NSMutableArray *pointArr = [NSMutableArray arrayWithCapacity:tmpArr.count];
    
    if(tmpArr != nil){
        if ([tmpArr count]>1) {
            NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"yieldday" ascending:YES]];
            [tmpArr sortUsingDescriptors:sortDescriptors];
        }
        //NSLog(@"%@",tmpArr);
        double yMin = 0;
        double yMax = 0;
        for (int i=0; i< tmpArr.count; i++) {
            NSString *dateStr= tmpArr[i][@"yieldday"];
            NSString *finalDate = [NSString stringWithFormat:@"%@.%@",[dateStr substringWithRange:NSMakeRange(0, 4)],[dateStr substringWithRange:NSMakeRange(4, 2)]];
            [xArr addObject:finalDate];
            //NSString *yieldRate = tmpArr[i][@"yieldrate"];
            
            double yRate = [tmpArr[i][@"yieldrate"] doubleValue] *100;
            [pointArr addObject:[NSString stringWithFormat:@"%.1f",yRate]];
            if (yRate > yMax) {
                yMax = yRate;
            }
           
            if (yRate < yMin) {
                yMin = yRate;
            }
           
            if (yMin +10 > yMax) {
                yMax = yMin + 10;
            }
        }
        yMin-= 10;
        double diff = (yMax - yMin)/5.0f;
        
        for (NSInteger i=0; i<6; i++) {
            NSString *str = [NSString stringWithFormat:@"%.1f",yMin + i*diff];
            [yArr addObject:str];
        }
    }
    
//    NSLog(@"%@",xArr);
//    NSLog(@"%@",yArr);
//    NSLog(@"%@",pointArr);
    [self showContractDataGraph:[xArr copy] YArray:[yArr copy] PointArray:[pointArr copy]];
}

-(BrokrnSelfSView*)brokenView{
    if (_brokenView == nil) {
        CGRect rect = CGRectMake(self.contentView.frame.origin.x+20, self.contentView.frame.origin.y+61,
                                 self.contentView.frame.size.width,
                                 self.contentView.frame.size.height - 125);
        
        _brokenView = [[BrokrnSelfSView alloc]initWithFrame:rect];
        _brokenView.userInteractionEnabled = NO;
        [self.contentView addSubview:_brokenView];
    }
    return _brokenView;
}

@end

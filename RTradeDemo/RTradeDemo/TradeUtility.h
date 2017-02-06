//
//  TradeUtility.h
//  RTradeDemo
//
//  Created by administrator on 16/5/14.
//  Copyright © 2016年 administrator. All rights reserved.
// 网络请求的界面

#import <Foundation/Foundation.h>
#import "AFNetworking.h"



@interface TradeUtility : NSObject


+(NSDictionary *)HTTPSyncPOSTRequest:(NSString *)url parameters:( NSDictionary *)parameters;
+(NSString *)HTTPBodyWithParameters:( NSDictionary *)parameters;
+(void)LocalInitConfigFile;
+(void)LocalDeleteConfigFile;
+(NSString *)LocalLoadConfigFileByKey:(NSString *)key defaultvalue:(NSString *)defaultvalue;  //本地取值
+(BOOL)LocalSaveConfigFileByKey:(NSString *)key value:(NSString *)value;        //本地存执值
+(void)ShowNetworkErrDlg:(UIViewController *)view;
+(void)ShowServiceInfoDlg:(UIViewController *)view;


+(void)requestWithUrl:(NSString *)url
           httpMethod:(NSString *)method
               pramas:(NSMutableDictionary *)prama
             fileData:(NSMutableDictionary *)fileDic
              success:(void (^)(id result))successBlock
              failure:(void (^)(NSError *error))failBlock;



+(void)requestAdvertiseWithSuccess:(void (^)(id result))successBlock
                           failure:(void (^)(NSError *error))failBlock;
+(void)downloadWithUrl:(NSString *)url fileName:(NSString *)fileName;

//计算文本内容的高度
+ (float)getTextHeight:(float)fontSize
                 width:(float)width
                  text:(NSString *)text;
//pragma mark - 根据图片url获取图片尺寸
+(CGSize)getImageSizeWithURL:(id)imageURL;

+(UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;

+(NSString *)parseDateTime:(NSString *)dateStr;
@end

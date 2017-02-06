//
//  TradeUtility.m
//  RTradeDemo
//
//  Created by administrator on 16/5/14.
//  Copyright © 2016年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TradeUtility.h"
#import "AppDelegate.h"

#define  BaseUrl  @"http://inf.91trader.com/rtrade/user/"
#define  NewBaseUrl  @"http://interface.91trader.com/Public/interface.php"
#define AdvertiseUrl @"http://i.l.inmobicdn.net/banners/FileData/290057e6-a662-411d-86bb-688b3c284460.jpeg"

@implementation TradeUtility
+(void)requestWithUrl:(NSString *)url
           httpMethod:(NSString *)method
               pramas:(NSMutableDictionary *)prama
             fileData:(NSMutableDictionary *)fileDic
              success:(void (^)(id result))successBlock
              failure:(void (^)(NSError *error))failBlock{
    NSString *_url;
    
    //1.url
    if([url rangeOfString:@"91trader"].location != NSNotFound)//_roaldSearchText
    {
        _url =  url;
    } else{
        _url = NewBaseUrl;
        NSLog(@"%@",_url);
        if (prama != nil) {
            [prama setObject:url forKey:@"action"];
        } else{
            prama = [NSMutableDictionary dictionary];
            [prama setObject:url forKey:@"action"];
        }
    }
    
    NSLog(@"%@",url);
    
    
    //2.参数
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
//    [prama setObject:[sinaweiboInfo objectForKey:@"AccessTokenKey"] forKey:@"access_token"];
    
    //请求数据
    //AFHTTPSessionManager
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AFHTTPSessionManager *manager = [app sharedHTTPSession];
    if ([method caseInsensitiveCompare:@"GET"] == NSOrderedSame) {
        [manager GET:_url parameters:prama progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            successBlock(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failBlock(error);
        }];
//        [manager GET:_url parameters:prama success:^(NSURLSessionDataTask *task, id responseObject) {
//            successBlock(responseObject);
//        } failure:^(NSURLSessionDataTask *task, NSError *error) {
//            failBlock(error);
//        }];
    }else if ([method caseInsensitiveCompare:@"POST"] == NSOrderedSame){
        if (fileDic) {//带有图片
            [manager POST:_url parameters:prama constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                //图片数据
                for (NSString *key in fileDic) {
                    NSData *data =  fileDic[key];
                    //把图片拼接到参数中
                    [formData appendPartWithFileData:data name:key fileName:key mimeType:@"image/jpeg"];
                }
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                successBlock(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                failBlock(error);
            }];
//           [manager POST:_url parameters:prama constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//                //图片数据
//                for (NSString *key in fileDic) {
//                    NSData *data =  fileDic[key];
//                    //把图片拼接到参数中
//                    [formData appendPartWithFileData:data name:key fileName:key mimeType:@"image/jpeg"];
//                }
//            } success:^(NSURLSessionDataTask *task, id responseObject) {
//                successBlock(responseObject);
//            } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                failBlock(error);
//            }];

        }else{
            [manager POST:_url parameters:prama progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                successBlock(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                failBlock(error);
            }];
//            [manager POST:_url parameters:prama success:^(NSURLSessionDataTask *task, id responseObject) {
//                successBlock(responseObject);
//            } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                failBlock(error);
//            }];
        }
    }
}


+ ( NSString *)HTTPBodyWithParameters:( NSDictionary *)parameters
{
    NSMutableArray *parametersArray = [[ NSMutableArray alloc ] init ];
    
    for ( NSString *key in [parameters allKeys ]) {
        id value = [parameters objectForKey :key];
        if ([value isKindOfClass :[ NSString class ]]) {
            [parametersArray addObject :[ NSString stringWithFormat : @"%@=%@" ,key,value]];
        }
        
    }
    
    return [parametersArray componentsJoinedByString : @"&" ];
}

+(NSDictionary *)HTTPSyncPOSTRequest:(NSString *)url parameters:( NSDictionary *)parameters
{
    NSLog(@"HTTPSyncGETRequest=%@",url);
    NSURL *requrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requrl];
    NSString *HTTPBodyString = [ self HTTPBodyWithParameters :parameters];
    [request setHTTPBody :[HTTPBodyString dataUsingEncoding : NSUTF8StringEncoding ]];
    [request setHTTPMethod : @"POST" ];
    
    NSData *data  = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//    NSData *data  = [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:nil];
                     //NSLog(@"NSdata=%@",data);
    if(data == nil)
    {
        return nil;
    }
    
    NSDictionary *resDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"请求完成...%@",resDict);
    
    return resDict;
}

+(void)LocalInitConfigFile{
    NSFileManager *fileManager = [NSFileManager defaultManager]; NSString *writableDBPath = [self applicationDocumentsDirectoryFile];
    BOOL dbexits = [fileManager fileExistsAtPath:writableDBPath];
    if (!dbexits) {
        BOOL success = [fileManager createFileAtPath:writableDBPath contents:nil attributes:nil];
        if (!success) {
            NSLog(@"错误写入文件");
        }else{
            NSMutableDictionary *config = [NSMutableDictionary dictionaryWithCapacity:10];
            [config setObject:@"0" forKey:@"uid"];
            
//            NSLog(@"init config=%@",config);
            [config writeToFile:writableDBPath atomically:YES];
        }
    }
}
+(void)LocalDeleteConfigFile{
    NSFileManager *fileManager = [NSFileManager defaultManager]; NSString *writableDBPath = [self applicationDocumentsDirectoryFile];
    BOOL dbexits = [fileManager fileExistsAtPath:writableDBPath];
    if (dbexits) {
        [fileManager removeItemAtPath:writableDBPath error:nil];
    }
}

+ (NSString *)applicationDocumentsDirectoryFile {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains
                                   (NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory
                      stringByAppendingPathComponent:@"TradeConfig1.plist"];
    return path;
}

+(NSString *)LocalLoadConfigFileByKey:(NSString *)key defaultvalue:(NSString *)defaultvalue
{
    NSString *path = [self applicationDocumentsDirectoryFile];
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSString *value = [config objectForKey:key];
    if(value != nil)
    {
        return value;
    }
    else
    {
        return defaultvalue;
    }
}

+(BOOL)LocalSaveConfigFileByKey:(NSString *)key value:(NSString *)value
{
    NSString *path = [self applicationDocumentsDirectoryFile];
    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
//    NSLog(@"key=%@,value=%@",key,value);
//    NSLog(@"path=%@",path);
//    NSLog(@"config=%@",config);
    
    [config setObject:value forKey:key];
    
//    NSLog(@"savecfg=%@",config);
    
    return [config writeToFile:path atomically:YES];
    
}

+(void)ShowNetworkErrDlg:(UIViewController *)view
{
    //初始化提示框；
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"网络错误" preferredStyle:  UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //点击按钮的响应事件；
    }]];
    
    //弹出提示框；
    [view presentViewController:alert animated:true completion:nil];
}

+(void)ShowServiceInfoDlg:(UIViewController *)view
{
    //初始化提示框；
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"在线客服" message:@"4008-888-1234" preferredStyle:  UIAlertControllerStyleAlert];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //点击按钮的响应事件；
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"拨打" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self callService:view];
        
    }]];
    
    //弹出提示框；
    [view presentViewController:alert animated:true completion:nil];
}

//-(void)callService:(UIViewController *)view{
//    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",@"4000620113"];
//    UIWebView * callWebview = [[UIWebView alloc] init];
//    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
//    [view addSubview:callWebview];
//}
+(void)requestAdvertiseWithSuccess:(void (^)(id result))successBlock
                           failure:(void (^)(NSError *error))failBlock{
    //AFHTTPSessionManager
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AFHTTPSessionManager *manager = [app sharedHTTPSession];
        [manager GET:AdvertiseUrl parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            successBlock(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failBlock(error);
        }];
//        [manager GET:AdvertiseUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//            successBlock(responseObject);
//        } failure:^(NSURLSessionDataTask *task, NSError *error) {
//            failBlock(error);
//        }];
}
//   download files
+(void)downloadWithUrl:(NSString *)url fileName:(NSString *)fileName{
    //AFHTTPSessionManager
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AFHTTPSessionManager *manager = [app sharedHTTPSession];
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    //url
//    NSString *url1 = [url stringByRemovingPercentEncoding];
    NSString *url1 = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url1]];

    NSURLSessionDownloadTask *downTask= [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //targetPath (临时的文件路径)
        //block的返回值真正我们要存储的位置
        
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",fileName]];
        NSLog(@"%@",filePath);
        
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"%@",response);
        NSLog(@"下载成功");
    }];
//    NSURLSessionDownloadTask *downTask= [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        //targetPath (临时的文件路径)
//        //block的返回值真正我们要存储的位置
//        
//        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",fileName]];
//        NSLog(@"%@",filePath);
//        
//        return [NSURL fileURLWithPath:filePath];
//    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//        NSLog(@"%@",response);
//        NSLog(@"下载成功");
//    }];
    //手动启动
    [downTask resume];
}

#pragma mark - 计算文本高度
#define kHeightDic @"kHeightDic"
//计算文本内容的高度
+ (float)getTextHeight:(float)fontSize
                 width:(float)width
                  text:(NSString *)text{
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:17]};

    CGSize stringSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    return stringSize.height;
}

//resize right barButton Item Images
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}
//时间的转换
+(NSString *)parseDateTime:(NSString *)dateStr{
    
    NSString *formater =@"yyyy-MM-dd HH:mm:ss";
    
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    //语言环境
    [dateformater setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    
    [dateformater setDateFormat:formater];
    //时间
    NSDate *date = [dateformater dateFromString:dateStr];
    
    //现在的时间
    return [date timeAgoSinceNow];
    
}
@end


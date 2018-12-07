//
//  ViewController.m
//  GetData
//
//  Created by lei li on 2018/12/7.
//  Copyright © 2018 lei li. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *temp = [ViewController json2Dictionary];
    NSArray *videoDetails = temp[@"videoDetails"];
    for (NSDictionary *tem in videoDetails) {
        [self testWithurl:tem[@"url"]];
    }
}
+(NSDictionary *)json2Dictionary
{
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"224" ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}
-(void)testWithurl:(NSString *)aUrl{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:@"https://www.parsevideo.com/api.php?callback=jQuery1124033001670671024796_1544160786004"];
    
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    
    NSString *orders = [NSString stringWithFormat:@"hash=7740487e13f9a91f4a9bc27ce5a71d4d&url=%@",aUrl];
    //5.设置请求体
    request.HTTPBody = [orders dataUsingEncoding:NSUTF8StringEncoding];
    
    //6.根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     data：响应体信息（期望的数据）
     response：响应头信息，主要是对服务器端的描述
     error：错误信息，如果请求失败，则error有值
     */
    __weak ViewController *weakself = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *str1 = [str stringByReplacingOccurrencesOfString:@"jQuery1124033001670671024796_1544160786004(" withString:@""];
        NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@");" withString:@""];
        //8.解析数据
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[str2 dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        
    }];
    
    //7.执行任务
    [dataTask resume];
    
    
    
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]init];
//    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
//    manager.responseSerializer = [AFJSONResponseSerializer new];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
//    [manager POST:@"http://www.wuqiongda8888.com/app/list.htm" parameters:@{@"id":@"50",
//                                                                            @"page":@"1",
//                                                                            @"pageSize":@"100000",
//                                                                            @"videoSize":@"100000"
//                                                                            } progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *content = [responseObject objectForKey:@"content"];
//        NSArray  *categoryVideos = content[@"categoryVideos"];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//    }];
}

@end

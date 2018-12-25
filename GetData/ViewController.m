//
//  ViewController.m
//  GetData
//
//  Created by lei li on 2018/12/7.
//  Copyright © 2018 lei li. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import <NSObject+LKDBHelper.h>
#import "CategoryModel.h"
#import "VideoModel.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>

@interface ViewController ()
{
    int download_index;
    int thumb_index;
}
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *videourlLabel;
@property(nonatomic,strong) UIProgressView *downloadProgress;
@property(nonatomic,strong) UILabel *progressLabel;
@property(nonatomic,strong) UIImageView *thumbImageView;

/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation ViewController

+(NSDictionary *)json2Dictionary
{
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"list" ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"获取视频分类" forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 100, 200, 50);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnCateGoryBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"获取视频列表" forState:UIControlStateNormal];
    btn1.frame = CGRectMake(100, 200, 200, 50);
    btn1.backgroundColor = [UIColor greenColor];
    [btn1 addTarget:self action:@selector(btnCateGoryBtnClick1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"获取视频列表" forState:UIControlStateNormal];
    btn2.frame = CGRectMake(100, 300, 200, 50);
    btn2.backgroundColor = [UIColor purpleColor];
    [btn2 addTarget:self action:@selector(downloadVideoBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 400, CGRectGetWidth(self.view.frame), 50)];
    [self.view addSubview:_titleLabel];
    self.videourlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 500, CGRectGetWidth(self.view.frame), 50)];
    [self.view addSubview:_videourlLabel];
    
    self.downloadProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 500,CGRectGetWidth(self.view.frame), 50)];
    [self.view addSubview:_downloadProgress];
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 510,CGRectGetWidth(self.view.frame), 50)];
    [self.view addSubview:_progressLabel];
    
//    download_index = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"download_index"];
    download_index = 2230;
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn3 setTitle:@"获取截图" forState:UIControlStateNormal];
    btn3.frame = CGRectMake(100, 360, 200, 50);
    btn3.backgroundColor = [UIColor yellowColor];
    [btn3 addTarget:self action:@selector(thumbnailImageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    
    self.thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight([UIScreen mainScreen].bounds)-200, CGRectGetWidth([UIScreen mainScreen].bounds), 200)];
    _thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_thumbImageView];
}
-(void)thumbnailImageBtnClick{
    NSArray *categorys = [VideoModel searchWithSQL:@"select * from VideoModel"];
    VideoModel *video = categorys[thumb_index];
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * rarFilePath = [docsdir stringByAppendingPathComponent:[NSString stringWithFormat:@"videofile/%@",video.categoryId]];//将需要创建的串拼接到后面
    NSString * dataFilePath = [rarFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",video.videoId]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];
    
    if ((dataFilePath && existed == YES) ) {
        NSURL *url = [NSURL fileURLWithPath:dataFilePath];
        UIImage *fileImage = [ViewController thumbnailImageForVideo:url atTime:500];
        self.thumbImageView.image = fileImage;
        //获取Document文件
        NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * rarFilePath = [docsdir stringByAppendingPathComponent:[NSString stringWithFormat:@"thumbImages/%@",video.categoryId]];//将需要创建的串拼接到后面
        NSString * dataFilePath = [rarFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",video.videoId]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = NO;
        // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
        BOOL existed = [fileManager fileExistsAtPath:rarFilePath isDirectory:&isDir];
        if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
            [fileManager createDirectoryAtPath:rarFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        // Write image to PNG
        [UIImagePNGRepresentation(fileImage) writeToFile:dataFilePath atomically:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self->thumb_index++;
            [self thumbnailImageBtnClick];
        });
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self->thumb_index++;
            [self thumbnailImageBtnClick];
        });
    }
}
+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:opts];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    return thumbnailImage;
}

-(void)btnCateGoryBtnClick{
    [LKDBHelper clearTableData:NSClassFromString(@"CategoryModel")];
    NSDictionary *list = [ViewController json2Dictionary];
    NSArray *categoryVideos = list[@"content"][@"categoryVideos"];
    NSArray *videos = categoryVideos[0][@"videos"];
    for (NSDictionary *temp in videos) {
        CategoryModel *category = [[CategoryModel alloc] init];
        category.categoryId = temp[@"id"];
        category.categoryName = temp[@"name"];
        category.categoryImgUrl = temp[@"url"];
        [category saveToDB];
    }
}
-(void)btnCateGoryBtnClick1{
    NSArray *categorys = [CategoryModel searchWithSQL:@"select * from CategoryModel"];

    __block int i = 0;
    
    __block int timeout=1000; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),2.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置

            });
        }else{

            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                if (i == categorys.count) {
                    dispatch_source_cancel(_timer);
                    return ;
                }
                CategoryModel *model = categorys[i];
                [self testWithID:model.categoryId];
                i++;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}
-(void)downloadVideoBtnClick{
    @try {
//        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
        NSArray *categorys = [VideoModel searchWithSQL:@"select * from VideoModel"];
        VideoModel *video = categorys[download_index];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.titleLabel.text = [NSString stringWithFormat:@"%d-%@-%@-%@",download_index,video.categoryId,video.videoId,video.videoName];
        });
        self->download_index++;
        
        //1.创建会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        
        //2.根据会话对象创建task
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.zhangdaniang.com:8080/http-transfer/VideoServlet?videoUrl=%@",video.videoUrl]];
        
        //3.创建可变的请求对象
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        //4.修改请求方法为POST
        request.HTTPMethod = @"GET";
        
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
            if (error) {
                [dataTask cancel];
                [weakself downloadVideoBtnClick];
            }else{
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"%@",dict);
                NSString *videoURL = dict[@"url"];
                
                if (videoURL == nil) {
                    [dataTask cancel];
                    [weakself downloadVideoBtnClick];
                }else{
                    //远程地址
                    NSURL *URL = [NSURL URLWithString:videoURL];
                    //默认配置
                    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                    
                    //AFN3.0+基于封住URLSession的句柄
                    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
                    
                    //请求
                    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                    
                    //下载Task操作
                    self.downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
                        
                        // @property int64_t totalUnitCount;     需要下载文件的总大小
                        // @property int64_t completedUnitCount; 当前已经下载的大小
                        
                        // 给Progress添加监听 KVO
                        NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                        // 回到主队列刷新UI
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // 设置进度条的百分比
                            self.progressLabel.text = [NSString stringWithFormat:@"%.2f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount];
                            self.downloadProgress.progress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
                        });
                        
                    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                        
                        //- block的返回值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
                        //                    dispatch_semaphore_signal(semaphore);   //发送信号
                        [weakself downloadVideoBtnClick];
                        
                        //获取Document文件
                        NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                        NSString * rarFilePath = [docsdir stringByAppendingPathComponent:[NSString stringWithFormat:@"videofile/%@",video.categoryId]];//将需要创建的串拼接到后面
                        NSString * dataFilePath = [rarFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",video.videoId]];
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        BOOL isDir = NO;
                        // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
                        BOOL existed = [fileManager fileExistsAtPath:rarFilePath isDirectory:&isDir];
                        if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
                            [fileManager createDirectoryAtPath:rarFilePath withIntermediateDirectories:YES attributes:nil error:nil];
                        }
                        //            if (!(dataIsDir == YES && dataExisted == YES) ) {
                        //                [fileManager createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
                        //            }
                        //
                        //
                        //            //suggestedFilename
                        //            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                        //
                        //            NSString *path = [cachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",video.videoName]];
                        return [NSURL fileURLWithPath:dataFilePath];
                        
                    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                        //设置下载完成操作
                        
                    }];
                    [self.downloadTask resume];
                }
            }
        }];
        //7.执行任务
        [dataTask resume];
//        dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    } @catch (NSException *exception) {
        [[NSUserDefaults standardUserDefaults] setInteger:download_index forKey:@"download_index"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } @finally {
        [[NSUserDefaults standardUserDefaults] setInteger:download_index forKey:@"download_index"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(void)testWithID:(NSString *)aID{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:@"http://www.wuqiongda8888.com/video/detailList.htm"];
    
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";

    NSString *orders = [NSString stringWithFormat:@"appId=50&pageSize=1000000&id=%@",aID];
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
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
       
        NSArray *videoDetails = dict[@"content"][@"videoDetails"];
        for (NSDictionary *temp in videoDetails) {
            VideoModel *video = [[VideoModel alloc] init];
            video.videoId = temp[@"id"];
            video.videoName = temp[@"name"];
            video.videoUrl = temp[@"url"];
            video.categoryId = aID;
            [video saveToDB];
        }
        
        dispatch_semaphore_signal(semaphore);   //发送信号
        
    }];
    //7.执行任务
    [dataTask resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
}

@end

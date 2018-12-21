//
//  VideoModel.h
//  GetData
//
//  Created by lei li on 2018/12/20.
//  Copyright © 2018 lei li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoModel : NSObject
@property(nonatomic,strong) NSString *videoId;
@property(nonatomic,strong) NSString *categoryId;
@property(nonatomic,strong) NSString *videoName;
@property(nonatomic,strong) NSString *videoUrl;
@property(nonatomic,strong) NSString *videoThumbImageUrl;
@property(nonatomic,assign) int playCount;
@end

NS_ASSUME_NONNULL_END

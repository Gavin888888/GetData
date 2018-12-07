//
//  CategoryModel.h
//  GetData
//
//  Created by lei li on 2018/12/7.
//  Copyright © 2018 lei li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NSObject+LKModel.h>
NS_ASSUME_NONNULL_BEGIN

@interface CategoryModel : NSObject
@property(nonatomic,strong) NSString *categoryId;
@property(nonatomic,strong) NSString *categoryName;
@property(nonatomic,strong) NSArray *videos;
@end

NS_ASSUME_NONNULL_END

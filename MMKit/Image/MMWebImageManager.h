//
//  MMWebImageManager.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/5/11.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<MMKit/MMKit.h>)
#import <MMKit/MMImageCache.h>
#else
#import "MMImageCache.h"
#endif

@class MMWebImageOperation;
NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, MMWebImageOptions) {
    MMWebImageOptionShowNetworkActivity = 1 << 0,   //显示网络加载进度
    MMWebImageOptionProgressive = 1 << 1,
    MMWebImageOptionProgressiveBlur = 1 << 2,
    MMWebImageOptionUseNSURLCache = 1 << 3,
    MMWebImageOptionAllowBackInvalidSSLCertificates = 1 << 4,
    MMWebImageOptionAllowBackgroundTask = 1 << 5,
    MMWebImageOptionHandleCookies = 1 << 6,
    MMWebImageOptionRefreshDiskCache = 1 << 7,
    MMWebImageOptionIngnoreDiskCache = 1 << 8,
    MMWebImageOptionIgnorePlaceHolder = 1 << 9,
    MMWebImageOptionIgnoreImageDecoding = 1 << 10,
    MMWebImageOptionIngoreAnimatedImage = 1 << 11,
    MMWebImageOptionSetImageWithFadeAnimation = 1 << 12,
    MMWebImageOptionAvoidSetImage = 1 << 13,
    MMWebImageOptionIgnoreFailedURL = 1 << 14,
};

//图片来源  1.无状态   2.闪存    3.内存    4.硬盘    5.网页或文件
typedef NS_OPTIONS(NSUInteger, MMWebImageFromType) {
    MMWebImageFromNone = 0,
    MMWebImageFromMemoryCacheFast,
    MMWebImageFromMemoryCache,
    MMWebImageFromDiskCache,
    MMWebImageFromRemote,
};
//图片的三种状态， 1.未完成，加载中    2.已取消       3.完成
typedef NS_OPTIONS(NSInteger, MMWebImageStage) {
    MMWebImageStageProgress = -1,
    MMWebImageStageCancelled = 0,
    MMWebImageStageFinished = 1,
};

typedef void (^MMWebImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

typedef UIImage * _Nullable (^MMWebImageTransformBlock)(UIImage *image, NSURL *url);

typedef void (^MMWebImageCompletionBlock)(UIImage * _Nullable image,
                                        NSURL *url,
                                        MMWebImageFromType from,
                                        MMWebImageStage state,
                                        NSError * _Nullable error);
/**
 
 */

@interface MMWebImageManager : NSObject
@property (nullable, nonatomic, strong) MMImageCache *cache;

@property (nullable, nonatomic, strong) NSOperationQueue *queue;

@property (nullable, nonatomic, copy) MMWebImageTransformBlock sharedTransformBlock;

@property (nonatomic) NSTimeInterval timeout;

@property (nullable, nonatomic, copy) NSString *username;

@property (nullable, nonatomic, copy) NSString *password;

@property (nullable, nonatomic, copy) NSDictionary <NSString *, NSString *> *headers;

@property (nullable, nonatomic, copy) NSDictionary <NSString *, NSString *> *(^headerFilter)(NSURL *url, NSDictionary<NSString *, NSString *> * _Nullable header);

@property (nullable, nonatomic, copy) NSString *(^cacheKeyFilter)(NSURL *url);


#pragma mark    Access-Methods
+ (instancetype)sharedManager;

- (instancetype)initWithCache:(nullable MMImageCache *)cache queue:(nullable NSOperationQueue *)queue NS_DESIGNATED_INITIALIZER;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (nullable MMWebImageOperation *)requestImageWithURL:(NSURL *)url
                                             oprtions:(MMWebImageOperation *)options
                                             progress:(nullable MMWebImageProgressBlock)progress
                                            transform:(nullable MMWebImageTransformBlock)tramsform
                                           completion:(nullable MMWebImageCompletionBlock)completion;

- (nullable NSDictionary<NSString *, NSString *> *)headersForURL:(NSURL *)url;

- (NSString *)cachekeyForURL:(NSURL *)url;


@end
NS_ASSUME_NONNULL_END

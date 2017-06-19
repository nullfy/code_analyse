//
//  MMWebImageOperation.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/5/12.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<MMKit/MMKit.h>)
#import <MMKit/MMImageCache.h>
#import <MMKit/MMWebImageManager.h>
#else
#import "MMImageCache.h"
#import "MMWebImageManager.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface MMWebImageOperation : NSOperation

#pragma mark - Properties

@property (nonatomic, strong, readonly)             NSURLRequest *request;
@property (nullable, nonatomic, strong, readonly)   NSURLResponse *response;
@property (nullable, nonatomic, strong, readonly)   MMImageCache *cache;
@property (nonatomic, strong, readonly)             NSString *cacheKey;
@property (nonatomic, readonly)                     MMWebImageOptions options;  //MMWebImageManager 中，有显示进度，显示加载情况等


@property (nonatomic) BOOL shouldUseCredentialStorage;

/*
 Web 服务可以在返回HTTP响应时附带认证要求chalenge，作用是询问HTTP请求的发起方是谁，这时发起方应提供正确的用户名与密码，然后web服务才会真正的响应
 
 NSURLConnection 的委托对象收到相应的消息并得到一个 NSURLAuthenticationChallenge 实例，该实例等发送方遵守 NSURLAuthenticationChallengeSender 协议，为了继续收到真实的数据，需要向该发送方发回一个 NSURLCredential实例 
 
 程序可以保留credential
 NSURLCredentialPersistenceNone,
 NSURLCredentialPersistenceForSession,
 NSURLCredentialPersistencePermanent,
 NSURLCredentialPersistenceSynchronizable NS_ENUM_AVAILABLE(10_8, 6_0)
 
 */
@property (nullable, nonatomic, strong) NSURLCredential *credential;

#pragma mark  - Method

- (instancetype)initWithRequest:(NSURLRequest *)request
                        options:(MMWebImageOptions)options
                          cache:(nullable MMImageCache *)cache
                       cacheKey:(nullable NSString *)cacheKey
                       progress:(nullable MMWebImageProgressBlock)progress
                      transform:(nullable MMWebImageTransformBlock)transform
                     completion:(nullable MMWebImageCompletionBlock)completion;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end
NS_ASSUME_NONNULL_END

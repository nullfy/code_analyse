//
//  MMWebImageManager.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/5/11.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMWebImageManager.h"
#import "MMImageCache.h"
#import "MMWebImageOperation.h"
#import "MMImageCoder.h"

@implementation MMWebImageManager

+ (instancetype)sharedManager {
    static MMWebImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MMImageCache *cache = [MMImageCache sharedCache];
        NSOperationQueue *queue = [NSOperationQueue new];
        if ([queue respondsToSelector:@selector(setQualityOfService:)]) {
            queue.qualityOfService = NSQualityOfServiceBackground;
        }
        manager = [[self alloc] initWithCache:cache queue:queue];
    });
    return manager;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"MMWebImageManager init error" reason:@"Use The designed initilizer to init" userInfo:nil];
    return [self initWithCache:nil queue:nil];
}

- (instancetype)initWithCache:(MMImageCache *)cache queue:(NSOperationQueue *)queue {
    self = [super init];
    if (!self) return nil;
    _cache = cache;
    _queue = queue;
    _timeout = 15.0f;
    
    return self;
}



@end

//
//  MMCache.h
//  PracticeKit
//
//  Created by 晓东 on 16/12/29.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMDiskCache, MMMemoryCache;

NS_ASSUME_NONNULL_BEGIN
@interface MMCache : NSObject

@property (copy, readonly) NSString *name;

@property (strong, readonly) MMMemoryCache *memoryCache;

@property (strong, readonly) MMDiskCache *diskCache;

- (nullable instancetype)initWithName:(NSString *)name;

- (nullable instancetype)initWithPath:(NSString *)path;

+ (nullable instancetype)cacheWithname:(NSString *)name;

+ (nullable instancetype)cacheWithPath:(NSString *)path;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;


#pragma mark    - Access Methods

- (BOOL)containObjectForKey:(NSString *)key;

- (void)containsObjectForKey:(NSString *)key withBlock:(nullable void (^)(NSString *key, BOOL contain))block;

- (nullable id<NSCoding>)objectForKey:(NSString *)key;

- (void)objectForKey:(NSString *)key withBlock:(nullable void(^)(NSString *key, id<NSCoding> object))block;

- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key;

- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key withBlock:(nullable void(^)(void))block;

- (void)removeObjectForKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key withBlock:(nullable void(^)(NSString *key))block;

- (void)removeAllObjects;

- (void)removeAllObjectsWithBlock:(void(^)(void))block;

- (void)removeAllObjectsWithProgressBlock:(nullable void(^)(int removeCount, int totalCount))progress
                                 endBlock:(nullable void(^)(BOOL error))end;

@end
NS_ASSUME_NONNULL_END

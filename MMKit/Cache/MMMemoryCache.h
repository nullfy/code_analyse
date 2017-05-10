//
//  MMMemoryCache.h
//  PracticeKit
//
//  Created by 晓东 on 16/12/29.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface MMMemoryCache : NSObject

@property (nullable, copy) NSString *name;
@property (readonly) NSUInteger totalCount;
@property (readonly) NSUInteger totalCost;

#pragma mark    -Limit  限制

@property NSUInteger countLimit;
@property NSUInteger costLimit;
@property NSTimeInterval ageLimit;
@property NSTimeInterval autoTrimInterval;  //自动清理时间

@property BOOL shouldRemoveAllObjectsOnMemoryWarning;
@property BOOL shouldRemoveAllObjectsWhenEnteringBackground;

@property (nullable, copy) void(^didReceiveMemoryWaringBlock)(MMMemoryCache *cache);
@property (nullable, copy) void(^didEnterBackgroundBlock)(MMMemoryCache *cache);

@property BOOL releaseOnMainThread;
@property BOOL releaseAsynchronously;

#pragma mark    Access Methods

- (BOOL)containsObjcectForKey:(id)key;
- (nullable id)objectForKey:(id)key;
- (void)setObject:(nullable id)object forKey:(id)key;
- (void)setObject:(nullable id)object forKey:(id)key withCost:(NSUInteger)cost;

- (void)removeObjectForKey:(id)key;
- (void)removeAllObjects;

- (void)trimToCount:(NSUInteger)count;
- (void)trimToCost:(NSUInteger)cost;
- (void)trimToAge:(NSTimeInterval)age;  //remove object from the cache with LRU(latest Recently used)

@end
NS_ASSUME_NONNULL_END

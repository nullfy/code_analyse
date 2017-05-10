//
//  MMDiskCache.h
//  PracticeKit
//
//  Created by 晓东 on 16/12/29.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface MMDiskCache : NSObject

@property (nullable, copy) NSString *name;

@property (readonly) NSString *path;

@property (readonly) NSUInteger inlineThreshold;

@property (nullable, copy) NSData *(^customArchiveBlock)(id object);

@property (nullable, copy) id (^customUnarchiveBlock)(NSData *data);

@property (nullable, copy) NSString *(^customFileNameBlock)(NSString *key);

@property NSUInteger countLimit;

@property NSUInteger costLimit;

@property NSTimeInterval ageLimit;

@property NSUInteger freeDisSpaceLimit;

@property NSTimeInterval autoTrimInterval;

@property BOOL errorLogsEnabled;


#pragma mark    -Initializer    

- (instancetype)init    UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new     UNAVAILABLE_ATTRIBUTE;

- (nullable instancetype)initWithPath:(NSString *)path;
- (nullable instancetype)initWithPath:(NSString *)path inlineThreshold:(NSUInteger)threshold NS_DESIGNATED_INITIALIZER;

#pragma mark    -Access Methods

- (BOOL)containsObjectForKey:(NSString *)key;

- (void)containsObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, BOOL contains))block;

- (nullable id<NSCoding>)objectForKey:(NSString *)key;

- (void)objectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<NSCoding> _Nullable object))block;

- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key;

- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key withBlock:(void(^)(void))block;

- (void)removeObjectForKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block;

- (void)removeAllObject;

- (void)removeAllObjectWithBlock:(void(^)(void))block;

- (void)removeAllObjectWithProgressBlock:(nullable void(^)(int removeCount, int totalCount))progress endBlock:(nullable void(^)(BOOL error))end;

- (NSInteger)totalCount;

- (void)totalCountWithBlock:(void(^)(NSInteger totalCount))block;

- (NSInteger)totalCost;

- (void)totalCostWithBlock:(void(^)(NSInteger totalCost))block;

#pragma mark    -Trim

- (void)trimToCount:(NSUInteger)count;

- (void)trimToCount:(NSUInteger)count withBlock:(void(^)(void))block;

- (void)trimToCost:(NSUInteger)cost;

- (void)trimToCost:(NSUInteger)cost withBlock:(void(^)(void))block;

- (void)trimToAge:(NSTimeInterval)age;

- (void)trimToAge:(NSTimeInterval)age withBlock:(void(^)(void))block;

#pragma mark    -Extended Data

+ (nullable NSData *)getExtendedDataFromObject:(id)object;

+ (void)setExtendedData:(nullable NSData *)extendedData toObject:(id)object;

@end
NS_ASSUME_NONNULL_END

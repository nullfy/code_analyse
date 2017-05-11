////
////  MMKvStorage.h
////  PracticeKit
////
////  Created by 晓东 on 17/1/12.
////  Copyright © 2017年 Xiaodong. All rights reserved.
////

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMKVStorageItem : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSData *value;
@property (nullable, nonatomic, strong) NSString *fileName;
@property (nonatomic, assign) int size;
@property (nonatomic, assign) int modTime;
@property (nonatomic, assign) int accessTime;
@property (nullable, nonatomic, strong) NSData *extendedData;

@end

typedef NS_ENUM(NSUInteger, MMKVStorageType) {
    MMKVStorageTypeFile = 0,
    MMKVStorageTypeSQLite = 1,
    MMKVStorageTypeMixed = 2,
};

@interface MMKVStorage : NSObject

//属性修饰符 默认的是atomic ，readwrite，assign
@property (nonatomic, readonly, strong) NSString *path;
@property (nonatomic, readonly, assign) MMKVStorageType type;
@property (nonatomic, assign) BOOL errorLogsEnabled;

//UNAVAILABLE_ATTRIBUTE  __attribute__ 是clang提供的一种源码注释，这是告诉编译器该方法失效了
//__attribute__((unavailable("new方法不可用，请用initWithName:")))  会出现报错提醒
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (nullable instancetype)initWithPath:(NSString *)path type:(MMKVStorageType)type NS_DESIGNATED_INITIALIZER;
- (BOOL)saveItem:(YYKVStorageItem *)item;
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value;
- (BOOL)saveItemWithKey:(NSString *)key
                  value:(NSData *)value
               fileName:(nullable NSString *)filename
           extendedData:(nullable NSData *)extendedData;
- (BOOL)removeItemForKey:(NSString *)key;
- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys;
- (BOOL)removeItemsLargerThanSize:(int)size;
- (BOOL)removeItemEarlierThanTime:(int)time;
- (BOOL)removeItemsToFitSize:(int)maxSize;
- (BOOL)removeItemsToFitCount:(int)maxCount;
- (BOOL)removeAllItems;
- (void)removeAllItemsWithProgressBlock:(void(^)(int removedCount, int totalCount))progress endBlock:(void(^)(BOOL error))end;

#pragma mark   -Get Item
- (nullable MMKVStorageItem *)getItemForKey:(NSString *)key;
- (nullable MMKVStorageItem *)getItemInfoForKey:(NSString *)key;
- (nullable NSData *)getItemValueForKey:(NSString *)key;
- (nullable NSArray<YYKVStorageItem *> *)getItemForKeys:(NSArray<NSString *> *)keys;
- (nullable NSArray<YYKVStorageItem *> *)getItemInfoForKeys:(NSArray<NSString *> *)keys;
- (nullable NSDictionary<NSString *, NSData *> *)getItemValueForKeys:(NSArray<NSString *> *)keys;

- (BOOL)itemExistsForKey:(NSString *)key;
- (int)getItemsCount;
- (int)getItemsSize;


@end

NS_ASSUME_NONNULL_END

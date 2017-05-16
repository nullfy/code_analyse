//
//  NSObject+MMModel.h
//  PracticeKit
//
//  Created by 晓东 on 16/12/5.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (MMModel)

+ (nullable instancetype)modelWithJSON:(id)json;

+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dictionary;

- (BOOL)modelSetWithJSON:(id)json;

- (BOOL)modelSetWithDictionary:(NSDictionary *)dic;

- (nullable id)modelToJSONObject;

- (nullable NSData *)modelToJSONData;

- (nullable NSString *)modelToJSONString;

- (nullable id)modelCopy;

- (void)modelEncodeWithCoder:(NSCoder *)aCoder;

- (id)modelInitWithCoder:(NSCoder *)aDecoder;

- (NSUInteger)modelHash;

- (BOOL)modelIsEqual:(id)model;

- (NSString *)modelDescription;

@end

@interface NSArray (MMModel)

+ (nullable NSArray *)modelArrayWithClass:(Class)cls json:(id)json;

@end

@interface NSDictionary (MMModel)

+ (nullable NSDictionary *)modelDictionaryWithClass:(Class)cls json:(id)json;

@end

@protocol MMModel <NSObject>

@optional

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;

+ (nullable Class)modelCustomClassForDictionary:(NSDictionary *)dictionary;

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;

+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic;

@end
NS_ASSUME_NONNULL_END

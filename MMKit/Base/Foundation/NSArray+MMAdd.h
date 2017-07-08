//
//  NSArray+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/11/25.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSArray (MMAdd)

+ (nullable NSArray *)getProperties:(Class)cls;

+ (nullable NSArray *)arrayWithPlistData:(NSData *)plist ;

+ (nullable NSArray *)arrayWithPlistString:(NSString *)plist;

- (nullable NSArray *)plistData;

- (nullable NSString *)plistString;

- (nullable id)randomObject;

- (nullable id)objectOrNilAtIndex:(NSUInteger)index;

- (nullable NSString *)jsonStringEncoded;

- (nullable NSString *)jsonPrettyStringEncoded;


@end

@interface NSMutableArray (MMAdd)

+ (nullable NSMutableArray *)arrayWithPlistData:(NSData *)plist;

+ (nullable NSMutableArray *)arrayWithPlistString:(NSString *)plist;

- (void)removeFirstObject;

- (void)removeLastObject;

- (nullable id)popFirstObject;

- (nullable id)popLastObject;

- (void)appendObject:(id)anyObject;

- (void)prependObject:(id)anyObject;

- (void)appendObjects:(NSArray *)objects;

- (void)prependObjects:(NSArray *)objects;

- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index;

- (void)reverse;

- (void)shuffle;    //打乱

@end
NS_ASSUME_NONNULL_END

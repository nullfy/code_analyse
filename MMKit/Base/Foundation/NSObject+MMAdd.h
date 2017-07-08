//
//  NSObject+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/11/17.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MMAdd)

#pragma mark    - 发带参数的消息 Sending message with variable parameters

- (nullable id)performSelectorWithArgs:(SEL)sel, ...;

- (void)performSelectorWithArgs:(SEL)sel afterDelay:(NSTimeInterval)delay, ...;

- (nullable id)performSelectorWithArgsOnMainThread:(SEL)sel waitUntilDone:(BOOL)wait, ...;

- (nullable id)performSelectorWithArgs:(SEL)sel onThread:(NSThread *)thread waitUntilDone:(BOOL)wait, ...;

- (void)performSelectorWithArgsInBackground:(SEL)sel, ...;

- (void)performSelector:(SEL)sel afterDelay:(NSTimeInterval)delay;

+ (BOOL)swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel;

+ (BOOL)swizzleClassMethod:(SEL)originalSel with:(SEL)newSel;


#pragma mark    -Associate Value    关联数据

- (void)setAssociateValue:(nullable id)value withKey:(void *)key;

- (void)setAssociateWeakValue:(nullable id)value withKey:(void *)key;

- (nullable id)getAssociatedValueForKey:(void *)key;

- (void)removeAssociatedValues;


#pragma mark    -Others         其他

+ (NSString *)className;

- (NSString *)className;

- (nullable id)deepCopy;

- (nullable id)deepCopyWithArchiver:(Class)archiver unarchiver:(Class)unarchiver;

@end

NS_ASSUME_NONNULL_END













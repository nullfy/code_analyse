//
//  NSObject+MMAddForKVO.h
//  PracticeKit
//
//  Created by 晓东 on 16/11/17.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (MMAddForKVO)

- (void)addObserverBlockForKeyPath:(NSString *)keyPath block:(void (^)(id _Nullable obj, _Nullable id oldVal, _Nullable id newVal))block;

- (void)removeObserverBlocksForKeyPath:(NSString *)keyPath;

- (void)removeObserverBlocks;


@end
NS_ASSUME_NONNULL_END

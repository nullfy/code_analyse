//
//  NSDictionary+MMAvoidCrash.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MMAvoidCrash)

+ (void)avoidCrashExchangeMethod;

/**
 常用的字面量创建方式 NSDictionary *dic = @{};
 其实是通过以下方法来创建的
 + (instancetype)dictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt
 */


@end

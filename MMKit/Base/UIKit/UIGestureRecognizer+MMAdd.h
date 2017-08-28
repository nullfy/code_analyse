//
//  UIGestureRecognizer+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/12/2.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIGestureRecognizer (MMAdd)

- (instancetype)initWithActionBlock:(void (^)(id sender))block;

- (void)addActionBlock:(void (^)(id sender))block;

- (void)removeAllActionBlocks;

@end
NS_ASSUME_NONNULL_END

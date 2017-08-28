//
//  UIControl+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/12/2.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIControl (MMAdd)

- (void)removeAllTargets;

- (void)setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

- (void)setBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(id sender))block;

- (void)removeAllBlocksForControlEvents:(UIControlEvents)controlEvents;

@end
NS_ASSUME_NONNULL_END

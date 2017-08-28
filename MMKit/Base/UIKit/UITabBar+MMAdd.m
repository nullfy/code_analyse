//
//  UITabBar+MMAdd.m
//  PracticeKit
//
//  Created by 晓东 on 2017/4/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "UITabBar+MMAdd.h"

static NSInteger kBadgeTag = 100;
static CGFloat kBadgeBase = 4.0f;

@implementation UITabBar (MMAdd)

- (void)showBadgeOnItemIndex:(NSInteger)index {
    [self removeBadgeOnItemIndex:index];
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor redColor];
    view.layer.cornerRadius = kBadgeBase;
    view.layer.masksToBounds = YES;
    
    CGRect tabBarFrame = self.frame;
    CGFloat percentX = (index + 0.6) / self.items.count;
    CGFloat x = ceilf(percentX * CGRectGetWidth(tabBarFrame));
    CGFloat y = ceilf(0.1 * CGRectGetHeight(tabBarFrame));
    
    view.frame = (CGRect){x, y, kBadgeBase * 2, kBadgeBase * 2};
    [self addSubview:view];
}

- (void)hideBadgeOnItemIndex:(NSInteger)index {
    [self removeBadgeOnItemIndex:index];
}

- (void)removeBadgeOnItemIndex:(NSInteger)index {
    for (UIView *view in self.subviews) {
        if (view.tag == kBadgeTag + index) [view removeFromSuperview];
    }
}



@end

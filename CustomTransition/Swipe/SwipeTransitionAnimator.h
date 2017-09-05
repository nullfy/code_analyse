//
//  SwipeTransitionAnimator.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/9/5.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwipeTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

- (instancetype)initWithTargetEdge:(UIRectEdge)targetEdge;

@property (nonatomic) UIRectEdge targetEdge;

@end

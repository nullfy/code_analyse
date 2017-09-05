//
//  SwipeTransitionAnimator.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/9/5.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "SwipeTransitionAnimator.h"

@implementation SwipeTransitionAnimator

- (instancetype)initWithTargetEdge:(UIRectEdge)targetEdge {
    self = [self init];
    if (self) {
        _targetEdge = targetEdge;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *container = transitionContext.containerView;
    UIView *fromView;
    UIView *toView;
    if ([transitionContext respondsToSelector:@selector(valueForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = from.view;
        toView = to.view;
    }
    
    BOOL isPresenting = to.presentingViewController == from;
    CGRect fromFrame = [transitionContext initialFrameForViewController:from];
    CGRect toFrame = [transitionContext finalFrameForViewController:to];
    
    CGVector offset = CGVectorMake(0.f, 0.f);
    if (self.targetEdge == UIRectEdgeTop) {
        offset = CGVectorMake(0.f, 1.f);
    } else if (self.targetEdge == UIRectEdgeBottom) {
        offset = CGVectorMake(0.f, -1.f);
    } else if (self.targetEdge == UIRectEdgeLeft) {
        offset = CGVectorMake(1.f, 0.f);
    } else if (self.targetEdge == UIRectEdgeRight) {
        offset = CGVectorMake(-1.f, 0.f);
    } else {
        NSAssert(NO, @"targetEdge must be one of UIRectEdgeTop");
    }
    
    if (isPresenting) {
        fromView.frame = fromFrame;
        toView.frame = CGRectOffset(toFrame, toFrame.size.width * offset.dx * -1, toFrame.size.height * offset.dy * -1);
    } else {
        fromView.frame = fromFrame;
        toView.frame = toFrame;
    }
    
    if (isPresenting) [container addSubview:toView];
    else [container insertSubview:toView belowSubview:fromView];
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:transitionDuration animations:^{
        if (isPresenting) {
            toView.frame = toFrame;
        } else {
            fromView.frame = CGRectOffset(fromFrame, fromFrame.size.width * offset.dx, fromFrame.size.height * offset.dy);
        }
    } completion:^(BOOL finished) {
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        if (wasCancelled) [toView removeFromSuperview];
    }];
}


@end

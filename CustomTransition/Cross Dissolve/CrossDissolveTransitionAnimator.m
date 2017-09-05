//
//  CrossDissolveTransitionAnimator.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/9/5.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "CrossDissolveTransitionAnimator.h"

@implementation CrossDissolveTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;//自定义转场动画时间
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    
    UIView *fromView;
    UIView *toView;
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = from.view;
        toView = to.view;
    }
    
    fromView.frame = [transitionContext initialFrameForViewController:from];
    toView.frame = [transitionContext finalFrameForViewController:to];//这里不能写initFrame，否则toView的frame为CGRectZero
    
    fromView.alpha = 1.0f;
    toView.alpha = 0.0f;
    [containerView addSubview:toView];
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];//转场时间
    
    [UIView animateWithDuration:transitionDuration animations:^{
        fromView.alpha = 0.0f;
        toView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        BOOL wasCanceled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCanceled];
    }];
}

@end

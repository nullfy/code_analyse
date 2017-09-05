//
//  SwipeTransitionDelegate.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/9/5.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "SwipeTransitionDelegate.h"
#import "SwipeTransitionAnimator.h"
#import "SwipeTransitionInteractionController.h"

@implementation SwipeTransitionDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[SwipeTransitionAnimator alloc] initWithTargetEdge:self.targetEdge];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[SwipeTransitionAnimator alloc] initWithTargetEdge:self.targetEdge];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (self.gestureRecognizer) {
        return [[SwipeTransitionInteractionController alloc] initWithGestureRecognizer:self.gestureRecognizer edgeForDragging:self.targetEdge];
    } else {
        return nil;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (self.gestureRecognizer) {
        return [[SwipeTransitionInteractionController alloc] initWithGestureRecognizer:self.gestureRecognizer edgeForDragging:self.targetEdge];
    } else {
        return nil;
    }
}

@end

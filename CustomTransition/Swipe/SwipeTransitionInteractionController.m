//
//  SwipeTransitionInteractionController.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/9/5.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "SwipeTransitionInteractionController.h"

@interface SwipeTransitionInteractionController ()

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, strong, readonly) UIScreenEdgePanGestureRecognizer *gestureRecognizer;

@property (nonatomic, readonly) UIRectEdge edge;

@end

@implementation SwipeTransitionInteractionController

- (instancetype)initWithGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer edgeForDragging:(UIRectEdge)edge {
    NSAssert(edge == UIRectEdgeTop || edge == UIRectEdgeLeft ||
             edge == UIRectEdgeRight || edge == UIRectEdgeBottom, @"edgeDragging must be one of UIRectEdge");
    self = [super init];
    if (self) {
        _gestureRecognizer = gestureRecognizer;
        _edge = edge;
        [_gestureRecognizer addTarget:self action:@selector(gestureRecognizerDidUpdate:)];
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"use -initWithGestureRecognizer: edgeForDragging" userInfo:nil];
}

- (void)dealloc {
    [self.gestureRecognizer removeTarget:self action:@selector(gestureRecognizerDidUpdate:)];
}

- (void)gestureRecognizerDidUpdate:(UIScreenEdgePanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: break;
        case UIGestureRecognizerStateChanged: {
            [self updateInteractiveTransition:[self percentForGesture:recognizer]];
        } break;
        case UIGestureRecognizerStateEnded: {
            if ([self percentForGesture:recognizer] >= 0.5) {//如果手势处于屏幕过半的位置就进行跳转
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];//否则取消
            }
        }
        default: {
            [self cancelInteractiveTransition];
        } break;
    }
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    [super startInteractiveTransition:transitionContext];
}

- (CGFloat)percentForGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    UIView *container = self.transitionContext.containerView;
    CGPoint locationInSourceView = [gesture locationInView:container];
    
    CGFloat width = CGRectGetWidth(container.bounds);
    CGFloat height = CGRectGetHeight(container.bounds);
    
    if (self.edge == UIRectEdgeRight) {
        return (width - locationInSourceView.x) / width;
    } else if (self.edge == UIRectEdgeLeft) {
        return locationInSourceView.x / width;
    } else if (self.edge == UIRectEdgeBottom) {
        return (height - locationInSourceView.y) / height;
    } else if (self.edge == UIRectEdgeTop) {
        return locationInSourceView.y / height;
    } else {
        return 0.f;
    }
}


@end

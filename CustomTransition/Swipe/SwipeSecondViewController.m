//
//  SwipeSecondViewController.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/9/5.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "SwipeSecondViewController.h"
#import "SwipeTransitionDelegate.h"

@interface SwipeSecondViewController ()

@end

@implementation SwipeSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIScreenEdgePanGestureRecognizer *interactiveTransitionRecognizer;
    interactiveTransitionRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(interactiveTransitionRecognizerAction:)];
    interactiveTransitionRecognizer.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:interactiveTransitionRecognizer];
}

- (void)interactiveTransitionRecognizerAction:(UIScreenEdgePanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self backView:sender];
    }
}


- (void)backView:(id)sender {
    if ([self.transitioningDelegate isKindOfClass:[SwipeTransitionDelegate class]]) {
        SwipeTransitionDelegate *transitionDelegate = self.transitioningDelegate;
        
        if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
            transitionDelegate.gestureRecognizer = sender;
        } else {
            transitionDelegate.gestureRecognizer = nil;
        }
        transitionDelegate.targetEdge = UIRectEdgeLeft;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

//
//  SwipeViewController.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/9/5.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "SwipeViewController.h"
#import "SwipeTransitionDelegate.h"
#import "SwipeSecondViewController.h"

@interface SwipeViewController ()

@property (nonatomic, strong) SwipeTransitionDelegate *customDelegate;

@end

@implementation SwipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIScreenEdgePanGestureRecognizer *interactiveTransitionRecognizer;
    interactiveTransitionRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(interactiveTransitionRecognizerAction:)];
    interactiveTransitionRecognizer.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:interactiveTransitionRecognizer];
}

- (void)nextVC {
    [self.navigationController pushViewController:[SwipeSecondViewController new] animated:YES];
}


- (void)interactiveTransitionRecognizerAction:(UIScreenEdgePanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        SwipeTransitionDelegate *transitionDelegate = self.customDelegate;
        if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
            transitionDelegate.gestureRecognizer = sender;
        } else {
            transitionDelegate.gestureRecognizer = nil;
        }
        
        transitionDelegate.targetEdge = UIRectEdgeRight;
        
        SwipeSecondViewController *destin = [SwipeSecondViewController new];
        destin.transitioningDelegate = transitionDelegate;
        destin.modalPresentationStyle = UIModalPresentationFullScreen;
    }
}

- (SwipeTransitionDelegate *)customDelegate {
    if (_customDelegate == nil) {
        _customDelegate = [[SwipeTransitionDelegate alloc] init];
    }
    return _customDelegate;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  CrossDissolveViewController.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/9/5.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "CrossDissolveViewController.h"
#import "CrossDissolveTransitionAnimator.h"
#import "CrossDissolveSecondViewController.h"

@interface CrossDissolveViewController ()<UIViewControllerTransitioningDelegate>

@end

@implementation CrossDissolveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 40)];
    button.center = self.view.center;
    [button setTitle:@"Next" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(nextVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)nextVC {
    CrossDissolveSecondViewController *vc = [CrossDissolveSecondViewController new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.transitioningDelegate = self;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [CrossDissolveTransitionAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [CrossDissolveTransitionAnimator new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

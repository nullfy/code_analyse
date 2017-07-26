//
//  UINavigationController+MMPlayer.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "UINavigationController+MMPlayer.h"

@implementation UINavigationController (MMPlayer)

/**
 如果window 的根视图是UINavigationController，则会先调用这个category， 然后调用UIViewController+MMPlayer
 只需要在支持除竖屏以外方向的页面重写下面三个方法
 */

#pragma mark    是否支持自动转屏
- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

#pragma mark    支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

#pragma mark    默认的屏幕方向(当前ViewController 必须是通过模态出来的UIViewController(模态带导航栏的无效))方式展现出来的才会调用这个方法
- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}


@end

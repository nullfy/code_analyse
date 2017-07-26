//
//  UIViewController+MMPlayer.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "UIViewController+MMPlayer.h"

@implementation UIViewController (MMPlayer)
/**
 默认情况下是不支持转屏，如需个别页面支持除竖屏外的其他方向，请在viewController 重写下面的三个方法
 */

//是否支持自动转屏
- (BOOL)shouldAutorotate {
    return NO;
}

//支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

//默认的屏幕方向(当前ViewController 必须是通过模态出来的UIViewController(模态带导航的无效)方式展现出来的，才会调用这个方法)
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

/**
 下面两个方法可以在个别页面里面重写
 */

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end

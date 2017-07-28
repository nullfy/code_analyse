//
//  UIWindow+MMPlayer.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/28.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "UIWindow+MMPlayer.h"

@implementation UIWindow (MMPlayer)

+ (UIViewController *)mmplayer_currentViewController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *topViewController = window.rootViewController;
    
    if (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    } else if ([topViewController isKindOfClass:[UINavigationController class]] &&
               [(UINavigationController *)topViewController topViewController]) {
        topViewController = [(UINavigationController *)topViewController topViewController];
    } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)topViewController;
        topViewController = tab.selectedViewController;
    }
    
    return  topViewController;
}


@end

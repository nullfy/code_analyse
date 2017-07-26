//
//  UITabBarController+MMPlayer.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "UITabBarController+MMPlayer.h"
#import <objc/runtime.h>

@implementation UITabBarController (MMPlayer)

+ (void)load {
    SEL selectors[] = { @selector(selectedIndex) };
    
    for (NSUInteger index = 0; index < sizeof(selectors)/sizeof(SEL); index++) {
        SEL originalSEL = selectors[index];
        SEL swizzleSEL = NSSelectorFromString([@"mmplayer_" stringByAppendingString:NSStringFromSelector(originalSEL)]);
        Method originalMethod = class_getInstanceMethod(self, originalSEL);
        Method swizzleMethod = class_getInstanceMethod(self, swizzleSEL);
        
        if (class_addMethod(self, originalSEL, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))) {
            class_replaceMethod(self, swizzleSEL, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzleMethod);
        }
    }
}

- (NSInteger)mmplayer_selectedIndex {
    NSInteger index = [self mmplayer_selectedIndex];
    if (index > self.viewControllers.count) return 0;
    return index;
}

/**
 如果window 的根视图是UITabBarController， 则会先调用这个Category，然后调用UIViewController+MMPlayer
 只需要在支持竖屏以外方向的页面重写下面三个方法
 */


//是否支持自动转屏
- (BOOL)shouldAutorotate {
    UIViewController *vc = self.viewControllers[self.selectedIndex];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.topViewController shouldAutorotate];
    } else {
        return [vc shouldAutorotate];
    }
}

//支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *vc = self.viewControllers[self.selectedIndex];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.topViewController supportedInterfaceOrientations];
    } else {
        return [vc supportedInterfaceOrientations];
    }
}

//默认的屏幕方向（当前ViewController 必须是通过模态出来的UIViewController (模态带导航的无效)方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *vc = self.viewControllers[self.selectedIndex];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.topViewController preferredInterfaceOrientationForPresentation];
    } else {
        return [vc preferredInterfaceOrientationForPresentation];
    }
}


@end

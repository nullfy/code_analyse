//
//  UIViewController+MMRootNavigationController.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/10/16.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "UIViewController+MMRootNavigationController.h"
#import "MMRootNavigationController.h"
#import <objc/runtime.h>
@implementation UIViewController (MMRootNavigationController)

@dynamic mm_disableInteractivePop;

- (void)setMm_disableInteractivePop:(BOOL)mm_disableInteractivePop {
    objc_setAssociatedObject(self, @selector(mm_disableInteractivePop), @(mm_disableInteractivePop), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)mm_disableInteractivePop {
    return [objc_getAssociatedObject(self, @selector(mm_disableInteractivePop)) boolValue];
}

- (Class)mm_navigationBarClass {
    return nil;
}

- (MMRootNavigationController *)mm_navigationController {
    UIViewController *vc = self;
    while (vc && ![vc isKindOfClass:[MMRootNavigationController class]]) {
        vc = vc.navigationController;
        NSLog(@"category VC nav---%@",vc);
    }
    return (MMRootNavigationController *)vc;
}

@end

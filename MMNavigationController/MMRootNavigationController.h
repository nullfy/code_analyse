//
//  MMRootViewController.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/10/16.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MMRootNavigationController.h"

@interface MMContainerController : UIViewController

@property (nonatomic, readonly, strong) __kindof UIViewController *contentViewController;

@end

@interface MMContainerNavigationController : UINavigationController
@end



IB_DESIGNABLE
@interface MMRootNavigationController : UINavigationController

@property (nonatomic, assign) IBInspectable BOOL useSystemBackBarButtonItem;
@property (nonatomic, assign) IBInspectable BOOL transiferNavigationBarAttributes;
@property (nonatomic, readonly, strong) UIViewController *mm_visibleViewController;
@property (nonatomic, readonly, strong) UIViewController *mm_topViewController;
@property (nonatomic, readonly, strong) NSArray <__kindof UIViewController *> *mm_viewControllers;

- (instancetype)initWithRootViewControllerNoWrapping:(UIViewController *)rootViewController;
- (void)removeViewController:(UIViewController *)controller NS_REQUIRES_SUPER;
- (void)removeViewController:(UIViewController *)controller animated:(BOOL)flag NS_REQUIRES_SUPER;

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
                  complete:(void(^)(BOOL finished))block;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated complete:(void(^)(BOOL finished))block;

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController
                                                     animated:(BOOL)animated
                                                     complete:(void(^)(BOOL finished))block;
- (NSArray<__kindof UIViewController *> *)popToRootViewControlleranimated:(BOOL)animated
                                                                 complete:(void(^)(BOOL finished))block;

@end

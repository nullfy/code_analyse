//
//  UIViewController+MMRootNavigationController.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/10/16.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMRootNavigationController;

@protocol MMNavigationItemCustomizable <NSObject>

@optional
- (UIBarButtonItem *)customBackItemWithTarget:(id)target action:(SEL)action DEPRECATED_MSG_ATTRIBUTE("use mm_customBackItemWithTarget instead");
- (UIBarButtonItem *)mm_customBackItemWithTarget:(id)target action:(SEL)action;
@end


IB_DESIGNABLE
@interface UIViewController (MMRootNavigationController)

@property (nonatomic, assign) IBInspectable BOOL mm_disableInteractivePop;
@property (nonatomic, readonly, strong) MMRootNavigationController *mm_navigationController;

- (Class)mm_navigationBarClass;

@end

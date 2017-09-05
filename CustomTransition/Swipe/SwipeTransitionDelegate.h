//
//  SwipeTransitionDelegate.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/9/5.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwipeTransitionDelegate : NSObject<UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *gestureRecognizer;

@property (nonatomic, assign) UIRectEdge targetEdge;

@end

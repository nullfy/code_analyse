//
//  SwipeTransitionInteractionController.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/9/5.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwipeTransitionInteractionController : UIPercentDrivenInteractiveTransition

- (instancetype)initWithGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer edgeForDragging:(UIRectEdge)edge NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

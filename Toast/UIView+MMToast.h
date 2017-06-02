//
//  UIView+MMToast.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/5/27.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MMToastPosition) {
    MMToastPositionMiddle = 0,  //Default
    MMToastPositionTop,
    MMToastPositionBottom,
};

typedef NS_ENUM(NSUInteger, MMToastStyle) {
    MMToastStyleWhite = 0,
    MMToastStyleBlack,
    MMToastStyleBlur,
};

@interface UIView (MMToast)

- (void)toast:(NSString *)msg;
- (void)toast:(NSString *)msg position:(MMToastPosition)position;
- (void)toast:(NSString *)msg style:(MMToastStyle)style;
- (void)toast:(NSString *)msg position:(MMToastPosition)position style:(MMToastStyle)style;
- (void)toast:(NSString *)msg duration:(NSTimeInterval)duration;
- (void)toast:(NSString *)msg duration:(NSTimeInterval)duration position:(MMToastPosition)position;
- (void)toast:(NSString *)msg duration:(NSTimeInterval)duration position:(MMToastPosition)position style:(MMToastStyle)style;

@end

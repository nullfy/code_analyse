//
//  MMBrightnessView.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/28.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMBrightnessView : UIView

@property (nonatomic, assign) BOOL isLockScreen;
@property (nonatomic, assign) BOOL isAllowLandscape;
@property (nonatomic, assign) BOOL isStatusBarHidden;
@property (nonatomic, assign) BOOL isLandscape;

+ (instancetype)sharedBrightness;

@end

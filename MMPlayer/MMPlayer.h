//
//  MMPlayer.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#ifndef MMPlayer_h
#define MMPlayer_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "UIWindow+MMPlayer.h"
#import "CALayer+MMPlayer.h"
#import "UIView+MMPlayer.h"
#import "UIImageView+MMPlayer.h"
#import "MMPlayerSlider.h"
#import "MMBrightnessView.h"
#import "MMMaterialDesignSpinner.h"
#import "MMPlayerControlViewDelegate.h"
#import "ASValuePopUpView.h"
#import "MMPlayerModel.h"
#import "MMPlayerControlView.h"

#define RGBA(r,g,b,a)                   [UIColor colorWithRed:r green:g blue:b alpha:a]

#define MMPlayerBundlePath(file)        [@"MMPlayer.bundle" stringByAppendingPathComponent:file]
#define MMPlayerFrameworkPath(file)     [@"Frameworks/MMPlayer.framework/MMPlayer.bundle" stringByAppendingPathComponent:file]
#define MMPlayerImage(file)             [UIImage imageNamed:MMPlayerBundlePath(file)] ?: [UIImage imageNamed:MMPlayerFrameworkPath(file)]
#define MMPlayerShared                  [MMBrightnessView sharedBrightness]

#define MMPlayerOrientationIsLandscape  UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)

#define MMPlayerOrientationIsPortrait   UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)


#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH                    [UIScreen mainScreen].bounds.size.width
#endif

#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT                   [UIScreen mainScreen].bounds.size.height
#endif

static NSString *const MMPlayerContentOffset = @"contentOffset";

#endif /* MMPlayer_h */

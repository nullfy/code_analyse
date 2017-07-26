//
//  UIAlertController+MMPlayer.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "UIAlertController+MMPlayer.h"

@implementation UIAlertController (MMPlayer)

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 9000
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
#else

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
#endif

@end

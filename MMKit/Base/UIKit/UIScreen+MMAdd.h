//
//  UIScreen+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/12/2.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIScreen (MMAdd)

+ (CGFloat)screenScale;

- (CGRect)currentBounds NS_EXTENSION_UNAVAILABLE_IOS("");

- (CGRect)boundsForOrientation:(UIInterfaceOrientation)orientation;

@property (nonatomic, readonly) CGSize sizeInPixel;

@property (nonatomic, readonly) CGFloat pixelsPerInch;


@end
NS_ASSUME_NONNULL_END

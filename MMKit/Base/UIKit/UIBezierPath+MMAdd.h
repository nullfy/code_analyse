//
//  UIBezierPath+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/12/3.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (MMAdd)

+ (nullable UIBezierPath *)bezierPathWithText:(NSString *)text font:(UIFont *)font;

@end
NS_ASSUME_NONNULL_END

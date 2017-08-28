//
//  UIButton+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 2017/2/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface UIButton (MMAdd)

+ (nullable UIButton *)buttonWithFrame:(CGRect)frame CenterTitle:(NSString *)title centerImage:(UIImage *)image;

@end
NS_ASSUME_NONNULL_END

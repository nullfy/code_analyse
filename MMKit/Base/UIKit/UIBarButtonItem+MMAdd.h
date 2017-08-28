//
//  UIBarButtonItem+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/12/2.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIBarButtonItem (MMAdd)

@property (nullable, nonatomic, copy)void (^actionBlock)(id);

@end
NS_ASSUME_NONNULL_END

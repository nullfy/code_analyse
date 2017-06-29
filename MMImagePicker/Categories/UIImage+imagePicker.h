//
//  UIImage+imagePicker.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/22.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (imagePicker)

+ (UIImage *)imageNamedFromMyBundle:(NSString *)name;

+ (UIImage *)mm_animatedGIFWithData:(NSData *)data;

@end

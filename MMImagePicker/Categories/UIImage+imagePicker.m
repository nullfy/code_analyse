//
//  UIImage+imagePicker.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/22.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "UIImage+imagePicker.h"

@implementation UIImage (imagePicker)
+ (UIImage *)imageNamedFromMyBundle:(NSString *)name {
    UIImage *image = [UIImage imageNamed:[@"MMImagePicke.bundle" stringByAppendingPathComponent:name]];
    if (image) {
        return image;
    } else {
        image = [UIImage imageNamed:[@"Frameworks/MMImagePicker.framework/MMImagePicker.bundle" stringByAppendingPathComponent:name]];
        if (!image) image = [UIImage imageNamed:name];
        return image;
    }
}

@end

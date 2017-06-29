//
//  MMImageCropManager.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/23.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMImageCropManager : NSObject

+ (void)overlayClipWithView:(UIView *)view rect:(CGRect)rect containerView:(UIView *)container needCircleCrop:(BOOL)needCrop;

+ (UIImage *)cropImageView:(UIImageView *)imageView toRect:(CGRect)rect scale:(CGFloat)scale containerView:(UIView *)container;

+ (UIImage *)circularClipImage:(UIImage *)image;

@end

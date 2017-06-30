//
//  MMImageCropManager.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/23.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMImageCropManager.h"
#import "MMImagePickManager.h"

@implementation MMImageCropManager

+ (void)overlayClipWithView:(UIView *)view rect:(CGRect)rect containerView:(UIView *)container needCircleCrop:(BOOL)needCrop {
    //#import <QuartzCore/CALayer.h> CALayer CoreAnimation
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:[UIScreen mainScreen].bounds];
    CAShapeLayer *layer = [CAShapeLayer layer];
    if (needCrop) {
        [path appendPath:[UIBezierPath bezierPathWithArcCenter:container.center radius:rect.size.width/2 startAngle:0 endAngle:2*M_PI clockwise:NO]];
    } else {
        [path appendPath:[UIBezierPath bezierPathWithRect:rect]];
    }
    layer.path = path.CGPath;
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.fillColor = [UIColor blackColor].CGColor;
    layer.opacity = 0.5f;
    [view.layer addSublayer:layer];
}

+ (UIImage *)cropImageView:(UIImageView *)imageView toRect:(CGRect)rect scale:(CGFloat)scale containerView:(UIView *)container {
    CGAffineTransform transform = CGAffineTransformIdentity;//CoreGraphic
    CGRect imageViewRect = [imageView convertRect:imageView.bounds toView:container];
    CGPoint point = CGPointMake(imageViewRect.origin.x + imageViewRect.size.width/2, imageViewRect.origin.y + imageViewRect.origin.y);
    CGFloat xMargin = container.width - CGRectGetMaxX(rect) - rect.origin.x;
    CGPoint zeroPoint = CGPointMake(container.width - xMargin/2, container.centerY);
    CGPoint translation = CGPointMake(point.x - zeroPoint.x, point.y - zeroPoint.y);
    transform = CGAffineTransformTranslate(transform, translation.x, translation.y);
    
    transform = CGAffineTransformScale(transform, scale, scale);
    
    CGImageRef imageRef = [self newTransformedImage:transform
                                        sourceImage:imageView.image.CGImage
                                         sourceSize:imageView.image.size
                                        outputWidth:rect.size.width * [UIScreen mainScreen].scale cropSize:rect.size
                                      imageViewSize:imageView.frame.size];
    UIImage *cropedImage = [UIImage imageWithCGImage:imageRef];
    cropedImage = [[MMImagePickManager manager] fixOrientation:cropedImage];
    CGImageRelease(imageRef);
    return cropedImage;
}

+ (CGImageRef)newTransformedImage:(CGAffineTransform)transform sourceImage:(CGImageRef)sourceImage sourceSize:(CGSize)sourceSize outputWidth:(CGFloat)width cropSize:(CGSize)cropSize imageViewSize:(CGSize)imageViewSize {
    CGImageRef source = [self newScaledImage:sourceImage toSize:sourceSize];
    CGFloat aspect = cropSize.height/cropSize.width;
    CGSize outputSize = CGSizeMake(width, width*aspect);
    
    CGContextRef context = CGBitmapContextCreate(NULL, outputSize.width, outputSize.height, CGImageGetBitsPerComponent(source), 0, CGImageGetColorSpace(source), CGImageGetBitmapInfo(source));
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));
    
    CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width/cropSize.width, outputSize.height/cropSize.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width/2.0f, cropSize.height/2.0f);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    CGContextConcatCTM(context, transform);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(-imageViewSize.width/2, -imageViewSize.height/2.0, imageViewSize.width, imageViewSize.height), source);
    
    CGImageRef result = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGImageRelease(source);
    return result;
}

+ (CGImageRef)newScaledImage:(CGImageRef)source toSize:(CGSize)size {
    CGSize sourceSize = size;
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, rgbColorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(rgbColorSpace);
    
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextTranslateCTM(context, size.width/2, size.height/2);
    CGContextDrawImage(context, CGRectMake(-sourceSize.width/2, -sourceSize.height/2, sourceSize.width, sourceSize.height), source);
    
    CGImageRef result = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    return result;
}

+ (UIImage *)circularClipImage:(UIImage *)image {//圆形切图
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image drawInRect:rect];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return result;
}

@end

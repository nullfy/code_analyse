//
//  UIImage+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/11/29.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MMAdd)

#pragma mark    Create Image
+ (nullable UIImage *)imageWithSmallGIFData:(NSData *)data scale:(CGFloat)scale;    //将 Gif Data 转成 Image

+ (BOOL)isAnimatedGIFData:(NSData *)data;   //判断是否是 Gif 数据

+ (BOOL)isAnimatedGIFFile:(NSString *)path;

+ (nullable UIImage *)imageWithPDF:(id)dataOrPath;      //将PDF 数据转成 Image

+ (nullable UIImage *)imageWithPDF:(id)dataOrPath size:(CGSize)size;

+ (nullable UIImage *)imageWithEmoji:(NSString *)emoji size:(CGFloat)size;  //将Emoji 转成图片

+ (nullable UIImage *)imageWithColor:(UIColor *)color;

+ (nullable UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (nullable UIImage *)imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef _Nonnull))drawBlock;


#pragma mark    Image Info

- (BOOL)hasAlphaChannel;                //判断是否有透明层

- (void)drawInRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;

- (nullable UIImage *)imageByResizeToSize:(CGSize)size;     //让图片重新适应尺寸

- (nullable UIImage *)imageByCropToRect:(CGRect)rect;

- (nullable UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(UIColor *)color;

- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius;

- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                                   borderWidth:(CGFloat)borderWidth
                                   borderColor:(nullable UIColor *)borderColor;

- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                                       corners:(UIRectCorner)corners
                                   borderWidth:(CGFloat)borderWidth
                                   borderColor:(nullable UIColor *)borderColor borderLineJoin:(CGLineJoin)borderLineJoin;

- (nullable UIImage *)imageByRotateLeft90;

- (nullable UIImage *)imageByRotateRight90;

- (nullable UIImage *)imageByFlipVertical;

- (nullable UIImage *)imageByFlipHorizontal;

#pragma mark    Image Effect    图片效果(虚化 着色)

- (nullable UIImage *)imageByTintColor:(UIColor *)color;

- (nullable UIImage *)imageByGrayscale;

- (nullable UIImage *)imageByBlurLight;

- (nullable UIImage *)imageByBlurExtraLight;

- (nullable UIImage *)imageByBlurDark;

- (nullable UIImage *)imageByBlurWithTint:(UIColor *)tintColor;

- (nullable UIImage *)imageByBlurRadius:(CGFloat)blurRadius
                              tintColor:(nullable UIColor *)tintColor
                               tintMode:(CGBlendMode)tintBlendMode
                             saturation:(CGFloat)saturation
                              maskImage:(nullable UIImage *)maskImage;




@end

NS_ASSUME_NONNULL_END

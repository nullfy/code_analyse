//
//  UIColor+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/11/29.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern void MM_RGB2HSL(CGFloat r, CGFloat g, CGFloat b,
                       CGFloat *h, CGFloat *s, CGFloat *l);

extern void MM_HSL2RGB(CGFloat h, CGFloat s, CGFloat l,
                       CGFloat *r, CGFloat *g, CGFloat *b);

extern void MM_RGB2HSB(CGFloat r, CGFloat g, CGFloat b,
                       CGFloat *h, CGFloat *s, CGFloat *v);

extern void MM_HSB2RGB(CGFloat h, CGFloat s, CGFloat v,
                       CGFloat *r, CGFloat *g, CGFloat *b);

extern void MM_RGB2CMYK(CGFloat r, CGFloat g, CGFloat b,
                        CGFloat *c, CGFloat *m, CGFloat *y, CGFloat *k);

extern void MM_CMYK2RGB(CGFloat c, CGFloat m, CGFloat y, CGFloat k,
                        CGFloat *r, CGFloat *g, CGFloat *b);

extern void MM_HSB2HSL(CGFloat h, CGFloat s, CGFloat b,
                       CGFloat *hh, CGFloat *ss, CGFloat *ll);

extern void MM_HSL2HSB(CGFloat h, CGFloat s, CGFloat l,
                       CGFloat *hh, CGFloat *ss, CGFloat *bb);

#ifndef UIColorHex
#define UIColorHex(_hex_) [UIColor colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#endif

@interface UIColor (MMAdd)

#pragma mark - Create a UIColor Object

+ (UIColor *)colorWithHue:(CGFloat)hue
               saturation:(CGFloat)saturation
                lightness:(CGFloat)lightness
                    alpha:(CGFloat)alpha;

+ (UIColor *)colorWithCyan:(CGFloat)cyan
                   magenta:(CGFloat)magenta
                    yellow:(CGFloat)yellow
                     black:(CGFloat)black
                     alpha:(CGFloat)alpha;

+ (UIColor *)colorWithRGB:(uint32_t)rgbValue;

+ (UIColor *)colorWithRGBA:(uint32_t)rgbaValue;

+ (UIColor *)colorWithRGB:(uint32_t)rgbValue alpha:(CGFloat)alpha;

+ (nullable UIColor *)colorWithHexString:(NSString *)hexStr;

- (UIColor *)colorByAddColor:(UIColor *)add blendMode:(CGBlendMode)blendMode;

- (UIColor *)colorByChangeHue:(CGFloat)hueDelta
                   saturation:(CGFloat)saturationDelta
                   brightness:(CGFloat)brightnessDelta
                        alpha:(CGFloat)alphaDelta;


#pragma mark - Get color's description

- (uint32_t)rgbValue;

- (uint32_t)rgbaValue;

- (nullable NSString *)hexString;

- (nullable NSString *)hexStringWithAlpha;


#pragma mark - Retrieving Color Information

- (BOOL)getHue:(CGFloat *)hue
    saturation:(CGFloat *)saturation
     lightness:(CGFloat *)lightness
         alpha:(CGFloat *)alpha;

- (BOOL)getCyan:(CGFloat *)cyan
        magenta:(CGFloat *)magenta
         yellow:(CGFloat *)yellow
          black:(CGFloat *)black
          alpha:(CGFloat *)alpha;

@property (nonatomic, readonly) CGFloat red;

@property (nonatomic, readonly) CGFloat green;

@property (nonatomic, readonly) CGFloat blue;

@property (nonatomic, readonly) CGFloat hue;

@property (nonatomic, readonly) CGFloat saturation;

@property (nonatomic, readonly) CGFloat brightness;

@property (nonatomic, readonly) CGFloat alpha;

@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;

@property (nullable, nonatomic, readonly) NSString *colorSpaceString;

@end

NS_ASSUME_NONNULL_END

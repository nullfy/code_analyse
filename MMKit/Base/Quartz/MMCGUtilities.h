//
//  MMCGUtilities.h
//  PracticeKit
//
//  Created by 晓东 on 16/11/29.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#if __has_include(<MMKit/MMkit.h>)
#import <MMkit/MMKitMacro.h>
#else
#import "MMKitMacro.h"
#endif

MM_EXTERN_C_BEGIN

NS_ASSUME_NONNULL_BEGIN

CGContextRef _Nullable MMCGContextCreateARGBBitmapContext(CGSize size, BOOL opaque, CGFloat scale);

CGContextRef _Nullable MMCGContextCreateGrayBitmapContext(CGSize size, CGFloat scale);

CGFloat MMScreenScale();

CGSize MMScreenSize();

static inline CGFloat MMDegreesToRadians(CGFloat degree) {
    return degree * M_PI / 180;
}

static inline CGFloat MMRadiansToDegree(CGFloat radians) {
    return radians * 180 / M_PI;
}

static inline CGFloat MMCGAffineTransformGetRotation(CGAffineTransform transform) {
    return atan2(transform.b, transform.a);
}

static inline CGFloat MMCGAffineTransformGetScaleX(CGAffineTransform transform) {
    return sqrt(transform.a * transform.a + transform.c * transform.c);
}

static inline CGFloat MMCGAffineTransformGetScaleY(CGAffineTransform transform) {
    return sqrt(transform.b * transform.b + transform.d * transform.d);
}

static inline CGFloat MMCGAffineTransformGetTranslateX(CGAffineTransform transform) {
    return transform.tx;
}

static inline CGFloat MMCGAffineTransformGetTranslateY(CGAffineTransform transform) {
    return transform.ty;
}

CGAffineTransform MMCGAffineTransformGetFromPoints(CGPoint before[3], CGPoint after[3]);

CGAffineTransform MMCGAffineTransformGetFromViews(UIView *from, UIView *to);

static inline CGAffineTransform MMCGAffineTransformMakeSkew(CGFloat x, CGFloat y) {
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform.c = -x;
    transform.b = y;
    return transform;
}

static inline UIEdgeInsets MMUIEdgeInsetsInvert(UIEdgeInsets insets) {
    return UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right);
}

UIViewContentMode MMCAGravityToUIViewContentMode(NSString *gravity);

NSString *MMUIViewContentModeToCAGravity(UIViewContentMode contentMode);

CGRect MMCGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode);

static inline CGPoint MMCGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
}

static inline CGFloat MMCGRectGetArea(CGRect rect) {
    if (CGRectIsNull(rect)) return 0;
    rect = CGRectStandardize(rect);
    return rect.size.width * rect.size.height;
}

static inline CGFloat MMCGPointGetDistanceToPoint(CGPoint p1, CGPoint p2) {
    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y) );
}

static inline CGFloat MMCGPointGetDistancetToRect(CGPoint p, CGRect rect) {
    rect = CGRectStandardize(rect);
    if (CGRectContainsPoint(rect, p)) return 0;
    CGFloat distV, distH;
    if (CGRectGetMinY(rect) <= p.y && p.y <= CGRectGetMaxY(rect)) {
        distV = 0;
    } else {
        distV = p.y < CGRectGetMinY(rect) ? CGRectGetMinY(rect) - p.y : p.y - CGRectGetMaxY(rect);
    }
    
    if (CGRectGetMinX(rect) <= p.x && p.x <= CGRectGetMaxX(rect)) {
        distH = 0;
    } else {
        distH = p.x < CGRectGetMinX(rect) ? CGRectGetMinX(rect) - p.x : p.x - CGRectGetMaxX(rect);
    }
    return MAX(distV, distH);
}

static inline CGFloat MMCGFloatToPixel(CGFloat value) {
    return value * MMScreenScale();
}

static inline CGFloat MMCGFloatFromPixel(CGFloat value) {
    return value / MMScreenScale();
}

static inline CGFloat MMCGFloatPixelFloor(CGFloat value) {
    CGFloat scale = MMScreenScale();
    return floor(value * scale) / scale;
}

static inline CGFloat MMCGFloatPixelRound(CGFloat value) {
    CGFloat scale = MMScreenScale();
    return round(value * scale) / scale;
}

static inline CGFloat MMCGFloatPixelCeil(CGFloat value) {
    CGFloat scale = MMScreenScale();
    return ceil(value * scale) / scale;
}

static inline CGFloat MMCGFloatPixelHalf(CGFloat value) {
    CGFloat scale = MMScreenScale();
    return (floor(value * scale) + 0.5) / scale;
}

static inline CGPoint MMCGPointPixelFloor(CGPoint point) {
    CGFloat scale = MMScreenScale();
    return CGPointMake(floor(point.x * scale) / scale, floor(point.y * scale) / scale);
}

static inline CGPoint MMCGPointPixelRound(CGPoint point) {
    CGFloat scale = MMScreenScale();
    return CGPointMake(round(point.x * scale) / scale, round(point.y * scale) / scale);
}

static inline CGPoint MMCGPointPixelCeil(CGPoint point) {
    CGFloat scale = MMScreenScale();
    return CGPointMake(floor(point.x * scale) / scale, floor(point.y * scale) / scale);
}

static inline CGPoint MMCGPointPixelHalf(CGPoint point) {
    CGFloat scale = MMScreenScale();
    return CGPointMake((floor(point.x * scale) + 0.5) / scale, (floor(point.y * scale) + 0.5) / scale );
}

static inline CGSize MMCGSizePixelFloor(CGSize size) {
    CGFloat scale = MMScreenScale();
    return CGSizeMake(floor(size.width * scale) / scale,
                      floor(size.height * scale) / scale);
}

/// round point value for pixel-aligned
static inline CGSize MMCGSizePixelRound(CGSize size) {
    CGFloat scale = MMScreenScale();
    return CGSizeMake(round(size.width * scale) / scale,
                      round(size.height * scale) / scale);
}

/// ceil point value for pixel-aligned
static inline CGSize MMCGSizePixelCeil(CGSize size) {
    CGFloat scale = MMScreenScale();
    return CGSizeMake(ceil(size.width * scale) / scale,
                      ceil(size.height * scale) / scale);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGSize MMCGSizePixelHalf(CGSize size) {
    CGFloat scale = MMScreenScale();
    return CGSizeMake((floor(size.width * scale) + 0.5) / scale,
                      (floor(size.height * scale) + 0.5) / scale);
}



/// floor point value for pixel-aligned
static inline CGRect MMCGRectPixelFloor(CGRect rect) {
    CGPoint origin = MMCGPointPixelCeil(rect.origin);
    CGPoint corner = MMCGPointPixelFloor(CGPointMake(rect.origin.x + rect.size.width,
                                                   rect.origin.y + rect.size.height));
    CGRect ret = CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
    if (ret.size.width < 0) ret.size.width = 0;
    if (ret.size.height < 0) ret.size.height = 0;
    return ret;
}

/// round point value for pixel-aligned
static inline CGRect MMCGRectPixelRound(CGRect rect) {
    CGPoint origin = MMCGPointPixelRound(rect.origin);
    CGPoint corner = MMCGPointPixelRound(CGPointMake(rect.origin.x + rect.size.width,
                                                   rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// ceil point value for pixel-aligned
static inline CGRect MMCGRectPixelCeil(CGRect rect) {
    CGPoint origin = MMCGPointPixelFloor(rect.origin);
    CGPoint corner = MMCGPointPixelCeil(CGPointMake(rect.origin.x + rect.size.width,
                                                  rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGRect MMCGRectPixelHalf(CGRect rect) {
    CGPoint origin = MMCGPointPixelHalf(rect.origin);
    CGPoint corner = MMCGPointPixelHalf(CGPointMake(rect.origin.x + rect.size.width,
                                                  rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}



/// floor UIEdgeInset for pixel-aligned
static inline UIEdgeInsets MMUIEdgeInsetPixelFloor(UIEdgeInsets insets) {
    insets.top = MMCGFloatPixelFloor(insets.top);
    insets.left = MMCGFloatPixelFloor(insets.left);
    insets.bottom = MMCGFloatPixelFloor(insets.bottom);
    insets.right = MMCGFloatPixelFloor(insets.right);
    return insets;
}

/// ceil UIEdgeInset for pixel-aligned
static inline UIEdgeInsets MMUIEdgeInsetPixelCeil(UIEdgeInsets insets) {
    insets.top = MMCGFloatPixelCeil(insets.top);
    insets.left = MMCGFloatPixelCeil(insets.left);
    insets.bottom = MMCGFloatPixelCeil(insets.bottom);
    insets.right = MMCGFloatPixelCeil(insets.right);
    return insets;
}

#ifndef kScreenScale
#define kScreenScale MMScreenScale()
#endif

#ifndef kScreenSize
#define kScreenSize MMScreenSize()
#endif

#ifndef kScreenWidth
#define kScreenWidth MMScreenSize().width
#endif

#ifndef kScreenHeight
#define kScreenHeight MMScreenSize().height
#endif


NS_ASSUME_NONNULL_END
MM_EXTERN_C_END

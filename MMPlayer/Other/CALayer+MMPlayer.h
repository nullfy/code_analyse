//
//  CALayer+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/11/29.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (MMPlayer)

- (UIImage *)snapshotImage;

- (NSData *)snapshotPDF;

- (void)setLayerShadow:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius;

- (void)removeAllSublayers;

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGPoint origin;
@property (nonatomic, getter=frameSize, setter=setFrameSize:) CGSize  size;

@property (nonatomic) CGFloat transformRotation;
@property (nonatomic) CGFloat transformRotationX;
@property (nonatomic) CGFloat transformRotationY;
@property (nonatomic) CGFloat transformRotationZ;
@property (nonatomic) CGFloat transformScale;
@property (nonatomic) CGFloat transformScaleX;
@property (nonatomic) CGFloat transformScaleY;
@property (nonatomic) CGFloat transformScaleZ;
@property (nonatomic) CGFloat transformTranslationX;
@property (nonatomic) CGFloat transformTranslationY;
@property (nonatomic) CGFloat transformTranslationZ;

@property (nonatomic) CGFloat transformDepth;

@property (nonatomic) UIViewContentMode contentMode;

- (void)addFadeAnimationWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve;

- (void)removePreviousFadeAnimation;



@end

NS_ASSUME_NONNULL_END

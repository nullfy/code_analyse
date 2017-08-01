//
//  UIView+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/11/30.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (MMAdd)

- (nullable UIImage *)snapshotImage;

- (nullable UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

- (nullable NSData *)snapshotPDF;

- (void)setLayerShadow:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius;

- (void)removeAllSubviews;

@property (nullable, nonatomic, readonly) UIViewController *viewController;
@property (nonatomic, readonly) CGFloat visibleAlpha;

- (CGPoint)convertPoint:(CGPoint)point toViewOrWindow:(UIView *)view;

- (CGPoint)convertPoint:(CGPoint)point fromViewOrWindow:(UIView *)view;

- (CGRect)convertRect:(CGRect)rect toViewOrWindow:(UIView *)view;

- (CGRect)convertRect:(CGRect)rect fromViewOrWindow:(UIView *)view;


@property (nonatomic) CGFloat left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  size;

@end

NS_ASSUME_NONNULL_END

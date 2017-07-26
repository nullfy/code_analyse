//
//  ASValuePopUpView.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ASValuePopUpViewDelegate <NSObject>

- (CGFloat)currentValueOffset;

- (void)colorDidUpdate:(UIColor *)opaqueColor;

@end

@interface ASValuePopUpView : UIView

@property (nonatomic, weak) id<ASValuePopUpViewDelegate> delegate;

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign) CGFloat arrowLength;

@property (nonatomic, assign) CGFloat widthPaddingFactor;

@property (nonatomic, assign) CGFloat heightPaddingFactor;

- (UIColor *)color;
- (void)setColor:(UIColor *)color;
- (UIColor *)opaqueColor;

- (void)setText:(NSString *)text;
- (void)setImage:(UIImage *)image;

- (void)setAnimatedColors:(NSArray <UIColor *> *)colors withKeyTimes:(NSArray<NSNumber *>*)keyTimes;

- (void)setAnimationOffset:(CGFloat)offset completion:(void(^)(UIColor *opaqueColor))completion;

- (void)setFrame:(CGRect)frame arrowOffset:(CGFloat)arrowOffset;

- (void)animatedBlock:(void(^)(CFTimeInterval duration))block;

- (void)showAnimated:(BOOL)animated;

- (void)hideAnimated:(BOOL)animated completionBlock:(void(^)())completion;

@end

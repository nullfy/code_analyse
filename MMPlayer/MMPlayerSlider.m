//
//  MMPlayerSlider.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMPlayerSlider.h"

@interface MMPlayerSlider ()<ASValuePopUpViewDelegate>
@property (nonatomic, strong) ASValuePopUpView *popUpView;
@property (nonatomic) BOOL popUpViewAlwaysOn; //Default is NO
@end

@implementation MMPlayerSlider {
    NSNumberFormatter *_numberFormatter;
    UIColor *_popUpViewColor;
    NSArray *_keyTimes;
    CGFloat _valueRange;
}

#pragma mark    LifeCycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updatePopUpView];
}

- (void)didMoveToWindow {
    if (!self.window) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } else {
        if (self.popUpViewAnimatedColors) {
            [self.popUpView setAnimatedColors:_popUpViewAnimatedColors withKeyTimes:_keyTimes];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
}

#pragma mark    override
- (void)setValue:(float)value {
    [super setValue:value];
    [self.popUpView setAnimationOffset:[self currentValueOffset] completion:^(UIColor *opaqueColor) {
        super.minimumTrackTintColor = opaqueColor;
    }];
}

- (void)setValue:(float)value animated:(BOOL)animated {
    if (animated) {
        [self.popUpView animatedBlock:^(CFTimeInterval duration) {
            [UIView animateWithDuration:duration animations:^{
                [super setValue:value animated:animated];
                
                [self.popUpView setAnimationOffset:[self currentValueOffset] completion:^(UIColor *opaqueColor) {
                    super.minimumTrackTintColor = opaqueColor;
                }];
                [self layoutIfNeeded];
            }];
        }];
        
    } else {
        [super setValue:value animated:animated];
    }
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    self.autoAdjustTrackColor = NO;
    [super setMinimumTrackTintColor:minimumTrackTintColor];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL begin = [super beginTrackingWithTouch:touch withEvent:event];
    if (begin && !self.popUpViewAlwaysOn) [self _showPopUpViewAnimated:NO];
    return begin;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL continueTrack = [super continueTrackingWithTouch:touch withEvent:event];
    if (continueTrack) {
        [self.popUpView setAnimationOffset:[self currentValueOffset] completion:^(UIColor *opaqueColor) {
            super.minimumTrackTintColor = opaqueColor;
        }];
    }
    return continueTrack;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    if (self.popUpViewAlwaysOn == NO) [self _hidePopUpViewAnimated:NO];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    if (self.popUpViewAlwaysOn == NO) [self _hidePopUpViewAnimated:NO];
}

- (void)setMaximumValue:(float)maximumValue {
    [super setMaximumValue:maximumValue];
    _valueRange = self.maximumValue - self.minimumValue;
}

- (void)setMinimumValue:(float)minimumValue {
    [super setMinimumValue:minimumValue];
    _valueRange = self.maximumValue - self.minimumValue;
}


#pragma mark    Private Method
- (void)setUp {
    _autoAdjustTrackColor = YES;
    _valueRange = self.maximumValue - self.minimumValue;
    _popUpViewAlwaysOn = NO;
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    
    _numberFormatter = formatter;
    
    self.popUpView = [ASValuePopUpView new];
    self.popUpViewColor = [UIColor colorWithHue:0.6 saturation:0.6 lightness:0.5 alpha:0.8];
    
    self.popUpView.alpha = 0.0;
    self.popUpView.delegate = self;
    [self addSubview:self.popUpView];
}

- (CGRect)thumbRect {
    return [self thumbRectForBounds:self.bounds
                          trackRect:[self trackRectForBounds:self.bounds]
                              value:self.value];
}

- (void)_showPopUpViewAnimated:(BOOL)animated {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderWillHidePopUpView:)]) {
        [self.popUpView showAnimated:animated];
    }
}

- (void)_hidePopUpViewAnimated:(BOOL)animated {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderWillHidePopUpView:)]) {
        [self.delegate sliderWillHidePopUpView:self];
    }
    
    [self.popUpView hideAnimated:animated completionBlock:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(sliderDidHidePopUpView:)]) {
            [self.delegate sliderDidHidePopUpView:self];
        }
    }];
}

- (void)updatePopUpView {
    CGSize popUpViewSize = CGSizeMake(100, 56 + self.popUpViewArrowLength + 18);
    
    CGRect thumbRect = [self thumbRect];
    CGFloat thumbWidth = CGRectGetWidth(thumbRect);
    CGFloat thumbHeight = CGRectGetHeight(thumbRect);
    
    CGRect popUpRect = CGRectInset(thumbRect, (thumbWidth - popUpViewSize.width)/2, (thumbHeight - popUpViewSize.height) / 2);
    popUpRect.origin.y = thumbRect.origin.y - popUpViewSize.height;
    
    CGFloat minOffsetX = CGRectGetMinX(popUpRect);
    CGFloat maxOffsetX = CGRectGetMaxX(popUpRect) - CGRectGetWidth(self.bounds);
    
    CGFloat offset = minOffsetX < 0.0 ? minOffsetX : (maxOffsetX > 0.0 ? maxOffsetX : 0.0);
    popUpRect.origin.x -= offset;
    
    [self.popUpView setFrame:popUpRect arrowOffset:offset];
}

- (void)didBecomeActiveNotification:(NSNotification *)note {
    if (self.popUpViewAnimatedColors) {
        [self.popUpView setAnimatedColors:_popUpViewAnimatedColors withKeyTimes:_keyTimes];
    }
}

- (NSArray *)keyTimesFromSliderPositions:(NSArray *)positions {
    if (!positions) return nil;
    
    NSMutableArray *keyTimes = @[].mutableCopy;
    for (NSNumber *num in [positions sortedArrayUsingSelector:@selector(compare:)]) {
        [keyTimes addObject:@((num.floatValue - self.minimumValue) / _valueRange)];
    }
    return keyTimes;
}


#pragma mark    Getter && Setter

- (void)setAutoAdjustTrackColor:(BOOL)autoAdjustTrackColor {
    if (_autoAdjustTrackColor == autoAdjustTrackColor) return;
    _autoAdjustTrackColor = autoAdjustTrackColor;
    if (autoAdjustTrackColor == NO) {
        super.minimumTrackTintColor = nil;
    } else {
        super.minimumTrackTintColor = [self.popUpView opaqueColor];
    }
}

- (UIColor *)popUpViewColor {
    return self.popUpViewColor ?: _popUpViewColor;
}

- (void)setPopUpViewColor:(UIColor *)color {
    _popUpViewColor = color;
    _popUpViewAnimatedColors = nil;
    [self.popUpView setColor:color];
    
    if (_autoAdjustTrackColor) super.minimumTrackTintColor = self.popUpView.opaqueColor;
}

- (void)setPopUpViewAnimatedColors:(NSArray *)popUpViewAnimatedColors {
    [self setPopUpViewAnimatedColors:popUpViewAnimatedColors withPositions:nil];
}

- (void)setPopUpViewCornerRadius:(CGFloat)popUpViewCornerRadius {
    self.popUpView.cornerRadius = popUpViewCornerRadius;
}

- (CGFloat)popUpViewCornerRadius {
    return self.popUpView.cornerRadius;
}

- (void)setPopUpViewArrowLength:(CGFloat)popUpViewArrowLength {
    self.popUpView.arrowLength = popUpViewArrowLength;
}

- (CGFloat)popUpViewArrowLength {
    return self.popUpView.arrowLength;
}

- (void)setPopUpViewWidthPaddingFactor:(CGFloat)popUpViewWidthPaddingFactor {
    self.popUpView.widthPaddingFactor = popUpViewWidthPaddingFactor;
}

- (CGFloat)popUpViewWidthPaddingFactor {
    return self.popUpView.widthPaddingFactor;
}

- (void)setPopUpViewHeightPaddingFactor:(CGFloat)popUpViewHeightPaddingFactor {
    self.popUpView.heightPaddingFactor = popUpViewHeightPaddingFactor;
}

- (CGFloat)popUpViewHeightPaddingFactor {
    return self.popUpView.heightPaddingFactor;
}


#pragma mark    Public Method
- (void)setText:(NSString *)text {
    [self.popUpView setText:text];
}

- (void)setImage:(UIImage *)image {
    [self.popUpView setImage:image];
}

- (void)showPopUpViewAnimated:(BOOL)animated {
    self.popUpViewAlwaysOn = YES;
    [self _showPopUpViewAnimated:animated];
}

- (void)hidePopUpViewAnimated:(BOOL)animated {
    self.popUpViewAlwaysOn = NO;
    [self _hidePopUpViewAnimated:animated];
}

- (void)setPopUpViewAnimatedColors:(NSArray *)popUpViewAnimatedColors withPositions:(NSArray *)positions {
    if (positions) {
        NSAssert(popUpViewAnimatedColors.count == positions.count, @"popUpViewAnimationColors and locations should contain the same number of items");
    }
    
    _popUpViewAnimatedColors = popUpViewAnimatedColors;
    _keyTimes = [self keyTimesFromSliderPositions:positions];
}


#pragma mark    ASValuePopUpViewDelegate

- (void)colorDidUpdate:(UIColor *)opaqueColor {
    super.minimumTrackTintColor = opaqueColor;
}

- (CGFloat)currentValueOffset {
    return (self.value - self.minimumValue) / _valueRange;
}


@end


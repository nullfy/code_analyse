//
//  ASValuePopUpView.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "ASValuePopUpView.h"

NSString *const SliderFillColorAnimation = @"fillColor";

@implementation CALayer (ASAnimationAdditions)

- (void)animateKey:(NSString *)animationName fromValue:(id)fromValue toValue:(id)toValue customize:(void(^)(CABasicAnimation *animation))block {
    [self setValue:toValue forKey:animationName];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:animationName];
    animation.fromValue = fromValue ?: [self.presentationLayer valueForKey:animationName];
    animation.toValue = toValue;
    if (block) block(animation);
    [self addAnimation:animation forKey:animationName];
}

@end

@interface ASValuePopUpView ()<CAAnimationDelegate>

@end

@implementation ASValuePopUpView {
    BOOL _shouldAnimate;
    CFTimeInterval _animatedDuration;
    CAShapeLayer *_pathLayer;
    CAShapeLayer *_colorAnimationLayer;
    
    UIImageView *_imageView;
    UILabel *_timeLabel;
    CGFloat _arrowCenterOffset;
    
}

#pragma mark    Override Method
+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
    if (_shouldAnimate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:event];
        animation.beginTime = CACurrentMediaTime();
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [layer.presentationLayer valueForKey:event];
        animation.duration = _animatedDuration;
        return animation;
    } else {
        return nil;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shouldAnimate = NO;
        self.layer.anchorPoint = CGPointMake(0.5, 1);
        
        self.userInteractionEnabled = NO;
        _pathLayer = (CAShapeLayer *)self.layer;
        _cornerRadius = 4.0;
        _arrowLength = 13.0;
        _widthPaddingFactor = 1.15;
        _heightPaddingFactor = 1.1;
        
        _colorAnimationLayer = [CAShapeLayer layer];
        [self.layer addSublayer:_colorAnimationLayer];
        
        _timeLabel = [UILabel new];
        _timeLabel.text = @"10:00";
        _timeLabel.font = [UIFont systemFontOfSize:10];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_timeLabel];
        
        _imageView = [UIImageView new];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect textRect = CGRectMake(self.bounds.origin.x, 0, self.bounds.size.width, 13);
    
    _timeLabel.frame = textRect;
    CGRect imageRect = CGRectMake(self.bounds.origin.x + 5, textRect.size.height + textRect.origin.y, self.bounds.size.width - 10, 56);
    _imageView.frame = imageRect;
}


#pragma mark    Getter && Setter

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (_cornerRadius == cornerRadius) return;
    _cornerRadius = cornerRadius;
    _pathLayer.path = [self pathForRect:self.bounds withArrowOffset:_arrowCenterOffset].CGPath;
}

#pragma mark    Public Method
- (UIColor *)color {
    return [UIColor colorWithCGColor:[_pathLayer.presentationLayer fillColor]];
}

- (void)setColor:(UIColor *)color {
    _pathLayer.fillColor = color.CGColor;
    [_colorAnimationLayer removeAnimationForKey:SliderFillColorAnimation];
}

- (UIColor *)opaqueColor {
    CGColorRef color = [_colorAnimationLayer.presentationLayer fillColor] ?: _pathLayer.fillColor;
    return opaqueUIColorFromCGColor(color);
}

- (void)setText:(NSString *)text {
    _timeLabel.text = text;
}

- (void)setImage:(UIImage *)image {
    _imageView.image = image;
}

- (void)setAnimatedColors:(NSArray<UIColor *> *)colors withKeyTimes:(NSArray<NSNumber *> *)keyTimes {
    NSMutableArray *cgColors = @[].mutableCopy;
    for (UIColor *color in colors) {
        [cgColors addObject:(id)color.CGColor];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:SliderFillColorAnimation];
    animation.keyTimes = keyTimes;
    animation.values = cgColors;
    animation.fillMode = kCAFillModeBoth;
    animation.duration = 1.0;
    animation.delegate = self;
    
    _colorAnimationLayer.speed = FLT_MIN;
    _colorAnimationLayer.timeOffset = 0;
    [_colorAnimationLayer addAnimation:animation forKey:SliderFillColorAnimation];
}

- (void)setAnimationOffset:(CGFloat)offset completion:(void (^)(UIColor *))completion {
    if ([_colorAnimationLayer animationForKey:SliderFillColorAnimation]) {
        _colorAnimationLayer.timeOffset = offset;
        _pathLayer.fillColor = [_colorAnimationLayer.presentationLayer fillColor];
        if (completion) completion([self opaqueColor]);
    }
}

- (void)setFrame:(CGRect)frame arrowOffset:(CGFloat)arrowOffset {
    if (arrowOffset != _arrowCenterOffset || !CGSizeEqualToSize(frame.size, self.frame.size)) {
        _pathLayer.path = [self pathForRect:frame withArrowOffset:arrowOffset].CGPath;
    }
    _arrowCenterOffset = arrowOffset;
    
    CGFloat anchorX = 0.5 + (arrowOffset/CGRectGetWidth(frame));
    self.layer.anchorPoint = CGPointMake(anchorX, 1);
    self.layer.position = CGPointMake(CGRectGetMinX(frame) + CGRectGetWidth(frame) * anchorX, 0);
    self.layer.bounds = (CGRect){CGPointZero, frame.size};
}

- (void)animatedBlock:(void (^)(CFTimeInterval))block {
    _shouldAnimate = YES;
    _animatedDuration = 0.5;
    
    CAAnimation *animation = [self.layer animationForKey:@"position"];
    if (animation) {
        CFTimeInterval elapsedTime = MIN(CACurrentMediaTime() - animation.beginTime, animation.duration);
        _animatedDuration = _animatedDuration * elapsedTime/animation.duration;
    }
    _shouldAnimate = NO;
    if (block) block(_animatedDuration);
}

- (void)showAnimated:(BOOL)animated {
    if (!animated) {
        self.layer.opacity = 1.0;
        return;
    }
    
    [CATransaction begin];
    
    {
        NSValue *fromValue = [self.layer animationForKey:@"transform"] ? [self.layer.presentationLayer valueForKey:@"transform"] : [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1)];
        
        [self.layer animateKey:@"transform" fromValue:fromValue toValue:[NSValue valueWithCATransform3D:CATransform3DIdentity] customize:^(CABasicAnimation *animation) {
            animation.duration = 0.4;
            animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.8 :0.25 :0.35 :0.5];
        }];
        
        [self.layer animateKey:@"opacity" fromValue:nil toValue:@1.0 customize:^(CABasicAnimation *animation) {
            animation.duration = 0.1;
        }];
    }
    
    [CATransaction commit];
}

- (void)hideAnimated:(BOOL)animated completionBlock:(void (^)())completion {
    [CATransaction begin];
    {
        [CATransaction setCompletionBlock:^{
            if (completion) completion();
            self.layer.transform = CATransform3DIdentity;
        }];
        
        if (animated) {
            [self.layer animateKey:@"transform" fromValue:nil toValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1.0)] customize:^(CABasicAnimation *animation) {
                animation.duration = 0.55;
                animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.1f :-2.f :0.3f :3.f];
            }];
            
            [self.layer animateKey:@"opacity" fromValue:nil toValue:@0.0 customize:^(CABasicAnimation *animation) {
                animation.duration = 0.0;
            }];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.layer.opacity = 0.0f;
            });
        }
    }
    [CATransaction commit];
}

#pragma mark    CAAnimation Delegate

- (void)animationDidStart:(CAAnimation *)anim {
    _colorAnimationLayer.speed = 0.0f;
    _colorAnimationLayer.timeOffset = [self.delegate currentValueOffset];
    
    _pathLayer.fillColor = [_colorAnimationLayer.presentationLayer fillColor];
    [self.delegate colorDidUpdate:self.opaqueColor];
}


#pragma mark    Private Method

- (UIBezierPath *)pathForRect:(CGRect)rect withArrowOffset:(CGFloat)offset {
    if (CGRectEqualToRect(rect, CGRectZero)) return nil;
    
    rect = (CGRect){CGPointZero, rect.size};
    
    CGRect roundedRect = rect;
    roundedRect.size.height -= _arrowLength;
    
    UIBezierPath *popPath = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:_cornerRadius];
    
    CGFloat maxX = CGRectGetMaxX(roundedRect);
    CGFloat arrowTipX = CGRectGetMinX(rect) + offset;
    CGPoint tip = CGPointMake(arrowTipX, CGRectGetMaxY(rect));
    
    CGFloat arrowLength = CGRectGetHeight(roundedRect) / 2.0;
    CGFloat x = arrowLength * tan(45.0 * M_PI/180);
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:tip];
    [arrowPath addLineToPoint:CGPointMake(MAX(arrowTipX - x, 0), CGRectGetMaxY(roundedRect) - arrowLength)];
    [arrowPath addLineToPoint:CGPointMake(MIN(arrowTipX + x, maxX), CGRectGetMaxY(roundedRect) - arrowLength)];
    [arrowPath closePath];
    
    [popPath appendPath:arrowPath];
    return popPath;
}

static UIColor* opaqueUIColorFromCGColor(CGColorRef color) {
    if (color == NULL) return nil;
    const CGFloat *components = CGColorGetComponents(color);
    UIColor *result;
    if (CGColorGetNumberOfComponents(color) == 2) {
        result = [UIColor colorWithWhite:components[0] alpha:1.0];
    } else {
        result = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:1.0];
    }
    return result;
}

@end

//
//  MMMaterialDesignSpinner.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMMaterialDesignSpinner.h"

static NSString *kMMRingStrokeAnimationKey = @"mmmaterialdesignspinner.stroke";
static NSString *kMMRingRotationAnimationKey = @"mmmaterialdesignspinner.rotation";


@interface MMMaterialDesignSpinner ()

@property (nonatomic, readonly, strong) CAShapeLayer *progressLayer;
@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation MMMaterialDesignSpinner

@synthesize progressLayer = _progressLayer;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialze];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialze];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialze];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.progressLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [self updatePath];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.progressLayer.strokeColor = self.tintColor.CGColor;
}


- (void)setAnimating:(BOOL)animate {
    animate ? [self startAnimating] : [self stopAnimating];
}

- (void)startAnimating {
    if (self.isAnimating) return;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = self.duration/0.375f;
    animation.fromValue = @0.f;
    animation.toValue = @(2*M_PI);
    animation.repeatCount = INFINITY;
    animation.removedOnCompletion = NO;
    [self.progressLayer addAnimation:animation forKey:kMMRingRotationAnimationKey];
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.keyPath = @"strokeStart";
    headAnimation.duration = self.duration/1.5f;
    headAnimation.fromValue = @0.f;
    headAnimation.toValue = @0.25f;
    headAnimation.timingFunction = self.timmingFunction;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animation];
    tailAnimation.keyPath = @"strokeEnd";
    tailAnimation.duration = self.duration/1.5f;
    tailAnimation.fromValue = @0.f;
    tailAnimation.toValue = @1.f;
    tailAnimation.timingFunction = self.timmingFunction;
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = self.duration/1.5f;
    endHeadAnimation.duration = self.duration/3.0f;
    endHeadAnimation.fromValue = @0.25f;
    endHeadAnimation.toValue = @1.f;
    endHeadAnimation.timingFunction = self.timmingFunction;

    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = self.duration/1.5f;
    endTailAnimation.duration = self.duration/3.0f;
    endTailAnimation.fromValue = @1.f;
    endTailAnimation.toValue = @1.f;
    endTailAnimation.timingFunction = self.timmingFunction;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    [animations setDuration:self.duration];
    [animations setAnimations:@[headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]];
    animations.repeatCount = INFINITY;
    animations.removedOnCompletion = NO;
    [self.progressLayer addAnimation:animations forKey:kMMRingStrokeAnimationKey];
    
    self.isAnimating = NO;
    if (self.hiddenWhenStopped) self.hidden = NO;
}

- (void)stopAnimating {
    if (!self.isAnimating) return;
    
    [self.progressLayer removeAnimationForKey:kMMRingRotationAnimationKey];
    [self.progressLayer removeAnimationForKey:kMMRingStrokeAnimationKey];
    self.isAnimating = NO;
    
    if (self.hiddenWhenStopped) self.hidden = YES;
}

#pragma mark    Private-Method
- (void)initialze {
    self.duration = 1.5f;
    self.timmingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addSublayer:self.progressLayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAnimations) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)resetAnimations {
    if (self.isAnimating) {
        [self stopAnimating];
        [self startAnimating];
    }
}

- (void)updatePath {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2) - self.progressLayer.lineWidth/2;
    CGFloat stargAngle = 0.f;
    CGFloat endAngle = 2 * M_PI;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:stargAngle endAngle:endAngle clockwise:YES];
    self.progressLayer.path = path.CGPath;
    
    self.progressLayer.strokeStart = 0.f;
    self.progressLayer.strokeEnd = 0.f;
}

#pragma mark    Setter && Getter

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = self.tintColor.CGColor;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.lineWidth = 1.5f;
    }
    return _progressLayer;
}

- (BOOL)isAnimating {
    return _isAnimating;
}

- (CGFloat)lineWidth {
    return self.progressLayer.lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    self.progressLayer.lineWidth = lineWidth;
    [self updatePath];
}

- (void)setHiddenWhenStopped:(BOOL)hiddenWhenStopped {
    _hiddenWhenStopped = hiddenWhenStopped;
    self.hidden = !self.isAnimating && hiddenWhenStopped;
}


@end

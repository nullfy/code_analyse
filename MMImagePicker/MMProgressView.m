//
//  MMProgressView.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMProgressView.h"

@interface MMProgressView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation MMProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        _progressLayer.opacity = 1.0f;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.lineWidth = 5;
        
        [_progressLayer setShadowColor:[UIColor blackColor].CGColor];
        [_progressLayer setShadowOffset:CGSizeMake(1, 1)];//设置阴影的偏移
        [_progressLayer setShadowOpacity:0.5];//设置阴影的清晰度
        [_progressLayer setShadowRadius:2.0f];//设置阴影圆环的宽度
    }
    return self;
}

- (void)drawRect:(CGRect)rect {//(渲染树)   呈现树->层级树->渲染树
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    CGFloat radius = rect.size.width/2;
    CGFloat startA = -M_PI_2;
    CGFloat endA = - M_PI_2 + M_PI * 2 * _progress;
    
    _progressLayer.frame = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    _progressLayer.path = path.CGPath;
    
    [_progressLayer removeFromSuperlayer];
    [self.layer addSublayer:_progressLayer];
}

- (void)setProgress:(double)progress {
    _progress = progress;
    [self setNeedsDisplay];//这里之后会调用drawRect
}



@end

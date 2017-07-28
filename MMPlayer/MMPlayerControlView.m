//
//  MMPlayerControlView.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/28.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMPlayerControlView.h"
#import "MMPlayerSlider.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+MMPlayer.h"
#import "MMMaterialDesignSpinner.h"

static const CGFloat MMPlayerAnimationTimeInterval = 7.0f;
static const CGFloat MMPlayerControlBarAutoFadeOutTimeInterval = 0.35f;

#pragma clang dignostic-push
#pragma clang dignostic ignored "-Wdeprecated-declarations"

@interface MMPlayerControlView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation MMPlayerControlView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
#pragma clang diagnostic pop

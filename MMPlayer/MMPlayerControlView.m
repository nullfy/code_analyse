//
//  MMPlayerControlView.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/28.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMPlayerControlView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MMPlayer.h"

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
@property (nonatomic, strong) MMPlayerSlider *videoSlider;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UIButton *lockButton;
@property (nonatomic, strong) MMMaterialDesignSpinner *activityView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *repeatButton;
@property (nonatomic, strong) UIImageView *bottomImageView;
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *resolutionButton;
@property (nonatomic, strong) UIView *resolutionView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *failButton;
@property (nonatomic, strong) UIView *fastView;
@property (nonatomic, strong) UILabel *fastTimeLabel;
@property (nonatomic, strong) UIProgressView *fastProgressView;
@property (nonatomic, strong) UIImageView *fastImageView;
@property (nonatomic, strong) UIButton *resolutionCurrentButton;
@property (nonatomic, strong) UIImageView *placeholderImageView;
@property (nonatomic, strong) UIProgressView *bottomProgressView;
@property (nonatomic, strong) NSArray *resolutionArray;

@property (nonatomic, assign, getter=isShowing) BOOL showing;
@property (nonatomic, assign, getter=isShrink) BOOL shrink;
@property (nonatomic, assign, getter=isCellVideo) BOOL cellVideo;
@property (nonatomic, assign, getter=isDragged) BOOL dragged;
@property (nonatomic, assign, getter=isPlayEnd) BOOL playEnd;
@property (nonatomic, assign, getter=isFullScreen) BOOL fullScreen;

@end

@implementation MMPlayerControlView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    /**
     top 关闭 title 分辨率 下载
     middle     play   lock
     bottom play  current slider  total 全屏
     */

    
    [self addSubview:self.placeholderImageView];
    [self addSubview:self.topImageView];
    [self addSubview:self.bottomImageView];
    
    [self.topImageView addSubview:self.titleLabel];
    [self.topImageView addSubview:self.resolutionButton];
    
    [self.bottomImageView addSubview:self.startButton];
    [self.bottomImageView addSubview:self.currentTimeLabel];
    [self.bottomImageView addSubview:self.progressView];
    [self.bottomImageView addSubview:self.videoSlider];
    [self.bottomImageView addSubview:self.fullScreenButton];
    [self.bottomImageView addSubview:self.totalTimeLabel];
    
    [self.topImageView addSubview:self.downloadButton];
    [self.topImageView addSubview:self.backButton];
    
    [self addSubview:self.lockButton];
    [self addSubview:self.activityView];
    [self addSubview:self.repeatButton];
    [self addSubview:self.playButton];
    [self addSubview:self.failButton];
    
    [self addSubview:self.fastView];
    [self.fastView addSubview:self.fastImageView];
    [self.fastView addSubview:self.fastTimeLabel];
    [self.fastView addSubview:self.fastProgressView];
    
    [self addSubview:self.closeButton];
    [self addSubview:self.bottomProgressView];
    
    [self layoutControlView];
    self.downloadButton.hidden = YES;
    self.resolutionButton.hidden = YES;
    
    [self resetControlView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self listeningRotating];
}

- (void)listeningRotating {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)layoutControlView {
    self.placeholderImageView.frame = self.bounds;
    
    self.closeButton.top = -7;
    self.closeButton.left = 7;
    self.closeButton.width = 20;
    self.closeButton.height = 20;
    
    self.topImageView.left = 0;
    self.topImageView.top = 0;
    self.topImageView.height = 50;
    self.topImageView.width = self.width;
    
    self.backButton.top = self.topImageView.top - 3;
    self.backButton.left = 10;
    self.backButton.width = 40;
    self.backButton.height = 40;
    
    self.downloadButton.width = 40;
    self.downloadButton.height = 49;
    self.downloadButton.right = self.topImageView.width - 10;
    self.downloadButton.centerY = self.backButton.centerY;
    
    self.resolutionButton.width = 40;
    self.resolutionButton.height = 25;
    self.resolutionButton.right = self.downloadButton.left - 10;
    self.resolutionButton.centerY = self.backButton.centerY;
    
    self.titleLabel.left = self.backButton.right + 5;
    self.titleLabel.centerY = self.backButton.centerY;
    self.titleLabel.right = self.resolutionButton.left - 10;
    self.titleLabel.height = self.backButton.height;
    

    self.bottomImageView.height = 50;
    self.bottomImageView.left = 0;
    self.bottomImageView.width = self.width;
    
    self.startButton.left = 5;
    self.startButton.width = 30;
    self.startButton.bottom = self.bottomImageView.height - 5;
    
    self.currentTimeLabel.width = 43;
    self.currentTimeLabel.centerY = self.startButton.centerY;
    self.currentTimeLabel.left = self.startButton.right + 3;
    
    self.fullScreenButton.width = 30;
    self.fullScreenButton.height = 30;
    self.fullScreenButton.centerY = self.startButton.centerY;
    self.fullScreenButton.right = self.bottomImageView.width - 5;
    
    self.totalTimeLabel.centerY = self.startButton.centerY;
    self.totalTimeLabel.width = 43;
    self.totalTimeLabel.right = self.fullScreenButton.left - 3;
    
    self.progressView.left = self.currentTimeLabel.right + 4;
    self.progressView.right = self.totalTimeLabel.left - 4;
    self.progressView.centerY = self.startButton.centerY;
    
    self.videoSlider.left = self.currentTimeLabel.right + 4;
    self.videoSlider.right = self.totalTimeLabel.left - 4;
    self.videoSlider.centerY = self.startButton.centerY;
    self.videoSlider.height = 30;
    
    self.lockButton.left = 15;
    self.lockButton.centerY = self.centerY;
    self.lockButton.width = 32;
    self.lockButton.height = 32;
    
    self.repeatButton.center = self.center;
    
    self.playButton.height = 50;
    self.playButton.width = 50;
    self.playButton.center = self.center;
    
    self.activityView.center = self.center;
    self.activityView.width = 45;
    self.activityView.height = 45;
    
    self.failButton.center = self.center;
    self.failButton.width = 130;
    self.failButton.height = 33;
    
    self.fastView.width = 125;
    self.fastView.height = 80;
    self.fastView.center = self.center;
    
    self.fastImageView.width = 32;
    self.fastImageView.height = 32;
    self.fastImageView.top = 5;
    self.fastImageView.centerX = self.fastView.centerX;
    
    self.fastTimeLabel.top = self.fastImageView.bottom + 2;
    self.fastTimeLabel.left = 0;
    self.fastTimeLabel.width = self.width;
    
    self.fastProgressView.left = 0;
    self.fastProgressView.right = self.fastProgressView.superview.width;
    self.fastProgressView.top = self.fastTimeLabel.bottom + 10;
    
    self.bottomProgressView.left = 0;
    self.bottomProgressView.width = self.bottomProgressView.superview.width;
    self.bottomProgressView.bottom = 0;
    self.bottomProgressView.height = self.bottomProgressView.superview.height;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIInterfaceOrientation currenOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currenOrientation == UIDeviceOrientationPortrait) {
        [self setOrientationPortraitLayout];
    } else {
        [self setOrientationLandscapeLayout];
    }
}


- (void)resetControlView {
    [self.activityView stopAnimating];
    self.videoSlider.value           = 0;
    self.bottomProgressView.progress = 0;
    self.progressView.progress       = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.totalTimeLabel.text         = @"00:00";
    self.fastView.hidden             = YES;
    self.repeatButton.hidden            = YES;
    self.playButton.hidden             = YES;
    self.resolutionView.hidden       = YES;
    self.failButton.hidden              = YES;
    self.backgroundColor             = [UIColor clearColor];
    self.downloadButton.enabled         = YES;
    self.shrink                      = NO;
    self.showing                     = NO;
    self.playEnd                    = NO;
    self.lockButton.hidden              = !self.isFullScreen;
    self.failButton.hidden              = YES;
    self.placeholderImageView.alpha  = 1;
    [self hideControlView];
}

- (void)setOrientationPortraitLayout {
    self.fullScreen = NO;
    self.lockButton.hidden = !self.isFullScreen;
    self.fullScreenButton.hidden = self.isFullScreen;
    
    self.backButton.top = 3;
    self.backButton.left = 10;
    self.backButton.width = 40;
    self.backButton.height = 40;
}

- (void)setOrientationLandscapeLayout {
    if ([self isCellVideo]) self.shrink = NO;
    self.fullScreen = YES;
    self.lockButton.hidden = !self.isFullScreen;
    self.fullScreenButton.selected = self.isFullScreen;
    
    [self.backButton setImage:MMPlayerImage(@"MMPlayer_back_full") forState:UIControlStateNormal];
    
    self.backButton.top = self.topImageView.top + 23;
    self.backButton.left = 10;
    self.width = 40;
    self.height = 40;
}

#pragma mark    Action

- (void)changeResolution:(UIButton *)button {
    button.selected = YES;
    if (button.isSelected) {
        button.backgroundColor = RGBA(86/255.0, 143/255.0, 232/255.0, 1);
    } else {
        button.backgroundColor = [UIColor clearColor];
    }
    
    self.resolutionCurrentButton.selected = NO;
    self.resolutionCurrentButton.backgroundColor = [UIColor clearColor];
    self.resolutionCurrentButton = button;
    
    self.resolutionView.hidden = YES;
    
    self.resolutionButton.selected = NO;
    
    [self.resolutionButton setTitle:button.titleLabel.text forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(mm_controlView:resolutionAction:)]) {
        [self.delegate mm_controlView:self resolutionAction:button];
    }
}

- (void)tapSliderAction:(UITapGestureRecognizer *)tap {
    if ([tap.view isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)tap.view;
        CGPoint point = [tap locationInView:slider];
        CGFloat length = slider.width;
        
        CGFloat tapValue = point.x / length;
        if ([self.delegate respondsToSelector:@selector(mm_controlView:progressSliderTap:)]) {
            [self.delegate mm_controlView:self progressSliderTap:tapValue];
        }
    }
}

- (void)panRecognizer:(UIPanGestureRecognizer *)pan { }

- (void)backButtonClick:(UIButton *)button {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (self.isCellVideo && orientation == UIInterfaceOrientationPortrait) {
        if ([self.delegate respondsToSelector:@selector(mm_controlView:closeAction:)]) {
            [self.delegate mm_controlView:self closeAction:button];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(mm_controlView:backAction:)]) {
            [self.delegate mm_controlView:self backAction:button];
        }
    }
}

- (void)lockScreenButtonClick:(UIButton *)button {
    button.selected = !button.selected;
    self.showing = NO;
    [self mm_playerShowControlView];
    if ([self.delegate respondsToSelector:@selector(mm_controlView:lockScreenAction:)]) {
        [self.delegate mm_controlView:self lockScreenAction:button];
    }
}

- (void)playButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(mm_controlView:playAction:)]) {
        [self.delegate mm_controlView:self playAction:sender];
    }
}

- (void)closeBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(mm_controlView:closeAction:)]) {
        [self.delegate mm_controlView:self closeAction:sender];
    }
}

- (void)fullScreenBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(mm_controlView:fullScreenAction:)]) {
        [self.delegate mm_controlView:self fullScreenAction:sender];
    }
}

- (void)repeatBtnClick:(UIButton *)sender {
    // 重置控制层View
    [self mm_playerResetControlView];
    [self mm_playerShowControlView];
    if ([self.delegate respondsToSelector:@selector(mm_controlView:repeatPlayAction:)]) {
        [self.delegate mm_controlView:self repeatPlayAction:sender];
    }
}

- (void)downloadBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(mm_controlView:downloadVideoAction:)]) {
        [self.delegate mm_controlView:self downloadVideoAction:sender];
    }
}

- (void)resolutionBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    // 显示隐藏分辨率View
    self.resolutionView.hidden = !sender.isSelected;
}

- (void)centerPlayBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(mm_controlView:centerPlayAction:)]) {
        [self.delegate mm_controlView:self centerPlayAction:sender];
    }
}

- (void)failBtnClick:(UIButton *)sender {
    self.failButton.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(mm_controlView:failAction:)]) {
        [self.delegate mm_controlView:self failAction:sender];
    }
}

- (void)progressSliderTouchBegan:(MMPlayerSlider *)sender {
    [self mm_playerCancelAutoFadeOutControlView];
    self.videoSlider.popUpView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(mm_controlView:progressSliderTouchBegan:)]) {
        [self.delegate mm_controlView:self progressSliderTouchBegan:sender];
    }
}

- (void)progressSliderValueChanged:(MMPlayerSlider *)sender {
    if ([self.delegate respondsToSelector:@selector(mm_controlView:progressSliderValueChanged:)]) {
        [self.delegate mm_controlView:self progressSliderValueChanged:sender];
    }
}

- (void)progressSliderTouchEnded:(MMPlayerSlider *)sender {
    self.showing = YES;
    if ([self.delegate respondsToSelector:@selector(mm_controlView:progressSliderTouchEnded:)]) {
        [self.delegate mm_controlView:self progressSliderTouchEnded:sender];
    }
}

- (void)playerPlayDidEnd {
    self.backgroundColor = RGBA(0, 0, 0, 6);
    self.repeatButton.hidden = NO;
    self.showing = NO; //初始化显示controlView为YES
    [self mm_playerShowControlView]; //延迟隐藏controlView
}

- (void)onDeviceOrientationChange {
    if (MMPlayerShared.isLockScreen) return;
    self.lockButton.hidden = !self.isFullScreen;
    self.fullScreenButton.selected = self.isFullScreen;
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationFaceUp ||
        orientation == UIDeviceOrientationFaceDown ||
        orientation == UIDeviceOrientationUnknown ||
        orientation == UIDeviceOrientationPortraitUpsideDown) {
        return;
    }
    
    if (!self.isShrink && !self.isPlayEnd && !self.showing) [self mm_playerShowOrHidecontrolView];
}

#pragma mark    Private

- (void)hideControlView {
    self.showing = NO;
    self.backgroundColor = RGBA(0, 0, 0, 0);
    self.topImageView.alpha = self.playEnd;
    self.bottomImageView.alpha = 0;
    self.lockButton.alpha = 0;
    self.bottomProgressView.alpha = 1;
    self.resolutionButton.selected = YES;
    [self resolutionBtnClick:self.resolutionButton];
    
    if (self.isFullScreen && !self.playEnd && !self.isShrink) MMPlayerShared.isStatusBarHidden = YES;
}

- (void)mm_playerCancelAutoFadeOutControlView {
    //delay perform
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


#pragma mark    notification

- (void)appEnterForeground {
    if (!self.shrink) [self mm_playerShowControlView];
}

- (void)appEnterBackground {
    [self mm_playerCancelAutoFadeOutControlView];
}

- (void)deviceOrientationChange {
    if (MMPlayerShared.isLockScreen) return;
    
    self.lockButton.hidden = !self.isFullScreen;
    self.fullScreenButton.selected = self.isFullScreen;
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationFaceUp ||
        orientation == UIDeviceOrientationFaceDown ||
        orientation == UIDeviceOrientationUnknown ||
        orientation == UIDeviceOrientationPortraitUpsideDown) return;
    if (!self.isShrink && !self.isPlayEnd && !self.showing) [self mm_playerShowOrHidecontrolView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}


@end
#pragma clang diagnostic pop

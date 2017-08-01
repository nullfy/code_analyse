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

- (void)closeButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(mm_controlView:closeAction:)]) {
        [self.delegate mm_controlView:self closeAction:sender];
    }
}

- (void)fullScreenButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(mm_controlView:fullScreenAction:)]) {
        [self.delegate mm_controlView:self fullScreenAction:sender];
    }
}

- (void)repeatButtonClick:(UIButton *)sender {
    // 重置控制层View
    [self mm_playerResetControlView];
    [self mm_playerShowControlView];
    if ([self.delegate respondsToSelector:@selector(mm_controlView:repeatPlayAction:)]) {
        [self.delegate mm_controlView:self repeatPlayAction:sender];
    }
}

- (void)downloadButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(mm_controlView:downloadVideoAction:)]) {
        [self.delegate mm_controlView:self downloadVideoAction:sender];
    }
}

- (void)resolutionButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    // 显示隐藏分辨率View
    self.resolutionView.hidden = !sender.isSelected;
}

- (void)centerPlayButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(mm_controlView:centerPlayAction:)]) {
        [self.delegate mm_controlView:self centerPlayAction:sender];
    }
}

- (void)failButtonClick:(UIButton *)sender {
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

- (void)showControlView {
    self.showing = YES;
    if (self.lockButton.isSelected) {//屏幕锁定
        self.topImageView.alpha = 0;
        self.bottomImageView.alpha = 0;
    } else {
        self.topImageView.alpha = 1;
        self.bottomImageView.alpha = 1;
    }
    
    self.backgroundColor = RGBA(0, 0, 0, 0.3);
    self.lockButton.alpha = 1;
    if (self.isCellVideo) self.shrink = NO; //cell Video 不能缩小
    self.bottomImageView.alpha = 0;
    MMPlayerShared.isStatusBarHidden = NO;
}

- (void)hideControlView {
    self.showing = NO;
    self.backgroundColor = RGBA(0, 0, 0, 0);
    self.topImageView.alpha = self.playEnd;
    self.bottomImageView.alpha = 0;
    self.lockButton.alpha = 0;
    self.bottomProgressView.alpha = 1;
    self.resolutionButton.selected = YES;
    [self resolutionButtonClick:self.resolutionButton];
    
    if (self.isFullScreen && !self.playEnd && !self.isShrink) MMPlayerShared.isStatusBarHidden = YES;
}

- (CGRect)thumbRect {
    return [self.videoSlider thumbRectForBounds:self.videoSlider.bounds
                               trackRect:[self.videoSlider trackRectForBounds:self.videoSlider.bounds]
                                   value:self.videoSlider.value];
}

//自动淡化隐藏进度条等视图
- (void)autoFadeOutControlView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(mm_playerHideControlView) object:nil];
    [self performSelector:@selector(mm_playerHideControlView) withObject:nil afterDelay:MMPlayerAnimationTimeInterval];
}

- (void)listeningRotating {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark    setter

- (void)setShrink:(BOOL)shrink {
    _shrink = shrink;
    self.closeButton.hidden = !shrink;
    self.bottomProgressView.hidden = shrink;
}

- (void)setFullScreen:(BOOL)fullScreen {
    _fullScreen = fullScreen;
    MMPlayerShared.isLandscape = fullScreen;
}

#pragma mark    getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLabel;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:MMPlayerImage(@"MMPlayer_back_full") forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView                        = [[UIImageView alloc] init];
        _topImageView.userInteractionEnabled = YES;
        _topImageView.alpha                  = 0;
        _topImageView.image                  = MMPlayerImage(@"MMPlayer_top_shadow");
    }
    return _topImageView;
}

- (UIImageView *)bottomImageView {
    if (!_bottomImageView) {
        _bottomImageView                        = [[UIImageView alloc] init];
        _bottomImageView.userInteractionEnabled = YES;
        _bottomImageView.alpha                  = 0;
        _bottomImageView.image                  = MMPlayerImage(@"MMPlayer_bottom_shadow");
    }
    return _bottomImageView;
}

- (UIButton *)lockButton {
    if (!_lockButton) {
        _lockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockButton setImage:MMPlayerImage(@"MMPlayer_unlock-nor") forState:UIControlStateNormal];
        [_lockButton setImage:MMPlayerImage(@"MMPlayer_lock-nor") forState:UIControlStateSelected];
        [_lockButton addTarget:self action:@selector(lockScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _lockButton;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startButton setImage:MMPlayerImage(@"MMPlayer_play") forState:UIControlStateNormal];
        [_startButton setImage:MMPlayerImage(@"MMPlayer_pause") forState:UIControlStateSelected];
        [_startButton addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:MMPlayerImage(@"MMPlayer_close") forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.hidden = YES;
    }
    return _closeButton;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel               = [[UILabel alloc] init];
        _currentTimeLabel.textColor     = [UIColor whiteColor];
        _currentTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView                   = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _progressView.trackTintColor    = [UIColor clearColor];
    }
    return _progressView;
}

- (MMPlayerSlider *)videoSlider {
    if (!_videoSlider) {
        _videoSlider                       = [[MMPlayerSlider alloc] init];
        _videoSlider.popUpViewCornerRadius = 0.0;
        _videoSlider.popUpViewColor = RGBA(19, 19, 9, 1);
        _videoSlider.popUpViewArrowLength = 8;
        
        [_videoSlider setThumbImage:MMPlayerImage(@"MMPlayer_slider") forState:UIControlStateNormal];
        _videoSlider.maximumValue          = 1;
        _videoSlider.minimumTrackTintColor = [UIColor whiteColor];
        _videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        
        // slider开始滑动事件
        [_videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [_videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        
        UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderAction:)];
        [_videoSlider addGestureRecognizer:sliderTap];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognizer:)];
        panRecognizer.delegate = self;
        [panRecognizer setMaximumNumberOfTouches:1];
        [panRecognizer setDelaysTouchesBegan:YES];
        [panRecognizer setDelaysTouchesEnded:YES];
        [panRecognizer setCancelsTouchesInView:YES];
        [_videoSlider addGestureRecognizer:panRecognizer];
    }
    return _videoSlider;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel               = [[UILabel alloc] init];
        _totalTimeLabel.textColor     = [UIColor whiteColor];
        _totalTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (UIButton *)fullScreenButton {
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:MMPlayerImage(@"MMPlayer_fullscreen") forState:UIControlStateNormal];
        [_fullScreenButton setImage:MMPlayerImage(@"MMPlayer_shrinkscreen") forState:UIControlStateSelected];
        [_fullScreenButton addTarget:self action:@selector(fullScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenButton;
}

- (MMMaterialDesignSpinner *)activityView {
    if (!_activityView) {
        _activityView = [[MMMaterialDesignSpinner alloc] init];
        _activityView.lineWidth = 1;
        _activityView.duration  = 1;
        _activityView.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    }
    return _activityView;
}

- (UIButton *)repeatButton {
    if (!_repeatButton) {
        _repeatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_repeatButton setImage:MMPlayerImage(@"MMPlayer_repeat_video") forState:UIControlStateNormal];
        [_repeatButton addTarget:self action:@selector(repeatButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _repeatButton;
}

- (UIButton *)downLoadButton {
    if (!_downloadButton) {
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadButton setImage:MMPlayerImage(@"MMPlayer_download") forState:UIControlStateNormal];
        [_downloadButton setImage:MMPlayerImage(@"MMPlayer_not_download") forState:UIControlStateDisabled];
        [_downloadButton addTarget:self action:@selector(downloadButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadButton;
}

- (UIButton *)resolutionButton {
    if (!_resolutionButton) {
        _resolutionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _resolutionButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _resolutionButton.backgroundColor = RGBA(0, 0, 0, 0.7);
        [_resolutionButton addTarget:self action:@selector(resolutionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resolutionButton;
}

- (UIButton *)playeButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:MMPlayerImage(@"MMPlayer_play_Button") forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(centerPlayButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)failButton {
    if (!_failButton) {
        _failButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_failButton setTitle:@"加载失败,点击重试" forState:UIControlStateNormal];
        [_failButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _failButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _failButton.backgroundColor = RGBA(0, 0, 0, 0.7);
        [_failButton addTarget:self action:@selector(failButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _failButton;
}

- (UIView *)fastView {
    if (!_fastView) {
        _fastView                     = [[UIView alloc] init];
        _fastView.backgroundColor     = RGBA(0, 0, 0, 0.8);
        _fastView.layer.cornerRadius  = 4;
        _fastView.layer.masksToBounds = YES;
    }
    return _fastView;
}

- (UIImageView *)fastImageView {
    if (!_fastImageView) {
        _fastImageView = [[UIImageView alloc] init];
    }
    return _fastImageView;
}

- (UILabel *)fastTimeLabel {
    if (!_fastTimeLabel) {
        _fastTimeLabel               = [[UILabel alloc] init];
        _fastTimeLabel.textColor     = [UIColor whiteColor];
        _fastTimeLabel.textAlignment = NSTextAlignmentCenter;
        _fastTimeLabel.font          = [UIFont systemFontOfSize:14.0];
    }
    return _fastTimeLabel;
}

- (UIProgressView *)fastProgressView {
    if (!_fastProgressView) {
        _fastProgressView                   = [[UIProgressView alloc] init];
        _fastProgressView.progressTintColor = [UIColor whiteColor];
        _fastProgressView.trackTintColor    = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    }
    return _fastProgressView;
}

- (UIImageView *)placeholderImageView {
    if (!_placeholderImageView) {
        _placeholderImageView = [[UIImageView alloc] init];
        _placeholderImageView.userInteractionEnabled = YES;
    }
    return _placeholderImageView;
}

- (UIProgressView *)bottomProgressView {
    if (!_bottomProgressView) {
        _bottomProgressView                   = [[UIProgressView alloc] init];
        _bottomProgressView.progressTintColor = [UIColor whiteColor];
        _bottomProgressView.trackTintColor    = [UIColor clearColor];
    }
    return _bottomProgressView;
}

#pragma mark    UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch {
    CGRect rect = [self thumbRect];
    CGPoint point = [gestureRecognizer locationInView:self.videoSlider];
    if ([touch.view isKindOfClass:[UISlider class]]) {
        if (point.x <= rect.origin.x + rect.size.width && point.x >= rect.origin.x) return NO;
    }
    return YES;
}

#pragma mark    public method

/** 重置ControlView */
- (void)mm_playerResetControlView {
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
    self.downLoadButton.enabled         = YES;
    self.shrink                      = NO;
    self.showing                     = NO;
    self.playEnd                    = NO;
    self.lockButton.hidden              = !self.isFullScreen;
    self.failButton.hidden              = YES;
    self.placeholderImageView.alpha  = 1;
    [self hideControlView];
}

- (void)mm_playerResetControlViewForResolution {
    self.fastView.hidden        = YES;
    self.repeatButton.hidden       = YES;
    self.resolutionView.hidden  = YES;
    self.playeButton.hidden        = YES;
    self.downLoadButton.enabled    = YES;
    self.failButton.hidden         = YES;
    self.backgroundColor        = [UIColor clearColor];
    self.shrink                 = NO;
    self.showing                = NO;
    self.playEnd               = NO;
}


/** 设置播放模型 */
- (void)mm_playerModel:(MMPlayerModel *)model {
    
    if (model.title) { self.titleLabel.text = model.title; }
    // 设置网络占位图片
    if (model.placeholderImageURLString) {
        [self.placeholderImageView setImageWithURLString:model.placeholderImageURLString placeholderImage:MMPlayerImage(@"MMPlayer_loading_bgView")];
    } else {
        self.placeholderImageView.image = model.placeholderImage;
    }
    if (model.resolutionDic) {
        [self mm_playerResolutionArray:[model.resolutionDic allKeys]];
    }
}

/** 正在播放（隐藏placeholderImageView） */
- (void)mm_playerItemPlaying {
    [UIView animateWithDuration:1.0 animations:^{
        self.placeholderImageView.alpha = 0;
    }];
}

- (void)mm_playerShowOrHideControlView {
    if (self.isShowing) {
        [self mm_playerHideControlView];
    } else {
        [self mm_playerShowControlView];
    }
}
/**
 *  显示控制层
 */
- (void)mm_playerShowControlView {
    if ([self.delegate respondsToSelector:@selector(mm_controlViewWillShow:isFullScreen:)]) {
        [self.delegate mm_controlViewWillShow:self isFullScreen:self.isFullScreen];
    }
    [self mm_playerCancelAutoFadeOutControlView];
    [UIView animateWithDuration:MMPlayerControlBarAutoFadeOutTimeInterval animations:^{
        [self showControlView];
    } completion:^(BOOL finished) {
        self.showing = YES;
        [self autoFadeOutControlView];
    }];
}


- (void)mm_playerCancelAutoFadeOutControlView {
    //delay perform
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

/**
 *  隐藏控制层
 */
- (void)mm_playerHideControlView {
    if ([self.delegate respondsToSelector:@selector(mm_controlViewWillHidden:isFullScreen:)]) {
        [self.delegate mm_controlViewWillHidden:self isFullScreen:self.isFullScreen];
    }
    [self mm_playerCancelAutoFadeOutControlView];
    [UIView animateWithDuration:MMPlayerControlBarAutoFadeOutTimeInterval animations:^{
        [self hideControlView];
    } completion:^(BOOL finished) {
        self.showing = NO;
    }];
}

/** 小屏播放 */
- (void)mm_playerBottomShrinkPlay {
    self.shrink = YES;
    [self hideControlView];
}

/** 在cell播放 */
- (void)mm_playerCellPlay {
    self.cellVideo = YES;
    self.shrink    = NO;
    [self.backButton setImage:MMPlayerImage(@"MMPlayer_close") forState:UIControlStateNormal];
}

- (void)mm_playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value {
    // 当前时长进度progress
    NSInteger proMin = currentTime / 60;//当前秒
    NSInteger proSec = currentTime % 60;//当前分钟
    // duration 总时长
    NSInteger durMin = totalTime / 60;//总秒
    NSInteger durSec = totalTime % 60;//总分钟
    if (!self.isDragged) {
        // 更新slider
        self.videoSlider.value           = value;
        self.bottomProgressView.progress = value;
        // 更新当前播放时间
        self.currentTimeLabel.text       = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    }
    // 更新总时间
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
}

- (void)mm_playerDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd hasPreview:(BOOL)preview {
    // 快进快退时候停止菊花
    [self.activityView stopAnimating];
    // 拖拽的时长
    NSInteger proMin = draggedTime / 60;//当前秒
    NSInteger proSec = draggedTime % 60;//当前分钟
    
    //duration 总时长
    NSInteger durMin = totalTime / 60;//总秒
    NSInteger durSec = totalTime % 60;//总分钟
    
    NSString *currentTimeStr = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    NSString *totalTimeStr   = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
    CGFloat  draggedValue    = (CGFloat)draggedTime/(CGFloat)totalTime;
    NSString *timeStr        = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totalTimeStr];
    
    // 显示、隐藏预览窗
    self.videoSlider.popUpView.hidden = !preview;
    // 更新slider的值
    self.videoSlider.value            = draggedValue;
    // 更新bottomProgressView的值
    self.bottomProgressView.progress  = draggedValue;
    // 更新当前时间
    self.currentTimeLabel.text        = currentTimeStr;
    // 正在拖动控制播放进度
    self.dragged = YES;
    
    if (forawrd) {
        self.fastImageView.image = MMPlayerImage(@"MMPlayer_fast_forward");
    } else {
        self.fastImageView.image = MMPlayerImage(@"MMPlayer_fast_backward");
    }
    self.fastView.hidden           = preview;
    self.fastTimeLabel.text        = timeStr;
    self.fastProgressView.progress = draggedValue;
    
}

- (void)mm_playerDraggedEnd {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.fastView.hidden = YES;
    });
    self.dragged = NO;
    // 结束滑动时候把开始播放按钮改为播放状态
    self.startButton.selected = YES;
    // 滑动结束延时隐藏controlView
    [self autoFadeOutControlView];
}

- (void)mm_playerDraggedTime:(NSInteger)draggedTime sliderImage:(UIImage *)image; {
    // 拖拽的时长
    NSInteger proMin = draggedTime / 60;//当前秒
    NSInteger proSec = draggedTime % 60;//当前分钟
    NSString *currentTimeStr = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    [self.videoSlider setImage:image];
    [self.videoSlider setText:currentTimeStr];
    self.fastView.hidden = YES;
}

/** progress显示缓冲进度 */
- (void)mm_playerSetProgress:(CGFloat)progress {
    [self.progressView setProgress:progress animated:NO];
}

/** 视频加载失败 */
- (void)mm_playerItemStatusFailed:(NSError *)error {
    self.failButton.hidden = NO;
}

/** 加载的菊花 */
- (void)mm_playerActivity:(BOOL)animated {
    if (animated) {
        [self.activityView startAnimating];
        self.fastView.hidden = YES;
    } else {
        [self.activityView stopAnimating];
    }
}

/** 播放完了 */
- (void)mm_playerPlayEnd {
    self.repeatButton.hidden = NO;
    self.playEnd         = YES;
    self.showing          = NO;
    // 隐藏controlView
    [self hideControlView];
    self.backgroundColor  = RGBA(0, 0, 0, .3);
    MMPlayerShared.isStatusBarHidden = NO;
    self.bottomProgressView.alpha = 0;
}

/**
 是否有下载功能
 */
- (void)mm_playerHasDownloadFunction:(BOOL)sender {
    self.downLoadButton.hidden = !sender;
}

/**
 是否有切换分辨率功能
 */
- (void)mm_playerResolutionArray:(NSArray *)resolutionArray {
    self.resolutionButton.hidden = NO;
    
    _resolutionArray = resolutionArray;
    [_resolutionButton setTitle:resolutionArray.firstObject forState:UIControlStateNormal];
    // 添加分辨率按钮和分辨率下拉列表
    self.resolutionView = [[UIView alloc] init];
    self.resolutionView.hidden = YES;
    self.resolutionView.backgroundColor = RGBA(0, 0, 0, 0.7);
    [self addSubview:self.resolutionView];
    
//    [self.resolutionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(40);
//        make.height.mas_equalTo(25*resolutionArray.count);
//        make.leading.equalTo(self.resolutionButton.mas_leading).offset(0);
//        make.top.equalTo(self.resolutionButton.mas_bottom).offset(0);
//    }];
    
    self.resolutionView.width = 40;
    self.resolutionView.height = 25 * resolutionArray.count;
    self.resolutionView.left = self.resolutionButton.left;
    self.resolutionView.top = self.resolutionButton.bottom;
    
    // 分辨率View上边的Button
    for (NSInteger i = 0 ; i < resolutionArray.count; i++) {
        UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
        Button.layer.borderColor = [UIColor whiteColor].CGColor;
        Button.layer.borderWidth = 0.5;
        Button.tag = 200+i;
        Button.frame = CGRectMake(0, 25*i, 40, 25);
        Button.titleLabel.font = [UIFont systemFontOfSize:12];
        [Button setTitle:resolutionArray[i] forState:UIControlStateNormal];
        if (i == 0) {
            self.resolutionCurrentButton = Button;
            Button.selected = YES;
            Button.backgroundColor = RGBA(86, 143, 232, 1);
        }
        [self.resolutionView addSubview:Button];
        [Button addTarget:self action:@selector(changeResolution:) forControlEvents:UIControlEventTouchUpInside];
    }
}

/** 播放按钮状态 */
- (void)mm_playerPlayButtonState:(BOOL)state {
    self.startButton.selected = state;
}

/** 锁定屏幕方向按钮状态 */
- (void)mm_playerLockButtonState:(BOOL)state {
    self.lockButton.selected = state;
}

/** 下载按钮状态 */
- (void)mm_playerDownloadButtonState:(BOOL)state {
    self.downLoadButton.enabled = state;
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

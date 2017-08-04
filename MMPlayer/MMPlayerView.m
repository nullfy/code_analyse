//
//  MMPlayerView.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/31.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

typedef NS_ENUM(NSUInteger, PanDirection) {
    PanDirectionHorizonMoved,
    PanDirectionVerticalMoved
};

@interface MMPlayerView ()<UIGestureRecognizerDelegate, UIAlertViewDelegate, MMPlayerControlViewDelegate>

@property (nonatomic, strong) AVPlayer                  *player;
@property (nonatomic, strong) AVPlayerItem              *playerItem;
@property (nonatomic, strong) AVURLAsset                *urlAsset;
@property (nonatomic, strong) AVAssetImageGenerator     *imageGenerator;
@property (nonatomic, strong) AVPlayerLayer             *playerLayer;
@property (nonatomic, strong) id                        timeObserver;
@property (nonatomic, strong) UISlider                  *volumeViewSlider;

@property (nonatomic, assign) CGFloat                   sumTime;
@property (nonatomic, assign) PanDirection              panDirection;
@property (nonatomic, assign) MMPlayerState             state;
@property (nonatomic, assign) BOOL                      isFullScreen;
/** 是否锁定屏幕方向 */
@property (nonatomic, assign) BOOL                      isLocked;
/** 是否在调节音量*/
@property (nonatomic, assign) BOOL                      isVolume;
/** 是否被用户暂停 */
@property (nonatomic, assign) BOOL                      isPauseByUser;
/** 是否播放本地文件 */
@property (nonatomic, assign) BOOL                      isLocalVideo;
/** slider上次的值 */
@property (nonatomic, assign) CGFloat                   sliderLastValue;
/** 是否再次设置URL播放视频 */
@property (nonatomic, assign) BOOL                      repeatToPlay;
/** 播放完了*/
@property (nonatomic, assign) BOOL                      playDidEnd;
/** 进入后台*/
@property (nonatomic, assign) BOOL                      didEnterBackground;
/** 是否自动播放 */
@property (nonatomic, assign) BOOL                      isAutoPlay;
/** 是否拖动进度条 */
@property (nonatomic, assign) BOOL                      isDragged;

@property (nonatomic, strong) UITapGestureRecognizer    *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer    *doubleTap;
@property (nonatomic, strong) NSArray                   *videoURLArray;
@property (nonatomic, strong) UIImage                   *thumbImage;
@property (nonatomic, strong) MMBrightnessView          *brightnessView;
@property (nonatomic, copy) NSString                    *videoGravity;


@property (nonatomic, strong) UIScrollView              *scrollView;
@property (nonatomic, strong) NSIndexPath               *indexPath;

@property (nonatomic, assign) BOOL                      viewDisappear;
@property (nonatomic, assign) BOOL                      isCellVideo;
@property (nonatomic, assign) BOOL                      isBottomVideo;
@property (nonatomic, assign) BOOL                      isChangeResolution;
@property (nonatomic, assign) CGPoint                   shrinkRightBottomPoint;
@property (nonatomic, assign) NSInteger                 seekTime;

@property (nonatomic, strong) UIPanGestureRecognizer    *shrinkPanGesture;
@property (nonatomic, strong) UIView                    *controlView;
@property (nonatomic, strong) MMPlayerModel             *playerModel;
@property (nonatomic, strong) NSURL                     *videoURL;
@property (nonatomic, strong) NSDictionary              *resolutionDic;

@end

@implementation MMPlayerView

#pragma mark    Life-Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializePlayer];
    }
    return self;
}

//xib 加载playerView会调用此方法
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializePlayer];
}

- (void)initializePlayer {
    self.cellPlayerOnCenter = YES;
}

- (void)dealloc {
    self.playerItem = nil;
    self.scrollView = nil;
    MMPlayerShared.isLockScreen = NO;
    
    [self.controlView mm_playerCancleAutoFadeOutcontrolView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

- (void)resetToPlayNewURL {
    self.repeatToPlay = YES;
    [self resetPlayer];
}

+ (instancetype)sharedPlayerView {
    static MMPlayerView *view = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view = [[self alloc] init];
    });
    return view;
}

- (void)playerModel:(MMPlayerModel *)model {
    [self playerControlView:nil playerModel:model];
}

- (void)playerControlView:(UIView *)controlView playerModel:(MMPlayerModel *)model {
    if (!controlView) {
        MMPlayerControlView *view = [MMPlayerControlView new];
        self.controlView = view;
    } else {
        self.controlView = controlView;
    }
    
    self.playerModel = model;
}

- (void)autoPlayTheVideo {
    [self configMMPlayer];
}

- (void)addPlayerToFatherView:(UIView *)view {
    if (view) {
        [self removeFromSuperview];
        [view addSubview:self];
        self.frame = view.bounds;
    }
}

- (void)resetPlayer {
    self.playDidEnd = NO;
    self.playerItem = nil;
    self.didEnterBackground = NO;
    
    self.seekTime = 0;
    self.isAutoPlay = NO;
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self pause];
    
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    
    self.imageGenerator = nil;
    self.player = nil;
    
    if (self.isChangeResolution) {
        [self.controlView mm_playerResetControlViewForResolution];
        self.isChangeResolution = NO;
    } else {
        [self.controlView mm_playerResetControlView];
    }
    
    self.controlView = nil;
    if (!self.repeatToPlay) [self removeFromSuperview];
    
    self.isBottomVideo = NO;//底部播放Video
    
    if (self.isCellVideo && !self.repeatToPlay) {
        self.viewDisappear = YES;
        self.isCellVideo = NO;
        self.scrollView = nil;
        self.indexPath = nil;
    }
}

- (void)resetToPlayNewVideo:(MMPlayerModel *)model {
    self.repeatToPlay = YES;
    [self resetPlayer];
    self.playerModel = model;
    [self configMMPlayer];
}

#pragma mark    Config

- (void)configMMPlayer {
    //AVPlayerLayer->AVPlayer->AVPlayItem->AVURLAsset
    self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.backgroundColor = [UIColor blackColor];
    self.playerLayer.videoGravity = self.videoGravity;
    self.isAutoPlay = YES;
    
    [self createTimer];
    [self configVolume];
    
    if ([self.videoURL.scheme isEqualToString:@"file"]) {
        self.state = MMPlayerStatePlaying;
        self.isLocalVideo = YES;
        [self.controlView mm_playerDownloadButtonState:NO]; //通过传入值来控制是否可点击
    } else {
        self.state = MMPlayerStateBuffering;
        self.isLocalVideo = NO;
        [self.controlView mm_playerDownloadButtonState:YES];
    }
    
    [self play];
    self.isPauseByUser = NO;
}

- (void)createTimer {
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                                                  queue:nil
                                                             usingBlock:^(CMTime time) {
                                                                 AVPlayerItem *currentItem= weakSelf.playerItem;
                                                                 NSArray *loadRanges = currentItem.seekableTimeRanges;
                                                                 
                                                                 if (loadRanges.count > 0 && currentItem.duration.timescale != 0) {
                                                                     NSInteger currentTime = (NSInteger)CMTimeGetSeconds(time);
                                                                     
                                                                     CGFloat totalTime = (CGFloat)currentItem.duration.value/currentItem.duration.timescale;
                                                                     
                                                                     CGFloat value = CMTimeGetSeconds(currentItem.currentTime) / totalTime;
                                                                     
                                                                     [weakSelf.controlView mm_playerCurrentTime:currentTime totalTime:totalTime sliderValue:value];
                                                                 }
                                                                 
                                                             }];
}

- (void)configVolume {
    MPVolumeView *volumeView = [MPVolumeView new];
    _volumeViewSlider = nil;
    for (UIView *view in volumeView.subviews) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                                          error:&error];
    if (!success) {};
}

- (void)play {
    [self.controlView mm_playerPlayButtonState:YES]; //传入值控制是否被选中
    if (self.state == MMPlayerStatePause) self.state = MMPlayerStatePlaying;
    self.isPauseByUser = NO;
    [_player play];
}

- (void)pause {
    [self.controlView mm_playerPlayButtonState:NO];
    if (self.state == MMPlayerStatePlaying) self.state = MMPlayerStatePause;
    self.isPauseByUser = NO;
    [_player pause];
}

//Cell 相关
- (void)cellVideoWithScrollView:(UIScrollView *)scrollView atIndexPath:(NSIndexPath *)indexPath{
    if (!self.viewDisappear && self.playerItem) [self resetPlayer];
    
    self.isCellVideo = YES;
    self.viewDisappear = NO;
    self.scrollView = scrollView;
    self.indexPath = indexPath;
    
    [self.controlView mm_playerCellPlay];
    
    self.shrinkPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(shrinkPanAction:)];
}

- (void)seekToTime:(NSInteger)time completion:(void(^)())completion {
    if (self.player.currentItem.status == AVPlayerStatusReadyToPlay) {
        [self.controlView mm_playerActivity:YES];
        [self.player pause];
        
        CMTime draggedTime = CMTimeMake(time, 1);
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:draggedTime toleranceBefore:CMTimeMake(1, 1) toleranceAfter:CMTimeMake(1, 1) completionHandler:^(BOOL finished) {
            [weakSelf.controlView mm_playerActivity:NO];
            
            if (completion) completion(finished);
            [weakSelf.player play];
            weakSelf.seekTime = 0;
            weakSelf.isDragged = NO;
            
            [weakSelf.controlView mm_playerDraggedEnd];
            if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp && !weakSelf.isLocalVideo) {
                weakSelf.state = MMPlayerStateBuffering;
            }
        }];
    }
}

#pragma mark    Gesture

- (void)createGesture {
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    self.singleTap.delegate = self;
    self.singleTap.numberOfTouchesRequired = 1;
    self.singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:self.singleTap];
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    self.doubleTap.delegate = self;
    self.doubleTap.numberOfTouchesRequired = 1;
    self.doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:self.doubleTap];
    
    [self.singleTap setDelaysTouchesBegan:YES];
    [self.doubleTap setDelaysTouchesBegan:YES];
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
}

- (void)shrinkPanAction:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:[UIApplication sharedApplication].keyWindow];
    
    MMPlayerView *view = (MMPlayerView *)pan.view;
    
    const CGFloat width = view.frame.size.width;
    const CGFloat height = view.frame.size.height;
    const CGFloat distance = 10;
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (point.x < width/2) { //在屏幕左半边
            point.x = width/2 + distance;
        } else if (point.x > SCREEN_WIDTH - width/2) {
            point.x = SCREEN_WIDTH - width/2 - distance;
        }
        
        if (point.y < height/2) {
            point.y = height/2 + distance;
        } else if (point.y > SCREEN_WIDTH - height/2) {
            point.y = SCREEN_HEIGHT - height/2 - distance;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            view.center = point;
            self.shrinkRightBottomPoint = CGPointMake(SCREEN_WIDTH - CGRectGetMinX(view.frame) - width, SCREEN_HEIGHT - CGRectGetMinY(view.frame) - height);
        }];
    } else {
        view.center = point;
        self.shrinkRightBottomPoint = CGPointMake(SCREEN_WIDTH - CGRectGetMinX(view.frame) - CGRectGetWidth(view.frame), SCREEN_HEIGHT - CGRectGetMinY(view.frame) - CGRectGetHeight(view.frame));
    }
}

- (void)douleTapAction:(UIGestureRecognizer *)gesture {
    if (self.playDidEnd) return;
    
    [self.controlView mm_playerShowControlView];
    if (self.isPauseByUser) [self play];
    else [self pause];
    
    if (!self.isAutoPlay) {
        self.isAutoPlay = YES;
        [self configMMPlayer];
    }
}

- (void)singleTapAction:(UIGestureRecognizer *)tap {
    if ([tap isKindOfClass:[NSNumber class]] && ![(id)tap boolValue]) {
        [self _fullScreenAction];
        return;
    }
    
    if (tap.state == UIGestureRecognizerStateRecognized) {
        if (self.isBottomVideo && !self.isFullScreen) {
            [self _fullScreenAction];
        } else {
            if (self.playDidEnd) {
                return;
            }else {
                [self.controlView mm_playerShowOrHidecontrolView];
            }
        }
    }
}

- (void)doubleTapAction:(UIGestureRecognizer *)tap {
    if (self.playDidEnd) return;
    [self.controlView mm_playerShowControlView];
    if (self.isPauseByUser) [self play];
    else [self pause];
    if (!self.isAutoPlay) {
        self.isAutoPlay = YES;
        [self configMMPlayer];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.isAutoPlay) {
        UITouch *touch = [touches anyObject];
        if (touch.tapCount == 1) {
            [self performSelector:@selector(singleTapAction:) withObject:@(NO)];
        } else if (touch.tapCount == 2) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTapAction:) object:nil];
            [self doubleTapAction:touch.gestureRecognizers.lastObject];
        }
    }
}

- (void)panDirection:(UIPanGestureRecognizer *)pan {
    CGPoint locationPoint = [pan locationInView:self];
    
    /**
     我们要响应水平移动和垂直移动
     根据上次和本次移动的位置，算出一个速率的point
     */
    CGPoint veloctyPoint = [pan velocityInView:self];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) {
                self.panDirection = PanDirectionHorizonMoved;
                
                CMTime time = self.player.currentTime;
                self.sumTime = time.value / time.timescale;
            } else if (x < y) {
                self.panDirection = PanDirectionVerticalMoved;
                if (locationPoint.x > (self.bounds.size.width/2)) {
                    self.isVolume = YES;
                } else {
                    self.isVolume = NO;
                }
            }
        }break;
        case UIGestureRecognizerStateChanged: {
            switch (self.panDirection) {
                case PanDirectionHorizonMoved: {
                    [self horizontalMoved:veloctyPoint.x];
                }  break;
                case PanDirectionVerticalMoved: {
                    [self verticalMoved:veloctyPoint.y];
                } break;
                default: break;
            }
        } break;
        case UIGestureRecognizerStateEnded: {
            switch (self.panDirection) {
                case PanDirectionHorizonMoved: {
                    self.isPauseByUser = NO;
                    [self seekToTime:self.sumTime completion:nil];
                    self.sumTime = 0;
                } break;
                case PanDirectionVerticalMoved: {
                    self.isVolume = NO;
                    break;
                } break;
                default: break;
            }
        } break;
        default: break;
    }
}

- (void)horizontalMoved:(CGFloat)value {
    self.sumTime += value/200;
    
    CMTime total = self.playerItem.duration;
    CGFloat totalMoveDuration = (CGFloat)total.value/total.timescale;
    if (self.sumTime > totalMoveDuration) self.sumTime = totalMoveDuration;
    if (self.sumTime < 0) self.sumTime = 0;
    
    BOOL style = NO;
    if (value > 0) style = YES;
    if (value < 0) style = NO;
    if (value == 0) return;
    
    self.isDragged = YES;
    [self.controlView mm_playerDraggedTime:self.sumTime totalTime:totalMoveDuration isForward:style hasPreview:NO];
}

- (void)verticalMoved:(CGFloat)value {
    self.isVolume ? (self.volumeViewSlider.value -= value/1000) : ([UIScreen mainScreen].brightness -= value/1000);
}

#pragma mark    Orientation

- (void)_fullScreenAction {
    if (MMPlayerShared.isLockScreen) {
        [self unLockTheScreen];
        return;
    }
    
    if (self.isFullScreen) {
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
        self.isFullScreen = NO;
        return;
    } else {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationLandscapeRight) {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        } else {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        }
    }
}

- (void)unLockTheScreen {
    MMPlayerShared.isLockScreen = NO;
    [self.controlView mm_playerLockScreenButtonState:NO];
    self.isLocked = NO;
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationLandscapeRight ||
        orientation == UIInterfaceOrientationLandscapeLeft) {
        [self setOrientationLandscapeConstraint:orientation];
    } else if (orientation == UIInterfaceOrientationPortrait){
        [self setOrientationPortraitConstraint];
    }
}

- (void)setOrientationLandscapeConstraint:(UIInterfaceOrientation)orientation {
    [self toOrientation:orientation];
    self.isFullScreen = YES;
}

- (void)setOrientationPortraitConstraint {
    if (self.isCellVideo) {
        if ([self.scrollView isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)self.scrollView;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.indexPath];
            
            self.isBottomVideo = NO;
            if (![tableView.visibleCells containsObject:cell]) {
                [self updatePlayerViewToBottom];
            } else {
                UIView *fatherView = [cell.contentView viewWithTag:self.playerModel.fatherViewTag];
                [self addPlayerToFatherView:fatherView];
            }
        } else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
            UICollectionView *collectionView = (UICollectionView *)self.scrollView;
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.indexPath];
            self.isBottomVideo = NO;
            if (![collectionView.visibleCells containsObject:cell]) {
                [self updatePlayerViewToBottom];
            } else {
                UIView *fatherView = [cell viewWithTag:self.playerModel.fatherViewTag];
                [self addPlayerToFatherView:fatherView];
            }
        }
    } else {
        [self addPlayerToFatherView:self.playerModel.fatherView];
    }
    
    [self toOrientation:UIInterfaceOrientationPortrait];
    self.isFullScreen = NO;
}

- (void)updatePlayerViewToBottom {
    if (self.isBottomVideo) return;
    self.isBottomVideo = YES;
    if (self.playDidEnd) {
        self.repeatToPlay = NO;
        self.playDidEnd = NO;
        [self resetPlayer];
        return;
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    if (CGPointEqualToPoint(self.shrinkRightBottomPoint, CGPointZero)) {
        self.shrinkRightBottomPoint = CGPointMake(10, self.scrollView.contentInset.bottom + 10);
    } else {
        [self setShrinkRightBottomPoint:self.shrinkRightBottomPoint];
    }
    [self.controlView mm_playerBottomShrinkPlay];
}

- (void)onDeviceOrientationChange {
    /**
     UIDeviceOrientation 与 UIInterfaceOrientation 差别
     相同点都是有水平／横左／横右／反转
     不同的是DeviceOrientation 多了两个屏幕朝上／朝下
     */
    if (!self.player) return;
    if (MMPlayerShared.isLockScreen) return;
    if (self.didEnterBackground) return;
    if (self.playerPushedOrPresented) return;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    
    if (orientation == UIDeviceOrientationFaceUp ||
        orientation == UIDeviceOrientationFaceDown ||
        orientation == UIDeviceOrientationUnknown) {
        return;
    }
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown: break;
        
        case UIInterfaceOrientationPortrait: {
            if (self.isFullScreen) [self toOrientation:UIInterfaceOrientationPortrait];
        } break;
            
        case UIInterfaceOrientationLandscapeLeft: {
            [self toOrientation:UIInterfaceOrientationLandscapeLeft];
            if (self.isFullScreen == NO)    self.isFullScreen = YES;
        } break;
            
        case UIInterfaceOrientationLandscapeRight: {
            [self toOrientation:UIInterfaceOrientationLandscapeRight];
            if (self.isFullScreen == NO) self.isFullScreen = YES;
        } break;
            
        default: break;
    }
}

- (void)toOrientation:(UIInterfaceOrientation)orientation {
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (currentOrientation == orientation) return;
    
    if (orientation != UIInterfaceOrientationPortrait) {
        if (currentOrientation == UIInterfaceOrientationPortrait) {
            [self removeFromSuperview];
            MMBrightnessView *brightnessView = [MMBrightnessView sharedBrightness];
            [[UIApplication sharedApplication].keyWindow insertSubview:self belowSubview:brightnessView];
            self.frame = (CGRect){0, 0, SCREEN_WIDTH, SCREEN_HEIGHT};
        }
    }
    
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.transform = CGAffineTransformIdentity;
    self.transform = [self getTransformRotationAngle];
    [UIView commitAnimations];
}

- (CGAffineTransform)getTransformRotationAngle {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

#pragma mark   Setter

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    self.repeatToPlay = NO;
    self.playDidEnd = NO;
    
    [self addNotifications];
    self.isPauseByUser =YES;
    [self createGesture];
}

- (void)setState:(MMPlayerState)state {
    _state = state;
    
    [self.controlView mm_playerActivity:state == MMPlayerStateBuffering];
    if (state == MMPlayerStatePlaying || state == MMPlayerStateBuffering) {
        [self.controlView mm_playerItemPlaying];
    } else if (state == MMPlayerStateFailed) {
        NSError *error = [self.playerItem error];
        [self.controlView mm_playerItemStatusFailed:error];
    }
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem == playerItem) return;
    
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)setScrollView:(UIScrollView *)scrollView {
    if (_scrollView == scrollView) return;
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:MMPlayerContentOffset];
    }
    _scrollView = scrollView;
    if (scrollView) {
        [scrollView addObserver:self forKeyPath:MMPlayerContentOffset options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)setPlayerLayerGravity:(MMPlayerLayerGravity)playerLayerGravity {
    _playerLayerGravity = playerLayerGravity;
    switch (playerLayerGravity) {
        case MMPlayerLayerGravityResize: {
            self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            self.videoGravity = AVLayerVideoGravityResize;
        } break;
        case MMPlayerLayerGravityResizeAspect: {
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            self.videoGravity = AVLayerVideoGravityResizeAspect;
        } break;
        case MMPlayerLayerGravityResizeAspectFill: {
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.videoGravity = AVLayerVideoGravityResizeAspectFill;
        } break;
        default: break;
    }
}

- (void)setHasDownload:(BOOL)hasDownload {
    _hasDownload = hasDownload;
    [self.controlView mm_playerHasDownLoadFunction:hasDownload];
}

- (void)setResolutionDic:(NSDictionary *)resolutionDic {
    _resolutionDic = resolutionDic;
    self.videoURLArray = [resolutionDic allValues];
}

- (void)setControlView:(UIView *)controlView {
    if (_controlView) return;
    _controlView = controlView;
    controlView.delegate = self;
    [self addSubview:controlView];
    controlView.frame = self.bounds;
}

- (void)setPlayerModel:(MMPlayerModel *)playerModel {
    _playerModel = playerModel;
    
    if (playerModel.seekTime) self.seekTime = playerModel.seekTime;
    [self.controlView mm_playerModel:playerModel];
    
    if (playerModel.resolutionDic) self.resolutionDic = playerModel.resolutionDic;
    
    if (playerModel.scrollView && playerModel.indexPath && playerModel.videoURL) {
        NSCAssert(playerModel.fatherViewTag, @"请指定playviews所在fatherViewTag");
        [self cellVideoWithScrollView:playerModel.scrollView atIndexPath:playerModel.indexPath];
        if ([self.scrollView isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)playerModel.scrollView;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:playerModel.indexPath];
            UIView *fatherView = [cell.contentView viewWithTag:playerModel.fatherViewTag];
            [self addPlayerToFatherView:fatherView];
        } else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
            UICollectionView *collectionView = (UICollectionView *)playerModel.scrollView;
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:playerModel.indexPath];
            UIView *fatherView = [cell.contentView viewWithTag:playerModel.fatherViewTag];
            [self addPlayerToFatherView:fatherView];
        }
    } else {
        NSCAssert(playerModel.fatherView, @"请指定playerView的fatherView");
        [self addPlayerToFatherView:playerModel.fatherView];
    }
    self.videoURL = playerModel.videoURL;
}

- (void)setShrinkRightBottomPoint:(CGPoint)shrinkRightBottomPoint {
    _shrinkRightBottomPoint = shrinkRightBottomPoint;
    CGFloat width = SCREEN_WIDTH * 0.5 - 20;
    CGFloat height = (self.bounds.size.height / self.bounds.size.width);
    self.width = width;
    self.height = height;
    self.bottom = -shrinkRightBottomPoint.y;
    self.left = -shrinkRightBottomPoint.x - width;
}

- (void)setPlayerPushedOrPresented:(BOOL)playerPushedOrPresented {
    _playerPushedOrPresented = playerPushedOrPresented;
    if (playerPushedOrPresented) {
        [self pause];
    } else {
        [self play];
    }
}

#pragma mark    Getter

- (AVAssetImageGenerator *)imageGenerator {
    if (!_imageGenerator) {
        _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.urlAsset];
    }
    return _imageGenerator;
}

- (MMBrightnessView *)brightnessView {
    if (!_brightnessView) {
        _brightnessView = [MMBrightnessView sharedBrightness];
    }
    return _brightnessView;
}

- (NSString *)videoGravity {
    if (!_videoGravity) {
        _videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return _videoGravity;
}


#pragma mark    MMPlayerControlViewDelegate
- (void)mm_controlView:(UIView *)controlView backAction:(UIButton *)backBtn {
    if (MMPlayerShared.isLockScreen) {
        [self unLockTheScreen];
    } else {
        if (!self.isFullScreen) {
            [self pause];
            if ([self.delegate respondsToSelector:@selector(mm_playerBackAction)]) {
                [self.delegate mm_playerBackAction];
            }
        } else {
            [self interfaceOrientation:UIInterfaceOrientationPortrait];
        }
    }
}
- (void)mm_controlView:(UIView *)controlView closeAction:(UIButton *)closeBtn {
    [self resetPlayer];
    [self removeFromSuperview];
}

- (void)mm_controlView:(UIView *)controlView playAction:(UIButton *)playBtn {
    self.isPauseByUser = !self.isPauseByUser;
    if (self.isPauseByUser) {
        [self pause];
        if (self.state == MMPlayerStatePlaying) self.state = MMPlayerStatePause;
    } else {
        [self play];
        if (self.state == MMPlayerStatePause) self.state = MMPlayerStatePlaying;
    }
    
    if (!self.isAutoPlay) {
        self.isAutoPlay = YES;
        [self configMMPlayer];
    }
}

- (void)mm_controlView:(UIView *)controlView fullScreenAction:(UIButton *)fullScreenBtn {
    [self _fullScreenAction];
}

- (void)mm_controlView:(UIView *)controlView lockScreenAction:(UIButton *)lockScreenBtn {
    self.isLocked = lockScreenBtn.selected;
    MMPlayerShared.isLockScreen = lockScreenBtn.selected;
}

- (void)mm_controlView:(UIView *)controlView repeatPlayAction:(UIButton *)repeatPlayBtn {
    self.playDidEnd = NO;
    self.repeatToPlay = NO;
    [self seekToTime:0 completion:nil];
    
    //根据路径来判断是否是缓冲数据
    if ([self.videoURL.scheme isEqualToString:@"file"]) {
        self.state = MMPlayerStatePlaying;
    } else {
        self.state = MMPlayerStateBuffering;
    }
}

- (void)mm_controlView:(UIView *)controlView centerPlayAction:(UIButton *)centerPlayBtn {
    [self configMMPlayer];
}

- (void)mm_controlView:(UIView *)controlView failAction:(UIButton *)failBtn {
    [self configMMPlayer];
}

- (void)mm_controlView:(UIView *)controlView downloadVideoAction:(UIButton *)downloadBtn {
    NSString *urlString = self.videoURL.absoluteString;
    if ([self.delegate respondsToSelector:@selector(mm_playerDownload:)]) {
        [self.delegate mm_playerDownload:urlString];
    }
}

- (void)mm_controlView:(UIView *)controlView resolutionAction:(UIButton *)resolutionBtn {
    NSInteger currentTime = (NSInteger)CMTimeGetSeconds(self.player.currentTime);
    NSString *videoString = self.videoURLArray[resolutionBtn.tag - 200];
    NSURL *videoURL = [NSURL URLWithString:videoString];
    if ([videoURL isEqual:self.videoURL]) return;
    
    self.isChangeResolution = YES;
    [self resetToPlayNewURL];
    
    self.videoURL = videoURL;
    self.seekTime = currentTime;
    
    [self autoPlayTheVideo];
}

- (void)mm_controlView:(UIView *)controlView progressSliderTap:(CGFloat)value {
    NSLog(@"进度条点击total---%lld, timeScale---%d",self.playerItem.duration.value, self.playerItem.duration.timescale);
    CGFloat total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
    
    NSInteger dragedSecend = floor(total * value);
    [self.controlView mm_playerPlayButtonState:YES];
    [self seekToTime:dragedSecend completion:nil];
}

- (void)mm_controlView:(UIView *)controlView progressSliderTouchBegan:(UISlider *)slider {
    
}

- (void)mm_controlView:(UIView *)controlView progressSliderValueChanged:(UISlider *)slider {
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        self.isDragged = YES;
        
        BOOL style = NO;
        CGFloat value = slider.value - self.sliderLastValue;
        if (value > 0) style = YES;
        if (value < 0) style = NO;
        if (value == 0) return;
        
        self.sliderLastValue = slider.value;
        
        CGFloat total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
        CGFloat draggedSecond = floor(total * slider.value);
        
        CMTime dragCMTime = CMTimeMake(draggedSecond, 1);
        [controlView mm_playerDraggedTime:draggedSecond totalTime:total isForward:style hasPreview:self.isFullScreen ? self.hasPreviewView : NO];
        
        if (total > 0) { //总时长大于0时可以拖动
            if (self.isFullScreen && self.hasPreviewView) {
                [self.imageGenerator cancelAllCGImageGeneration];
                self.imageGenerator.appliesPreferredTrackTransform = YES;
                self.imageGenerator.maximumSize = CGSizeMake(100, 56);
                
                AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
                    NSLog(@"%zd", error);
                    if (result != AVAssetImageGeneratorSucceeded) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                        [controlView mm_playerDraggedTime:draggedSecond sliderImage:self.thumbImage ?: MMPlayerImage(@"MMPlayer_loading_bgView")];
                        });
                    } else {
                        self.thumbImage = [UIImage imageWithCGImage:image];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [controlView mm_playerDraggedTime:draggedSecond sliderImage:self.thumbImage ?: MMPlayerImage(@"MMPlayer_loading_bgView")];
                        });
                    }
                };
                [self.imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:dragCMTime]]
                                                          completionHandler:handler];
            }
        } else {
            slider.value = 0;
        }
    } else {
        slider.value = 0;
    }
}

- (void)mm_controlView:(UIView *)controlView progressSliderTouchEnded:(UISlider *)slider {
    if (self.player.currentItem.status == AVPlayerStatusReadyToPlay) {
        self.isPauseByUser = NO;
        self.isDragged = NO;
        
        CGFloat total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
        NSInteger draggedSeconds = floor(total * slider.value);
        [self seekToTime:draggedSeconds completion:nil];
    }
}

- (void)mm_controlViewWillShow:(UIView *)controlView isFullScreen:(BOOL)fullScreen {
    if ([self.delegate respondsToSelector:@selector(mm_playerControlViewWillShow:isFullScreen:)]) {
        [self.delegate mm_playerControlViewWillShow:controlView isFullScreen:fullScreen];
    }
}

- (void)mm_controlViewWillHidden:(UIView *)controlView isFullScreen:(BOOL)fullScreen {
    if ([self.delegate respondsToSelector:@selector(mm_playerControlViewWillHidden:isFullScreen:)]) {
        [self.delegate mm_playerControlViewWillHidden:controlView isFullScreen:fullScreen];
    }
}

#pragma mark    Notifications
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterForeground)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    //耳机插入／拔出通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioRouteRemoveListener:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStatusBarOrientationChange)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)appDidEnterBackground {
    self.didEnterBackground = YES;
    MMPlayerShared.isLockScreen = YES;
    
    [_player pause];
    self.state = MMPlayerStatePause;
}

- (void)appDidEnterForeground {
    self.didEnterBackground = NO;
    MMPlayerShared.isLockScreen = self.isLocked;
    if (!self.isPauseByUser) {
        self.state = MMPlayerStatePlaying;
        self.isPauseByUser = NO;
        [self play];
    }
}

//耳机插拔事件回调
- (void)audioRouteRemoveListener:(NSNotification *)noti {
    NSDictionary *dic = noti.userInfo;
    
    NSInteger routeChangeReason = [[dic valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable: break;  //耳机插入
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {     //耳机拔出
            [self play];
        } break;
        case AVAudioSessionRouteChangeReasonCategoryChange: {
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
        } break;
        default: break;
    }
}

- (void)onStatusBarOrientationChange {
    if (!self.didEnterBackground) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (orientation == UIInterfaceOrientationPortrait) {
            [self setOrientationPortraitConstraint];
            
            if (self.cellPlayerOnCenter) {
                if ([self.scrollView isKindOfClass:[UITableView class]]) {
                    UITableView *tableView = (UITableView *)self.scrollView;
                    [tableView scrollToRowAtIndexPath:self.indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                } else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
                    UICollectionView *collection = (UICollectionView *)self.scrollView;
                    [collection scrollToItemAtIndexPath:self.indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                }
            }
            
            [self.brightnessView removeFromSuperview];
            [[UIApplication sharedApplication].keyWindow addSubview:self.brightnessView];
            
            self.brightnessView.frame = (CGRect){(SCREEN_HEIGHT - 155)/2, (SCREEN_WIDTH - 155)/2, 155, 155};
        } else {
            if (orientation == UIInterfaceOrientationLandscapeRight) {
                [self toOrientation:UIInterfaceOrientationLandscapeRight];
            } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
            }
            
            [self.brightnessView removeFromSuperview];
            [self addSubview:self.brightnessView];
            self.brightnessView.center = self.center;
            self.brightnessView.width = 155;
            self.brightnessView.height = 155;
        }
    }
}

- (void)moviePlayDidEnd:(NSNotification *)noti {
    self.state = MMPlayerStateStopped;
    if (self.isBottomVideo && !self.isFullScreen) { //播放完了，如果是在小屏模式 && 在bottom位置，直接关闭播放器
        self.repeatToPlay = NO;
        self.playDidEnd = NO;
        [self resetPlayer];
    } else {
        if (!self.isDragged) { //如果不是拖拽中，直接结束播放
            self.playDidEnd = YES;
            [self.controlView mm_playerPlayEnd];
        }
    }
}

@end
#pragma clang diagnostic pop

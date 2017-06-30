//
//  MMVideoPlayerController.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/30.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMVideoPlayerController.h"
#import "MMImagePickerController.h"
#import "MMPhotoPreviewCell.h"
#import "MMImagePickManager.h"
#import "MMAssetModel.h"
#import "MMImagePickerMacro.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@interface MMVideoPlayerController () {
    UIView *_toolBar;
    UIButton *_doneButton;
    UIProgressView *_progress;
    
    UIStatusBarStyle _originalStatuBarStyle;
    
    AVPlayer *_player;
    UIButton *_playButton;
    UIImage *_cover;
}

@end

@implementation MMVideoPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    if (nav) self.navigationItem.title = nav.previewButtonTitle;
    
    [self configMoviePlayer];
}

#pragma makr    Life-Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originalStatuBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = kiOS7Later ? UIStatusBarStyleLightContent : UIStatusBarStyleBlackOpaque;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originalStatuBarStyle;
}

- (void)configMoviePlayer {
    [[MMImagePickManager manager] getPhotoWithAsset:_model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        _cover = photo;
    }];
 
    [[MMImagePickManager manager] getVideoWithAsset:_model.asset completion:^(AVPlayerItem *playItem, NSDictionary *info) {
       dispatch_async(dispatch_get_main_queue(), ^{
           _player = [AVPlayer playerWithPlayerItem:playItem];
           AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
           playerLayer.frame = self.view.bounds;
           
           [self.view.layer addSublayer:playerLayer];
           [self addProgressObserver];
           [self configPlayButton];
           [self configBottomToolBar];
           
           [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNav) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
       });
    }];
}

- (void)configPlayButton {
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton.frame = CGRectMake(0, 64, self.view.width, self.view.height - 64 - 44);
    [_playButton setImage:[UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlay.png"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlayHL.png"] forState:UIControlStateHighlighted];
    [_playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
}

- (void)configBottomToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
    CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(self.view.width - 44 - 12, 0, 44, 44);
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    if (nav) {
        [_doneButton setTitle:nav.doneButtonTitle forState:UIControlStateNormal];
        [_doneButton setTitleColor:nav.okButtonTitleColorNormal forState:UIControlStateNormal];
    } else {
        [_doneButton setTitle:[NSBundle mm_localizedStringForKey:@"Done"] forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0] forState:UIControlStateNormal];
    }
    [_toolBar addSubview:_doneButton];
    [self.view addSubview:_toolBar];
}

- (void)addProgressObserver {
    AVPlayerItem *item = _player.currentItem;
    UIProgressView *progress = _progress;
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds([item duration]);
        if (current) [progress setProgress:(current/total) animated:YES];
    }];
}

#pragma mark    Click-Event

- (void)doneButtonClick {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    if (nav) {
        if (nav.autoDismiss) [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    }
}

- (void)playButtonClick {
    CMTime currentTime = _player.currentItem.currentTime;
    CMTime durationTime = _player.currentItem.duration;
    if (_player.rate == 0.0f) {
        if (currentTime.value == durationTime.value) [_player.currentItem seekToTime:CMTimeMake(0, 1)];
        self.navigationController.navigationBarHidden = YES;
        [_playButton setImage:nil forState:UIControlStateNormal];
        if (kiOS7Later) [UIApplication sharedApplication].statusBarHidden = YES;
        _toolBar.hidden = YES;
        [_player play];
    } else {
        [self pausePlayerAndShowNav];
    }
}

- (void)callDelegateMethod {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    
    if ([nav.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingVideo:sourceAssets:)]) {
        [nav.pickerDelegate imagePickerController:nav didFinishPickingVideo:_cover sourceAssets:_model.asset];
    }
    if (nav.didFinishPickVideoHandle) nav.didFinishPickVideoHandle(_cover, _model.asset);
}

#pragma mark    Notification
- (void)pausePlayerAndShowNav {
    [_player pause];
    _toolBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
    [_playButton setImage:[UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlay.png"] forState:UIControlStateNormal];
    if (kiOS7Later) [UIApplication sharedApplication].statusBarHidden = NO;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
#pragma clang diagnostic pop

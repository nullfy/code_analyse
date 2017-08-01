//
//  MMPlayerView.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/31.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPlayer.h"

@protocol MMPlayerDelegate <NSObject>

@optional
- (void)mm_playerBackAction;
- (void)mm_playerDownload:(NSString *)url;
- (void)mm_playerControlViewWillShow:(UIView *)controlView isFullScreen:(BOOL)fullScreen;
- (void)mm_playerControlViewWillHidden:(UIView *)controlView isFullScreen:(BOOL)fullScreen;

@end

typedef NS_ENUM(NSUInteger, MMPlayerLayerGravity) {
    MMPlayerLayerGravityResize,
    MMPlayerLayerGravityResizeAspect,
    MMPlayerLayerGravityResizeAspectFill
};

typedef NS_ENUM(NSUInteger, MMPlayerState) {
    MMPlayerStateFailed,
    MMPlayerStateBuffering,
    MMPlayerStatePlaying,
    MMPlayerStateStopped,
    MMPlayerStatePause
};

@interface MMPlayerView : UIView

@property (nonatomic, assign) MMPlayerLayerGravity playerLayerGravity;
@property (nonatomic, assign) BOOL hasDownload;
@property (nonatomic, assign) BOOL hasPreviewView;
@property (nonatomic, weak) id<MMPlayerDelegate> delegate;
@property (nonatomic, readonly, assign) BOOL isPauseByUser;
@property (nonatomic, assign) BOOL mute;
@property (nonatomic, assign) BOOL stopPlayWhileCellNotVisiable;
@property (nonatomic, assign) BOOL cellPlayerOnCenter;
@property (nonatomic, assign) BOOL playerPushedOrPresented;

+ (instancetype)sharedPlayerView;
- (void)playerControlView:(UIView *)controlView playerModel:(MMPlayerModel *)model;
- (void)playerModel:(MMPlayerModel *)model;
- (void)autoPlayTheVideo;
- (void)resetPlayer;
- (void)resetToPlayNewVideo:(MMPlayerModel *)model;
- (void)play;
- (void)pause;

@end

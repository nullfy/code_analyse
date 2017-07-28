//
//  UIView+MMPlayer.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPlayerControlViewDelegate.h"


@class MMPlayerModel, MMVideoPlayerController;
@interface UIView (MMPlayer)

@property (nonatomic, weak) id<MMPlayerControlViewDelegate> delegate;
- (void)mm_playerModel:(MMPlayerModel *)model; //设置播放模型
- (void)mm_playerShowOrHidecontrolView;

- (void)mm_playerShowControlView;//显示控制层
- (void)mm_playerHideControlView;//隐藏控制层

- (void)mm_playerResetControlView;//重置controlView

- (void)mm_playerResetControlViewForResolution;//切换分辨率时重置ControlView

- (void)mm_playerCancleAutoFadeOutcontrolView;//取消自动隐藏控制层View

- (void)mm_playerItemPlaying;//开始播放

- (void)mm_playerPlayEnd;//播放完了

- (void)mm_playerHasDownLoadFunction:(BOOL)sender;//是否有下载功能

- (void)mm_playerResolutionArray:(NSArray *)resolutionArray;//是否有切换分辨率

- (void)mm_playerPlayButtonState:(BOOL)state;//播放按钮状态

- (void)mm_playerLockScreenButtonState:(BOOL)state;//锁定屏幕

- (void)mm_playerDownloadButtonState:(BOOL)state;//下载按钮状态

- (void)mm_playerActivity:(BOOL)animated;//加载的菊花

- (void)mm_playerDraggedTime:(NSInteger)draggedTime sliderImage:(UIImage *)image;//设置预览图
- (void)mm_playerDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forward hasPreview:(BOOL)preview;//拖拽快进／快退

- (void)mm_playerDraggedEnd;//滑动调整进度结束

- (void)mm_playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value;//正常播放

- (void)mm_playerSetProgress:(CGFloat)progress;//progress 显示缓冲进度

- (void)mm_playerItemStatusFailed:(NSError *)error;//视频加载失败

- (void)mm_playerBottomShrinkPlay;//小屏播放

- (void)mm_playerCellPlay;//cell 播放

@end

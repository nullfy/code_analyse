//
//  MMPlayerControlViewDelegate.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#ifndef MMPlayerControlViewDelegate_h
#define MMPlayerControlViewDelegate_h

@protocol MMPlayerControlViewDelegate <NSObject>

@optional
- (void)mm_controlView:(UIView *)controlView backAction:(UIButton *)backBtn;
- (void)mm_controlView:(UIView *)controlView closeAction:(UIButton *)closeBtn;
- (void)mm_controlView:(UIView *)controlView playAction:(UIButton *)playBtn;
- (void)mm_controlView:(UIView *)controlView fullScreenAction:(UIButton *)fullScreenBtn;
- (void)mm_controlView:(UIView *)controlView lockScreenAction:(UIButton *)lockScreenBtn;
- (void)mm_controlView:(UIView *)controlView repeatPlayAction:(UIButton *)repeatPlayBtn;
- (void)mm_controlView:(UIView *)controlView centerPlayAction:(UIButton *)centerPlayBtn;
- (void)mm_controlView:(UIView *)controlView failAction:(UIButton *)failBtn;
- (void)mm_controlView:(UIView *)controlView downloadVideoAction:(UIButton *)downloadBtn;
- (void)mm_controlView:(UIView *)controlView resolutionAction:(UIButton *)resolutionBtn;
- (void)mm_controlView:(UIView *)controlView progressSliderTap:(CGFload)value;
- (void)mm_controlView:(UIView *)controlView progressSliderTouchBegan:(UISlider *)slider;
- (void)mm_controlView:(UIView *)controlView progressSliderTouchEnded:(UISlider *)slider;
- (void)mm_controlViewWillShow:(UIView *)controlView isFullScreen:(BOOL)fullScreen;
- (void)mm_controlViewWillHidden:(UIView *)controlView isFullScreen:(BOOL)fullScreen;

@end

#endif /* MMPlayerControlViewDelegate_h */

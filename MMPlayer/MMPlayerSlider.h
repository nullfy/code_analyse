//
//  MMPlayerSlider.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASValuePopUpView.h"

@class MMPlayerSlider;
@protocol MMPlayerTrackingSliderDelegate <NSObject>

- (void)sliderWillDisplayPopUpView:(MMPlayerSlider *)slider;

@optional
- (void)sliderWillHidePopUpView:(MMPlayerSlider *)slider;
- (void)sliderDidHidePopUpView:(MMPlayerSlider *)slider;

@end

@interface MMPlayerSlider : UISlider

@property (nonatomic, strong) UIColor *popUpViewColor;
@property (nonatomic, strong) NSArray *popUpViewAnimatedColors;

@property (nonatomic, readonly, strong) ASValuePopUpView *popUpView;

@property (nonatomic, assign) CGFloat popUpViewCornerRadius;
@property (nonatomic, assign) CGFloat popUpViewArrowLength;
@property (nonatomic, assign) CGFloat popUpViewWidthPaddingFactor;
@property (nonatomic, assign) CGFloat popUpViewHeightPaddingFactor;

@property (nonatomic, assign) BOOL autoAdjustTrackColor;
@property (nonatomic, weak) id<MMPlayerTrackingSliderDelegate> delegate;

- (void)setText:(NSString *)text;
- (void)setImage:(UIImage *)image;

- (void)showPopUpViewAnimated:(BOOL)animated;
- (void)hidePopUpViewAnimated:(BOOL)animated;

- (void)setPopUpViewAnimatedColors:(NSArray *)popUpViewAnimatedColors withPositions:(NSArray *)positions;
@end

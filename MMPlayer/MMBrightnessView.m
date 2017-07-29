//
//  MMBrightnessView.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/28.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMBrightnessView.h"
#import "MMPlayer.h"

@interface MMBrightnessView ()

@property (nonatomic, strong) UIImageView *backImage;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIView *longView;
@property (nonatomic, strong) NSMutableArray *tipArray;
@property (nonatomic, assign) BOOL orientationDidChange;

@end

@implementation MMBrightnessView

+ (instancetype)sharedBrightness {
    static MMBrightnessView *view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view = [[self class] init];
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    });
    return view;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5, 155, 155);
        
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        UIToolbar *tool = [[UIToolbar alloc] initWithFrame:self.bounds];
        tool.alpha = 0.97;
        [self addSubview:tool];
        
        self.backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 79, 76)];
        self.backImage.image = MMPlayerImage(@"MMPlayer_brightness");
        [self addSubview:self.backImage];
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30)];
        self.title.font = [UIFont systemFontOfSize:16];
        self.title.textColor = RGBA(0.25f, 0.22f, 0.21f, 1.0f);
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.text = @"亮度";
        [self addSubview:self.title];
        
        self.longView = [[UIView alloc] initWithFrame:CGRectMake(13, 132, self.bounds.size.width - 26, 7)];
        self.longView.backgroundColor = RGBA(0.25f, 0.22f, 0.21f, 1.0f);
        [self addSubview:self.longView];
        
        [self createTips];
        [self addNotification];
        [self addObserver];
        
        self.alpha = 0.0;
    }
    return self;
}

- (void)createTips {
    self.tipArray = @[].mutableCopy;
    
    CGFloat width = (CGRectGetWidth(_longView.frame) - 17) / 16;
    CGFloat height = 5;
    CGFloat tipY = 1;
    for (NSInteger i = 0 ; i < 16; i++) {
        CGFloat tipX = i * (width + 1) + 1;
        UIImageView *image = [UIImageView new];
        image.backgroundColor = [UIColor whiteColor];
        image.frame = (CGRect){tipX, tipY, width, height};
        
        [self.longView addSubview:image];
        [self.tipArray addObject:image];
    }
    
    [self updateLongView:[UIScreen mainScreen].brightness];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLayer:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)addObserver {
    [[UIScreen mainScreen] addObserver:self
                            forKeyPath:@"brightness"
                               options:NSKeyValueObservingOptionNew
                               context:NULL];
}

- (void)updateLongView:(CGFloat)sound {
    CGFloat stage = 1 / 50.0;
    NSInteger level = sound / stage;
    
    for (NSInteger i = 0 ; i < self.tipArray.count; i++) {
        UIImageView *image = self.tipArray[i];
        if (i <= level) {
            image.hidden = NO;
        } else {
            image.hidden = YES;
        }
    }
}

- (void)updateLayer:(NSNotification *)noti {
    self.orientationDidChange = YES;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    CGFloat sound = [change[@"new"] floatValue];
    [self appearSoundView];
    [self updateLongView:sound];
}

- (void)appearSoundView {
    if (self.alpha == 0.0) {
        self.orientationDidChange = NO;
        self.alpha = 1.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self disappearSoundView];
        });
    }
}

- (void)disappearSoundView {
    if (self.alpha == 1.0) {
        [UIView animateWithDuration:0.8 animations:^{
            self.alpha = 0.0;
        }];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backImage.center = CGPointMake(155 * 0.5, 155 * 0.5);
    self.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5);
}

- (void)dealloc {
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)setIsStatusBarHidden:(BOOL)isStatusBarHidden {
    _isStatusBarHidden = isStatusBarHidden;
    [[UIWindow mmplayer_currentViewController] setNeedsStatusBarAppearanceUpdate];
}

- (void)setIsLandscape:(BOOL)isLandscape {
    _isLandscape = isLandscape;
    [[UIWindow mmplayer_currentViewController] setNeedsStatusBarAppearanceUpdate];
}



@end

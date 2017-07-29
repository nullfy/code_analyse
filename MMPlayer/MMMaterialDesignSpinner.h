//
//  MMMaterialDesignSpinner.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double MMMaterialDesignSpinnerVersionNumber;

FOUNDATION_EXPORT const unsigned char MMMaterialDesignSpinnerVersionString[];

@interface MMMaterialDesignSpinner : UIView

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) BOOL hiddenWhenStopped;

@property (nonatomic, strong) CAMediaTimingFunction *timmingFunction;
@property (nonatomic, assign, readonly) BOOL isAnimating;
@property (nonatomic, assign) NSTimeInterval duration;


- (void)setAnimating:(BOOL)animate;

- (void)startAnimating;

- (void)stopAnimating;
@end

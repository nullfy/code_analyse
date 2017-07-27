//
//  UIApplication+MMPlayer.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/27.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (MMPlayer)

@property (nonatomic, readonly, strong) NSMutableDictionary *mm_cacheFailTimes;

- (UIImage *)mm_cacheImageForRequest:(NSURLRequest *)request;

- (void)mm_cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request;

- (void)mm_cacheFailRequest:(NSURLRequest *)request;

- (NSUInteger)mm_failTimesForRequest:(NSURLRequest *)request;

@end

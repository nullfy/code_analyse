//
//  MMLaunchMeasure.m
//  PracticeKit
//
//  Created by 李晓东 on 2018/1/19.
//  Copyright © 2018年 Xiaodong. All rights reserved.
//

#import "MMLaunchMeasure.h"
#import <mach/mach_time.h>

static uint64_t loadTime;
static uint64_t applicationRespondedTime = -1;
static mach_timebase_info_data_t timebaseInfo;

static inline NSTimeInterval MachTimeToSecondes(uint64_t machTime) {
    return ((machTime / 1e9) * timebaseInfo.numer)/timebaseInfo.denom;
}

@implementation MMLaunchMeasure

+ (void)load {
    loadTime = mach_absolute_time();
    mach_timebase_info(&timebaseInfo);
    
    @autoreleasepool {
        __block id<NSObject> obs;
        obs = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                                object:nil
                                                                 queue:nil
                                                            usingBlock:^(NSNotification * _Nonnull note) {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    applicationRespondedTime = mach_absolute_time();
                                                                    NSLog(@"StartupMeasure: it took %f secondes until the app could respond to user interaction", MachTimeToSecondes(applicationRespondedTime - loadTime));
                                                                    [[NSNotificationCenter defaultCenter] removeObserver:obs];
                                                                });
                                                            }];
    }
    
}


@end










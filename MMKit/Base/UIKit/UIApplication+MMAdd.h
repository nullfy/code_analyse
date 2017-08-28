//
//  UIApplication+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/12/3.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIApplication (MMAdd)

@property (nonatomic, readonly) NSURL *documentsURL;
@property (nonatomic, readonly) NSString *documentsPath;

@property (nonatomic, readonly) NSURL *cachesURL;
@property (nonatomic, readonly) NSString *cachesPath;

@property (nonatomic, readonly) NSURL *libaryURL;
@property (nonatomic, readonly) NSString *libaryPath;

@property (nonatomic, readonly, nullable) NSString *appBundleName;
@property (nonatomic, readonly, nullable) NSString *appVersion;
@property (nonatomic, readonly, nullable) NSString *appBuildVersion;
@property (nonatomic, readonly, nullable) NSString *appBundleID;
@property (nonatomic, readonly) BOOL isPirated;
@property (nonatomic, readonly) BOOL isBeingDebugged;
@property (nonatomic, readonly) int64_t memoryUsage;
@property (nonatomic, readonly) float cpuUsage;


- (void)incrementNetworkActivityCount;

- (void)decrementNetworkActivityCount;

+ (BOOL)isAppExtension;

+ (nullable UIApplication *)sharedExtensionApplication;


@end
NS_ASSUME_NONNULL_END

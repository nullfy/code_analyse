//
//  UIDevice+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/12/2.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, MMNetworkTrafficType) {
    MMNetworkTrafficTypeWWANSent        = 1 << 0,
    MMNetworkTrafficTypeWWANReceived    = 1 << 1,
    MMNetworkTrafficTypeWIFISent        = 1 << 2,
    MMNetworkTrafficTypeWIFIReceived    = 1 << 3,
    MMNetworkTrafficTypeAWDLSent = 1 << 4,
    MMNetworkTrafficTypeAWDLReceived = 1 << 5,
    
    MMNetworkTrafficTypeWWAN = MMNetworkTrafficTypeWWANSent | MMNetworkTrafficTypeWWANReceived,
    MMNetworkTrafficTypeWIFI = MMNetworkTrafficTypeWIFISent | MMNetworkTrafficTypeWIFIReceived,
    MMNetworkTrafficTypeAWDL = MMNetworkTrafficTypeAWDLSent | MMNetworkTrafficTypeAWDLReceived,
    
    MMNetworkTrafficTypeALL = MMNetworkTrafficTypeWWAN | MMNetworkTrafficTypeWIFI | MMNetworkTrafficTypeAWDL,
};

/**
 获取设备信息 常见于2011-2012年间的博客
 
 */

@interface UIDevice (MMAdd)

#pragma mark    Device Information      设备信息

+ (double)systemVersion;

@property (nonatomic, readonly) BOOL isPad;

@property (nonatomic, readonly) BOOL isSimulator;

@property (nonatomic, readonly) BOOL isJailbroken;

@property (nonatomic, readonly) BOOL canMakePhoneCalls NS_EXTENSION_UNAVAILABLE_IOS("");

@property (nonatomic, readonly) NSString *machineModel;

@property (nonatomic, readonly) NSString *machineModelName;

@property (nonatomic, readonly) NSDate *systemUptime;


#pragma mark    Network Infomation

@property (nullable, nonatomic, readonly) NSString *ipAddressWIFI;

@property (nullable, nonatomic, readonly) NSString *ipAddressCell;

- (uint64_t)getNetworkTrafficBytes:(MMNetworkTrafficType)types;


#pragma mark    Disk Space  磁盘空间

@property (nonatomic, readonly) int64_t diskSpace;

@property (nonatomic, readonly) int64_t diskSpaceFree;

@property (nonatomic, readonly) int64_t diskSpaceUsed;


#pragma mark    Memeory Info    内存信息

@property (nonatomic, readonly) int64_t memoryTotal;

@property (nonatomic, readonly) int64_t memoryUsed;

@property (nonatomic, readonly) int64_t memoryFree;

@property (nonatomic, readonly) int64_t memoryActive;

@property (nonatomic, readonly) int64_t memoryInactive;

@property (nonatomic, readonly) int64_t memoryWired;

@property (nonatomic, readonly) int64_t memoryPurgable;


#pragma mark    CPU Info    CPU信息

@property (nonatomic, readonly) NSUInteger cpuCount;

@property (nonatomic, readonly) float cpuUsage;

@property (nullable, nonatomic, readonly) NSArray<NSNumber *> *cpuUsagePerProcessor;

@end

NS_ASSUME_NONNULL_END



#ifndef kSystemViewsion
#define kSystemView [UIDevice systemVersion]
#endif

#ifndef kiOS10Later
#define kiOS10Later (kSystemVion >= 10)
#endif

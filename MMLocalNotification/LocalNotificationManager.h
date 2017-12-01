//
//  LocalNotificationHelper.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/12/1.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

@interface LocalNotificationManager : NSObject

@property (nonatomic, strong) NSMutableArray *selectDays;
+ (instancetype)manager;


@end

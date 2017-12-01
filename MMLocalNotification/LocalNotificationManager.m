//
//  LocalNotificationHelper.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/12/1.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "LocalNotificationManager.h"

@implementation LocalNotificationManager

+ (instancetype)manager {
    static LocalNotificationManager *tmp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tmp = [[self alloc] init];
        
    });
    return tmp;
}

- (void)clearAllNotification {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        for (UNNotificationRequest *request in requests) {
            NSLog(@"----%@----%@",request.content.body, [(UNCalendarNotificationTrigger *)(request.trigger) nextTriggerDate]);
        }
    }];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    
    UIApplication *application = [UIApplication sharedApplication];
    
    NSArray *localNotifications = [application scheduledLocalNotifications];
    for (UILocalNotification *local in localNotifications) {
        NSLog(@"启动时间:%@--重复类型:%ld==提示:%@\n",local.fireDate,(unsigned long)local.repeatInterval,local.alertBody);
    }
    [application cancelAllLocalNotifications];
#endif

}

- (void)openMessageNotificationServiceWithBlock:(void(^)(BOOL isOpen))returnBlock {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        if (returnBlock) {
            returnBlock(settings.authorizationStatus == UNAuthorizationStatusAuthorized);
        }
    }];
    //    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    //    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
    //                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
    //                              if (returnBlock) returnBlock(granted);
    //                          }];
    
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    returnBlock([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]);
#else
    UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (returnBlock) {
        returnBlock(type != UIRemoteNotificationTypeNone);
    }
#endif
}

- (void)showSettingPushAlertToController:(UIViewController *)controller {
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"提示" message:@"你已关闭通知推送权限,请点击去设置->通知->允许通知" preferredStyle:UIAlertControllerStyleAlert];
    [aler addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
    [aler addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }]];
    [controller presentViewController:aler animated:YES completion:NULL];
}

- (void)registerPunch {
    NSSet *categories;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    UNNotificationAction *action = [UNNotificationAction actionWithIdentifier:@"WODAOA_ACTION_ID" title:@"WODAOA_ACTION_TITLE" options:UNNotificationActionOptionForeground];
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"WODAOA_UN_CATEGORY" actions:@[action] intentIdentifiers:@[@"WODAOA_UN_INTENT_ID"] options:UNNotificationCategoryOptionCustomDismissAction];
    categories = [NSSet setWithObject:category];
    //iOS 10
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"request authorization succeeded!");
        }
    }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    //
    UIMutableUserNotificationAction *acceptAction = [UIMutableUserNotificationAction new];
    acceptAction.identifier = @"WODAOA_ACCEPT_IDENTIFIER";
    acceptAction.title = @"WODAOA_Accept";
    
    
    acceptAction.activationMode =  UIUserNotificationActivationModeForeground;//UIUserNotificationActivationMode.Foreground;
    acceptAction.destructive = false;
    acceptAction.authenticationRequired = false;
    UIMutableUserNotificationCategory *inviteCategory = [UIMutableUserNotificationCategory new];
    inviteCategory.identifier = @"WODAOA_INVITE_CATEGORY";
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    categories = [NSSet setWithObject:inviteCategory];
    //iOS 10 before
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

- (void)addNotification:(NSDate *)date attendanceType:(NSString *)type {
    if (kSystemVersion >= 10) {
        for (NSInteger i = 1; i <= self.selectDays.count; i++) {
            NSString *days = [NSString stringWithFormat:@"%@",[self.selectDays objectAtIndex:i-1]];
            if ([days isEqualToString:@"1"]) {
                NSLog(@"composweek--%ld",date.weekday);
                UNMutableNotificationContent *content = [UNMutableNotificationContent new];
                content.title = @"打卡提醒";
                content.sound = [UNNotificationSound defaultSound];
                content.body = [NSString stringWithFormat:@"考勤君友情提示:%@",type];
                content.userInfo = @{@"type": @"考勤",
                                     @"attendanceType": type};
                content.badge = @1;
                NSDateComponents *components = [NSDateComponents new];
                components.weekday = i;
                components.hour = date.hour;
                components.minute = date.minute;
                components.second = 0;
                UNNotificationTrigger *triger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
                //UNNotificationTrigger *triger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:7 * 24 * 3600 repeats:YES];
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSUUID UUID].UUIDString content:content trigger:triger];
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
                
                [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
                    NSLog(@"---%@---%@",request.trigger, request.content.body);
                }];
            }
        }
    } else if (kSystemVersion >= 8 && kSystemVersion < 10) {
        for (NSInteger i = 1; i <= self.selectDays.count; i++) {
            NSString *days = [NSString stringWithFormat:@"%@",[self.selectDays objectAtIndex:i-1]];
            if ([days isEqualToString:@"1"]) {
                NSInteger day = 0;
                day = i - date.weekday;//(temp == 0 ? temp : temp + 7);
                day = day >= 0 ? day : day + 7;
                
                NSDate *fireDate = [NSDate dateWithTimeInterval:day * 24 * 3600 sinceDate:date];
                UILocalNotification *notification = [UILocalNotification new];
                notification.fireDate = fireDate;
                notification.repeatInterval = NSCalendarUnitWeekOfYear;//NSCalendarUnitWeekday;
                notification.timeZone = [NSTimeZone systemTimeZone];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = [NSString stringWithFormat:@"考勤君友情提示:%@",type];
                notification.alertAction = @"打开";
                notification.applicationIconBadgeNumber += 1;
                NSDictionary *userInfo = @{@"type": @"考勤",
                                           @"attendanceType": type};
                notification.userInfo = userInfo;
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
        UIApplication *application = [UIApplication sharedApplication];
        NSArray *localNotifications = [application scheduledLocalNotifications];
        
        for (UILocalNotification *local in localNotifications) {
            NSLog(@"启动时间:%@--重复类型:%ld==提示:%@\n",local.fireDate,(unsigned long)local.repeatInterval,local.alertBody);
        }
    }
}


@end

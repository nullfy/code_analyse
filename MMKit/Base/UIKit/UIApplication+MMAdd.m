//
//  UIApplication+MMAdd.m
//  PracticeKit
//
//  Created by 晓东 on 16/12/3.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "UIApplication+MMAdd.h"
#import "UIDevice+MMAdd.h"
#import "NSArray+MMAdd.h"
#import "NSObject+MMAdd.h"
#import "MMKitMacro.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <objc/runtime.h>


MMSYNTH_DUMMY_CLASS(UIApplication_MMAdd)

#define kNetworkIndicatorDelay (1 / 30.0)

@interface _MMUIApplicationNetworkIndicatorInfo : NSObject
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer *timer;

@end
@implementation _MMUIApplicationNetworkIndicatorInfo


@end

@implementation UIApplication (MMAdd)

- (NSURL *)documentsURL {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)documentsPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSURL *)cachesURL {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)cachesPath {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSURL *)libaryURL {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)libaryPath {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}

- (BOOL)isPirated {
    if ([[UIDevice currentDevice] isSimulator]) return YES;
    
    if (getgid() <= 10) return YES;
    
    if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"SignerIdentity"]) return YES;
    
    if (![self _mm_fileExistInMainBundle:@"_CodeSignature"]) return YES;
    
    if (![self _mm_fileExistInMainBundle:@"SC_info"]) return YES;
    
    return NO;
}

- (BOOL)_mm_fileExistInMainBundle:(NSString *)name {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@",bundlePath,name];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

#pragma mark    Property 属性相关

- (NSString *)appBundleName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

- (NSString *)appBundleID {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

- (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSString *)appBuildVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (BOOL)isBeingDebugged {
    size_t size = sizeof(struct kinfo_proc);
    struct kinfo_proc info;
    int ret = 0, name[4];
    memset(&info, 0, sizeof(struct kinfo_proc));
    
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
    
    if (ret == (sysctl(name, 4, &info, &size, NULL, 0))) return ret != 0;
    
    return (info.kp_proc.p_flag & P_TRACED) ? YES : NO;
}

- (int64_t)memoryUsage {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kern = task_info(mach_thread_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kern != KERN_SUCCESS) return -1;
    return info.resident_size;
}

- (float )cpuUsage {
    kern_return_t kern;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kern = task_info(mach_thread_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kern != KERN_SUCCESS) return -1;
    
    thread_array_t thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t thread_basic_info;
    kern = task_threads(mach_thread_self(), &thread_list, &thread_count);
    if (kern != KERN_SUCCESS) return -1;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kern = thread_info(thread_list[j], THREAD_BASIC_INFO, (thread_info_t)tinfo, &thread_info_count);
        if (kern != KERN_SUCCESS) return -1;
        
        thread_basic_info = (thread_basic_info_t)thinfo;
        
        if (!(thread_basic_info->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + thread_basic_info->user_time.seconds + thread_basic_info->system_time.seconds;
            tot_usec = tot_usec + thread_basic_info->system_time.microseconds + thread_basic_info->system_time.microseconds;
            tot_cpu = tot_cpu + thread_basic_info->cpu_usage / (float)TH_USAGE_SCALE;
        }
    }
    
    kern = vm_deallocate(mach_thread_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kern == KERN_SUCCESS);
    return tot_cpu;
}

MMSYNTH_DYNAMIC_PROPERTY_OBJECT(networkActivityInfo, setNetworkActivityInfo, RETAIN_NONATOMIC, _MMUIApplicationNetworkIndicatorInfo *);

- (void)_delaySetActivity:(NSTimer *)timer {
    NSNumber *visible = timer.userInfo;
    if (self.networkActivityIndicatorVisible != visible.boolValue) {
        [self setNetworkActivityIndicatorVisible:visible.boolValue];
    }
    [timer invalidate];
}

- (void)_changeNetworkActivityCount:(NSInteger)delta {
    @synchronized (self) {
        dispatch_async_on_main_queue(^{
            _MMUIApplicationNetworkIndicatorInfo *info = [self networkActivityInfo];
            if (!info) {
                info = [_MMUIApplicationNetworkIndicatorInfo new];
                [self setNetworkActivityInfo:info];
            }
            NSInteger count = info.count;
            count += delta;
            info.count = count;
            [info.timer invalidate];
            info.timer = [NSTimer timerWithTimeInterval:kNetworkIndicatorDelay target:self selector:@selector(_delaySetActivity:) userInfo:@(info.count > 0) repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:info.timer forMode:NSRunLoopCommonModes];
        });
    }
}

- (void)incrementNetworkActivityCount {
    [self _changeNetworkActivityCount:1];
}

- (void)decrementNetworkActivityCount {
    [self _changeNetworkActivityCount:-1];
}



+ (BOOL)isAppExtension {
    static BOOL isAppExtension;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"UIApplication");
        if (!cls || ![cls respondsToSelector:@selector(sharedApplication)]) isAppExtension = YES;
    });
    return isAppExtension;
}

+ (UIApplication *)sharedExtensionApplication {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunderclared-selector"
    return [self isAppExtension] ? nil : [UIApplication performSelector:@selector(sharedApplication)];
#pragma clang diagnostic pop
}







@end

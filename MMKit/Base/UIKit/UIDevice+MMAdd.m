//
//  UIDevice+MMAdd.m
//  PracticeKit
//
//  Created by 晓东 on 16/12/2.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "UIDevice+MMAdd.h"
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <mach/mach.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import "MMKitMacro.h"
#import "NSString+MMAdd.h"

MMSYNTH_DUMMY_CLASS(UIDevice_MMAdd)

@implementation UIDevice (MMAdd)

+ (double)systemVersion {
    static double version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return version;
}

- (BOOL)isPad {
    static BOOL pad;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    });
    return pad;
}

- (BOOL)isSimulator {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

- (BOOL)isJailbroken {
    if ([self isSimulator]) return NO;
    
    NSArray *paths = @[@"/Applications/Cydia.app",
                       @"/private/var/lib/apt/",
                       @"/private/var/lib/cydia",
                       @"/private/var/stash"];
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return YES;
    }
    
    FILE *bash = fopen("/bin/bash", "r");
    if (bash != NULL) {
        fclose(bash);
        return YES;
    }
    
    NSString *path = [NSString stringWithFormat:@"/private/%@",[NSString stringWithUUID]];
    if ([@"test" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return YES;
    }
    return NO;
}


#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
- (BOOL)canMakePhoneCalls {
    __block BOOL can;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        can = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
    });
    return can;
}

#endif

- (NSString *)ipAddressWithIfaName:(NSString *)name {
    if (name.length == 0) return nil;
    NSString *address = nil;
    struct ifaddrs *addrs = NULL;
    if (getifaddrs(&addrs) == 0) {
        struct ifaddrs *addr = addrs;
        while (addr) {
            if ([[NSString stringWithUTF8String:addr->ifa_name] isEqualToString:name]) {
                sa_family_t family = addr->ifa_addr->sa_family;
                switch (family) {
                    case AF_INET: {
                        char str[INET_ADDRSTRLEN] = {0};
                        inet_ntop(family, &(((struct sockaddr_in *)addr->ifa_addr)->sin_addr), str, sizeof(str));
                        if (strlen(str) > 0) address = [NSString stringWithUTF8String:str];
                    } break;
                    case AF_INET6: {
                        char str[INET6_ADDRSTRLEN] = {0};
                        inet_ntop(family, &(((struct sockaddr_in6 *)addr->ifa_addr)->sin6_addr), str, sizeof(str));
                        if (strlen(str) > 0) address = [NSString stringWithUTF8String:str];
                    } break;
                    default:   break;
                }
                if (address) break;
            }
            addr = addr->ifa_next;
        }
    }
    freeifaddrs(addrs);
    return address;
}

- (NSString *)ipAddressWIFI {
    return [self ipAddressWithIfaName:@"en0"];
}

- (NSString *)ipAddressCell {
    return [self ipAddressWithIfaName:@"pdp_ip0"];
}

typedef struct {
    uint64_t en_in;
    uint64_t en_out;
    uint64_t pdp_ip_in;
    uint64_t pdp_ip_out;
    uint64_t awdl_in;
    uint64_t awdl_out;
    
} mm_net_interface_counter;

static uint64_t mm_net_counter_add(uint64_t counter, uint64_t bytes) {
    if (bytes < (counter % 0xFFFFFFFF)) {
        counter += 0xFFFFFFFF - (counter % 0xFFFFFFFF);
        counter += bytes;
    } else {
        counter = bytes;
    }
    return counter;
}

static uint64_t mm_net_counter_get_by_type(mm_net_interface_counter *counter, MMNetworkTrafficType type) {
    uint64_t bytes = 0;
    if (type & MMNetworkTrafficTypeWWANSent) bytes += counter->pdp_ip_out;
    if (type & MMNetworkTrafficTypeWWANReceived) bytes += counter->pdp_ip_in;
    if (type & MMNetworkTrafficTypeWIFISent) bytes += counter->en_out;
    if (type & MMNetworkTrafficTypeWIFIReceived) bytes += counter->en_in;
    if (type & MMNetworkTrafficTypeAWDLSent) bytes += counter->awdl_out;
    if (type & MMNetworkTrafficTypeAWDLReceived) bytes += counter->awdl_in;
    return bytes;
}

static mm_net_interface_counter mm_get_net_interface_counter() {
    static dispatch_semaphore_t lock;
    static NSMutableDictionary *shareInCounters;
    static NSMutableDictionary *sharedOutCounters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInCounters = [NSMutableDictionary new];
        sharedOutCounters = [NSMutableDictionary new];
        lock = dispatch_semaphore_create(1);
    });
    
    mm_net_interface_counter counter = {0};
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    if (getifaddrs(&addrs) == 0) {
        cursor = addrs;
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        while (cursor) {
            if (cursor->ifa_addr->sa_family == AF_LINK) {
                const struct if_data *data = cursor->ifa_data;
                NSString *name = cursor->ifa_name ? [NSString stringWithUTF8String:cursor->ifa_name] : nil;
                if (name) {
                    uint64_t counter_in = ((NSNumber *)shareInCounters[name]).unsignedLongLongValue;
                    counter_in = mm_net_counter_add(counter_in, data->ifi_ibytes);
                    sharedOutCounters[name] = @(counter_in);
                    
                    uint64_t counter_out = ((NSNumber *)sharedOutCounters[name]).unsignedLongLongValue;
                    counter_out = mm_net_counter_add(counter_out, data->ifi_obytes);
                    sharedOutCounters[name] = @(counter_out);
                    
                    if ([name hasPrefix:@"en"]) {
                        counter.en_in += counter_in;
                        counter.en_out += counter_out;
                    } else if ([name hasPrefix:@"awld"]) {
                        counter.en_in += counter_in;
                        counter.en_out += counter_out;
                    } else if ([name hasPrefix:@"pdp_ip"]) {
                        counter.pdp_ip_in += counter_in;
                        counter.pdp_ip_out += counter_out;
                    }
                }
            }
            cursor = cursor->ifa_next;
        }
        dispatch_semaphore_signal(lock);
        freeifaddrs(addrs);
    }
    return counter;
}

- (uint64_t)getNetworkTrafficBytes:(MMNetworkTrafficType)types {
    mm_net_interface_counter counter = mm_get_net_interface_counter();
    return mm_net_counter_get_by_type(&counter, types);
}

- (NSString *)machineModel {
    static NSString *model;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        free(machine);
    });
    return model;
}

- (NSString *)machineModelName {
    static NSString *name;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *model = [self machineModel];
        if (!model) return ;
        NSDictionary *dic = @{
                              @"Watch1,1" : @"Apple Watch",
                              @"Watch1,2" : @"Apple Watch",
                              
                              @"iPod1,1" : @"iPod touch 1",
                              @"iPod2,1" : @"iPod touch 2",
                              @"iPod3,1" : @"iPod touch 3",
                              @"iPod4,1" : @"iPod touch 4",
                              @"iPod5,1" : @"iPod touch 5",
                              @"iPod7,1" : @"iPod touch 6",
                              
                              @"iPhone1,1" : @"iPhone 1G",
                              @"iPhone1,2" : @"iPhone 3G",
                              @"iPhone2,1" : @"iPhone 3GS",
                              @"iPhone3,1" : @"iPhone 4 (GSM)",
                              @"iPhone3,2" : @"iPhone 4",
                              @"iPhone3,3" : @"iPhone 4 (CDMA)",
                              @"iPhone4,1" : @"iPhone 4S",
                              @"iPhone5,1" : @"iPhone 5",
                              @"iPhone5,2" : @"iPhone 5",
                              @"iPhone5,3" : @"iPhone 5c",
                              @"iPhone5,4" : @"iPhone 5c",
                              @"iPhone6,1" : @"iPhone 5s",
                              @"iPhone6,2" : @"iPhone 5s",
                              @"iPhone7,1" : @"iPhone 6 Plus",
                              @"iPhone7,2" : @"iPhone 6",
                              @"iPhone8,1" : @"iPhone 6s",
                              @"iPhone8,2" : @"iPhone 6s Plus",
                              @"iPhone8,4" : @"iPhone SE",
                              
                              @"iPad1,1" : @"iPad 1",
                              @"iPad2,1" : @"iPad 2 (WiFi)",
                              @"iPad2,2" : @"iPad 2 (GSM)",
                              @"iPad2,3" : @"iPad 2 (CDMA)",
                              @"iPad2,4" : @"iPad 2",
                              @"iPad2,5" : @"iPad mini 1",
                              @"iPad2,6" : @"iPad mini 1",
                              @"iPad2,7" : @"iPad mini 1",
                              @"iPad3,1" : @"iPad 3 (WiFi)",
                              @"iPad3,2" : @"iPad 3 (4G)",
                              @"iPad3,3" : @"iPad 3 (4G)",
                              @"iPad3,4" : @"iPad 4",
                              @"iPad3,5" : @"iPad 4",
                              @"iPad3,6" : @"iPad 4",
                              @"iPad4,1" : @"iPad Air",
                              @"iPad4,2" : @"iPad Air",
                              @"iPad4,3" : @"iPad Air",
                              @"iPad4,4" : @"iPad mini 2",
                              @"iPad4,5" : @"iPad mini 2",
                              @"iPad4,6" : @"iPad mini 2",
                              @"iPad4,7" : @"iPad mini 3",
                              @"iPad4,8" : @"iPad mini 3",
                              @"iPad4,9" : @"iPad mini 3",
                              @"iPad5,1" : @"iPad mini 4",
                              @"iPad5,2" : @"iPad mini 4",
                              @"iPad5,3" : @"iPad Air 2",
                              @"iPad5,4" : @"iPad Air 2",
                              @"iPad6,3" : @"iPad Pro (9.7 inch)",
                              @"iPad6,4" : @"iPad Pro (9.7 inch)",
                              @"iPad6,7" : @"iPad Pro (12.9 inch)",
                              @"iPad6,8" : @"iPad Pro (12.9 inch)",
                              
                              @"AppleTV2,1" : @"Apple TV 2",
                              @"AppleTV3,1" : @"Apple TV 3",
                              @"AppleTV3,2" : @"Apple TV 3",
                              @"AppleTV5,3" : @"Apple TV 4",
                              
                              @"i386" : @"Simulator x86",
                              @"x86_64" : @"Simulator x64",
                              };
        name = dic[model];
        if (!name) name = model;
    });
    return name;
}

//开机时间
- (NSDate *)systemUptime {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSTimeInterval time = [processInfo systemUptime];
    
    //获取当前进程
    NSLog(@"processInfo === %@", [NSProcessInfo processInfo]);
    
    //当前进程的环境，例如输出log的设备等
    NSLog(@"environment === %@", processInfo.environment);
    
    //执行进程的电脑的主机名(反正我在手机上输出为空)
    NSLog(@"hostName === %@", processInfo.hostName);
    
    //进程名字(你的项目名字)
    NSLog(@"processName === %@", processInfo.processName);
    
    //进程的标示符,通常叫做进程ID,每次你重新运行项目这个值都会增加，加的数目看你开了几条进程，并且这个值会一直增加，除非你重启电脑，进程ID清0。
    NSLog(@"processIdentifier === %d", processInfo.processIdentifier);
    
    //每次运行都会生成一个不确定的标示符
    NSLog(@"globallyUniqueString === %@", processInfo.globallyUniqueString);
    
    //操作系统的版本号以及build号
    NSLog(@"operatingSystemVersionString === %@", processInfo.operatingSystemVersionString);
    
    //操作系统的版本号，大版本号.小版本号.小版本补丁号
    NSLog(@"operatingSystemVersion === %ld\n%ld\n%ld", (long)processInfo.operatingSystemVersion.majorVersion, (long)processInfo.operatingSystemVersion.minorVersion, (long)processInfo.operatingSystemVersion.patchVersion);
    
    //当前项目进程数量
    NSLog(@"processorCount === %lu", (unsigned long)processInfo.processorCount);
    
    //当前项目活跃进程数量
    NSLog(@"activeProcessorCount === %lu", (unsigned long)processInfo.activeProcessorCount);
    
    //设备的CPU物理内存，byte单位
    NSLog(@"activeProcessorCount === %lu", (unsigned long)processInfo.physicalMemory);
    
    //判断当前进程执行的系统版本是否低于所指定的版本
    NSLog(@"isOperatingSystemAtLeastVersion: === %d", [processInfo isOperatingSystemAtLeastVersion:processInfo.operatingSystemVersion]);
    
    //上次设备重启到现在的秒数
    NSLog(@"systemUptime === %f", processInfo.systemUptime);
    
    //- (id <NSObject>)beginActivityWithOptions:(NSActivityOptions)options reason:(NSString *)reason这个函数使某个进程变成某种状态，以及变成这种状态的理由，需要与- (void)endActivity:(id <NSObject>)activity结合使用。activity这个属性是用于显示结果的。
    
    //- (void)performActivityWithOptions:(NSActivityOptions)options reason:(NSString *)reason usingBlock:(void (^)(void))block使某个进程变成某种状态，以及变成这种状态的理由，状态结束后会在block中回调
    
    //- (void)performExpiringActivityWithReason:(NSString *)reason usingBlock:(void(^)(BOOL expired))block使某个进程活跃结束
    
    //检索当前进程对系统是否设置为低功耗模式,这个属性值总为NO
    NSLog(@"%d", processInfo.isLowPowerModeEnabled);
    
    //FOUNDATION_EXTERN NSNotificationName const NSProcessInfoPowerStateDidChangeNotification进程功耗状态的变化
    
    
    return [[NSDate alloc ]initWithTimeIntervalSinceNow:(0-time)];
}

- (int64_t)diskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space = [[attrs objectForKey:NSFileSystemSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

- (int64_t)diskSpaceFree {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space = [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

- (int64_t)diskSpaceUsed {
    int64_t total = self.diskSpace;
    int64_t free = self.diskSpaceFree;
    if (total < 0 || free < 0) return -1;
    int64_t used = total - free;
    if (used < 0) used = -1;
    return used;
}

- (int64_t)memoryTotal {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return page_size * (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count);
}

- (int64_t)memoryFree {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.free_count * page_size;
}

- (int64_t)memoryActive {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.active_count * page_size;
}

- (int64_t)memoryInactive {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.inactive_count * page_size;
}

- (int64_t)memoryWired {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.wire_count * page_size;
}

- (int64_t)memoryPurgable {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.purgeable_count * page_size;
}

- (NSUInteger)cpuCount {
    return [NSProcessInfo processInfo].activeProcessorCount;
}

- (float)cpuUsage {
    float cpu = 0;
    NSArray *cpus = [self cpuUsagePerProcessor];
    if (cpus.count == 0) return -1;
    for (NSNumber *n in cpus) {
        cpu += n.floatValue;
    }
    return cpu;
}

//获取每个cpu 处理器的使用情况
- (NSArray *)cpuUsagePerProcessor {
    processor_info_array_t _cpuInfo, _prevCPUInfo = nil;
    mach_msg_type_number_t _numCPUInfo, _numPreCPUInfo = 0;
    unsigned _numCPUs;
    NSLock *_cpuUsageLock;
    
    int _mib[2U] = {CTL_HW, HW_NCPU };
    size_t _sizeOfNumCPUS = sizeof(_numCPUs);
    int _status = sysctl(_mib, 2U, &_numCPUs, &_sizeOfNumCPUS, NULL, 0U);
    if (_status) _numCPUs = 1;
    
    _cpuUsageLock = [NSLock new];
    
    natural_t _numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &_numCPUsU, &_cpuInfo, &_numCPUInfo);
    if (err == KERN_SUCCESS) {
        [_cpuUsageLock lock];
        
        NSMutableArray *cpus = [NSMutableArray new];
        for (unsigned i = 0U; i < _numCPUs; ++i) {
            Float32 _inUse, _total;
            if (_prevCPUInfo) {
                _inUse = (
                          (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                          );
                _total = _inUse + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                _inUse = _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                _total = _inUse + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            [cpus addObject:@(_inUse / _total)];
        }
        
        [_cpuUsageLock unlock];
        if (_prevCPUInfo) {
            size_t preCPUInfoSize = sizeof(integer_t) * _numPreCPUInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)_prevCPUInfo, preCPUInfoSize);
        }
        return cpus;
    } else {
        return nil;
    }
}


@end

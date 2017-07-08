//
//  NSThread+MMAdd.m
//  PracticeKit
//
//  Created by 晓东 on 16/11/29.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "NSThread+MMAdd.h"
#import <CoreFoundation/CoreFoundation.h>

@interface NSThread_MMAdd : NSObject    @end

@implementation NSThread_MMAdd  @end

#if __has_feature(objc_arc)
#error This file must be compiled without ARC . Specify the -fno-objc-arc flag to this file.
#endif

static NSString *const MMNSThreadAutoReleasePoolKey = @"MMNSThreadAutoreleasePoolKey";
static NSString *const MMNSThreadAutoReleasePoolStackKey = @"MMNSThreadAutoReleaseStackKey";

static const void *PoolStackRetainCallBack(CFAllocatorRef allocator, const void *value) {
    return value;
}

static void PoolStackReleaseCallBack(CFAllocatorRef allocator, const void *value) {
    CFRelease((CFTypeRef)value);
}

static inline void MMAutoreleasePoolPush() {
    NSMutableDictionary *dic = [NSThread currentThread].threadDictionary;
    NSMutableArray *poolStack = dic[MMNSThreadAutoReleasePoolStackKey];
    
    if (!poolStack) {
        CFArrayCallBacks callbacks = {0};
        callbacks.retain = PoolStackRetainCallBack;
        callbacks.release = PoolStackReleaseCallBack;
        poolStack = (id)CFArrayCreateMutable(CFAllocatorGetDefault(), 0, &callbacks);
        dic[MMNSThreadAutoReleasePoolStackKey] = poolStack;
        CFRelease(poolStack);
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [poolStack addObject:pool];
}

static inline void MMAutoreleasePoolPop() {
    NSMutableDictionary *dic = [NSThread currentThread].threadDictionary;
    NSMutableArray *poolStack = dic[MMNSThreadAutoReleasePoolStackKey];
    [poolStack removeLastObject];
}

static void MMRunLoopAutoreleasePoolObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    switch (activity) {
        case kCFRunLoopEntry: {
            MMAutoreleasePoolPush();
        } break;
        case kCFRunLoopBeforeWaiting: {
            MMAutoreleasePoolPop();
            MMAutoreleasePoolPush();
        } break;
        case kCFRunLoopExit: {
            MMAutoreleasePoolPop();
        } break;
        default: break;
    }
}

static void MMRunLoopAutoreleasePoolSetup() {
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    
    CFRunLoopObserverRef pushObserver;
    pushObserver = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopEntry,
                                           true,
                                           -0x7FFFFFFF,
                                           MMRunLoopAutoreleasePoolObserverCallBack,
                                           NULL);
    CFRunLoopAddObserver(runloop, pushObserver, kCFRunLoopCommonModes);
    CFRelease(pushObserver);
    
    CFRunLoopObserverRef popObserver;
    popObserver = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                          kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                          true,
                                          0x7FFFFFFF,
                                          MMRunLoopAutoreleasePoolObserverCallBack,
                                          NULL);
    CFRunLoopAddObserver(runloop, popObserver, kCFRunLoopCommonModes);
    CFRelease(popObserver);
}


@implementation NSThread (MMAdd)

+ (void)addAutoreleasePoolToCurrentRunloop {
    if ([NSThread isMainThread]) return;
    NSThread *thread = [self currentThread];
    if (!thread) return;
    if (thread.threadDictionary[MMNSThreadAutoReleasePoolKey]) return;
    MMRunLoopAutoreleasePoolSetup();
    thread.threadDictionary[MMNSThreadAutoReleasePoolKey] = MMNSThreadAutoReleasePoolKey;
}

@end




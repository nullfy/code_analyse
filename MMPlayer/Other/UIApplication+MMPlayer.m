//
//  UIApplication+MMPlayer.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/27.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "UIApplication+MMPlayer.h"
#import "NSString+MMPlayer.h"
#import <objc/runtime.h>

@implementation UIApplication (MMPlayer)

- (NSMutableDictionary *)mm_cacheFailTimes {
    NSMutableDictionary *dic = objc_getAssociatedObject(self, _cmd);
    if (!dic) dic = [NSMutableDictionary new];
    return dic;
}

- (void)setMm_cacheFailTimes:(NSMutableDictionary *)mm_cacheFailTimes {
    objc_setAssociatedObject(self, @selector(mm_cacheFailTimes), mm_cacheFailTimes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)mm_cacheImageForRequest:(NSURLRequest *)request {
    if (request) {
        NSString *directorPath = [NSString mmplayer_cachePath];
        NSString *path = [NSString stringWithFormat:@"%@/%@", directorPath, [NSString cacheFileNameForKey:[NSString mmplayer_keyForRequest:request]]];
        return [UIImage imageWithContentsOfFile:path];
    }
    return nil;
}

- (NSUInteger)mm_failTimesForRequest:(NSURLRequest *)request {
    NSNumber *times = [self.mm_cacheFailTimes objectForKey:[NSString cacheFileNameForKey:[NSString mmplayer_keyForRequest:request]]];
    if (times && [times respondsToSelector:@selector(unsignedIntegerValue)]) {
        return times.unsignedIntegerValue;
    }
    return 0;
}

- (void)mm_cacheFailRequest:(NSURLRequest *)request {
    NSNumber *failTimes = [self.mm_cacheFailTimes objectForKey:[NSString cacheFileNameForKey:[NSString mmplayer_keyForRequest:request]]];
    NSUInteger times = 0;
    if (failTimes && [failTimes respondsToSelector:@selector(unsignedIntegerValue)]) times = failTimes.unsignedIntegerValue;
    
    times++;
    [self.mm_cacheFailTimes setObject:@(times) forKey:[NSString cacheFileNameForKey:[NSString mmplayer_keyForRequest:request]]];
}

- (void)mm_cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request {
    if (!image || !request) return;
    
    NSString *directPath = [NSString mmplayer_cachePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directPath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:directPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) return;
    }
    
    NSString *path = [directPath stringByAppendingPathComponent:[NSString cacheFileNameForKey:[NSString mmplayer_keyForRequest:request]]];
    NSData *data = UIImagePNGRepresentation(image);
    if (!data) data = UIImageJPEGRepresentation(image, 1.0);
    if (data) [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
}

#pragma mark    Private Method
- (void)mm_clearCache {
    [self.mm_cacheFailTimes removeAllObjects];
    self.mm_cacheFailTimes = nil;
}

- (void)mm_clearDiskCache {
    NSString *directPath = [NSString mmplayer_cachePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directPath]) {
        dispatch_queue_t queue = dispatch_queue_create("com.mmplayer.cachequeue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:directPath error:&error];
            [[NSFileManager defaultManager] createDirectoryAtPath:directPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        });
    }
    [self mm_clearCache];
}

@end

//
//  NSString+MMPlayer.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/27.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "NSString+MMPlayer.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MMPlayer)

+ (NSString *)cacheFileNameForKey:(NSString *)key {
    const char *str = key.UTF8String;
    if (str == NULL) str = "";
    
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    
    NSString *tail = [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", key.pathExtension];
    NSString *fileName = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], tail];
    return fileName;
}

+ (NSString *)mmplayer_cachePath {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *directPath = [[cachePath stringByAppendingPathComponent:@"default"] stringByAppendingPathComponent:@"com.mmplayer.default"];
    NSLog(@"cachepath----%@",directPath);
    return directPath;
}

+ (NSString *)mmplayer_keyForRequest:(NSURLRequest *)request {
    return request.URL.absoluteString;
}

@end

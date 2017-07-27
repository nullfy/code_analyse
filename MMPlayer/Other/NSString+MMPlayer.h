//
//  NSString+MMPlayer.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/27.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MMPlayer)

+ (NSString *)cacheFileNameForKey:(NSString *)key;
+ (NSString *)mmplayer_cachePath;
+ (NSString *)mmplayer_keyForRequest:(NSURLRequest *)request;

@end

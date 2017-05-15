//
//  MMImageCoder.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/5/12.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef MMIMAGE_WEBP_ENABLED 
#if __has_include(<webp/decode.h>) && __has_include(<webp/encode.h>) && \
__has_include(<webp/demux.h>) && __has_include(<webp/mux.h>)

#define MMIMAGE_WEBP_ENABLED 1
#import <WebP/decode.h>
#import <WebP/encode.h>
#import <WebP/demux.h>
#import <WebP/mux.h>
#elif __has_include("webp/decode.h") && __has_include("webp/encode.h") && \
__has_include("webp/demux.h") && __has_include("webp/mux.h")
#define MMIMAge_WEBP_ENABLED 1
#import "webp/decode.h"
#import "webp/encode.h"
#import "webp/demux.h"
#import "webp/mux.h"
#else
#define MMIMAGE_WEBP_ENABLED 0
#endif
#endif

@interface MMImageCoder : NSObject

@end

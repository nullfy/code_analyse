//
//  NSBundle+ImagePicker.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "NSBundle+ImagePicker.h"

@implementation NSBundle (ImagePicker)

+ (NSString *)mm_localizedStringForKey:(NSString *)key value:(NSString *)value {
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language rangeOfString:@"zh-Hans"].location != NSNotFound) {
            language = @"zh-Hans";
        } else {
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[NSBundle mm_imagePickerBundle] pathForResource:language ofType:@"lproj"]];
    }
    NSString *result = [bundle localizedStringForKey:key value:value table:nil];
    return result;
}

+ (instancetype)mm_imagePickerBundle {
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MMImagePicker" ofType:@"bundle"];
        if (!path) {
            path = [[NSBundle mainBundle] pathForResource:@"MMImagePicker" ofType:@"bundle" inDirectory:@"Frameworks/MMImagePicker.framwork/"];
        }
        bundle = [NSBundle bundleWithPath:path];
    }
    return bundle;
}

+ (NSString *)mm_localizedStringForKey:(NSString *)key {
    return [self mm_localizedStringForKey:key value:@""];
}


@end

//
//  NSBundle+ImagePicker.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (ImagePicker)

+ (NSString *)mm_localizedStringForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)mm_localizedStringForKey:(NSString *)key;

@end

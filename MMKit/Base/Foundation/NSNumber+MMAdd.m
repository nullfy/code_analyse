//
//  NSNumber+MMAdd.m
//  PracticeKit
//
//  Created by 晓东 on 16/11/17.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "NSNumber+MMAdd.h"
#import "MMKitMacro.h"
#import "NSString+MMAdd.h"

MMSYNTH_DUMMY_CLASS(NSNumber_MMAdd)

@implementation NSNumber (MMAdd)

+ (NSNumber *)numberWithString:(NSString *)string {
    NSString *str = [[string stringByTrim] lowercaseString];
    if (!str || !str.length) {
        return nil;
    }
    
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{@"true"     : @(YES),
                @"yes"      : @(YES),
                @"false"    : @(NO),
                @"no"       : @(NO),
                @"nil"      : [NSNull null],
                @"null"     : [NSNull null],
                @"<null>"   : [NSNull null]};
    });
    id num = dic[str];
    if (num) {
        if (num == [NSNull null]) return nil;
        return num;
    }
    
    //十六进制 number
    int sign = 0;
    if ([str hasPrefix:@"0x"]) sign = 1;
    else if ([str hasPrefix:@"-0x"]) sign = -1;
    if (sign != 0) {
        NSScanner *scan = [NSScanner scannerWithString:str];
        unsigned num = -1;
        BOOL suc = [scan scanHexInt:&num];
        if (suc) {
            return [NSNumber numberWithLong:((long)num *sign)];
        } else {
            return nil;
        }
    }
    
    //一般的number
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}

@end

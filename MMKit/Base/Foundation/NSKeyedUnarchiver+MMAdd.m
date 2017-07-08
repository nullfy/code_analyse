//
//  NSKeyedUnarchiver+MMAdd.m
//  PracticeKit
//
//  Created by 晓东 on 16/11/29.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "NSKeyedUnarchiver+MMAdd.h"
#import "MMKitMacro.h"

MMSYNTH_DUMMY_CLASS(NSKeyUnarchiver_MMAdd)

@implementation NSKeyedUnarchiver (MMAdd)

+ (id)unarchiveObjectWithData:(NSData *)data exception:(NSException * _Nullable __autoreleasing *)exception {
    id object = nil;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *e) {
        if (exception) *exception = e;
    } @finally {
        
    }
    return object;
}

+ (id)unarchiveObjectWithFile:(NSString *)path exception:(NSException * _Nullable __autoreleasing *)exception {
    id object = nil;
    
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    } @catch (NSException *e) {
        if (exception) *exception = e;
    } @finally {
        
    }
    return object;
}

@end

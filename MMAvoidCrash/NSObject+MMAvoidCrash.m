//
//  NSObject+MMAvoidCrash.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "NSObject+MMAvoidCrash.h"
#import "MMAvoidCrash.h"

@implementation NSObject (MMAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(setValue:forKey:)
                              otherMethodSel:@selector(avoidCrashSetValue:forKey:)];
        
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(setValue:forKeyPath:)
                              otherMethodSel:@selector(avoidCrashSetValue:forKeyPath:)];
        
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(setValue:forUndefinedKey:)
                              otherMethodSel:@selector(avoidCrashSetValue:forUndefinedKey:)];
        
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(setValuesForKeysWithDictionary:)
                              otherMethodSel:@selector(avoidCrashSetValuesForKeysWithDictionary:)];
    });
}

#pragma private-method

- (void)avoidCrashSetValue:(id)value forKey:(NSString *)key {
    @try {
        [self avoidCrashSetValue:value forKey:key];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultIgnore];
    } @finally {
        
    }
}

- (void)avoidCrashSetValue:(id)value forKeyPath:(NSString *)keyPath {
    @try {
        [self avoidCrashSetValue:value forKeyPath:keyPath];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultIgnore];
    } @finally {
        
    }
}

- (void)avoidCrashSetValue:(id)value forUndefinedKey:(NSString *)key {
    @try {
        [self avoidCrashSetValue:value forUndefinedKey:key];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultIgnore];
    } @finally {
        
    }
}

- (void)avoidCrashSetValuesForKeysWithDictionary:(NSDictionary <NSString *, id> *)keysAndValues {
    @try {
        [self avoidCrashSetValuesForKeysWithDictionary:keysAndValues];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultIgnore];
    } @finally {
        
    }
}



@end

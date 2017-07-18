//
//  NSMutableDictionary+MMAvoidCrash.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "NSMutableDictionary+MMAvoidCrash.h"
#import "MMAvoidCrash.h"

@implementation NSMutableDictionary (MMAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MMAvoidCrash exchangeClassMethod:self
                                methodSel:@selector(dictionaryWithObjects:forKeys:count:)
                           otherMethodSel:@selector(avoidCrashDictionaryWithObjects:forKeys:count:)];
    });
}

+ (instancetype)avoidCrashDictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt {
    id obj = nil;
    @try {
        obj = [self avoidCrashDictionaryWithObjects:objects forKeys:keys count:cnt];
    } @catch (NSException *exception) {
        NSString *toDo = @"This framework is to remove nil key-values and instance a dictionary";
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:toDo];
        
        NSUInteger index = 0;
        id _Nonnull __unsafe_unretained newObjects[cnt];
        id _Nonnull __unsafe_unretained newKeys[cnt];
        
        for (NSInteger i = 0; i < cnt; i++) {
            if (objects[i] && keys[i]) {
                newObjects[i] = objects[i];
                newKeys[i] = keys[i];
                index++;
            }
        }
        obj = [self avoidCrashDictionaryWithObjects:newObjects forKeys:newKeys count:index];
    } @finally {
        return obj;
    }
}

@end

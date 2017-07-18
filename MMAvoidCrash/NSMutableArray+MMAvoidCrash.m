
//
//  NSMutableArray+MMAvoidCrash.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "NSMutableArray+MMAvoidCrash.h"
#import "MMAvoidCrash.h"

@implementation NSMutableArray (MMAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class __NSArrayM = NSClassFromString(@"__NSArrayM");
        
        [MMAvoidCrash exchangeInstanceMethod:__NSArrayM
                                   methodSel:@selector(objectAtIndex:)
                              otherMethodSel:@selector(avoidCrashObjectAtIndex:)];
        
        [MMAvoidCrash exchangeInstanceMethod:__NSArrayM
                                   methodSel:@selector(setObject:atIndexedSubscript:)
                              otherMethodSel:@selector(avoidCrashSetObject:atIndexedSubscript:)];
        
        [MMAvoidCrash exchangeInstanceMethod:__NSArrayM
                                   methodSel:@selector(removeObjectAtIndex:)
                              otherMethodSel:@selector(avoidCrashRemoveObjectAtIndex:)];
        
        [MMAvoidCrash exchangeInstanceMethod:__NSArrayM
                                   methodSel:@selector(insertObject:atIndex:)
                              otherMethodSel:@selector(avoidCrashInsertObject:atIndex:)];
        
        [MMAvoidCrash exchangeInstanceMethod:__NSArrayM
                                   methodSel:@selector(getObjects:range:)
                              otherMethodSel:@selector(avoidCrashGetObjects:range:)];
    });
}

#pragma mark private-metho

- (void)avoidCrashSetObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    @try {
        [self avoidCrashSetObject:obj atIndexedSubscript:idx];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultIgnore];
    } @finally {
        
    }
}

- (void)avoidCrashRemoveObjectAtIndex:(NSUInteger)index {
    @try {
        [self avoidCrashRemoveObjectAtIndex:index];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultIgnore];
    } @finally {
        
    }
}

- (void)avoidCrashInsertObject:(id)anObject atIndex:(NSUInteger)index {
    @try {
        [self avoidCrashInsertObject:anObject atIndex:index];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultIgnore];
    } @finally {
        
    }
}

- (id)avoidCrashObjectAtIndex:(NSUInteger)index {
    id obj = nil;
    @try {
        obj = [self avoidCrashObjectAtIndex:index];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultIgnore];
    } @finally {
        return obj;
    }
}

- (void)avoidCrashGetObjects:(__unsafe_unretained id  _Nonnull *)objects range:(NSRange)range {
    @try {
        [self avoidCrashGetObjects:objects range:range];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultIgnore];
    } @finally {
        
    }
}

@end

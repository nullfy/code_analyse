//
//  NSMutableString+MMAvoidCrash.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "NSMutableString+MMAvoidCrash.h"
#import "MMAvoidCrash.h"

@implementation NSMutableString (MMAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = NSClassFromString(@"__NSCFString");
        
        [MMAvoidCrash exchangeInstanceMethod:aClass
                                   methodSel:@selector(replaceCharactersInRange:withString:)
                              otherMethodSel:@selector(avoidCrashReplaceCharactersInRange:withString:)];
        
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(deleteCharactersInRange:)
                              otherMethodSel:@selector(avoidCrashDeleteCharactersInRange:)];
        
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(insertString:atIndex:)
                              otherMethodSel:@selector(avoidCrashInsertString:atIndex:)];
    });
}

#pragma private-method

- (void)avoidCrashReplaceCharactersInRange:(NSRange)range withString:(NSString *)replacement {
    @try {
        [self avoidCrashReplaceCharactersInRange:range withString:replacement];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultIgnore];
    } @finally {
        
    }
}

- (void)avoidCrashInsertString:(NSString *)aString atIndex:(NSUInteger)loc {
    @try {
        [self avoidCrashInsertString:aString atIndex:loc];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultIgnore];
    } @finally {
        
    }
}

- (void)avoidCrashDeleteCharactersInRange:(NSRange)range {
    @try {
        [self avoidCrashDeleteCharactersInRange:range];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultIgnore];
    } @finally {
        
    }
}

@end

//
//  NSString+MMAvoidCrash.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "NSString+MMAvoidCrash.h"
#import "MMAvoidCrash.h"

@implementation NSString (MMAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(characterAtIndex:)
                              otherMethodSel:@selector(avoidCrashCharacterAtIndex:)];
        
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(substringFromIndex:)
                              otherMethodSel:@selector(avoidCrashSubstringFromIndex:)];
        
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(substringToIndex:)
                              otherMethodSel:@selector(avoidCrashSubstringToIndex:)];
        
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(substringWithRange:)
                              otherMethodSel:@selector(avoidCrashSubstringWithRange:)];
        
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(stringByReplacingOccurrencesOfString:withString:)
                              otherMethodSel:@selector(avoidCrashStringByReplacingOccurrencesOfString:withString:)];
        
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(stringByReplacingCharactersInRange:withString:)
                              otherMethodSel:@selector(avoidCrashStringByReplacingCharactersInRange:withString:)];
        
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(stringByReplacingOccurrencesOfString:withString:options:range:)
                              otherMethodSel:@selector(avoidCrashStringByReplacingOccurrencesOfString:withString:options:range:)];
        
       
    });
}


#pragma private-method

- (unichar)avoidCrashCharacterAtIndex:(NSUInteger)index {
    unichar characteristic;
    @try {
        characteristic = [self avoidCrashCharacterAtIndex:index];
    } @catch (NSException *exception) {
        NSString *defaultToDo = @"This framework default is to return a without assign unichar";
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    } @finally {
        return characteristic;
    }
}

- (NSString *)avoidCrashSubstringFromIndex:(NSUInteger)index {
    NSString *subString = nil;
    @try {
        subString = [self avoidCrashSubstringFromIndex:index];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return subString;
    }
}

- (NSString *)avoidCrashSubstringToIndex:(NSUInteger)index {
    NSString *subString = nil;
    @try {
        subString = [self avoidCrashSubstringToIndex:index];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return subString;
    }
}


- (NSString *)avoidCrashSubstringWithRange:(NSRange)range {
    NSString *subString = nil;
    @try {
        subString = [self avoidCrashSubstringWithRange:range];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return subString;
    }
}

- (NSString *)avoidCrashStringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement {
    NSString *subString = nil;
    @try {
        subString = [self avoidCrashStringByReplacingCharactersInRange:range withString:replacement];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return subString;
    }
}

//nullable iOS6 以前没有
- (NSString *)avoidCrashStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement {
    NSString *subString = nil;
    @try {
        subString = [self avoidCrashStringByReplacingOccurrencesOfString:target withString:replacement];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return subString;
    }
}

- (NSString *)avoidCrashStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange {
    NSString *subString = nil;
    @try {
        subString = [self avoidCrashStringByReplacingOccurrencesOfString:target withString:replacement options:options range:searchRange];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return subString;
    }
}


@end

//
//  NSAttributedString+MMAvoidCrash.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "NSAttributedString+MMAvoidCrash.h"
#import "MMAvoidCrash.h"

@implementation NSAttributedString (MMAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class NSConcreteAttributedString = NSClassFromString(@"NSConcreteAttributedString");
        
        [MMAvoidCrash exchangeInstanceMethod:NSConcreteAttributedString
                                   methodSel:@selector(initWithString:)
                              otherMethodSel:@selector(avoidCrashInitWithString:)];
        
        [MMAvoidCrash exchangeInstanceMethod:NSConcreteAttributedString
                                   methodSel:@selector(initWithAttributedString:)
                              otherMethodSel:@selector(avoidInitWithAttributedString:)];
        
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(initWithString:attributes:)
                              otherMethodSel:@selector(avoidCrashInitWithString:attributes:)];
    });
}

# pragma mark private-method

- (instancetype)avoidCrashInitWithString:(NSString *)string {
    id obj = nil;
    @try {
        obj = [self avoidCrashInitWithString:string];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return obj;
    }
}

- (instancetype)avoidInitWithAttributedString:(NSString *)string {
    id obj = nil;
    @try {
        obj = [self avoidInitWithAttributedString:string];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return obj;
    }
}

- (instancetype)avoidCrashInitWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
    id obj = nil;
    @try {
        obj = [self avoidCrashInitWithString:str attributes:attrs];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return obj;
    }
}


@end

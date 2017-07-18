//
//  NSMutableAttributedString+MMAvoidCrash.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "NSMutableAttributedString+MMAvoidCrash.h"
#import "MMAvoidCrash.h"

@implementation NSMutableAttributedString (MMAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = NSClassFromString(@"NSConcreteMutableAttributedString");
        
        [MMAvoidCrash exchangeInstanceMethod:aClass
                                   methodSel:@selector(initWithString:)
                              otherMethodSel:@selector(avoidCrashInitWithString:)];
        
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(initWithString:attributes:)
                              otherMethodSel:@selector(avoidCrashInitWithString:attributes:)];
    });
}

# pragma mark private method

- (instancetype)avoidCrashInitWithString:(NSString *)str {
    id obj = nil;
    @try {
        obj = [self avoidCrashInitWithString:str];
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

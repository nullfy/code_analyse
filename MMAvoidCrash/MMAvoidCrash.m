//
//  AvoidCrash.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMAvoidCrash.h"

@implementation MMAvoidCrash

+ (void)becomeEffective {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject avoidCrashExchangeMethod];
        
        [NSString avoidCrashExchangeMethod];
        [NSMutableString avoidCrashExchangeMethod];
        
        [NSAttributedString avoidCrashExchangeMethod];
        [NSMutableAttributedString avoidCrashExchangeMethod];
        
        [NSArray avoidCrashExchangeMethod];
        [NSMutableArray avoidCrashExchangeMethod];
        
        [NSDictionary avoidCrashExchangeMethod];
        [NSMutableDictionary avoidCrashExchangeMethod];
        
    });
}

+ (void)exchangeClassMethod:(Class)aClass methodSel:(SEL)aSel otherMethodSel:(SEL)bSel {
    Method method1 = class_getClassMethod(aClass, aSel);
    Method method2 = class_getClassMethod(aClass, bSel);
    if (!method1 || !method2) return;
    method_exchangeImplementations(method1, method2);
}

+ (void)exchangeInstanceMethod:(Class)aClass methodSel:(SEL)aSel otherMethodSel:(SEL)bSel {
    Method method1 = class_getInstanceMethod(aClass, aSel);
    Method method2 = class_getInstanceMethod(aClass, bSel);
    if (!method1 || !method2) return;
    BOOL add = class_addMethod(aClass,
                               aSel,
                               method_getImplementation(method2),
                               method_getTypeEncoding(method2));
    if (add) {
        class_replaceMethod(aClass,
                            bSel,
                            method_getImplementation(method1),
                            method_getTypeEncoding(method1));
    } else {
        method_exchangeImplementations(method1, method2);
    }
}

+ (void)noteErrorWithException:(NSException *)exception defaultToDo:(NSString *)toDo {
    NSArray *array = [NSThread callStackSymbols]; //获取堆栈信息
    NSString *mainCallStackSymbolMsg = [MMAvoidCrash getMainCallStackSymbolMessageWithCallStacksSymbols:array];
    
    NSString *errorName = exception.name;
    
    //因为上面hook掉了原生方法 所以要去掉前缀
    NSString *errorReason = [exception.reason stringByReplacingOccurrencesOfString:@"avoidCrash" withString:@""];
    NSString *errorPlace = [NSString stringWithFormat:@"Error Place :%@",mainCallStackSymbolMsg];
    NSString *logErrorMsg = [NSString stringWithFormat:@"\n\n%@\n\n%@\n%@\n%@\n%@\n\n%@\n\n",
                             MMAvoidCrashSeparatorWithFlag,
                             errorName,
                             errorReason,
                             errorPlace,
                             toDo,
                             MMAvoidCrashSeparator];
    MMAvoidCrashLog(@"%@", logErrorMsg);
    
    NSDictionary *errorInfoDic = @{MMAvoidCrashErrorName        :   errorName,
                                   MMAvoidCrashErrorReason      :   errorReason,
                                   MMAvoidCrashErrorPlace       :   errorPlace,
                                   MMAvoidCrashDefaultToDo      :   toDo,
                                   MMAvoidCrashException        :   exception,
                                   MMAvoidCrashCallStackSymbols :   array};
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MMAvoidCrashNotification object:nil userInfo:errorInfoDic];
    });
    
}

#pragma private-method

+ (NSString *)getMainCallStackSymbolMessageWithCallStacksSymbols:(NSArray<NSString *> *)callSymbols {
    __block NSString *mainCallStackSymbolMsg = nil;
    NSString *reg = @"[-\\+]\\[.+\\]";
    
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:reg
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    for (NSInteger i = 0; i < callSymbols.count; i++) {
        NSString *callStackSymbol = callSymbols[i];
        [regularExp enumerateMatchesInString:callStackSymbol
                                     options:NSMatchingReportProgress
                                       range:NSMakeRange(0, callStackSymbol.length)
                                  usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                                      if (result) {
                                          NSString *tempMsg = [callStackSymbol substringWithRange:result.range];
                                          
                                          NSString *className = [[tempMsg componentsSeparatedByString:@" "] firstObject];
                                          className = [[className componentsSeparatedByString:@"["] lastObject];
                                          
                                          NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(className)];
                                          
                                          if (![className hasSuffix:@")"] && bundle == [NSBundle mainBundle]) {
                                              mainCallStackSymbolMsg = tempMsg;
                                          }
                                          *stop = YES;
                                      }
                                  }];
        if (mainCallStackSymbolMsg.length) break;
    }
    if (mainCallStackSymbolMsg == nil) mainCallStackSymbolMsg = MMAvoidCrashMainCallStackSymbolMsg;
    return mainCallStackSymbolMsg;
}


@end

//
//  MMAvoidCrashMacro.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#ifndef MMAvoidCrashMacro_h
#define MMAvoidCrashMacro_h

static NSString *const MMAvoidCrashNotification = @"mm_avoidcrash_notification";
static NSString *const MMAvoidCrashDefaultReturnNil = @"This framework default is to return nil to avoid crash";
static NSString *const MMAvoidCrashDefaultIgnore = @"This framework default is to ignore this operation to avoid crash";

static NSString *const MMAvoidCrashErrorName = @"MMAvoidCrashErrorName";
static NSString *const MMAvoidCrashErrorReason = @"MMAvoidCrashErrorReason";
static NSString *const MMAvoidCrashErrorPlace = @"MMAvoidCrashErrorPlace";
static NSString *const MMAvoidCrashDefaultToDo = @"MMAvoidCrashDefaultToDo";
static NSString *const MMAvoidCrashCallStackSymbols = @"MMAvoidCrashCallStackSymbols";
static NSString *const MMAvoidCrashException = @"MMAvoidCrashException";

static NSString *const MMAvoidCrashMainCallStackSymbolMsg = @"崩溃方法定位失败，请查看函数调用栈来排查错误信息";
static NSString *const MMAvoidCrashSeparator = @"==========================================================";
static NSString *const MMAvoidCrashSeparatorWithFlag = @"=======================MMAvoidCrashLog=======================";


#ifdef DEBUG
#define MMAvoidCrashLog(...) NSLog(@"%@", [NSString stringWithFormat:__VA_ARGS__])
#else
#define MMAvoidCrashLog(...)
#endif

#import "NSObject+MMAvoidCrash.h"
#import "NSArray+MMAvoidCrash.h"
#import "NSMutableArray+MMAvoidCrash.h"
#import "NSDictionary+MMAvoidCrash.h"
#import "NSMutableDictionary+MMAvoidCrash.h"
#import "NSString+MMAvoidCrash.h"
#import "NSMutableString+MMAvoidCrash.h"
#import "NSAttributedString+MMAvoidCrash.h"
#import "NSMutableAttributedString+MMAvoidCrash.h"


#endif /* MMAvoidCrashMacro_h */

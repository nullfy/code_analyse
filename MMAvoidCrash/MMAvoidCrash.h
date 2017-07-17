//
//  AvoidCrash.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "MMAvoidCrashMacro.h"

@interface MMAvoidCrash : NSObject

+ (void)becomeEffective;

+ (void)exchangeClassMethod:(Class)aClass methodSel:(SEL)aSel otherMethodSel:(SEL)bSel;

+ (void)exchangeInstanceMethod:(Class)aClass methodSel:(SEL)aSel otherMethodSel:(SEL)bSel;

+ (void)noteErrorWithException:(NSException *)exception defaultToDo:(NSString *)toDo;

@end

//
//  NSObject+MMAddForARC.m
//  PracticeKit
//
//  Created by 晓东 on 16/11/17.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "NSObject+MMAddForARC.h"

@interface NSObject_MMAddForARC : NSObject @end
@implementation NSObject_MMAddForARC @end

#if __has_feature(objc_arc)
#error This file must be compiled without ARC, Specify the -fno-objc-arc flag to this file.
#endif

@implementation NSObject (MMAddForARC)

- (instancetype)arcDebugRetain {
    return [self retain];
}

- (oneway void)arcDebugRelease {
    [self release];
}


- (instancetype)arcDebugAutorelease {
    return [self autorelease];
}

- (NSUInteger)arcDebugRetainCount {
    return [self retainCount];
}

@end

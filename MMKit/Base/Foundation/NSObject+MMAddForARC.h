//
//  NSObject+MMAddForARC.h
//  PracticeKit
//
//  Created by 晓东 on 16/11/17.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MMAddForARC)

- (instancetype)arcDebugRetain;

- (oneway void)arcDebugRelease;

- (instancetype)arcDebugAutorelease;

- (NSUInteger)arcDebugRetainCount;

@end

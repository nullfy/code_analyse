//
//  MMSentinel.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/19.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface MMSentinel : NSObject

@property (readonly) int32_t value;

- (int32_t)increase;

@end
NS_ASSUME_NONNULL_END

//
//  MMSentinel.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/19.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMSentinel.h"

@implementation MMSentinel {
    int32_t _value;
}

- (int32_t)value {
    return _value;
}

- (int32_t)increase {
    return OSAtomicIncrement32(&_value);
}



@end

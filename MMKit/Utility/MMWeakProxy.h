//
//  MMWeakProxy.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 初次使用是在MMWebImageOperation.h
 
 YY推荐的用法是 proxy 可以用于弱引用一个对象，用来避免循环引用，比如在用NSTimer CADisplayLink的时候
 
 @implement MyView {
    NSTimer *_timer
 }
 
 - (void)initTimer {
    MMWeakProxy *proxy = [MMWeakProxy proxyWithTarget:self];
    _timer = [NSTimer timerWithTimeInterval:0.1 target:proxy selector:@selector(tick:) userInfo:nil repeats:YES];
 }
 
 - (void)tick:(NSTimer *)timer {...}
 
 */
NS_ASSUME_NONNULL_BEGIN
@interface MMWeakProxy : NSProxy

@property (nullable, nonatomic, weak, readonly) id target;
- (instancetype)initWithTarget:(id)target;
+ (instancetype)proxyWithTarget:(id)target;


@end
NS_ASSUME_NONNULL_END

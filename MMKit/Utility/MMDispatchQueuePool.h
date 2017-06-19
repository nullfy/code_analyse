//
//  MMDispatchQueuePool.h
//  PracticeKit
//
//  Created by 晓东 on 16/12/29.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef MMDispatchQueuePool_h
#define MMDispatchQueuePool_h

NS_ASSUME_NONNULL_BEGIN

extern dispatch_queue_t MMDispatchQueueGetForQOS(NSQualityOfService qos);

@interface MMDispatchQueuePool : NSObject

/**
 <#name#>
 
 
 */

/**
 一个线程池包含多个线程，用这个类来控制线程的数量
 Quality of Service(QoS)
 iOS8 之后提供的新功能，通过枚举来告诉系统我们在进行什么样的工作，然后系统会通过合理的资源控制来最高效的执行任务代码，其中主要涉及到CPU的优先级，IO优先级，任务运行在哪个线程以及运行的顺序等，我们通过一个抽象的Quality of Service参数来表明任务的意图以及类别
 -----------------------------
 Global queue                       Corresponding QoS Class
 
 MainThread                         User-interactive        NSQualityOfServiceUserInteractive
 DISPATCH_PRIORITY_HIGH             User-initiated          NSQualityOfServiceUserInitiated
 DISPATCH_PRIORITY_DEFAULT          Default                 NSQualityOfServiceDefault
 DISPATCH_RPIORITY_LOW              Utility                 NSQualityOfServiceUtility
 DISPATCH_PRIORITY_BACKGROUND       Background              NSQualityOfServiceBackground
 
 -----------------------------
 
 
*/



- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithName:(nullable NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos;

@property (nullable, nonatomic, readonly) NSString *name;

- (dispatch_queue_t)queue;

+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos;

@end
NS_ASSUME_NONNULL_END
#endif

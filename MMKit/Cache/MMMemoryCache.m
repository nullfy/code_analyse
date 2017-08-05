//
//  MMMemoryCache.m
//  PracticeKit
//
//  Created by 晓东 on 16/12/29.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "MMMemoryCache.h"
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <pthread.h>

#if __has_include("MMDispatchQueuePool.h")
#import "MMDispatchQueuePool.h"
#endif

#ifdef MMDispatchQueuePool_h
static inline  dispatch_queue_t MMMemoryCacheGetReleaseQueue() {
    return MMDispatchQueueGetForQOS(NSQualityOfServiceUtility);
}
#else
static inline dispatch_queue_t MMMemoryCacheGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}
#endif

@interface _MMLinkedMapNode : NSObject {
    @package
    __unsafe_unretained _MMLinkedMapNode *_prev;
    __unsafe_unretained _MMLinkedMapNode *_next;
    id _key;
    id _value;
    NSUInteger _cost;
    NSTimeInterval _time;
}

@end

@implementation _MMLinkedMapNode
@end


@interface _MMLinkedMap : NSObject {
    @package
    CFMutableDictionaryRef _dic;
    NSUInteger _totalCost;
    NSUInteger _totalCount;
    _MMLinkedMapNode *_head;
    _MMLinkedMapNode *_tail;
    BOOL _releaseOnMainThread;
    BOOL _releaseAsynchronously;
}

- (void)insertNodeAtHead:(_MMLinkedMapNode *)node;

- (void)bringNodeToHead:(_MMLinkedMapNode *)node;

- (void)removeNode:(_MMLinkedMapNode *)node;

- (_MMLinkedMapNode *)removeTailNode;//清除尾部的节点

- (void)removeAll;

@end

@implementation _MMLinkedMap

- (instancetype)init {
    self = [super init];
    _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    _releaseOnMainThread = NO;
    _releaseAsynchronously = NO;
    return self;
}

- (void)dealloc {
    CFRelease(_dic);
}

/*
 插入节点到链表头部
 1.判断是否已有头部
 如果有node->next = _head; _head->prev = node; _head = node;
 如果没有就直接将 _head = _tail = node;
 */
- (void)insertNodeAtHead:(_MMLinkedMapNode *)node {
    CFDictionarySetValue(_dic, (__bridge const void *)(node -> _key), (__bridge const void *)(node));
    _totalCost += node->_cost;
    _totalCount++;
    if (_head) {
        node->_next = _head;
        _head->_prev = node;
        _head = node;
    } else {
        _head = _tail = node;
    }
}

/*
 将已有节点移到头部
 1.如果只有一个节点 返回
 2.如果节点为尾部
    _tail = node->prev
    _tail->next = nil;
 3.节点在中间 
    先切断node后面的前指向
    再切段node前面的后指向
    node->next->prev = node->prev
    node->prev->next = node->next
 
 4.将node的前后指向布置好
    node->next = head
    node->prev = nil;
    _head->prev = node;
    _head = node;
 */
- (void)bringNodeToHead:(_MMLinkedMapNode *)node {
    if (_head == node) return;
    if (_tail == node) {
        _tail = node->_prev;
        _tail->_next = nil;
    } else {
        node->_next->_prev = node->_prev;
        node->_prev->_next = node->_next;
    }
    node->_next = _head;
    node->_prev = nil;
    _head->_prev = node;
    _head = node;
}

/*
 移除节点
 1.先将node后节点的前指向重新指向
 2.再将node前节点的后指向重指向
 3.如果node为head 重新确定 head = node->next;
 4.如果node为tail  重新确定 tail = node->prev;
 */
- (void)removeNode:(_MMLinkedMapNode *)node {
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(node->_key));
    _totalCost -= node->_cost;
    _totalCount--;
    if (node->_next) node->_next->_prev = node->_prev;
    if (node->_prev) node->_prev->_next = node->_next;
    if (_head == node) _head = node->_next;
    if (_tail == node) _tail = node->_prev;
}

- (_MMLinkedMapNode *)removeTailNode {
    if (!_tail) return nil;
    _MMLinkedMapNode *tail = _tail;
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(_tail->_key));
    _totalCost -= _tail->_cost;
    _totalCount--;
    if (_head == _tail) {
        _head = _tail = nil;
    } else {
        _tail = _tail->_prev;
        _tail->_next = nil;
    }
    return tail;
}

- (void)removeAll {
    _totalCount = 0;
    _totalCost = 0;
    _head = nil;
    _tail = nil;
    if (CFDictionaryGetCount(_dic) > 0) { //返回dic里面有多少个value
        CFMutableDictionaryRef holder = _dic;
        _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        if (_releaseAsynchronously) {
            dispatch_queue_t queue = _releaseOnMainThread ? dispatch_get_main_queue() : MMMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                CFRelease(holder);
            });
        } else if (_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CFRelease(holder);
            });
        } else {
            CFRelease(holder);
        }
    }
}



@end

@implementation MMMemoryCache {
    pthread_mutex_t _lock;
    _MMLinkedMap *_lru;
    dispatch_queue_t _queue;
}

- (void)_trimRecursively {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) self = _self;
        if (!self) return ;
        [self _trimInBackground];
        [self _trimRecursively];
    });
}

- (void)_trimInBackground {
    dispatch_async(_queue, ^{
        [self _trimToCost:self->_costLimit];
        [self _trimToCount:self->_countLimit];
        [self _trimToAge:self->_ageLimit];
    });
}

- (void)_trimToCost:(NSUInteger)costLimit {
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (costLimit == 0) {
        [_lru removeAll];
        finish = YES;
    } else if (_lru->_totalCost <= costLimit) {
        finish = YES;
    }
    
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_totalCost > costLimit) {
                _MMLinkedMapNode *node = [_lru removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 100);   //10ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MMMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; //在线程中释放
        });
    }
}

- (void)_trimToCount:(NSUInteger)countLimit {
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (countLimit == 0) {
        [_lru removeAll];
        finish = YES;
    } else if (_lru->_totalCount <= countLimit) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_totalCount > countLimit) {
                _MMLinkedMapNode *node = [_lru removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000);//    10ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MMMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count];
        });
    }
}

- (void)_trimToAge:(NSUInteger)ageLimit {
    BOOL finish = NO;
    NSTimeInterval now = CACurrentMediaTime();
    pthread_mutex_lock(&_lock);
    if (ageLimit <= 0) {
        [_lru removeAll];
        finish = YES;
    } else if (!_lru->_tail || (now - _lru->_tail->_time) <= ageLimit) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = @[].mutableCopy;
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_tail && (now - _lru->_tail->_time) > ageLimit) {
                _MMLinkedMapNode *node = [_lru removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000);
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MMMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count];
        });
    }
}

- (void)_appDidReciveMemoryWarningNotification {
    if (self.didReceiveMemoryWaringBlock) {
        self.didReceiveMemoryWaringBlock(self);
    }
    if (self.shouldRemoveAllObjectsOnMemoryWarning) {
        [self removeAllObjects];
    }
}

- (void)_appDidEnterBackgroundNotification {
    if (self.didEnterBackgroundBlock) {
        self.didEnterBackgroundBlock(self);
    }
    if (self.shouldRemoveAllObjectsWhenEnteringBackground) {
        [self removeAllObjects];
    }
}

#pragma mark    - Public    公开方法
- (instancetype)init {
    self = [super init];
    pthread_mutex_init(&_lock,NULL);
    _lru = [_MMLinkedMap new];
    _queue = dispatch_queue_create("com.mumuno.cache.memory", DISPATCH_QUEUE_SERIAL);
    
    _countLimit = NSUIntegerMax;
    _costLimit = NSUIntegerMax;
    _ageLimit = DBL_MAX;
    _autoTrimInterval = 5.0;
    _shouldRemoveAllObjectsOnMemoryWarning = YES;
    _shouldRemoveAllObjectsWhenEnteringBackground = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidReciveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self _trimRecursively];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_lru removeAll];
    pthread_mutex_destroy(&_lock);
}

- (NSUInteger)totalCount {
    pthread_mutex_lock(&_lock);
    NSUInteger count = _lru->_totalCount;
    pthread_mutex_unlock(&_lock);
    return count;
}

- (NSUInteger)totalCost {
    pthread_mutex_lock(&_lock);
    NSUInteger totalCost = _lru->_totalCost;
    pthread_mutex_unlock(&_lock);
    return totalCost;
}

- (BOOL)releaseOnMainThread {
    pthread_mutex_lock(&_lock);
    BOOL releaseOnMainThread = _lru->_releaseOnMainThread;
    pthread_mutex_unlock(&_lock);
    return releaseOnMainThread;
}

- (void)setReleaseOnMainThread:(BOOL)releaseOnMainThread {
    pthread_mutex_lock(&_lock);
    _lru->_releaseOnMainThread = releaseOnMainThread;
    pthread_mutex_unlock(&_lock);
}

- (BOOL)containsObjcectForKey:(id)key {
    if (!key) return nil;
    pthread_mutex_lock(&_lock);
    BOOL contains = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)(key));
    pthread_mutex_unlock(&_lock);
    return contains;
}

- (id)objectForKey:(id)key {
    if (!key) return nil;
    pthread_mutex_lock(&_lock);
    _MMLinkedMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)(key));
    if (node) {
        node->_time = CACurrentMediaTime();
        [_lru bringNodeToHead:node];
    }
    pthread_mutex_unlock(&_lock);
    return node ? node->_value : nil;
}

- (void)setObject:(id)object forKey:(id)key {
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost {
    if (!key) return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    
    pthread_mutex_lock(&_lock);
    _MMLinkedMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)(key));
    NSTimeInterval now = CACurrentMediaTime();
    if (node) {
        _lru->_totalCost -= node->_cost;
        _lru->_totalCost += cost;
        node->_cost = cost;
        node->_time = now;
        node->_value = object;
        [_lru bringNodeToHead:node];
    } else {
        node = [_MMLinkedMapNode new];
        node->_cost = cost;
        node->_time = now;
        node->_key = key;
        node->_value = object;
        [_lru insertNodeAtHead:node];
    }
    if (_lru->_totalCost > _costLimit) {
        dispatch_async(_queue, ^{
            [self trimToCost:_costLimit];
        });
    }
    if (_lru->_totalCount > _countLimit) {
        _MMLinkedMapNode *node = [_lru removeTailNode];
        if (_lru->_releaseAsynchronously) {
            dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MMMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class];//这里是为了给node增加使用的周期，如果没有在开的queue中调用node的方法，node就会在queue之前被释放掉 这样做的目的是为了让node在开的子线程中进行释放而不是在主线程
            });
        } else if (_lru->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class];
            });
        }
    }
    pthread_mutex_unlock(&_lock);
}

- (void)removeObjectForKey:(id)key {
    if (!key) return;
    pthread_mutex_lock(&_lock);
    _MMLinkedMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)(key));
    if (node) {
        [_lru removeNode:node];
        if (_lru->_releaseAsynchronously) {
            dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MMMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class];
            });
        } else if (_lru->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class];
            });
        }
    }
    pthread_mutex_unlock(&_lock);
}

- (void)removeAllObjects {
    pthread_mutex_lock(&_lock);
    [_lru removeAll];
    pthread_mutex_unlock(&_lock);
}

- (void)trimToCount:(NSUInteger)count {
    if (count == 0) {
        [self removeAllObjects];
        return;
    }
    [self _trimToCount:count];
}

- (void)trimToCost:(NSUInteger)cost {
    [self _trimToCost:cost];
}

- (void)trimToAge:(NSTimeInterval)age {
    [self _trimToAge:age];
}

- (NSString *)description {
    if (_name) return [NSString stringWithFormat:@"<%@: %p>(%@)",self.class,self,_name];
    else return [NSString stringWithFormat:@"<%@: %p>",self.class,self];
}

@end

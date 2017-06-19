//
//  MMWebImageOperation.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/5/12.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMWebImageOperation.h"
#import "UIApplication+MMAdd.h"
#import "UIImage+MMAdd.h"
#import <ImageIO/ImageIO.h> //kCGImagePropertyJFIFIsProgressive

#import "MMImage.h"
#import "MMKitMacro.h"
#import "MMWeakProxy.h"

#if __has_include("MMDispatchQueuePool.h")
#import "MMDispatchQueuePool.h"
#else
#import <libkern/OSAtomic.h>
#endif

static BOOL MMCGImageLastPixelFilled(CGImageRef image) {
    if (!image)     return NO;
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    if (width == 0 || height == 0) return NO;
    CGContextRef context = CGBitmapContextCreate(NULL, 1, 1, 8, 0, MMCGColorSpaceGetDeviceRGB(), kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault);
    if (!context) return NO;
    CGContextDrawImage(context, CGRectMake(-(int)width + 1, 0, width, height), image);
    uint8_t *bytes = CGBitmapContextGetData(context);
    BOOL isAlpha = bytes && bytes[0] == 0;
    CFRelease(context);
    return !isAlpha;
}

static NSData *JPEGSOSMarker() {
    static NSData *marker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uint8_t bytes[2] = {0xFF, 0xDA};
        marker = [NSData dataWithBytes:bytes length:2];
    });
    return marker;
}

static NSMutableSet *URLBlacklist;
static dispatch_semaphore_t URLBlackListBlock;

static void URLBlackListInit() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        URLBlacklist = [NSMutableSet new];
        URLBlackListBlock = dispatch_semaphore_create(1);
    });
}

static BOOL URLBlacListContains(NSURL *url) {
    if (!url || url == (id)[NSNull null]) return NO;
    URLBlackListInit();
    dispatch_semaphore_wait(URLBlackListBlock, DISPATCH_TIME_FOREVER);
    BOOL contains = [URLBlacklist containsObject:url];
    dispatch_semaphore_signal(URLBlackListBlock);
    return contains;
}

static void URLInBlackListAdd(NSURL *url) {
    if (!url || url == (id)[NSNull null]) return;
    URLBlackListInit();
    dispatch_semaphore_wait(URLBlackListBlock, DISPATCH_TIME_FOREVER);
    [URLBlacklist addObject:url];
    dispatch_semaphore_signal(URLBlackListBlock);
}

@interface MMWebImageOperation ()<NSURLConnectionDelegate>
@property (readwrite, getter=isExecuting) BOOL executing;
@property (readwrite, getter=isFinished) BOOL finished;
@property (readwrite, getter=isCancelled) BOOL  cancelled;
@property (readwrite, getter=isStarted) BOOL started;
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) NSInteger expectedSize;
@property (nonatomic, assign) UIBackgroundTaskIdentifier taskID;

@property (nonatomic, assign) NSTimeInterval lastProgressiveDecodeTimeStamp;
@property (nonatomic, strong) MMImageDecoder *progressiveDecoder;
@property (nonatomic, assign) BOOL progressiveIgnored;
@property (nonatomic, assign) BOOL progressiveDetected;
@property (nonatomic, assign) NSUInteger progressiveScanedLength;
@property (nonatomic, assign) NSUInteger progressiveDisplayCount;

@property (nonatomic, copy) MMWebImageProgressBlock progress;
@property (nonatomic, copy) MMWebImageTransformBlock transform;
@property (nonatomic, copy) MMWebImageCompletionBlock completion;

@end

@implementation MMWebImageOperation

@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancelled = _cancelled;

+ (void)_networkThreadMain:(id)object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"com.mumusa.mmkit.webimage.request"];
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
        [runloop run];
    }
}

+ (NSThread *)_networkThread {
    static NSThread *thread = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(_networkThreadMain:) object:nil];
        if ([thread respondsToSelector:@selector(setQualityOfService:)]) {
            thread.qualityOfService = NSQualityOfServiceBackground;
        }
        [thread start];
    });
    return thread;
}

+ (dispatch_queue_t)_imageQueue {
#ifdef MMDispatchQueuePool_h
    return MMDispatchQueueGetForQOS(NSQualityOfServiceUtility);
#else
    #define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0)  {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0);
                queues[i] = dispatch_queue_create("com.mumusa.mmkit.decode", attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.mumusa.mmkit.decode", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
            }
        }
    });
    
    int32_t cur = OSAtomicIncrement32(&counter);
    if (cur < 0) cur = -cur;
    return queues[(cur) % queueCount];
    #undef MAX_QUEUE_COUNT //define 作用域标示
#endif
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"MMWebImageOperation init error" reason:@"MMWebImageOperation must be initialized with request . Use the designated initialized to init" userInfo:nil];
    return [self initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]] options:0 cache:nil cacheKey:nil progress:nil transform:nil completion:nil];
}

- (instancetype)initWithRequest:(NSURLRequest *)request
                        options:(MMWebImageOptions)options
                          cache:(MMImageCache *)cache
                       cacheKey:(NSString *)cacheKey
                       progress:(MMWebImageProgressBlock)progress
                      transform:(MMWebImageTransformBlock)transform
                     completion:(MMWebImageCompletionBlock)completion {
    self = [super init];
    if (!self) return nil;
    if (!request) return nil;
    _request = request;
    _options = options;
    _cache = cache;
    _cacheKey = cacheKey;
    _progress = progress;
    _transform = transform;
    _completion = completion;
    _executing = NO;
    _finished = NO;
    _cancelled = NO;
    _taskID = UIBackgroundTaskInvalid;
    _lock = [NSRecursiveLock new];
    return self;
}

- (void)dealloc {
    [_lock lock];
    if (_taskID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedExtensionApplication] endBackgroundTask:_taskID];
        _taskID = UIBackgroundTaskInvalid;
    }
    if ([self isExecuting]) {
        self.cancelled = YES;
        self.finished = YES;
        if (_connection) {
            [_connection cancel];
            if (![_request.URL isFileURL] && (_options & MMWebImageOptionShowNetworkActivity)) {
                [[UIApplication sharedExtensionApplication] decrementNetworkActivityCount];
            }
        }
        if (_completion) {
            @autoreleasepool {
                _completion(nil, _request.URL, MMWebImageFromNone, MMWebImageStageCancelled, nil);
            }
        }
    }
    [_lock unlock];
}

- (void)_endBackgroundTask {
    [_lock lock];
    if (_taskID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedExtensionApplication] endBackgroundTask:_taskID];
        _taskID = UIBackgroundTaskInvalid;
    }
    [_lock unlock];
}

- (void)_finish {
    self.executing = NO;
    self.finished = YES;
    [self _endBackgroundTask];
}

- (void)_startOperation {
    if ([self isCancelled]) return;
    @autoreleasepool {
        if (_cache &&
            !(_options & MMWebImageOptionUseNSURLCache) &&
            !(_options & MMWebImageOptionRefreshImageCache)) {
            UIImage *image = [_cache getImageForKey:_cacheKey withType:MMImageCacheTypeMemory];
            if (image) {
                [_lock lock];
                if (![self isCancelled]) {
                    if (_completion) _completion(image, _request.URL, MMWebImageFromMemoryCache, MMWebImageStageFinished, nil);
                }
                [self _finish];
                [_lock unlock];
                return;
            }
            if (!(_options & MMWebImageOptionIngnoreDiskCache)) {
                __weak typeof(self) _self = self;
                dispatch_async([self.class _imageQueue], ^{
                    __strong typeof(_self) self = _self;
                    if (!self || [self isCancelled]) return;
                    UIImage *image = [self.cache getImageForKey:self.cacheKey withType:MMImageCacheTypeDisk];
                    if (image) {
                        [self.cache setImage:image imageData:nil forKey:self.cacheKey withType:MMImageCacheTypeMemory];
                        [self performSelector:@selector(_didReceiveImageFromDiskCache:) onThread:[self.class _networkThread] withObject:image waitUntilDone:NO];
                    } else {
                        [self performSelector:@selector(_startRequest:) onThread:[self.class _networkThread] withObject:nil waitUntilDone:NO];
                    }
                });
                return;
            }
        }
    }
    [self performSelector:@selector(_startRequest:) onThread:[self.class _networkThread] withObject:nil waitUntilDone:NO];
}

- (void)_startRequest:(id)object {
    if ([self isCancelled]) return;
    @autoreleasepool {
        if ((_options & MMWebImageOptionIgnoreFailedURL) && URLBlacListContains(_request.URL)) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{NSLocalizedDescriptionKey : @"Failed to load URL, blacklisted"}];
            [_lock lock];
            if (![self isCancelled]) {
                if (_completion) _completion(nil, _request.URL, MMWebImageFromNone, MMWebImageStageFinished, error);
            }
            [self _finish];
            [_lock unlock];
            return;
        }
        
        if (_request.URL.isFileURL) {
            NSArray *kes = @[NSURLFileSizeKey];
            NSDictionary *attr = [_request.URL resourceValuesForKeys:kes error:nil];
            NSNumber *fileSize = attr[NSURLFileSizeKey];
            _expectedSize = fileSize ? fileSize.unsignedIntegerValue : -1;
        }
        
        [_lock lock];
        if (![self isCancelled]) {
            _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:[MMWeakProxy proxyWithTarget:self]];
            if (![_request.URL isFileURL] && (_options & MMWebImageOptionShowNetworkActivity)) {
                [[UIApplication sharedExtensionApplication] incrementNetworkActivityCount];
            }
        }
        [_lock unlock];
    }
}

- (void)_cancleOperation {
    @autoreleasepool {
        if (_connection) {
            if (![_request.URL isFileURL] && (_options & MMWebImageOptionShowNetworkActivity)) {
                [[UIApplication sharedExtensionApplication] decrementNetworkActivityCount];
            }
        }
        [_connection cancel];
        _connection = nil;
        if (_completion) _completion(nil, _request.URL, MMWebImageFromNone, MMWebImageStageCancelled, nil);
        [self _endBackgroundTask];
    }
}

- (void)_didReceiveImageFromDiskCache:(UIImage *)image {
    @autoreleasepool {
        [_lock lock];
        if (![self isCancelled]) {
            if (image) {
                if (_completion) _completion(image, _request.URL, MMWebImageFromDiskCache, MMWebImageStageFinished, nil);
                [self _finish];
            } else {
                [self _startRequest:nil];
            }
        }
        [_lock unlock];
    }
}

- (void)_didReceiveImageFromWeb:(UIImage *)image {
    @autoreleasepool {
        [_lock lock];
        if (![self isCancelled]) {
            if (_cache) {
                if (image || (_options & MMWebImageOptionRefreshImageCache)) {
                    NSData *data = _data;
                    dispatch_sync([MMWebImageOperation _imageQueue], ^{
                        [_cache setImage:image imageData:data forKey:_cacheKey withType:MMImageCacheTypeAll];
                    });
                }
            }
            _data = nil;
            NSError *error = nil;
            if (!image) {
                error = [NSError errorWithDomain:@"com.ibireme." code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Web image decode fail."}];
                if (_options & MMWebImageOptionIgnoreFailedURL) {
                    if (URLBlacListContains(_request.URL)) {
                        error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{ NSLocalizedDescriptionKey : @"Failed to load URL, blacklisted. "}];
                    } else {
                        URLInBlackListAdd(_request.URL);
                    }
                }
            }
            if (_completion) _completion(image, _request.URL, MMWebImageFromNone, MMWebImageStageFinished, error);
            [self _finish];
        }
        [_lock unlock];
    }
}

#pragma mark - NSURLConnectionDelegate run in operation thread

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return _shouldUseCredentialStorage;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    @autoreleasepool {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if (!(_options & MMWebImageOptionAllowBackInvalidSSLCertificates) &&[challenge.sender respondsToSelector:@selector(performDefaultHandlingForAuthenticationChallenge:)]) {
                [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
            } else {
                NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
            }
        }else {
            if (challenge.previousFailureCount == 0) {
                if (_credential) {
                    [challenge.sender useCredential:_credential forAuthenticationChallenge:challenge];
                } else {
                    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
                }
            } else {
                [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
        }
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    if (!cachedResponse) return cachedResponse;
    if (_options & MMWebImageOptionUseNSURLCache) {
        return cachedResponse;
    } else {
        // ignore NSURLCache
        return nil;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    @autoreleasepool {
        NSError *error = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (id)response;
            NSInteger statuCode = httpResponse.statusCode;
            if (statuCode >= 400 || statuCode == 304) {
                error = [NSError errorWithDomain:NSURLErrorDomain code:statuCode userInfo:nil];
            }
        }
        if (error) {
            [_connection cancel];
            [self connection:_connection didFailWithError:error];
        } else {
            if ([response expectedContentLength]) {
                _expectedSize = (NSInteger)response.expectedContentLength;
                if (_expectedSize < 0) _expectedSize = -1;
            }
            _data = [NSMutableData dataWithCapacity:_expectedSize > 0 ? _expectedSize : 0];
            if (_progress) {
                [_lock lock];
                if (![self isCancelled]) _progress(0, _expectedSize);
                [_lock unlock];
            }
        }
    }
}

#define MIN_PROGRESSIVE_TIME_INTERVAL  0.2
#define MIN_PROGRESSIVE_BLUR_TIME_INTERVAL  0.4
- (void)connection:(NSURLConnection *)connection didReceiveData:(nonnull NSData *)data {
    @autoreleasepool {
        [_lock lock];
        BOOL cancelled = [self isCancelled];
        [_lock unlock];
        
        if (cancelled) return;
        if (data) [_data appendData:data];
        if (_progress) {
            [_lock lock];
            if (![self isCancelled]) {
                _progress(_data.length, _expectedSize);
            }
            [_lock unlock];
        }
    }
    
    BOOL progressive = (_options & MMWebImageOptionProgressive) > 0;
    BOOL progressiveBlur = (_options & MMWebImageOptionProgressiveBlur) > 0;
    if (!_completion || !(progressive || progressiveBlur)) return;
    if (data.length <= 16) return;
    if (_expectedSize > 0 && data.length >= _expectedSize * 0.99) return;
    if (_progressiveIgnored) return;
    
    NSTimeInterval min = progressiveBlur ? MIN_PROGRESSIVE_BLUR_TIME_INTERVAL : MIN_PROGRESSIVE_TIME_INTERVAL;
    NSTimeInterval now = CACurrentMediaTime();
    if (now - _lastProgressiveDecodeTimeStamp < min) return;
    
    if (!_progressiveDecoder) {
        _progressiveDecoder = [[MMImageDecoder alloc] initWithScale:[UIScreen mainScreen].scale];
    }
    [_progressiveDecoder updateData:_data final:NO];
    if ([self isCancelled]) return;
    
    if (_progressiveDecoder.type == MMImageTypeUnknown ||
        _progressiveDecoder.type == MMImageTypeWebP ||
        _progressiveDecoder.type == MMImageTypeOther) {
        _progressiveDecoder  = nil;
        _progressiveIgnored = YES;
        return;
    }
    if (progressiveBlur) {
        if (_progressiveDecoder.type != MMImageTypeJPEG &&
            _progressiveDecoder.type != MMImageTypePNG) {
            _progressiveDecoder = nil;
            _progressiveIgnored = YES;
            return;
        }
    }
    if (_progressiveDecoder.frameCount == 0) return;
    if (!progressiveBlur) {
        MMImageFrame *frame = [_progressiveDecoder frameAtIndex:0 decodeForDisplay:YES];
        if (frame.image) {
            [_lock lock];
            if (![self isCancelled]) {
                _completion(frame.image, _request.URL, MMWebImageFromRemote, MMWebImageStageProgress, nil);
                _lastProgressiveDecodeTimeStamp = now;
            }
            [_lock lock];
        }
        return;
    } else {
        if (_progressiveDecoder.type == MMImageTypeJPEG) {
            if (!_progressiveDetected) {
                NSDictionary *dic = [_progressiveDecoder framePropertiesAtIndex:0];
                NSDictionary *jpeg = dic[(id)kCGImagePropertyJFIFIsProgressive];
                NSNumber *isProg = jpeg[(id)kCGImagePropertyJFIFIsProgressive];
                if (!isProg.boolValue) {
                    _progressiveIgnored = YES;
                    _progressiveDecoder = nil;
                    return;
                }
                _progressiveDetected = YES;
            }
            
            NSInteger scanLength = (NSInteger)_data.length - (NSInteger)_progressiveScanedLength - 4;
            if (scanLength <= 2) return;
            NSRange scanRange = NSMakeRange(_progressiveScanedLength, scanLength);
            NSRange marketRange = [_data rangeOfData:JPEGSOSMarker() options:kNilOptions range:scanRange];
            _progressiveScanedLength = data.length;
            if (marketRange.location == NSNotFound) return;
            if ([self isCancelled]) return;
        } else if (_progressiveDecoder.type == MMImageTypePNG) {
            if (!_progressiveDetected) {
                NSDictionary *dic = [_progressiveDecoder framePropertiesAtIndex:0];
                NSDictionary *png = dic[(id)kCGImagePropertyPNGDictionary];
                NSNumber *isProg = png[(id)kCGImagePropertyPNGInterlaceType];
                if (!isProg.boolValue) {
                    _progressiveIgnored = YES;
                    _progressiveDecoder = nil;
                    return;
                }
                _progressiveDetected = YES;
            }
        }
        
        MMImageFrame *frame = [_progressiveDecoder frameAtIndex:0 decodeForDisplay:YES];
        UIImage *image = frame.image;
        if (!image) return;
        if ([self isCancelled]) return;
        
        if (!MMCGImageLastPixelFilled(image.CGImage)) return;
        _progressiveDisplayCount++;
        
        CGFloat radius = 32;
        if (_expectedSize > 0) {
            radius *= 1.0 / (2 * _data.length / (CGFloat)_expectedSize + 0.6) - 0.25;
        } else {
            radius /= (_progressiveDisplayCount);
        }
        
        image = [image imageByBlurRadius:radius tintColor:nil tintMode:kCGBlendModeNormal saturation:1 maskImage:nil];
        if (image) {
            [_lock lock];
            if (![self isCancelled]) {
                if (_completion) _completion(image, _request.URL, MMWebImageFromRemote, MMWebImageStageProgress, nil);
                _lastProgressiveDecodeTimeStamp = now;
            }
            [_lock unlock];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    @autoreleasepool {
        [_lock lock];
        
        [_lock unlock];
    }
}






@end

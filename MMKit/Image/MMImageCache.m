//
//  MMImageCache.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/5/11.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMImageCache.h"
#import "MMMemoryCache.h"
#import "MMDiskCache.h"
#import "UIImage+MMAdd.h"
#import "NSObject+MMAdd.h"
#import "MMImage.h"

#if __has_include("MMDispatchQueuePool.h")
#import "MMDispatchQueuePool.h"
#endif

static inline dispatch_queue_t MMImageCacheIOQueue() {
#ifdef MMDispatchQueuePool_h
    return MMDispatchQueueGetForQOS(NSQualityOfServiceDefault);
#else
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
#endif
}

//用于图片decode 的队列
static inline dispatch_queue_t MMImageCacheDecodeQueue() {
#ifdef MMDispatchQueuePool_h
    return MMDispatchQueueGetForQOS(NSQualityOfServiceUtility);
#else
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
#endif
}

@interface MMImageCache ()

- (NSUInteger)imageCost:(UIImage *)image;
- (UIImage *)imageFromData:(NSData *)data;

@end

@implementation MMImageCache

- (NSUInteger)imageCost:(UIImage *)image {
    CGImageRef cgImage = image.CGImage;
    if (!cgImage) return 1;
    CGFloat height = CGImageGetHeight(cgImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);    //计算图片大小通过每行字节大小 * 行高
    NSUInteger cost = bytesPerRow * height;
    if (cost == 0) cost = 1;
    return cost;
}

- (UIImage *)imageFromData:(NSData *)data {
    NSData *scaleData = [MMDiskCache getExtendedDataFromObject:data];
    CGFloat scale = 0;
    if (scaleData) {
        scale = [(NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithData:scaleData] doubleValue];
    }
    if (scale <= 0) scale = [UIScreen mainScreen].scale;
    UIImage *image;
    if (_allowAnimatedImage) {
        image = [[YYImage alloc] initWithData:data scale:scale];
        if (_decodeForDisplay) image = [image imageByDecoded];
    } else {
        
    }
    return image;
}

#pragma mark  Public

+ (instancetype)sharedCache {
    static MMImageCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        cachePath = [cachePath stringByAppendingPathComponent:@"com.mumuno.mmkit"];
        cachePath = [cachePath stringByAppendingPathComponent:@"images"];
        cache = [[self alloc] initWithPath:cachePath];
    });
    return cache;
}

- (instancetype)initWithPath:(NSString *)path {
    MMMemoryCache *memoryCache = [MMMemoryCache new];
    memoryCache.shouldRemoveAllObjectsOnMemoryWarning = YES;
    memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = YES;
    memoryCache.countLimit = NSUIntegerMax;
    memoryCache.costLimit = NSUIntegerMax;
    memoryCache.ageLimit = 12 * 60 * 60;
    
    MMDiskCache *diskCache = [[MMDiskCache alloc] initWithPath:path];
    diskCache.customArchiveBlock = ^(id object){ return (NSData *)object; };
    diskCache.customUnarchiveBlock = ^(NSData *data) {return (id)data;};
    if (!diskCache || !memoryCache) return nil;
    
    self = [super init];
    _memoryCache = memoryCache;
    _diskCache = diskCache;
    _allowAnimatedImage = YES;
    _decodeForDisplay = YES;
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"MMImageCache init error" reason:@"MMImaegCache must be initialized with a path , Use 'initWithPath:' instead" userInfo:nil];
    return [self initWithPath:@""];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    [self setImage:image imageData:nil forKey:key withType:MMImageCacheTypeAll];
}

- (void)setImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key withType:(MMImageCacheType)type {
    if (!key || (image == nil && imageData.length == 0)) return;
    
    __weak typeof(self) _self = self;
    if (type & MMImageCacheTypeMemory) {    //add MemoryCache type 是否包含MMImageCacheTypeMemory
        if (image) {
            if (image.isDecodedForDisplay) { //isDecodedForDisplay控制着图片显示在屏幕上是否需要额外的解码  如果已解码好就直接缓存，否则通过DecodeQueue进行解码后再缓存
                [_memoryCache setObject:image forKey:key withCost:[_self imageCost:image]];
            } else {
                dispatch_async(MMImageCacheDecodeQueue(), ^{
                    __strong typeof(_self) self = _self;
                    if (!self) return ;
                    [self.memoryCache setObject:[image imageByDecoded] forKey:key withCost:[self imageCost:image]];
                });
            }
        } else if (imageData) {
            dispatch_async(MMImageCacheDecodeQueue(), ^{
                __strong typeof(_self) self = _self;
                if (!self) return ;
                UIImage *newImage = [self imageFromData:imageData];
                [self.memoryCache setObject:newImage forKey:key withCost:[self imageCost:newImage]];
            });
        }
    }
    
    if (type & MMImageCacheTypeDisk) {
        if (imageData) {
            [MMDiskCache setExtendedData:[NSKeyedArchiver archivedDataWithRootObject:@(image.scale)] toObject:imageData];
        } else if (image) {
            dispatch_async(MMImageCacheIOQueue(), ^{
                __strong typeof(_self) self = _self;
                if (!self) return ;
                NSData *data = [image imageDataRepresentation];
                [MMDiskCache setExtendedData:[NSKeyedArchiver archivedDataWithRootObject:@(image.scale)] toObject:data];
                [self.diskCache setObject:data forKey:key];
            });
        }
    }
}

- (void)removeImageForKey:(NSString *)key {
    [self removeImageForKey:key withType:MMImageCacheTypeAll];
}

- (void)removeImageForKey:(NSString *)key withType:(MMImageCacheType)type {
    if (type & MMImageCacheTypeMemory) [_memoryCache removeObjectForKey:key];
    if (type & MMImageCacheTypeDisk) [_diskCache removeObjectForKey:key];
}

- (BOOL)containsImageForKey:(NSString *)key {
    return [self containsImageForKey:key withType:MMImageCacheTypeAll];
}

- (BOOL)containsImageForKey:(NSString *)key withType:(MMImageCacheType)type {
    if (type & MMImageCacheTypeMemory) {
        if ([_memoryCache containsObjcectForKey:key]) return YES;
    }
    if (type & MMImageCacheTypeDisk) {
        if ([_diskCache containsObjectForKey:key]) return YES;
    }
    return NO;
}

- (UIImage *)getImageForKey:(NSString *)key {
    return [self getImageForKey:key withType:MMImageCacheTypeAll];
}

- (UIImage *)getImageForKey:(NSString *)key withType:(MMImageCacheType)type {
    if (!key) return nil;
    if (type & MMImageCacheTypeMemory) {
        UIImage *image = [_memoryCache objectForKey:key];
        if (image) return image;
    }
    if (type & MMImageCacheTypeDisk) {
        NSData *data = (id)[_diskCache objectForKey:key];
        UIImage *image = [self imageFromData:data];
        if (image && (type & MMImageCacheTypeMemory)) {
            [_memoryCache setObject:image forKey:key withCost:[self imageCost:image]];
        }
        return image;
    }
    return nil;
}

- (void)getImageForKey:(NSString *)key withType:(MMImageCacheType)type withBlock:(void (^)(UIImage * image, MMImageCacheType))block {
    if (!block) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = nil;
        if (type & MMImageCacheTypeMemory) {
            image = [_memoryCache objectForKey:key];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(image, MMImageCacheTypeMemory);
                });
                return;
            }
        }
        
        if (type & MMImageCacheTypeDisk) {
            NSData *data = (id)[_diskCache objectForKey:key];
            image = [self imageFromData:data];
            if (image) {
                [_memoryCache setObject:image forKey:key];
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(image, MMImageCacheTypeDisk);
                });
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil, MMImageCacheTypeNone);
        });
    });
}

- (NSData *)getImageDataForKey:(NSString *)key {
    return (id)[_diskCache objectForKey:key];
}

- (void)getImageDataForKey:(NSString *)key withBlock:(void (^)(NSData * imageData))block {
    if (!block) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = (id)[_diskCache objectForKey:key];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(data);
        });
    });
}

@end

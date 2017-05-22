//
//  MMImageCache.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/5/11.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//


#import <UIKit/UIKit.h>

@class MMMemoryCache, MMDiskCache;


NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, MMImageCacheType) {
    MMImageCacheTypeNone = 0,                       //二进制0000，十进制1
    MMImageCacheTypeMemory = 1 << 0,                //0001, 1
    MMImageCacheTypeDisk = 1 << 1,                  //0010, 2
    MMImageCacheTypeAll = MMImageCacheTypeDisk | MMImageCacheTypeMemory, //0001 | 0010 = 0011, 3
    
    /**
     MMOption option = MMOption1 | MMOption2;   //0001 | 0010 = 0011,3
     
     检查是否包含某选项
     if(option & MMOption3) { //0011 & 0100 = 0000
        //包含MMOption3
     } else {
        //不包含MMOption3
     }
     
     增加选项
     option = option | MMOption4;//0011 | 1000 = 1011, 11
     
     减少选项
     option = option & (~MMOption4);// 1011 & (~1000) = 0011, 3
     */

};

/**
 imageCache 缓存也是分别做了memoryCache 和 diskCache
 diskCachePath = [NSSearchPathForDirectoriesInDomains(NSCacheDirectory, NSUserDomainMask, YES), lastObject];
 diskCachePath/com.ibireme.yykit/images
 
 
 allowAnimatedImage 这个属性用于控制从diskMemory读取图片时对gif 进行解码，默认是YES
 decodeForDisplay   默认是YES 用于控制是否将图片解码成位图到内存中
 
 方法提供三个方面 都是通过key
 1.增改 
    setImage: forKey:
    setImage: imageData: forKey: withType:
 2.删
    removeImageForKey:
    removeImageForKey: withType:
 3.查
    containImageForKey:
    contaimImageForKey: withType:
    
    getImageForKey:
    getImgaeForKey: withType:
    getImageForKey: withType: withBlock:
    getImageDataForKey:
    getImageDataForKey: withBlock:
 
 
 ImageCacheI/O
 1.通过创建优先级为NSQualityOfServiceDefault／DISPATCH_QUEUE_PRIORITY_DEFAULT 的队列I／O操作
 
 ImageCacheDecode
 1.通过创建优先级为NSQualityOfServiceDefault／DISPATCH_QUEUE_PRIORITY_DEFAULT 的队列进行解码操作
 
 内部匿名方法
 1.获取图片的大小
 2.imageData->UIImage

 
 */


@interface MMImageCache : NSObject
#pragma mark -Attribute

@property (nullable, copy) NSString *name;

@property (strong, readonly) MMMemoryCache *memoryCache;

@property (strong, readonly) MMDiskCache *diskCache;

@property BOOL allowAnimatedImage;  //运行动图

@property BOOL decodeForDisplay;

#pragma mark    - Initializer

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

+ (instancetype)sharedCache;

- (nullable instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

#pragma mark - Access Mehtods

- (void)setImage:(UIImage *)image forKey:(NSString *)key;

- (void)setImage:(nullable UIImage *)image
       imageData:(nullable NSData *)imageData
          forKey:(NSString *)key
        withType:(MMImageCacheType)type;

- (nullable UIImage *)getImageForKey:(NSString *)key;

- (nullable UIImage *)getImageForKey:(NSString *)key withType:(MMImageCacheType)type;

- (void)getImageForKey:(NSString *)key
              withType:(MMImageCacheType)type
             withBlock:(void(^)(UIImage * _Nullable image, MMImageCacheType type))block;

- (nullable NSData *)getImageDataForKey:(NSString *)key;

- (void)getImageDataForKey:(NSString *)key withBlock:(void(^)(NSData * _Nullable imageData))block;

- (void)removeImageForKey:(NSString *)key;

- (void)removeImageForKey:(NSString *)key withType:(MMImageCacheType)type;

- (BOOL)containsImageForKey:(NSString *)key withType:(MMImageCacheType)type;

- (BOOL)containsImageForKey:(NSString *)key;

@end
NS_ASSUME_NONNULL_END

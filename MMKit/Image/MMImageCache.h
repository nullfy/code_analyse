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

@interface MMImageCache : NSObject

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

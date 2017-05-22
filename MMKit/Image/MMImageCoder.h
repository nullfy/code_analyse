//
//  MMImageCoder.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/5/12.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MMImageType) {
    MMImageTypeUnknown = 0,
    MMImageTypeJPEG,
    MMImageTypeJPEG2000,
    MMImageTypeTIFF,
    MMImageTypeBMP,
    MMImageTypeICO,
    MMImageTypeICNS,
    MMImageTypeGIF,
    MMImageTypePNG,
    MMImageTypeWebP,
    MMImageTypeOther,
};

/**
 iOS从磁盘中加载一张图片，使用UIImageView 显示在屏幕下需要经过以下步骤
 1.从磁盘拷贝数据到内核缓冲区
 2.从内核缓冲区复制数据到用户空间
 3.生成UIImageView，把图像数据赋值给UIImageView
 4.如果图像数据为未解码的 PNG／JPG，解码为位图数据
 5.CATransaction 捕获到UIImageView layer树的变化
 6.主线程Runloop提交CATransaction，开始进行图像渲染
    6.1.如果数据没有字节对齐，Core Animatiion 会再拷贝一份数据，进行字节对齐
    6.2.GPU 处理位图数据，进行渲染
 
 */


//渲染前处理图片
typedef NS_ENUM(NSUInteger, MMImageDisposeMehtod) {
    MMImageDisposeNone = 0,
    MMImageDisposeBackground,
    MMImageDisposePrevious,
};

//图片合成
typedef NS_ENUM(NSUInteger, MMImageBlendOperation) {
    MMImageBlendNone = 0,
    MMImageBlendOver,
};

@interface MMImageFrame : NSObject<NSCopying>

@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;
@property (nonatomic) NSUInteger offsetX;
@property (nonatomic) NSUInteger offsetY;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) MMImageDisposeMehtod dispose;
@property (nonatomic) MMImageBlendOperation blend;
@property (nullable, nonatomic, strong) UIImage *image;
+ (instancetype)frameWithImage:(UIImage *)image;
@end

@interface MMImageDecoder : NSObject

#pragma mark  - Attribute
@property (nullable, nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) MMImageType type;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) NSUInteger frameCount;
@property (nonatomic, readonly) NSUInteger loopCount;
@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;
@property (nonatomic, readonly, getter = isFinalized) BOOL finalized;

#pragma mark - Public Mehtod
- (instancetype)initWithScale:(CGFloat)scale NS_DESIGNATED_INITIALIZER;

- (BOOL)updateData:(nullable NSData *)data final:(BOOL)finally;

+ (nullable instancetype)decoderWithData:(NSData *)data scale:(CGFloat)scale;

- (nullable MMImageFrame *)frameAtIndex:(NSUInteger)index decodeForDisplay:(BOOL)decodeForDisplay;

- (NSTimeInterval)frameDurationAtIndex:(NSUInteger)index;

- (nullable NSDictionary *)framePropertiesAtIndex:(NSUInteger)index;

- (nullable NSDictionary *)imageProperties;

@end

@interface MMImageEncoder : NSObject

#pragma mark  - Attribute
@property (nonatomic, readonly) MMImageType type;
@property (nonatomic) NSUInteger loopCount;
@property (nonatomic) BOOL lossless;
@property (nonatomic) CGFloat quality;

#pragma mark - Public Mehod
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (nullable instancetype)initWithType:(MMImageType)type NS_DESIGNATED_INITIALIZER;

- (void)addImage:(UIImage *)image duration:(NSTimeInterval)duration;

- (void)addImageWithData:(UIImage *)image duration:(NSTimeInterval)duration;

- (void)addImageWithFile:(NSString *)path duration:(NSTimeInterval)duration;

- (nullable NSData *)encode;

- (BOOL)encodeToFile:(NSString *)path;

+ (nullable NSData *)encodeImage:(UIImage *)image type:(MMImageType)type quality:(CGFloat)quality;

+ (nullable NSData *)encodeImageWithDecoder:(MMImageDecoder *)decoder type:(MMImageType)type quality:(CGFloat)quality;

@end
NS_ASSUME_NONNULL_END

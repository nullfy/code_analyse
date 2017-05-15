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

//渲染前处理图片
typedef NS_ENUM(NSUInteger, MMImageDisposeMehtod) {
    MMImageDisposeNone = 0,
    MMImageDisposeBackground,
    MMImageDisposePrevious,
};

//图片混合
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

@property (nullable, nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) MMImageType type;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) NSUInteger frameCount;
@property (nonatomic, readonly) NSUInteger loopCount;
@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;
@property (nonatomic, readonly, getter = isFinalized) BOOL finalized;

- (instancetype)initWithScale:(CGFloat)scale NS_DESIGNATED_INITIALIZER;

- (BOOL)updateData:(nullable NSData *)data final:(BOOL)finally;

+ (nullable instancetype)decoderWithData:(NSData *)data scale:(CGFloat)scale;

- (nullable MMImageFrame *)frameAtIndex:(NSUInteger)index decodeForDisplay:(BOOL)decodeForDisplay;

- (NSTimeInterval)frameDurationAtIndex:(NSUInteger)index;

- (nullable NSDictionary *)framePropertiesAtIndex:(NSUInteger)index;

- (nullable NSDictionary *)imageProperties;

@end

@interface MMImageEncoder : NSObject

@property (nonatomic, readonly) MMImageType type;
@property (nonatomic) NSUInteger loopCount;
@property (nonatomic) BOOL lossless;
@property (nonatomic) CGFloat quality;

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

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

/**
 ImageFrame 包含了图片等尺寸信息
 */


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

- (void)addImageWithData:(NSData *)data duration:(NSTimeInterval)duration;

- (void)addImageWithFile:(NSString *)path duration:(NSTimeInterval)duration;

- (nullable NSData *)encode;

- (BOOL)encodeToFile:(NSString *)path;

+ (nullable NSData *)encodeImage:(UIImage *)image type:(MMImageType)type quality:(CGFloat)quality;

+ (nullable NSData *)encodeImageWithDecoder:(MMImageDecoder *)decoder type:(MMImageType)type quality:(CGFloat)quality;

@end


#pragma mark - Helper

/// Detect a data's image type by reading the data's header 16 bytes (very fast).
CG_EXTERN MMImageType MMImageDetectType(CFDataRef data);

/// Convert MMImageType to UTI (such as kUTTypeJPEG).
CG_EXTERN CFStringRef _Nullable MMImageTypeToUTType(MMImageType type);

/// Convert UTI (such as kUTTypeJPEG) to MMImageType.
CG_EXTERN MMImageType MMImageTypeFromUTType(CFStringRef uti);

/// Get image type's file extension (such as @"jpg").
CG_EXTERN NSString *_Nullable MMImageTypeGetExtension(MMImageType type);

/// Returns the shared DeviceRGB color space.
CG_EXTERN CGColorSpaceRef MMCGColorSpaceGetDeviceRGB();

/// Returns the shared DeviceGray color space.
CG_EXTERN CGColorSpaceRef MMCGColorSpaceGetDeviceGray();

/// Returns whether a color space is DeviceRGB.
CG_EXTERN BOOL MMCGColorSpaceIsDeviceRGB(CGColorSpaceRef space);

/// Returns whether a color space is DeviceGray.
CG_EXTERN BOOL MMCGColorSpaceIsDeviceGray(CGColorSpaceRef space);

/// Convert EXIF orientation value to UIImageOrientation.
CG_EXTERN UIImageOrientation MMUIImageOrientationFromEXIFValue(NSInteger value);

/// Convert UIImageOrientation to EXIF orientation value.
CG_EXTERN NSInteger MMUIImageOrientationToEXIFValue(UIImageOrientation orientation);



/**
 Create a decoded image.
 
 @discussion If the source image is created from a compressed image data (such as
 PNG or JPEG), you can use this method to decode the image. After decoded, you can
 access the decoded bytes with CGImageGetDataProvider() and CGDataProviderCopyData()
 without additional decode process. If the image has already decoded, this method
 just copy the decoded bytes to the new image.
 
 @param imageRef          The source image.
 @param decodeForDisplay  If YES, this method will decode the image and convert
 it to BGRA8888 (premultiplied) or BGRX8888 format for CALayer display.
 
 @return A decoded image, or NULL if an error occurs.
 */
CG_EXTERN CGImageRef _Nullable MMCGImageCreateDecodedCopy(CGImageRef imageRef, BOOL decodeForDisplay);

/**
 Create an image copy with an orientation.
 
 @param imageRef       Source image
 @param orientation    Image orientation which will applied to the image.
 @param destBitmapInfo Destimation image bitmap, only support 32bit format (such as ARGB8888).
 @return A new image, or NULL if an error occurs.
 */
CG_EXTERN CGImageRef _Nullable MMCGImageCreateCopyWithOrientation(CGImageRef imageRef,
                                                                  UIImageOrientation orientation,
                                                                  CGBitmapInfo destBitmapInfo);

/**
 Create an image copy with CGAffineTransform.
 
 @param imageRef       Source image.
 @param transform      Transform applied to image (left-bottom based coordinate system).
 @param destSize       Destination image size
 @param destBitmapInfo Destimation image bitmap, only support 32bit format (such as ARGB8888).
 @return A new image, or NULL if an error occurs.
 */
CG_EXTERN CGImageRef _Nullable MMCGImageCreateAffineTransformCopy(CGImageRef imageRef,
                                                                  CGAffineTransform transform,
                                                                  CGSize destSize,
                                                                  CGBitmapInfo destBitmapInfo);

/**
 Encode an image to data with CGImageDestination.
 
 @param imageRef  The image.
 @param type      The image destination data type.
 @param quality   The quality (0.0~1.0)
 @return A new image data, or nil if an error occurs.
 */
CG_EXTERN CFDataRef _Nullable MMCGImageCreateEncodedData(CGImageRef imageRef, MMImageType type, CGFloat quality);


/**
 Whether WebP is available in MMImage.
 */
CG_EXTERN BOOL MMImageWebPAvailable();

/**
 Get a webp image frame count;
 
 @param webpData WebP data.
 @return Image frame count, or 0 if an error occurs.
 */
CG_EXTERN NSUInteger MMImageGetWebPFrameCount(CFDataRef webpData);

/**
 Decode an image from WebP data, returns NULL if an error occurs.
 
 @param webpData          The WebP data.
 @param decodeForDisplay  If YES, this method will decode the image and convert it
 to BGRA8888 (premultiplied) format for CALayer display.
 @param useThreads        YES to enable multi-thread decode.
 (speed up, but cost more CPU)
 @param bypassFiltering   YES to skip the in-loop filtering.
 (speed up, but may lose some smooth)
 @param noFancyUpsampling YES to use faster pointwise upsampler.
 (speed down, and may lose some details).
 @return The decoded image, or NULL if an error occurs.
 */
CG_EXTERN CGImageRef _Nullable MMCGImageCreateWithWebPData(CFDataRef webpData,
                                                           BOOL decodeForDisplay,
                                                           BOOL useThreads,
                                                           BOOL bypassFiltering,
                                                           BOOL noFancyUpsampling);

typedef NS_ENUM(NSUInteger, MMImagePreset) {
    MMImagePresetDefault = 0,  ///< default preset.
    MMImagePresetPicture,      ///< digital picture, like portrait, inner shot
    MMImagePresetPhoto,        ///< outdoor photograph, with natural lighting
    MMImagePresetDrawing,      ///< hand or line drawing, with high-contrast details
    MMImagePresetIcon,         ///< small-sized colorful images
    MMImagePresetText          ///< text-like
};

/**
 Encode a CGImage to WebP data
 
 @param imageRef      image
 @param lossless      YES=lossless (similar to PNG), NO=lossy (similar to JPEG)
 @param quality       0.0~1.0 (0=smallest file, 1.0=biggest file)
 For lossless image, try the value near 1.0; for lossy, try the value near 0.8.
 @param compressLevel 0~6 (0=fast, 6=slower-better). Default is 4.
 @param preset        Preset for different image type, default is MMImagePresetDefault.
 @return WebP data, or nil if an error occurs.
 */
CG_EXTERN CFDataRef _Nullable MMCGImageCreateEncodedWebPData(CGImageRef imageRef,
                                                             BOOL lossless,
                                                             CGFloat quality,
                                                             int compressLevel,
                                                             MMImagePreset preset);

NS_ASSUME_NONNULL_END


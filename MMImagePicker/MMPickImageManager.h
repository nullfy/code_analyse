//
//  MMPickImageManager.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@class MMAssetModel, MMAlbumModel;
@interface MMPickImageManager : NSObject

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

@property (nonatomic, weak) id pickerDelegate;

@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;

@property (nonatomic, assign) BOOL shouldFixOrientation;
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;
@property (nonatomic, assign) BOOL hideWhenUnselectable;

+ (instancetype)manager;

+ (NSInteger)authorizationStatus;

- (BOOL)authorizationStatusAuthorized;

- (void)requstAuthorizationWithCompletion:(void(^)())completion;

- (void)getCameraRollAlbum:(BOOL)allowPickImage
            allowPickVideo:(BOOL)allowPickVedio
                completion:(void (^)(MMAlbumModel *model))completion;

- (void)getAllAlbum:(BOOL)allowPickImage
     allowPickVedio:(BOOL)allowVedio
         completion:(void (^)(NSArray<MMAlbumModel *> * models))completion;


- (void)getAssetsFromFetchResult:(id)result
                  allowPickImage:(BOOL)allowPickImage allowPickVideo:(BOOL)allowPickVedio
                      completion:(void (^)(NSArray<MMAlbumModel *> * models))completion;

- (void)getAssetsFromFetchResult:(id)result
                         atIndex:(NSUInteger)index
                  allowPickImage:(BOOL)allowPickImage
                  allowPickVideo:(BOOL)allowPickVedio
                      completion:(void (^)(MMAlbumModel *model))completion;

- (void)getPostImageWithAlbumModel:(MMAlbumModel *)model
                        completion:(void(^)(UIImage *postImage))completion;

- (PHImageRequestID)getPhotoWithAsset:(id)asset
                           completion:(void(^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;

- (PHImageRequestID)getPhotoWithAsset:(id)asset
                           photoWidth:(CGFloat)photoWidth
                           completion:(void(^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;

- (PHImageRequestID)getPhotoWithAsset:(id)asset
                           completion:(void(^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion
                      progressHandler:(void(^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                 networkAccessAllowed:(BOOL)allowed;

- (PHImageRequestID)getPhotoWithAsset:(id)asset
                           photoWidth:(CGFloat)photoWidth
                           completion:(void(^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion
                      progressHandler:(void(^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                 networkAccessAllowed:(BOOL)allowed;;

- (void)getOriginalPhotoWithAsset:(id)asset
                       completion:(void(^)(UIImage *photo, NSDictionary *info))completion;

- (void)getOriginalPhotoWithAsset:(id)asset
                       newCompletion:(void(^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;

- (void)getOriginalPhotoDataWithAsset:(id)asset
                           completion:(void(^)(NSData *data, NSDictionary *info))completion;


- (void)savePhotoWithImage:(UIImage *)image completion:(void(^)(NSError *error))completion;
- (void)savePhotoWithImage:(UIImage *)image location:(CLLocation *)location completion:(void(^)(NSError *error))completion;


- (void)getVideoWithAsset:(id)asset completion:(void(^)(AVPlayerItem *playItem, NSDictionary *info))completion;
- (void)getVideoWithAsset:(id)asset
             progressHandler:(void(^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                  completion:(void(^)(AVPlayerItem *item, NSDictionary *info))completion;

- (void)getVideoPathWithAsset:(id)asset completion:(void(^)(NSString *path))completion;

- (void)getPhotoBytesWithArray:(NSArray *)photos completion:(void(^)(NSString *total))completion;

- (BOOL)isAssetsArray:(NSArray *)assets containAsset:(id)asset;

- (NSString *)getAssetIdentifier:(id)asset;

- (BOOL)isCameraRollAlbum:(NSString *)albumName;

- (CGSize)photoSizeWithAsset:(id)asset;

- (UIImage *)fixOrientation:(UIImage *)image;

@end

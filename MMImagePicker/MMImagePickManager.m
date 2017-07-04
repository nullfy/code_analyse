//
//  MMImagePickManager.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMImagePickManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MMAssetModel.h"
#import "MMImagePickerMacro.h"
#import "MMImagePickerController.h"

static CGSize AssetGridThumbnailSize;
static CGFloat MMScreenScale;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@interface MMImagePickManager()

@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;

@end

@implementation MMImagePickManager

#pragma mark    Getter&Setter
- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    CGFloat margin = 4;
    CGFloat width = (SCREEN_WIDTH - 2 * margin - 4) / columnNumber - margin;
    AssetGridThumbnailSize = CGSizeMake(width * MMScreenScale, width * MMScreenScale);
}

- (ALAssetsLibrary *)library {
    if (_assetLibrary == nil) {
        _assetLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetLibrary;
}

#pragma mark    Method

+ (instancetype)manager {
    static MMImagePickManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        if (kiOS8Later) {
            manager.cachingImageManager = [[PHCachingImageManager alloc] init];
        }
        MMScreenScale = 2.0;
        if (SCREEN_WIDTH > 700)     MMScreenScale = 1.5;
    });
    return manager;
}

+ (NSInteger)authorizationStatus {
    if (kiOS8Later) {
        return [PHPhotoLibrary authorizationStatus];
    } else {
        return [ALAssetsLibrary authorizationStatus];
    }
    return 0;
}

- (BOOL)authorizationStatusAuthorized {
    NSInteger status = [self.class authorizationStatus];
    if (status == 0) {
        [self requstAuthorizationWithCompletion:nil];
    }
    return status == 3;
}

- (void)requstAuthorizationWithCompletion:(void (^)())completion {
    void (^callCompletionBlock)() = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion();
        });
    };
    if (kiOS8Later) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                callCompletionBlock();
            }];
        });
    } else {
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            callCompletionBlock();
        } failureBlock:^(NSError *error) {
            callCompletionBlock();
        }];
    }
}

- (void)getCameraRollAlbum:(BOOL)allowPickImage allowPickVideo:(BOOL)allowPickVideo completion:(void (^)(MMAlbumModel *))completion {
    __block MMAlbumModel *model;
    
    if (kiOS8Later) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        if (!allowPickVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        if (!allowPickImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                                    PHAssetMediaTypeVideo];
        // option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:self.sortAscendingByModificationDate]];
        if (!self.sortAscendingByModificationDate) {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
        }
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *collection in smartAlbums) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            if ([self isCameraRollAlbum:collection.localizedTitle]) {
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                model = [self modelWithResult:fetchResult name:collection.localizedTitle];
                if (completion) completion(model);
                break;
            }
        }
    } else {
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if ([group numberOfAssets] < 1) return;
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            if ([self isCameraRollAlbum:name]) {
                model = [self modelWithResult:group name:name];
                if (completion) completion(model);
                *stop = YES;
            }
        } failureBlock:nil];
    }
}

/*
 获取所有相册文件夹中的图片
 
 */
- (void)getAllAlbum:(BOOL)allowPickImage allowPickVideo:(BOOL)allowVedio completion:(void (^)(NSArray<MMAlbumModel *> *))completion {
    NSMutableArray *albumArray = @[].mutableCopy;
    if (kiOS8Later) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        if (!allowVedio) options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        if (!allowPickImage) options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        
        //options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:self.sortAscendingByModificationDate]];
        if (!self.sortAscendingByModificationDate) {
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
        }
        PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
        PHFetchResult *smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        PHFetchResult *topLevelUserCollections = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:nil];
        PHFetchResult *syncedAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        PHFetchResult *sharedAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
        
        NSArray *allAlbums = @[myPhotoStreamAlbum, smartAlbum, topLevelUserCollections, syncedAlbum, sharedAlbum];
        
        for (PHFetchResult *result in allAlbums) {
            for (PHAssetCollection *collection in result) {
                if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
                if (fetchResult.count < 1) continue;
                
                if ([self.pickerDelegate respondsToSelector:@selector(isAlbumCanSelect:result:)]) {
                    if (![self.pickerDelegate isAlbumCanSelect:collection.localizedTitle result:fetchResult]) {
                        continue;
                    }
                }
                
                if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]) {
                    continue;
                }
                if ([self isCameraRollAlbum:collection.localizedTitle]) {
                    [albumArray insertObject:[self modelWithResult:fetchResult name:collection.localizedTitle] atIndex:0];
                } else {
                    [albumArray addObject:[self modelWithResult:fetchResult name:collection.localizedTitle]];
                }
            }
        }
        if (completion && albumArray.count > 0) completion(albumArray);
    } else {
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group == nil) {
                if (completion && albumArray.count > 0) completion(albumArray);
            }
            
            if ([group numberOfAssets] < 1) return ;
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];//拿到相册分组名
            
            if ([self.pickerDelegate respondsToSelector:@selector(isAlbumCanSelect:result:)]) {
                if (![self.pickerDelegate isAlbumCanSelect:name result:group]) {
                    return;
                }
            }
            
            if ([self isCameraRollAlbum:name]) {
                [albumArray insertObject:[self modelWithResult:group name:name] atIndex:0];
            } else if ([name isEqualToString:@"My Photo Stream"] || [name isEqualToString:@"我的照片流"]) {
                if (albumArray.count) {
                    [albumArray insertObject:[self modelWithResult:group name:name] atIndex:0];
                } else {
                    [albumArray addObject:[self modelWithResult:group name:name]];
                }
            } else {
                [albumArray addObject:[self modelWithResult:group name:name]];
            }
        } failureBlock:nil];
    }
}

//加载单个相册集中的图片
- (void)getAssetsFromFetchResult:(id)result allowPickImage:(BOOL)allowPickImage allowPickVideo:(BOOL)allowPickVideo completion:(void (^)(NSArray<MMAssetModel *> *))completion {
    NSMutableArray *photoArr = [NSMutableArray array];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MMAssetModel *model = [self assetModelWithAsset:obj allowPickImage:allowPickImage allowPickVideo:allowPickVideo];
                                   //assetModelWithAsset:obj allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
            if (model) {
                [photoArr addObject:model];
            }
        }];
        if (completion) completion(photoArr);
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = (ALAssetsGroup *)result;
        if (allowPickImage && allowPickVideo) {
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
        } else if (allowPickVideo) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
        } else if (allowPickImage) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
        ALAssetsGroupEnumerationResultsBlock resultBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop)  {
            if (result == nil) {
                if (completion) completion(photoArr);
            }
            MMAssetModel *model = [self assetModelWithAsset:result allowPickImage:allowPickImage allowPickVideo:allowPickVideo];
                                   //assetModelWithAsset:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
            if (model) {
                [photoArr addObject:model];
            }
        };
        if (self.sortAscendingByModificationDate) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (resultBlock) { resultBlock(result,index,stop); }
            }];
        } else {
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (resultBlock) { resultBlock(result,index,stop); }
            }];
        }
    }
}

- (void)getAssetsFromFetchResult:(id)result atIndex:(NSUInteger)index allowPickImage:(BOOL)allowPickImage allowPickVideo:(BOOL)allowPickVideo completion:(void (^)(MMAssetModel *))completion {
    if ([result isKindOfClass:[PHFetchResult class]]) {//Photos
        PHFetchResult *_result = (PHFetchResult *)result;
        PHAsset *asset;
        @try {
            asset = _result[index];
        } @catch (NSException *exception) {
            if (completion) completion(nil);
        } @finally {
            
        }
        MMAssetModel *model = [self assetModelWithAsset:asset allowPickImage:allowPickImage allowPickVideo:allowPickVideo];
        if (completion) completion(model);
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = (ALAssetsGroup *)result;
        if (allowPickImage && allowPickVideo) {
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
        } else if (allowPickVideo) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
        } else if (allowPickImage) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        @try {
            [group enumerateAssetsAtIndexes:indexSet options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (!result) return ;
                MMAssetModel *model = [self assetModelWithAsset:result allowPickImage:allowPickImage allowPickVideo:allowPickVideo];
                if (completion) completion(model);
            }];
        } @catch (NSException *exception) {
            if (completion) completion(nil);
        } @finally {
            
        }
    }
}



- (MMAssetModel *)assetModelWithAsset:(id)asset allowPickImage:(BOOL)allowImage allowPickVideo:(BOOL)allowVideo{
    BOOL canSelect = YES;
    if ([self.pickerDelegate respondsToSelector:@selector(isAssetCanSelect:)]) {
        canSelect = [self.pickerDelegate isAssetCanSelect:asset];
    }
    if (!canSelect) return nil;
    MMAssetModel *model;
    MMAssetModelMediaType type = MMAssetModelMediaTypePhoto;
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *_asset = (PHAsset *)asset;
        if (_asset.mediaType == PHAssetMediaTypeVideo) {
            type = MMAssetModelMediaTypeVideo;
        } else if (_asset.mediaType == PHAssetMediaTypeAudio) {
            type = MMAssetModelMediaTypeAudio;
        } else if (_asset.mediaType == PHAssetMediaTypeImage) {
            if ([[_asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                type = MMAssetModelMediaTypeGIF;
            }
        }
        if (!allowVideo && type == MMAssetModelMediaTypeVideo) return nil;
        if (!allowImage && type == MMAssetModelMediaTypePhoto) return nil;
        if (!allowImage && type == MMAssetModelMediaTypeGIF) return nil;
        if (self.hideWhenUnselectable) {
            if (![self isPhotoSelectableWithAsset:_asset])     return nil;
        }
        
        NSString *timeLength = type == MMAssetModelMediaTypeVideo ? [NSString stringWithFormat:@"%0.0f",_asset.duration] : @"";
        timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
        model = [MMAssetModel modelWithAsset:_asset type:type];
    } else if([asset isKindOfClass:[ALAsset class]]) {
        if (!allowVideo) {
            model = [MMAssetModel modelWithAsset:asset type:type];
            return model;
        }
        
        if ([[asset valueForProperty:ALAssetPropertyDuration] doubleValue]) {
            type = MMAssetModelMediaTypeVideo;
            NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
            NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
            timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
            model = [MMAssetModel modelWithAsset:asset type:type timeLength:timeLength];
        } else {
            if (self.hideWhenUnselectable) {
                if (![self isPhotoSelectableWithAsset:asset]) return nil;
            }
            model = [MMAssetModel modelWithAsset:asset type:type];
        }
    }
    return model;
}


- (MMAlbumModel *)modelWithResult:(id)result name:(NSString *)name {
    MMAlbumModel *model = [[MMAlbumModel alloc] init];
    model.result = result;
    model.name = name;
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        model.count = fetchResult.count;
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = (ALAssetsGroup *)result;
        model.count = [group numberOfAssets];
    }
    return model;
}

- (BOOL)isPhotoSelectableWithAsset:(id)asset {
    CGSize size = [self photoSizeWithAsset:asset];
    if (self.minPhotoWidthSelectable > size.width ||
        self.minPhotoHeightSelectable > size.height) {
        return NO;
    }
    return YES;
}

- (CGSize)photoSizeWithAsset:(id)asset {
    if (kiOS8Later) {
        PHAsset *_asset = (PHAsset *)asset;
        return CGSizeMake(_asset.pixelWidth, _asset.pixelHeight);
    } else {
        ALAsset *_asset = (ALAsset *)asset;
        return _asset.defaultRepresentation.dimensions;
    }
}

- (NSString *)getNewTimeFromDurationSecond:(NSInteger)time {
    NSString *result;
    if (time < 10) {
        result = [NSString stringWithFormat:@"0:0%zd",time];
    } else if (time < 60) {
        result = [NSString stringWithFormat:@"0:%zd",time];
    } else {
        NSInteger min = floor(time/60);
        NSInteger sec = time - min*60;
        if (sec < 10) {
            result = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            result = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return result;
}

- (void)getPhotoBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *))completion {
    __block NSInteger dataLength = 0;
    __block NSInteger assetCount = 0;
    for (NSInteger i = 0; i < photos.count; i++) {
        MMAssetModel *model = photos[i];
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                if (model.type != MMAssetModelMediaTypeVideo) dataLength += imageData.length;
                assetCount++;
                if (assetCount == photos.count) {
                    NSString *bytes = [self getBytesFromDataLength:dataLength];
                    if (completion) completion(bytes);
                }
            }];
        } else if ([model.asset isKindOfClass:[ALAsset class]]) {
            ALAssetRepresentation *representation = [model.asset defaultRepresentation];
            if (model.type != MMAssetModelMediaTypeVideo) dataLength += (NSInteger)representation.size;
            if (i >= photos.count -1) {
                NSString *bytes = [self getBytesFromDataLength:dataLength];
                if (completion) completion(bytes);
            }
        }
    }
}

- (NSString *)getBytesFromDataLength:(NSInteger)length {
    NSString *bytes;
    if (length >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",length/1024/1024.0];
    } else if (length >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.01fk",length/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdb",length];
    }
    return bytes;
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *, NSDictionary *, BOOL))completion {
    CGFloat width = SCREEN_WIDTH;
    if (width > _photoPreviewMaxWidth) {
        width = _photoPreviewMaxWidth;
    }
    return [self getPhotoWithAsset:asset photoWidth:width completion:completion progressHandler:nil networkAccessAllowed:YES];
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *, BOOL))completion {
    return [self getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *, NSDictionary *, BOOL))completion progressHandler:(void (^)(double, NSError *, BOOL *, NSDictionary *))progressHandler networkAccessAllowed:(BOOL)allowed {
    CGFloat width = SCREEN_WIDTH;
    if (width > _photoPreviewMaxWidth) width = _photoPreviewMaxWidth;
    
    return [self getPhotoWithAsset:asset photoWidth:width completion:completion progressHandler:progressHandler networkAccessAllowed:allowed];
}


- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *, BOOL))completion progressHandler:(void (^)(double, NSError *, BOOL *, NSDictionary *))progressHandler networkAccessAllowed:(BOOL)allowed {
    if ([asset isKindOfClass:[PHAsset class]]) {
        CGSize imageSize;
        if (photoWidth < SCREEN_WIDTH && photoWidth < _photoPreviewMaxWidth) {
            imageSize = AssetGridThumbnailSize;
        } else {
            PHAsset *_asset = (PHAsset *)asset;
            CGFloat aspectRatio = _asset.pixelWidth / (CGFloat)_asset.pixelHeight;
            CGFloat pixelWidth = photoWidth * MMScreenScale * 1.5;
            
            if (aspectRatio > 1) pixelWidth = pixelWidth * aspectRatio;
            if (aspectRatio < 0.2) pixelWidth = pixelWidth * 0.5;
            
            CGFloat pixelHeight = pixelWidth / aspectRatio;
            imageSize = CGSizeMake(pixelWidth, pixelHeight);
        }
        
        __block UIImage *image;
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        PHImageRequestID requstID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) image = result;
            BOOL finished = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (finished && result) {
                result = [self fixOrientation:result];
                if (completion) completion(result, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
            
            if ([info objectForKey:PHImageResultIsInCloudKey] && !result && allowed) {
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressHandler) progressHandler(progress, error, stop, info);
                    });
                };
                option.networkAccessAllowed = YES;
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                    resultImage = [self scaleImage:resultImage toSize:imageSize];
                    if (!resultImage) resultImage = image;
                }];
            }
        }];
        return requstID;
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *_asset = (ALAsset *)asset;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CGImageRef thumbnailImageRef = _asset.thumbnail;
            UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef scale:2.0 orientation:UIImageOrientationUp];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(thumbnailImage, nil, YES);
                
                if (photoWidth == SCREEN_WIDTH || photoWidth == _photoPreviewMaxWidth) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        ALAssetRepresentation *represent = [_asset defaultRepresentation];
                        CGImageRef fullImageRef = [represent fullScreenImage];
                        UIImage *fullImage = [UIImage imageWithCGImage:fullImageRef scale:2.0 orientation:UIImageOrientationUp];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) completion(fullImage, nil, NO);
                        });
                    });
                }
            });
        });
    }
    return 0;

}

#pragma mark 获取封面图

- (void)getPostImageWithAlbumModel:(MMAlbumModel *)model completion:(void (^)(UIImage *))completion {
    if (kiOS8Later) {
        id asset = [model.result lastObject];
        if (!self.sortAscendingByModificationDate) asset = [model.result firstObject];
        [[MMImagePickManager manager] getPhotoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (completion) completion(photo);
        }];
    } else {
        ALAssetsGroup *group = model.result;
        UIImage *postImage = [UIImage imageWithCGImage:group.posterImage];
        if (completion) completion(postImage);
    }
}


#pragma mark    获取原图
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *, NSDictionary *))completion {
    [self getOriginalPhotoWithAsset:asset newCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) completion(photo, info);
    }];
}

//获取原图
- (void)getOriginalPhotoWithAsset:(id)asset newCompletion:(void (^)(UIImage *, NSDictionary *, BOOL))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.networkAccessAllowed = YES;
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
           
            BOOL finished = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (finished && result) {
                result = [self fixOrientation:result];
                BOOL isDegrade = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                if (completion) completion(result, info, isDegrade);
            }
        }];
        
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *_asset = (ALAsset *)asset;
        ALAssetRepresentation *represent = [_asset defaultRepresentation];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CGImageRef originalImageRef = [represent fullScreenImage];
            UIImage *orignalImage = [UIImage imageWithCGImage:originalImageRef scale:2.0 orientation:UIImageOrientationUp];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(orignalImage, nil, NO);
            });
        });
    }
}

- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *, NSDictionary *, BOOL))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        option.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            BOOL finished = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (finished && imageData) {
                if (completion) completion(imageData, info, NO);
            }
        }];
        
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *_asset = (ALAsset *)asset;
        ALAssetRepresentation *represent = [_asset defaultRepresentation];
        Byte *imageBuffer = (Byte *)malloc(represent.size);
        NSUInteger bufferSize = [represent getBytes:imageBuffer fromOffset:0.0 length:represent.size error:nil];
        NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
        if (completion) completion(imageData, nil, NO);
    }
}

- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(NSError *))completion {
    [self savePhotoWithImage:image location:nil completion:completion];
}

- (void)savePhotoWithImage:(UIImage *)image location:(CLLocation *)location completion:(void (^)(NSError *))completion {
    NSData *data = UIImageJPEGRepresentation(image, 0.9);
    //iOS8 PHAsset的保存方法会失败
    if (kiOS9Later) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *option = [[PHAssetResourceCreationOptions alloc] init];
            option.shouldMoveFile = YES;
            
            PHAssetCreationRequest *requst = [PHAssetCreationRequest creationRequestForAsset];
            [requst addResourceWithType:PHAssetResourceTypePhoto data:data options:option];
            if (location) requst.location = location;
            requst.creationDate = [NSDate date];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
           dispatch_async(dispatch_get_main_queue(), ^{
               if (success && completion) {
                   completion(nil);
               } else {
                   if (completion) completion(error);
               }
           });
        }];
    } else {
        [self.assetLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            
            if (error && completion) completion(error);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (completion) completion(nil);
            });
        }];
    }
}


//获取视频

- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem *, NSDictionary *))completion {
    [self getVideoWithAsset:asset progressHandler:nil completion:completion];
}

- (void)getVideoWithAsset:(id)asset progressHandler:(void (^)(double, NSError *, BOOL *, NSDictionary *))progressHandler completion:(void (^)(AVPlayerItem *, NSDictionary *))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
        option.networkAccessAllowed = YES;
        option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progressHandler) progressHandler(progress, error, stop, info);
            });
        };
        [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:option resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            if (completion) completion(playerItem, info);
        }];
        
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *_asset = (ALAsset *)asset;
        ALAssetRepresentation *represent = [_asset defaultRepresentation];
        NSString *uti = [represent UTI];
        NSURL *videoURL = [[_asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoURL];
        if (progressHandler) progressHandler(1, nil, nil, nil);
        if (completion && item) completion(item, nil);
    }
}

- (void)getVideoPathWithAsset:(id)asset completion:(void (^)(NSString *))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
        option.networkAccessAllowed = YES;
        option.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        option.version = PHVideoRequestOptionsVersionOriginal;
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:option resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset *videoAsset = (AVURLAsset *)asset;
            [self _getVideoPathWithAsset:videoAsset completion:completion];
        }];
        
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *_asset = (ALAsset *)asset;
        NSURL *videoURL = [_asset valueForProperty:ALAssetPropertyAssetURL];
        AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        [self _getVideoPathWithAsset:videoAsset completion:completion];
    }
}

- (void)_getVideoPathWithAsset:(AVURLAsset *)asset completion:(void(^)(NSString *))completion {
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    
    if ([presets containsObject:AVAssetExportPreset640x480]) {
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPreset640x480];
        session.shouldOptimizeForNetworkUse = YES;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/output-%@.mp4",[formatter stringFromDate:[NSDate date]]];
        session.outputURL = [NSURL fileURLWithPath:path];
        
        NSArray *supportedTypes = session.supportedFileTypes;
        if ([supportedTypes containsObject:AVFileTypeMPEG4]) {
            session.outputFileType = AVFileTypeMPEG4;
        } else if (supportedTypes.count == 0) {
            if (completion) completion(nil);
            return;
        }else {
            session.outputFileType = [supportedTypes objectAtIndex:0];
        }
        
        NSString *tmpPath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        AVMutableVideoComposition *composition = [self fixCompositionWithAsset:asset];
        if (composition.renderSize.width) session.videoComposition = composition;//修正视屏转向
        
        [session exportAsynchronouslyWithCompletionHandler:^{
            switch (session.status) {
                    case AVAssetExportSessionStatusUnknown: {
                    
                    } break;
                    case AVAssetExportSessionStatusFailed: {
                        
                    } break;
                    case AVAssetExportSessionStatusWaiting: {
                        
                    } break;
                    case AVAssetExportSessionStatusCancelled: {
                        
                    } break;
                    case AVAssetExportSessionStatusCompleted: {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) completion(path);
                        });
                    } break;
                    case AVAssetExportSessionStatusExporting: {
                        
                    } break;
            }
        }];
    }
}

- (AVMutableVideoComposition *)fixCompositionWithAsset:(AVURLAsset *)asset {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
    int degree = [self degreeFromVideoFileWithAsset:asset];
    if (degree != 0) {
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        AVMutableVideoCompositionInstruction *rotateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        rotateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        AVMutableVideoCompositionLayerInstruction *rotationLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        if (degree == 90) {
            //顺时针旋转 90度
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0);
            mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI_2);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            [rotationLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if (degree == 180) {
            //顺时针旋转 180度
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            [rotationLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if (degree == 270) {
            //顺时针旋转 270度
            translateToCenter = CGAffineTransformMakeTranslation(0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI_2*3.0);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            [rotationLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        }
        rotateInstruction.layerInstructions = @[rotationLayerInstruction];
        videoComposition.instructions = @[rotateInstruction];
    }
    return videoComposition;
}

- (int)degreeFromVideoFileWithAsset:(AVAsset *)asset {
    int degree = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (tracks.count > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
            degree = 90;
        } else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
            degree = 270;
        } else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
            degree = 0;
        } else if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
            degree = 180;
        }
    }
    return degree;
}


- (BOOL)isAssetsArray:(NSArray *)assets containAsset:(id)asset {
    if (kiOS8Later) {
        return [assets containsObject:asset];
    } else {
        NSMutableArray *selectedAssetURLs = @[].mutableCopy;
        for (ALAsset *item in assets) {
            [selectedAssetURLs addObject:[item valueForProperty:ALAssetPropertyURLs]];
        }
        return [selectedAssetURLs containsObject:[asset valueForProperty:ALAssetPropertyURLs]];
    }
}

- (BOOL)isCameraRollAlbum:(NSString *)albumName {
    NSString *version = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (version.length <= 1) {
        version = [version stringByAppendingString:@"00"];
    } else if (version.length <= 2) {
        version = [version stringByAppendingString:@"0"];
    }
    
    if (version.floatValue >= 800 && version.floatValue < 802) {
        return [albumName isEqualToString:@"最近添加"] || [albumName isEqualToString:@"Recently Added"];
    } else {
        return [albumName isEqualToString:@"所有照片"] || [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"All Photos"];
    }
}

- (NSString *)getAssetIdentifier:(id)asset {
    if (kiOS8Later) {
        PHAsset *_asset = (PHAsset *)asset;
        return _asset.localIdentifier;
    } else {
        ALAsset *_asset = (ALAsset *)asset;
        NSURL *assetURL = [_asset valueForProperty:ALAssetPropertyAssetURL];
        return assetURL.absoluteString;
    }
}


- (UIImage *)fixOrientation:(UIImage *)image {
    if (![self shouldFixOrientation]) return image;
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (image.imageOrientation) {
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored: {
                transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
                transform = CGAffineTransformRotate(transform, M_PI);
            } break;
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored: {
                transform = CGAffineTransformTranslate(transform, image.size.width, 0);
                transform = CGAffineTransformRotate(transform, M_PI_2);
            } break;
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:{
                transform = CGAffineTransformTranslate(transform, 0, image.size.height);
                transform = CGAffineTransformRotate(transform, -M_PI_2);
            } break;

        default:
            break;
    }
    
    switch (image.imageOrientation) {
            case UIImageOrientationUpMirrored:
            case UIImageOrientationDownMirrored:{
                transform = CGAffineTransformTranslate(transform, image.size.width, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
            } break;

            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRightMirrored:{
                transform = CGAffineTransformTranslate(transform, image.size.height, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
            } break;
            
        default:
            break;
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL, image.size.width, image.size.height, CGImageGetBitsPerComponent(image.CGImage), 0, CGImageGetColorSpace(image.CGImage), CGImageGetAlphaInfo(image.CGImage));
    CGContextConcatCTM(context, transform);
    
    switch (image.imageOrientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRightMirrored:
            case UIImageOrientationRight: {
                CGContextDrawImage(context, CGRectMake(0, 0, image.size.height, image.size.width), image.CGImage);
            } break;
        default:
            CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
            break;
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGContextRelease(context);
    CGImageRelease(imageRef);
    return result;
}


- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *new = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return new;
    } else {
        return image;
    }
}




@end
#pragma clang diagnostic pop

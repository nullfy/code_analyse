//
//  MMPickImageManager.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMPickImageManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MMAssetModel.h"
#import "MMImagePickerMacro.h"

static CGSize AssetGridThumbnailSize;
static CGFloat MMScreenScale;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@interface MMPickImageManager()

@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;

@end

@implementation MMPickImageManager

#pragma mark    Getter&Setter
- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    CGFloat margin = 4;
    CGFloat width = (kScreenWidth - 2 * margin - 4) / columnNumber - margin;
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
    static MMPickImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        if (kiOS8Later) {
            manager.cachingImageManager = [[PHCachingImageManager alloc] init];
        }
        MMScreenScale = 2.0;
        if (kScreenWidth > 700)     MMScreenScale = 1.5;
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

- (void)getCameraRollAlbum:(BOOL)allowPickImage allowPickVideo:(BOOL)allowPickVedio completion:(void (^)(MMAlbumModel *))completion {
    __block MMAlbumModel *model;
    if (kiOS8Later) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        if (!allowPickVedio) {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }
        if (!allowPickImage) {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
        //options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:self.sortAscendingByModificationDate]];
        if (!self.sortAscendingByModificationDate) {
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
        }
    
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *collection in smartAlbums) {
            if (![collection isKindOfClass:[PHAssetCollection class]]) return;
            if ([self isCameraRollAlbum:collection.localizedTitle]) {
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
                model = [self modelWithResult:result name:collection.localizedTitle];
                if (completion) completion(model);
                break;
            }
        }
    } else {
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if ([group numberOfAssets] < 1) return ;
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            if ([self isCameraRollAlbum:name]) {
                model = [self modelWithResult:group name:name];
                if (completion) completion(model);
                *stop = YES;
            }
        } failureBlock:nil];
    }
}

- (void)getAllAlbum:(BOOL)allowPickImage allowPickVedio:(BOOL)allowVedio completion:(void (^)(NSArray<MMAlbumModel *> *))completion {
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
                
                
            }
        }
        
    }
}


- (MMAlbumModel *)modelWithResult:(id)result name:(NSString *)name {
    return @"";
}




@end
#pragma clang diagnostic pop

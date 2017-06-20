//
//  MMAssetModel.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MMAssetModelMediaType) {
    MMAssetModelMediaTypePhoto=0,
    MMAssetModelMediaTypeLivePhoto,
    MMAssetModelMediaTypeGIF,
    MMAssetModelMediaTypeVideo,
    MMAssetModelMediaTypeAudio,
};


@interface MMAssetModel : NSObject

@property (nonatomic, strong) id asset;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, assign) MMAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;

+ (instancetype)modelWithAsset:(id)asset type:(MMAssetModelMediaType)type;
+ (instancetype)modelWithAsset:(id)asset type:(MMAssetModelMediaType)type timeLength:(NSString *)timeLength;

@end


@interface MMAlbumModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) id result;
@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;

@end

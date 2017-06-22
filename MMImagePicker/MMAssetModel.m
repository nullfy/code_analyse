//
//  MMAssetModel.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMAssetModel.h"
#import "MMImagePickManager.h"

@implementation MMAssetModel

+ (instancetype)modelWithAsset:(id)asset type:(MMAssetModelMediaType)type {
    MMAssetModel *model = [[MMAssetModel alloc] init];
    model.asset = asset;
    model.selected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(id)asset type:(MMAssetModelMediaType)type timeLength:(NSString *)timeLength {
    MMAssetModel *model = [MMAssetModel modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end

@implementation MMAlbumModel

- (void)setResult:(id)result {
    _result = result;
    BOOL allowPickImage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"mm_allowPickImage"]isEqualToString:@"1"];;
    BOOL allowPickVideo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"mm_allowPickVedio"] isEqualToString:@"1"];
    [[MMImagePickManager manager] getAssetsFromFetchResult:result allowPickImage:allowPickImage allowPickVideo:allowPickVideo completion:^(NSArray<MMAlbumModel *> *models) {
        _models = models;
        if (_selectedModels) [self checkSelectedModels];
    }];
}

- (void)setSelectedModels:(NSArray *)selectedModels {
    _selectedModels = selectedModels;
    if (_models) [self checkSelectedModels];
}

- (void)checkSelectedModels {
    self.selectedCount = 0;
    NSMutableArray *seletedAssets = @[].mutableCopy;
    for (MMAssetModel *model in _selectedModels) {
        [seletedAssets addObject:model.asset];
    }
    for (MMAssetModel *model in _models) {
        if ([[MMImagePickManager manager] isAssetsArray:seletedAssets containAsset:model.asset]){
            self.selectedCount++;
        }
    }
}

- (NSString *)name {
    if (_name) return _name;
    return @"";
}

@end

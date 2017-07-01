//
//  MMAssetCell.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMAlbumModel, MMAssetModel;
typedef NS_ENUM(NSUInteger, MMAssetCellType) {
    MMAssetCellTypePhoto = 0,
    MMAssetCellTypeLivePhoto,
    MMAssetCellTypeGIF,
    MMAssetCellTypeVideo,
    MMAssetCellTypeAudio,
};

@interface MMAssetCell : UICollectionViewCell

@property (nonatomic, weak) UIButton *selectPhotoButton;
@property (nonatomic, strong) MMAssetModel *model;
@property (nonatomic, copy) NSString *selectImageName;
@property (nonatomic, copy) NSString *defImageName;
@property (nonatomic, copy) NSString *representedAssetID;

@property (nonatomic, assign) MMAssetCellType type;
@property (nonatomic, assign) int32_t imageRequestID;

@property (nonatomic, assign) BOOL allowPickGIF;
@property (nonatomic, assign) BOOL showSeletedButton;

@property (nonatomic, copy) void(^didSeletePhotoBlock)(BOOL seleted);

@end

@interface MMAlbumCell : UITableViewCell

@property (nonatomic, strong) MMAlbumModel *model;
@property (nonatomic, weak) UIButton *selectedCountButton;

@end

@interface MMAssetCameraCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

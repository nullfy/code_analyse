//
//  MMAssetCell.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMAssetCell.h"
#import "MMAssetModel.h"
#import "MMPickImageManager.h"
#import "MMProgressView.h"
#import "MMImagePickerMacro.h"

@interface MMAssetCell ()
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIImageView *selectImageView;
@property (nonatomic, weak) UIImageView *videoImageView;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UILabel *timeLabel;

@property (nonatomic, strong) MMProgressView *progressView;
@property (nonatomic, assign) int32_t bigImageRequstID;

@end

@implementation MMAssetCell

- (void)setModel:(MMAssetModel *)model {
    _model = model;
    if (kiOS8Later) {
        self.representedAssetID = [[MMPickImageManager manager] getAssetIdentifier:model.asset];
    }
    int32_t imageRequstID = [[MMPickImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (_progressView) {
            self.progressView.hidden = YES;
            self.imageView.alpha = 1.0f;
        }
        if (!kiOS8Later) {
            self.imageView.image = photo;
            return ;
        }
        if ([self.representedAssetID isEqualToString:[[MMPickImageManager manager] getAssetIdentifier:model.asset]]) {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequstID];
        }
        if (!isDegraded) self.imageRequstID = 0;
    }];
}


@end

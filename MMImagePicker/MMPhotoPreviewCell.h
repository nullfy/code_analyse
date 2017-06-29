//
//  MMPhotoPreviewCell.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/29.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMAssetModel, MMProgressView, MMPhotoPreviewView;
@interface MMPhotoPreviewCell : UICollectionViewCell

@property (nonatomic, strong) MMPhotoPreviewView *previewView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, strong) MMAssetModel *model;

@property (nonatomic, copy)  void(^singleTapGestureBlock)();
@property (nonatomic, copy) void(^imageProgressUpdateBlock)(double progress);

- (void)recoverSubViews;

@end

@interface MMPhotoPreviewView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) MMProgressView *progressView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, strong) MMAssetModel *model;
@property (nonatomic, strong) id asset;
@property (nonatomic, copy)  void(^singleTapGestureBlock)();
@property (nonatomic, copy) void(^imageProgressUpdateBlock)(double progress);

@property (nonatomic, assign) int32_t imageRequestID;

- (void)recoverSubViews;

@end

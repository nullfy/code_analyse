//
//  MMAssetCell.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMAssetCell.h"
#import "MMAssetModel.h"
#import "MMImagePickManager.h"
#import "MMProgressView.h"
#import "MMImagePickerMacro.h"
#import "UIImage+imagePicker.h"

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
        self.representedAssetID = [[MMImagePickManager manager] getAssetIdentifier:model.asset];
    }
    int32_t imageRequstID = [[MMImagePickManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (_progressView) {
            self.progressView.hidden = YES;
            self.imageView.alpha = 1.0f;
        }
        if (!kiOS8Later) {
            self.imageView.image = photo;
            return ;
        }
        if ([self.representedAssetID isEqualToString:[[MMImagePickManager manager] getAssetIdentifier:model.asset]]) {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequstID];
        }
        if (!isDegraded) self.imageRequstID = 0;
    } progressHandler:nil networkAccessAllowed:NO];
    
    if (imageRequstID && self.imageRequstID && imageRequstID != self.imageRequstID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequstID];
    }
    
    self.imageRequstID = imageRequstID;
    self.selectPhotoButton.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamedFromMyBundle:self.selectImageName] : [UIImage imageNamedFromMyBundle:self.defImageName];
    self.type = (NSInteger)model.type;
    
    if (![[MMImagePickManager manager] isPhotoSelectableWithAsset:model.asset]) {
        if (_selectImageView.hidden == NO) {
            self.selectPhotoButton.hidden = YES;
            self.selectImageView.hidden = YES;
        }
    }
    if (model.isSelected) [self fetchBigImage];
}

- (void)setShowSeletedButton:(BOOL)showSeletedButton {
    _showSeletedButton = showSeletedButton;
    if (!_selectPhotoButton.hidden) _selectPhotoButton.hidden = !showSeletedButton;
    if (!_selectImageView.hidden) _selectImageView.hidden = !showSeletedButton;
}

- (void)setType:(MMAssetCellType)type {
    _type = type;
    if (type == MMAssetCellTypePhoto ||
        type == MMAssetCellTypeLivePhoto ||
        (type == MMAssetCellTypeGIF && !_allowPickGIF)) {
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
        _bottomView.hidden = YES;
    } else {
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        _bottomView.hidden = NO;
        if (type == MMAssetCellTypeVideo) {
            _timeLabel.textAlignment = NSTextAlignmentRight;
            _timeLabel.text = _model.timeLength;
            _timeLabel.left = _videoImageView.right;
            _videoImageView.hidden = NO;
        } else {
            _timeLabel.text = @"GIF";
            _videoImageView.hidden = YES;
            _timeLabel.left = 5;
            _timeLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
}

- (void)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSeletePhotoBlock) self.didSeletePhotoBlock(sender.isSelected);
    
    _selectImageView.image = sender.isSelected ? [UIImage imageNamedFromMyBundle:_selectImageName] : [UIImage imageNamedFromMyBundle:_defImageName];
    
    if (sender.isSelected) {
        [_selectImageView.layer showOscillatoryAnimationWithType:MMOscillatorAnimationTypeToBigger];
        [self fetchBigImage];
    } else {
        if (_bigImageRequstID && _progressView) {
            [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequstID];
            [self hideProgressView];
        }
    }
}

- (void)hideProgressView {
    _progressView.hidden = YES;
    _imageView.alpha = 1.0;
}

- (void)fetchBigImage {
    _bigImageRequstID = [[MMImagePickManager manager] getPhotoWithAsset:_model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (_progressView) [self hideProgressView];
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        if (_model.isSelected) {
            progress = progress > 0.02 ? progress : 0.02;
            _progressView.progress = progress;
            _progressView.hidden = NO;
            _imageView.alpha = 0.4;
            if (progress >= 1) [self hideProgressView];
        } else {
            *stop = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    } networkAccessAllowed:YES];
}

- (UIButton *)selectPhotoButton {
    if (_selectImageView == nil) {
        UIButton *selectImageView = [[UIButton alloc] init];
        selectImageView.frame = CGRectMake(self.width - 44, 0, 44, 44);
        [selectImageView addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectImageView];
        _selectPhotoButton = selectImageView;
    }
    return _selectPhotoButton;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, self.width, self.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
        
        [self.contentView bringSubviewToFront:_selectImageView];
        [self.contentView bringSubviewToFront:_bottomView];
    }
    return _imageView;
}

- (UIImageView *)selectImageView {
    if (_selectImageView == nil) {
        UIImageView *selectImageView = [[UIImageView alloc] init];
        selectImageView.frame = CGRectMake(self.width - 27, 0, 27, 27);
        [self.contentView addSubview:selectImageView];
        _selectImageView = selectImageView;
    }
    return _selectImageView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.frame = CGRectMake(0, self.height - 17, self.width, 17);
        bottomView.backgroundColor = [UIColor blackColor];
        bottomView.alpha = 0.8;
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UILabel *)timeLength {
    if (_timeLabel == nil) {
        UILabel *timeLength = [[UILabel alloc] init];
        timeLength.font = [UIFont boldSystemFontOfSize:11];
        timeLength.frame = CGRectMake(self.imageView.right, 0, self.width - self.imageView.right - 5, 17);
        timeLength.textColor = [UIColor whiteColor];
        timeLength.textAlignment = NSTextAlignmentRight;
        [self.bottomView addSubview:timeLength];
        _timeLabel = timeLength;
    }
    return _timeLabel;
}

@end

@interface MMAlbumCell ()

@property (nonatomic, weak) UIImageView *posterImageView;
@property (nonatomic, weak) UIImageView *arrowImageView;
@property (nonatomic, weak) UILabel *titleLabel;

@end

@implementation MMAlbumCell

- (void)setModel:(MMAlbumModel *)model {
    _model = model;
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLabel.attributedText = nameString;
    [[MMImagePickManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.posterImageView.image = postImage;
    }];
    if (model.selectedCount) {
        self.selectedCountButton.hidden = NO;
        [self.selectedCountButton setTitle:[NSString stringWithFormat:@"%zd",model.selectedCount] forState:UIControlStateNormal];
    } else {
        self.selectedCountButton.hidden = YES;
    }
}

/// For fitting iOS6
- (void)layoutSubviews {
    if (kiOS7Later) [super layoutSubviews];
    _selectedCountButton.frame = CGRectMake(self.width - 24 - 30, 23, 24, 24);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    if (kiOS7Later) [super layoutSublayersOfLayer:layer];
}

#pragma mark - Lazy load

- (UIImageView *)posterImageView {
    if (_posterImageView == nil) {
        UIImageView *posterImageView = [[UIImageView alloc] init];
        posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        posterImageView.clipsToBounds = YES;
        posterImageView.frame = CGRectMake(0, 0, 70, 70);
        [self.contentView addSubview:posterImageView];
        _posterImageView = posterImageView;
    }
    return _posterImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *titleLable = [[UILabel alloc] init];
        titleLable.font = [UIFont boldSystemFontOfSize:17];
        titleLable.frame = CGRectMake(80, 0, self.width - 80 - 50, self.height);
        titleLable.textColor = [UIColor blackColor];
        titleLable.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLable];
        _titleLabel = titleLable;
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView {
    if (_arrowImageView == nil) {
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        CGFloat arrowWH = 15;
        arrowImageView.frame = CGRectMake(self.width - arrowWH - 12, 28, arrowWH, arrowWH);
        [arrowImageView setImage:[UIImage imageNamedFromMyBundle:@"TableViewArrow.png"]];
        [self.contentView addSubview:arrowImageView];
        _arrowImageView = arrowImageView;
    }
    return _arrowImageView;
}

- (UIButton *)selectedCountButton {
    if (_selectedCountButton == nil) {
        UIButton *selectedCountButton = [[UIButton alloc] init];
        selectedCountButton.layer.cornerRadius = 12;
        selectedCountButton.clipsToBounds = YES;
        selectedCountButton.backgroundColor = [UIColor redColor];
        [selectedCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        selectedCountButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:selectedCountButton];
        _selectedCountButton = selectedCountButton;
    }
    return _selectedCountButton;
}

@end

@implementation MMAssetCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _imageView = [UIImageView new];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

@end

//
//  MMPhotoPreviewCell.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/29.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMPhotoPreviewCell.h"
#import "MMImagePickManager.h"
#import "MMProgressView.h"
#import "MMImageCropManager.h"
#import "MMAssetModel.h"
#import "MMImagePickerMacro.h"

@implementation MMPhotoPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.previewView = [[MMPhotoPreviewView alloc] initWithFrame:self.bounds];
        __weak typeof(self) weakSelf = self;
        self.previewView.singleTapGestureBlock = ^{
            if (weakSelf.singleTapGestureBlock) weakSelf.singleTapGestureBlock();
        };
        self.previewView.imageProgressUpdateBlock = ^(double progress) {
            if (weakSelf.imageProgressUpdateBlock) weakSelf.imageProgressUpdateBlock(progress);
        };
        [self addSubview:_previewView];
    }
    return self;
}

- (void)setModel:(MMAssetModel *)model {
    _model = model;
    _previewView.asset = model.asset;
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = allowCrop;
    _previewView.allowCrop = allowCrop;
}

- (void)setCropRect:(CGRect)cropRect {
    _cropRect = cropRect;
    _previewView.cropRect = cropRect;
}

- (void)recoverSubViews {//主要是resizesubview
    [_previewView recoverSubViews];
}

 @end


@interface MMPhotoPreviewView ()<UIScrollViewDelegate>

@end

@implementation MMPhotoPreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(10, 0, self.width - 20, self.height);// 这里是屏幕宽
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        [self addSubview:_scrollView];
        
        _containerView = [UIView new];
        _containerView.contentMode = UIViewContentModeScaleAspectFill;
        [_scrollView addSubview:_containerView];
        
        _imageView = [UIImageView new];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [_containerView addSubview:_imageView];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        
        [self configProgressView];
    }
    return self;
}

- (void)configProgressView {
    _progressView = [MMProgressView new];
    static CGFloat progressWidth = 40;
    CGFloat progressX = (self.width - progressWidth)/2;
    CGFloat progressY = (self.height - progressWidth)/2;
    _progressView.frame = CGRectMake(progressX, progressY, progressWidth, progressWidth);
    _progressView.hidden = YES;
    [self addSubview:_progressView];
}

- (void)setModel:(MMAssetModel *)model {
    _model = model;
    [_scrollView setZoomScale:1.0 animated:NO];
    
    if (model.type == MMAssetModelMediaTypeGIF) {
        [[MMImagePickManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            _imageView.image = photo;
            [self resizeSubViews];
            
            [[MMImagePickManager manager] getOriginalPhotoDataWithAsset:model.asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                if (!isDegraded) {
                    _imageView.image = [UIImage mm_animatedGIFWithData:data];
                    [self resizeSubViews];
                }
            }];
        } progressHandler:nil networkAccessAllowed:NO];
    } else {
        self.asset = model.asset;
    }
}

- (void)setAsset:(id)asset {
    if (_asset && _imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    
    _asset = asset;
    _imageRequestID = (uint32_t)[[MMImagePickManager manager] getPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (![asset isEqual:_asset]) return ;
        _imageView.image = photo;
        [self resizeSubViews];
        _progressView.hidden = YES;
        if (_imageProgressUpdateBlock) _imageProgressUpdateBlock(1);
        if (!isDegraded) _imageRequestID = 0;
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        if (![asset isEqual:_asset]) return ;
        _progressView.hidden = NO;
        [self bringSubviewToFront:_progressView];
        progress = progress > 0.02 ? progress : 0.02;
        _progressView.progress = progress;
        if (self.imageProgressUpdateBlock) _imageProgressUpdateBlock(progress);
        
        if (progress >= 1) {
            _progressView.hidden = YES;
            _imageRequestID = 0;
        }
    } networkAccessAllowed:YES];
    NSLog(@"%i", _imageRequestID);
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = allowCrop;
    _scrollView.maximumZoomScale = allowCrop ? 4.0 : 2.5;
    if ([self.asset isKindOfClass:[PHAsset class]]) {
        PHAsset *myAsset = (PHAsset *)_asset;
        CGFloat ratio = myAsset.pixelWidth/myAsset.pixelHeight;
        if (ratio > 1.5) {
            self.scrollView.maximumZoomScale *= ratio/1.5;
        }
    }
}

#pragma mark    Tap Event
- (void)singleTap:(UIGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) self.singleTapGestureBlock();
}

- (void)doubleTap:(UIGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width/newZoomScale;
        CGFloat ysize = self.frame.size.height/newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)resizeSubViews {
    //根据单击双击改变containerView的尺寸
    _containerView.origin = CGPointZero;
    _containerView.width = self.scrollView.width;
    
    UIImage *image = _imageView.image;
    if (image.size.height/image.size.width > self.height/self.scrollView.width) {
        _containerView.height = floor(image.size.height/(image.size.width/_scrollView.width));
    } else {
        CGFloat height = image.size.height/image.size.width * _scrollView.width;
        if (height < 1 || isnan(height)) height = self.height;
        height = floor(height);
        _containerView.height = height;
        _containerView.centerY = self.height/2;
    }
    
    if (_containerView.height > self.height && _containerView.height - self.height <= 1) {
        _containerView.height = self.height;
    }
    
    CGFloat contentSizeHeight = MAX(_containerView.height , self.height);
    _scrollView.contentSize = CGSizeMake(_containerView.width, contentSizeHeight);
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _containerView.height <= self.height ? NO : YES;
    [self refreshScrollViewContentSize];
}

- (void)refreshScrollViewContentSize {
    if (_allowCrop) {
        CGFloat contentWidthAdd = _scrollView.width - CGRectGetMaxX(_cropRect);
        CGFloat contentHeightAdd = (MIN(_containerView.height, self.height) - _cropRect.size.height)/2;
        
        CGFloat newWidth = _scrollView.contentSize.width + contentWidthAdd;
        CGFloat newHeight = MAX(_scrollView.contentSize.height, self.height) + contentHeightAdd;
        
        _scrollView.contentSize = CGSizeMake(newWidth, newHeight);
        _scrollView.alwaysBounceVertical = YES;
        
        if (contentHeightAdd > 0) {
            _scrollView.contentInset = UIEdgeInsetsMake(contentHeightAdd, _cropRect.origin.x, 0, 0);
        } else {
            _scrollView.contentInset = UIEdgeInsetsZero;
        }
    }
}

- (void)recoverSubViews {
    [_scrollView setZoomScale:1.0 animated:YES];
    [self resizeSubViews];
}

#pragma mark    Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _containerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self refreshScrollViewContentSize];
}

#pragma mark    Private

- (void)refreshImageContainerViewCenter {
    CGFloat offsetx = (_scrollView.width > _scrollView.contentSize.width) ? ((_scrollView.width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsety = (_scrollView.height > _scrollView.contentSize.height) ? ((_scrollView.height - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.containerView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetx, _scrollView.contentSize.height * 0.5 + offsety);
}

@end

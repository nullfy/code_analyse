//
//  MMPhotoPreviewController.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/22.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMPhotoPreviewController.h"
#import "MMAssetModel.h"
#import "MMImagePickManager.h"
#import "MMImagePickerMacro.h"
#import "MMPhotoPreviewCell.h"
#import "MMImagePickerController.h"
#import "MMImageCropManager.h"

@interface MMPhotoPreviewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate> {
    UICollectionView *_collectionView;
    NSArray *_photosTemp;
    NSArray *_assetsTemp;
    
    //自定义顶部的navbar
    UIView *_navBar;
    UIButton *_backButton;
    UIButton *_selectButton;
    
    //自定义底部的toolbar
    UIView *_toolBar;
    UIButton *_doneButton;
    UIImageView *_numberImageView;
    UILabel *_numberLabel;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
}

@property (nonatomic, assign) BOOL isHideNavBar;
@property (nonatomic, assign) double progress;

@property (nonatomic, strong) UIView *cropBgView;
@property (nonatomic, strong) UIView *cropView;
@property (nonatomic, strong) id alertView;


@end

@implementation MMPhotoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MMImagePickManager manager].shouldFixOrientation = YES;
    __weak typeof(self) weakSelf = self;
    MMImagePickerController *_pickerVC = (MMImagePickerController *)weakSelf.navigationController;
    if (!self.models.count) {
        self.models = [NSMutableArray arrayWithArray:_pickerVC.selectedModels];
        _assetsTemp = [NSMutableArray arrayWithArray:_pickerVC.selectedAssets];
        self.isSelectedOriginalPhoto = _pickerVC.isSelectOriginalPhoto;
    }
    
    [self configCollectionView];
    [self configCropView];
    [self configCustomNavBar];
    [self configBottomToolBar];
    self.view.clipsToBounds = YES;
}

- (void)configCollectionView {
    //预览图的展示方式 横向滑动 每个cell的宽度比屏幕宽20
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.view.width + 20, self.view.height);
    layout.minimumInteritemSpacing = 0;// 每个cell间的间隔
    layout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.width + 20, self.view.height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    _collectionView.contentSize = CGSizeMake(self.models.count * (self.view.width + 20), 0);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[MMPhotoPreviewCell class] forCellWithReuseIdentifier:@"MMPhotoPreviewCell"];
}

- (void)configCropView {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    if (!nav.showSelectButton && nav.allowCrop) {
        _cropBgView = [UIView new];
        _cropBgView.userInteractionEnabled = NO;
        _cropBgView.backgroundColor = [UIColor clearColor];
        _cropBgView.frame = self.view.bounds;
        [self.view addSubview:_cropView];
        
        [MMImageCropManager overlayClipWithView:_cropView rect:nav.cropRect containerView:self.view needCircleCrop:nav.needCircleCrop];
        
        _cropView = [UIView new];
        _cropView.userInteractionEnabled = NO;
        _cropView.backgroundColor = [UIColor clearColor];
        _cropView.frame = nav.cropRect;
        _cropView.layer.borderColor = [UIColor whiteColor].CGColor;
        _cropView.layer.borderWidth = 1.0f;
        if (nav.needCircleCrop) {
            _cropView.layer.cornerRadius = nav.cropRect.size.width;
            _cropView.clipsToBounds = YES;
        }
        [self.view addSubview:_cropView];
        if (nav.cropViewSettingBlock) nav.cropViewSettingBlock(_cropView);
    }
}

- (void)configCustomNavBar {
    /*
     自定义导航条
     1.两个控件，一个返回button， 一个选中button
     */
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    
    _navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 64)];
    _navBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    _navBar.alpha = 0.7;
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 44, 44)];
    [_backButton setImage:[UIImage imageNamedFromMyBundle:@"navi_back.png"] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 54, 10, 42, 42)];
    [_selectButton setImage:[UIImage imageNamedFromMyBundle:nav.photoDefImageName] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamedFromMyBundle:nav.photoSelImageName] forState:UIControlStateSelected];
    [_selectButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    _selectButton.hidden = nav.maxImagesCount == 1;
    
    [_navBar addSubview:_selectButton];
    [_navBar addSubview:_backButton];
    [self.view addSubview:_navBar];
}

- (void)configBottomToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
    static CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = Color(rgb, rgb, rgb, 0.7);
    
    /*
     顶部工具栏的逻辑是
     1.一共有三个控件，原图button， 原图大小label（默认是隐藏），完成button
     2.原图大小label 在默认情况下是隐藏的，只有在选中时才可见
     3.需要处理
     */
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    if (nav.allowPickOriginalPhoto) {
#warning error 多写了full [_originalPhotoButton setTitle:
        //NSString *fullImageText = [NSBundle mm_localizedStringForKey:@"Full_image"];
        CGFloat fullImageWidth = [nav.fullImageButtonTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil].size.width;
        
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.frame = CGRectMake(0, 0, fullImageWidth + 56, 44);
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        _originalPhotoButton.backgroundColor = [UIColor clearColor];
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_originalPhotoButton setTitle:nav.fullImageButtonTitle forState:UIControlStateNormal];
        [_originalPhotoButton setTitle:nav.fullImageButtonTitle forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:nav.photoPreviewOriginDefImageName] forState:UIControlStateNormal];
        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:nav.photoOriginSelImageName] forState:UIControlStateSelected];
        
        _originalPhotoLabel = [[UILabel alloc] init];
        _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 42, 0, 80, 44);
        _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLabel.font = [UIFont systemFontOfSize:13];
        _originalPhotoLabel.textColor = [UIColor whiteColor];
        _originalPhotoLabel.backgroundColor = [UIColor clearColor];
        if (_isSelectedOriginalPhoto) [self showPhotoBytes];
    }
    
    //完成按钮
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(self.view.width - 44 - 12, 0, 44, 44);
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitle:nav.doneButtonTitle forState:UIControlStateNormal];
    [_doneButton setTitleColor:nav.okButtonTitleColorNormal forState:UIControlStateNormal];
    
    //选中图片数量背景图片
    _numberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedFromMyBundle:nav.photoNumberIconImageName]];
    _numberImageView.backgroundColor = [UIColor clearColor];
    _numberImageView.frame = CGRectMake(self.view.width - 56 - 28, 7, 30, 30);
    _numberImageView.hidden = nav.selectedModels.count <= 0;
    
    _numberLabel = [UILabel new];
    _numberLabel.frame = _numberImageView.frame;
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = [NSString stringWithFormat:@"%zd", nav.selectedModels.count];
    _numberLabel.hidden = nav.selectedModels.count <= 0;
    _numberLabel.backgroundColor = [UIColor clearColor];

    [_originalPhotoButton addSubview:_originalPhotoLabel];
    [_toolBar addSubview:_doneButton];
    [_toolBar addSubview:_originalPhotoButton];
    [_toolBar addSubview:_numberImageView];
#warning numlabel 比imageview早添加
    [_toolBar addSubview:_numberLabel];
    [self.view addSubview:_toolBar];

}

#pragma mark    Click-Event

- (void)select:(UIButton *)button {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    MMAssetModel *model = (MMAssetModel *)_models[_currentIndex];
    if (!button.isSelected) {
        if (nav.selectedModels.count >= nav.maxImagesCount) {
            NSString *title = [NSString stringWithFormat:[NSBundle mm_localizedStringForKey:@"Select a maximum of %zd photos"], nav.maxImagesCount];
            [nav showAlertWithTitle:title];
            return;
        } else {
            [nav.selectedModels addObject:model];
            if (self.photos) {
                [nav.selectedAssets addObject:_assetsTemp[_currentIndex]];
                [self.photos addObject:_photosTemp[_currentIndex]];
            }
            if (model.type == MMAssetModelMediaTypeVideo) {
                [nav showAlertWithTitle:[NSBundle mm_localizedStringForKey:@"Select the video when in multi state, we will handle the video as a photo"]];
            }
        }
    } else {
        NSArray *selectedModels = [NSArray arrayWithArray:nav.selectedModels];
        for (MMAssetModel *model_item in selectedModels) {
            //判断当前的图片的requstID 是否被选中
            if ([[[MMImagePickManager manager] getAssetIdentifier:model.asset] isEqualToString:[[MMImagePickManager manager] getAssetIdentifier:model_item.asset]]) {
                //这里没有直接remove item 而是多加了一层requstID判断
                NSArray *selectmodelsTmp = [NSArray arrayWithArray:nav.selectedModels];
                for (NSInteger i = 0; i < selectmodelsTmp.count; i++) {
                    MMAssetModel *model = selectmodelsTmp[i];
                    if ([model isEqual:model_item]) {
                        [nav.selectedModels removeObjectAtIndex:i];
                        break;
                    }
                }
                if (self.photos) {
                    NSArray *selectedAssetsTmp = [NSArray arrayWithArray:nav.selectedAssets];
                    for (NSInteger i = 0; i < selectedAssetsTmp.count; i++) {
                        id asset = selectedAssetsTmp[i];
                        if ([asset isEqual:_assetsTemp[_currentIndex]]) {
                            [nav.selectedAssets removeObjectAtIndex:i];
                            break;
                        }
                    }
                    [self.photos removeObject:_photosTemp[_currentIndex]];
                }
                break;
            }
        }
    }
    model.selected = !button.isSelected;
    [self refreshNavBarAndBottomBarState];
    if (model.isSelected) {//选中时数字变化的动画
        [_selectButton.imageView.layer showOscillatoryAnimationWithType:MMOscillatorAnimationTypeToBigger ];
    }
    [_numberImageView.layer showOscillatoryAnimationWithType:MMOscillatorAnimationTypeToSmaller];
}

- (void)originalPhotoButtonClick {
    /*
     原图按钮的选中与反选
     1.原图大小label的显示与否，同时更新文字
     2.原图按钮的选择与否
     3.右上角选中按钮的的选择（原图按钮的反选不会取消图片的选中状态）
     4.如果该图片未曾选中过，还要判断当前选中的图片数量有没有超过最大数，同时根据配置中是否显示选中按钮来判断
     5.如果条件都成立 就选中该张图片
     */
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectedOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectedOriginalPhoto) {
        [self showPhotoBytes];
        if (!_selectButton.isSelected) {
            MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
            if (nav.selectedModels.count < nav.maxImagesCount && nav.showSelectButton) {
                [self select:_selectButton];
            }
        }
    }
}

- (void)doneButtonClick {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;

    //如果图片正在从iCloud同步，提醒用户
    if (_progress > 0 && _progress < 1) {
        _alertView = [nav showAlertWithTitle:[NSBundle mm_localizedStringForKey:@"Synchronizing photos from iCloud"]];
        return;
    }
    
    //选中为空 点击确定时选中当前预览图片
    if (nav.selectedModels.count == 0 && nav.minImagesCount <= 0) {
        MMAssetModel *model = _models[_currentIndex];
        [nav.selectedModels addObject:model];
    }
    
    //允许选中
    if (nav.allowCrop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
        MMPhotoPreviewCell *cell = (MMPhotoPreviewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        UIImage *cropedImage = [MMImageCropManager cropImageView:cell.previewView.imageView toRect:nav.cropRect scale:cell.previewView.scrollView.zoomScale containerView:self.view];
        
        if (nav.needCircleCrop) {
            cropedImage = [MMImageCropManager circularClipImage:cropedImage];
        }
        if (self.doneButtonClickBlockCropMode) {
            MMAssetModel *model = _models[_currentIndex];
            self.doneButtonClickBlockCropMode(cropedImage, model.asset);
        }
    } else if (self.doneButtonClickBlock) {
        self.doneButtonClickBlock(_isSelectedOriginalPhoto);
    }
    if (self.doneButtonClickWithPreviewType) self.doneButtonClickWithPreviewType(self.photos, nav.selectedAssets, self.isSelectedOriginalPhoto);
}

- (void)backButtonClick {
    if (self.navigationController.childViewControllers.count < 2) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    if (self.backButtonClickBlock) self.backButtonClickBlock(_isSelectedOriginalPhoto);
}


#pragma mark    Collection-Delegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[MMPhotoPreviewCell class]]) [(MMPhotoPreviewCell *)cell recoverSubViews];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[MMPhotoPreviewCell class]]) [(MMPhotoPreviewCell *)cell recoverSubViews];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"MMPhotoPreviewCell";
    MMPhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.model = _models[indexPath.row];
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    cell.cropRect = nav.cropRect;
    cell.allowCrop = nav.allowCrop;
    
    __weak typeof(self) weakSelf = self;
    if (!cell.singleTapGestureBlock) {
        __weak typeof(_navBar) weakNavBar = _navBar;
        __weak typeof(_toolBar) weakToolBar = _toolBar;
        cell.singleTapGestureBlock = ^{
            weakSelf.isHideNavBar = !weakSelf.isHideNavBar;
            weakNavBar.hidden = weakSelf.isHideNavBar;
            weakToolBar.hidden = weakSelf.isHideNavBar;
        };
    }
    
    cell.imageProgressUpdateBlock = ^(double progress) {
        weakSelf.progress = progress;
        if (progress >= 1) {
            if (weakSelf.alertView) {
                [nav hideAlertView:weakSelf.alertView];
                [weakSelf doneButtonClick];
            }
        }
    };
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth +  ((self.view.width + 20) * 0.5);
    
    NSInteger currentIndex = offSetWidth / (self.view.width + 20);
    
    if (currentIndex < _models.count && _currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        [self refreshNavBarAndBottomBarState];
    }
}


#pragma mark    View Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if (kiOS7Later) [UIApplication sharedApplication].statusBarHidden = YES;
    if (_currentIndex) [_collectionView setContentOffset:CGPointMake((self.view.width + 20) * _currentIndex, 0) animated:NO];
    [self refreshNavBarAndBottomBarState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (kiOS7Later) [UIApplication sharedApplication].statusBarHidden = NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma makr    Getter

- (void)setPhotos:(NSMutableArray *)photos {
    _photos = photos;
    _photosTemp = [NSArray arrayWithArray:photos];
}

#pragma mark    Private method
- (void)refreshNavBarAndBottomBarState {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    MMAssetModel *model = _models[_currentIndex];
    _selectButton.selected = model.isSelected;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",nav.selectedModels.count];
    _numberImageView.hidden = (nav.selectedModels.count <= 0 || _isHideNavBar || _isCropImage);
    _numberLabel.hidden = (nav.selectedModels.count <= 0 || _isHideNavBar || _isCropImage);
    
    _originalPhotoButton.selected = _isSelectedOriginalPhoto;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectedOriginalPhoto) [self showPhotoBytes];
    
    // If is previewing video, hide original photo button
    // 如果正在预览的是视频，隐藏原图按钮
    if (!_isHideNavBar) {
        if (model.type == MMAssetModelMediaTypeVideo) {
            _originalPhotoButton.hidden = YES;
            _originalPhotoLabel.hidden = YES;
        } else {
            _originalPhotoButton.hidden = NO;
            if (_isSelectedOriginalPhoto)  _originalPhotoLabel.hidden = NO;
        }
    }
    
    _doneButton.hidden = NO;
    _selectButton.hidden = !nav.showSelectButton;
    // 让宽度/高度小于 最小可选照片尺寸 的图片不能选中
    if (![[MMImagePickManager manager] isPhotoSelectableWithAsset:model.asset]) {
        _numberLabel.hidden = YES;
        _numberImageView.hidden = YES;
        _selectButton.hidden = YES;
        _originalPhotoButton.hidden = YES;
        _originalPhotoLabel.hidden = YES;
        _doneButton.hidden = YES;
    }
}

- (void)showPhotoBytes {//显示源图文件大小
    [[MMImagePickManager manager] getPhotoBytesWithArray:@[_models[_currentIndex]] completion:^(NSString *total) {
        _originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",total];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

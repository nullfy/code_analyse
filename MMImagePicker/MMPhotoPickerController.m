//
//  MMPhotoPickerController.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/22.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMPhotoPickerController.h"
#import "MMImagePickerController.h"
#import "MMImagePickManager.h"
#import "MMLocationManager.h"
#import "MMLocationManager.h"
#import "MMPhotoPreviewController.h"
#import "MMGIFPhotoPreviewController.h"
#import "MMVideoPlayerController.h"
#import "MMImagePickerMacro.h"
#import "MMAssetCell.h"
#import "MMAssetModel.h"

@interface MMPhotoPickerController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {
    NSMutableArray *_models;
    
    UIButton *_previewButton;
    UIButton *_doneButton;
    UIImageView *_numberImageView;
    UILabel *_numberLabel;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    
    BOOL _shouldScrollToBottom;
    BOOL _showTakePhotoButton;
}
@property (assign) CGRect previousPreheatRect;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, strong) MMCollectionView *collectionView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) CLLocation *location;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation MMPhotoPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    _isSelectOriginalPhoto = nav.isSelectOriginalPhoto;
    _shouldScrollToBottom = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _model.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nav.cancelButtonTitle style:UIBarButtonItemStylePlain target:nav action:@selector(cancelButtonClick)];
    _showTakePhotoButton = (([[MMImagePickManager manager] isCameraRollAlbum:_model.name]) && nav.allowTakePicture);
}

static CGSize AssetGridThumbnailSize;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat scale = 2.0;
    if ([UIScreen mainScreen].bounds.size.width > 600) scale = 1.0;
    CGSize cellSize = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height*scale);
    if (!_models) [self fetchAssetModels];//加载图片信息
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    nav.isSelectOriginalPhoto = _isSelectOriginalPhoto;
}


- (void)fetchAssetModels {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    if (_isFirstAppear) [nav showProgressHUD];
    
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        if (nav.sortAscendingByModificationDate && _isFirstAppear && kiOS8Later) {
            [[MMImagePickManager manager] getCameraRollAlbum:nav.allowPickImage allowPickVideo:nav.allowPickVideo completion:^(MMAlbumModel *model) {
                _model = model;
                _models = [NSMutableArray arrayWithArray:model.models];
                [self initSubViews];
            }];
        } else {
            if (_showTakePhotoButton || !kiOS8Later || _isFirstAppear) {
                [[MMImagePickManager manager] getAssetsFromFetchResult:_model.result allowPickImage:nav.allowPickImage allowPickVideo:nav.allowPickVideo completion:^(NSArray<MMAlbumModel *> *models) {
                    _models = [NSMutableArray arrayWithArray:models];
                    [self initSubViews];
                }];
            } else {
                _models = [NSMutableArray arrayWithArray:_model.models];
                [self initSubViews];
            }
        }
    });
}

- (void)initSubViews {
    dispatch_async(dispatch_get_main_queue(), ^{
        MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
        [nav hideProgressHUD];
        
        [self checkSelectedModels];
        [self configCollectionView];
        [self configBottomToolBar];
        [self scrollCollectionViewToBottom];
    });
}

- (void)checkSelectedModels {
    for (MMAssetModel *model in _models) {
        model.selected = NO;
        NSMutableArray *selectedAssets = @[].mutableCopy;
        MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
        for (MMAssetModel *selectModel in nav.selectedModels) {
            [selectedAssets addObject:selectModel.asset];
        }
        if ([[MMImagePickManager manager] isAssetsArray:selectedAssets containAsset:model.asset]) {
            model.selected = YES;
        }
    }
}

- (void)configCollectionView {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    
    CGFloat margin = 5;
    CGFloat top = 0;
    CGFloat collectionHeight = 0;
    CGFloat itemWH = (self.view.width - (self.columnNumber + 1)*margin) / self.columnNumber;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = margin;// 每个cell间的间隔
    layout.minimumLineSpacing = margin;
    
    if (self.navigationController.navigationBar.isTranslucent) {//iOS6After  YES
        top = 44;
        if (kiOS7Later) top += 20;
        collectionHeight = nav.showSelectButton ? self.view.height - 50 - top : self.view.height - top;
    } else {
        CGFloat navHeight = 44;
        if (kiOS7Later) navHeight += 20;
        collectionHeight = nav.showSelectButton ? self.view.height - 50 - navHeight : self.view.height - navHeight;
    }
    
    _collectionView = [[MMCollectionView alloc] initWithFrame:CGRectMake(0, top, self.view.width, self.view.height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    
    if (_showTakePhotoButton & nav.allowTakePicture) {
        _collectionView.contentSize = CGSizeMake(self.view.width, ((_model.count + self.columnNumber)/self.columnNumber) * self.view.width);
    } else {
        _collectionView.contentSize = CGSizeMake(self.view.width, ((_model.count + self.columnNumber - 1)/self.columnNumber) * self.view.width);
    }
    
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[MMAssetCell class] forCellWithReuseIdentifier:@"MMAssetCell"];
    [_collectionView registerClass:[MMAssetCameraCell class] forCellWithReuseIdentifier:@"MMAssetCameraCell"];
    
}

- (void)configBottomToolBar {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    if (!nav.showSelectButton) return;
    
    CGFloat yOffset = 0;
    if (self.navigationController.navigationBar.isTranslucent) {
        yOffset = self.view.height - 50;
    } else {
        CGFloat navigationHeight = 44;
        if (kiOS7Later) navigationHeight += 20;
        yOffset = self.view.height - 50 - navigationHeight;
    }
    
    UIView *bottomToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, self.view.width, 50)];
    CGFloat rgb = 253 / 255.0;
    bottomToolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    
    CGFloat previewWidth = [nav.previewButtonTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.width + 2;
    if (!nav.allowPreview) {
        previewWidth = 0.0;
    }
    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _previewButton.frame = CGRectMake(10, 3, previewWidth, 44);
    _previewButton.width = !nav.showSelectButton ? 0 : previewWidth;
    [_previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_previewButton setTitle:nav.previewButtonTitle forState:UIControlStateNormal];
    [_previewButton setTitle:nav.previewButtonTitle forState:UIControlStateDisabled];
    [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _previewButton.enabled = nav.selectedModels.count;
    
    if (nav.allowPickOriginalPhoto) {
        CGFloat fullImageWidth = [nav.fullImageButtonTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.frame = CGRectMake(CGRectGetMaxX(_previewButton.frame), self.view.height - 50, fullImageWidth + 56, 50);
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_originalPhotoButton setTitle:nav.fullImageButtonTitle forState:UIControlStateNormal];
        [_originalPhotoButton setTitle:nav.fullImageButtonTitle forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:nav.photoOriginDefImageName] forState:UIControlStateNormal];
        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:nav.photoOriginSelImageName] forState:UIControlStateSelected];
        _originalPhotoButton.selected = _isSelectOriginalPhoto;
        _originalPhotoButton.enabled = nav.selectedModels.count > 0;
        
        _originalPhotoLabel = [[UILabel alloc] init];
        _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 46, 0, 80, 50);
        _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLabel.font = [UIFont systemFontOfSize:16];
        _originalPhotoLabel.textColor = [UIColor blackColor];
        if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
    }
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(self.view.width - 44 - 12, 3, 44, 44);
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitle:nav.doneButtonTitle forState:UIControlStateNormal];
    [_doneButton setTitle:nav.doneButtonTitle forState:UIControlStateDisabled];
    [_doneButton setTitleColor:nav.okButtonTitleColorNormal forState:UIControlStateNormal];
    [_doneButton setTitleColor:nav.okButtonTitleColorNormal forState:UIControlStateDisabled];
    _doneButton.enabled = nav.selectedModels.count || nav.alwaysEnableDoneBtn;
    
    _numberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedFromMyBundle:nav.photoNumberIconImageName]];
    _numberImageView.frame = CGRectMake(self.view.width - 56 - 28, 10, 30, 30);
    _numberImageView.hidden = nav.selectedModels.count <= 0;
    _numberImageView.backgroundColor = [UIColor clearColor];
    
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.frame = _numberImageView.frame;
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",nav.selectedModels.count];
    _numberLabel.hidden = nav.selectedModels.count <= 0;
    _numberLabel.backgroundColor = [UIColor clearColor];
    
    UIView *divide = [[UIView alloc] init];
    CGFloat rgb2 = 222 / 255.0;
    divide.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
    divide.frame = CGRectMake(0, 0, self.view.width, 1);
    
    [bottomToolBar addSubview:divide];
    [bottomToolBar addSubview:_previewButton];
    [bottomToolBar addSubview:_doneButton];
    [bottomToolBar addSubview:_numberImageView];
    [bottomToolBar addSubview:_numberLabel];
    [self.view addSubview:bottomToolBar];
    [self.view addSubview:_originalPhotoButton];
    [_originalPhotoButton addSubview:_originalPhotoLabel];
}

- (void)scrollCollectionViewToBottom {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    
    if (_shouldScrollToBottom && _models.count > 0 && nav.sortAscendingByModificationDate) {
        NSInteger item = _models.count - 1;
        if (_showTakePhotoButton) {
            if (nav.allowPickImage && nav.allowTakePicture) item += 1;
        }
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        _shouldScrollToBottom = NO;
    }
}


- (void)getSelectedPhotoBytes {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    [[MMImagePickManager manager] getPhotoBytesWithArray:nav.selectedModels completion:^(NSString *totalBytes) {
        _originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

- (void)pushPhotoPreviewController:(MMPhotoPreviewController *)photoPreviewVc {
    __weak typeof(self) weakSelf = self;
    photoPreviewVc.isSelectedOriginalPhoto = _isSelectOriginalPhoto;
    [photoPreviewVc setBackButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [weakSelf.collectionView reloadData];
        [weakSelf refreshBottomToolBarStatus];
    }];
    [photoPreviewVc setDoneButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [weakSelf doneButtonClick];
    }];
    [photoPreviewVc setDoneButtonClickBlockCropMode:^(UIImage *cropedImage, id asset) {
        [weakSelf didGetAllPhotos:@[cropedImage] assets:@[asset] infoArr:nil];
    }];
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}


#pragma mark    Click && Event

- (void)doneButtonClick {
//    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
//    
//    if (nav.minImagesCount && nav.selectedModels.count < nav.minImagesCount) {
//        NSString *title = [NSString stringWithFormat:[NSBundle mm_localizedStringForKey:@"Select a minimum of %zd photos" ], nav.minImagesCount];
//        [nav showAlertWithTitle:title];
//    }
//    [nav showProgressHUD];
//    
//    NSMutableArray *photos, *assets, *infos;
//    photos = assets = infos = @[].mutableCopy;
//    for (NSInteger i = 0; i < nav.selectedModels.count; i++) {
//        [photos addObject:@1];
//        [assets addObject:@1];
//        [infos addObject:@1];
//    }
//    
//    __block BOOL hasShowAlert = YES;
//    __block id alertView;
//    [MMImagePickManager manager].shouldFixOrientation = YES;
//    for (NSInteger i = 0; i < nav.selectedModels.count; i++) {
//        MMAssetModel *model = nav.selectedModels[i];
//        [[MMImagePickManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
//            if (isDegraded) return ;
//            if (photo) {
//                photo = [self scaleImage:photo toSize:CGSizeMake(nav.photoWidth, (int)(nav.photoWidth * photo.size.height / photo.size.width))];
//                [photos replaceObjectAtIndex:i withObject:photo];
//            }
//            if (info) [infos replaceObjectAtIndex:i withObject:info];
//            [assets replaceObjectAtIndex:i withObject:model.asset];
//            
//            for (id item in photos) {
//                if ([item isKindOfClass:[NSNumber class]]) return;
//            }
//            if (hasShowAlert) {
//                [nav hideAlertView:alertView];
//                [self didGetAllPhotos:photos assets:assets infoArr:infos];
//            }
//        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//            if (progress < 1 && hasShowAlert && !alertView) {
//                [nav hideProgressHUD];
//                alertView = [nav showAlertWithTitle:[NSBundle mm_localizedStringForKey:@"Synchronizing photos from iCloud"]];
//                hasShowAlert = NO;
//                return ;
//            }
//            if (progress >= 1) hasShowAlert = YES;
//        } networkAccessAllowed:YES];
//    }
//    if (nav.selectedModels.count <= 0) [self didGetAllPhotos:photos assets:assets infoArr:infos];
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    // 1.6.8 判断是否满足最小必选张数的限制
    if (nav.minImagesCount && nav.selectedModels.count < nav.minImagesCount) {
        NSString *title = [NSString stringWithFormat:[NSBundle mm_localizedStringForKey:@"Select a minimum of %zd photos"], nav.minImagesCount];
        [nav showAlertWithTitle:title];
        return;
    }
    
    [nav showProgressHUD];
    NSMutableArray *photos = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *infoArr = [NSMutableArray array];
    for (NSInteger i = 0; i < nav.selectedModels.count; i++) { [photos addObject:@1];[assets addObject:@1];[infoArr addObject:@1]; }
    
    __block BOOL havenotShowAlert = YES;
    [MMImagePickManager manager].shouldFixOrientation = YES;
    __block id alertView;
    for (NSInteger i = 0; i < nav.selectedModels.count; i++) {
        MMAssetModel *model = nav.selectedModels[i];
        [[MMImagePickManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded) return;
            if (photo) {
                photo = [self scaleImage:photo toSize:CGSizeMake(nav.photoWidth, (int)(nav.photoWidth * photo.size.height / photo.size.width))];
                [photos replaceObjectAtIndex:i withObject:photo];
            }
            if (info)  [infoArr replaceObjectAtIndex:i withObject:info];
            [assets replaceObjectAtIndex:i withObject:model.asset];
            
            for (id item in photos) { if ([item isKindOfClass:[NSNumber class]]) return; }
            
            if (havenotShowAlert) {
                [nav hideAlertView:alertView];
                [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
            }
        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            // 如果图片正在从iCloud同步中,提醒用户
            if (progress < 1 && havenotShowAlert && !alertView) {
                [nav hideProgressHUD];
                alertView = [nav showAlertWithTitle:[NSBundle mm_localizedStringForKey:@"Synchronizing photos from iCloud"]];
                havenotShowAlert = NO;
                return;
            }
            if (progress >= 1) {
                havenotShowAlert = YES;
            }
        } networkAccessAllowed:YES];
    }
    if (nav.selectedModels.count <= 0) {
        [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
    }

}

- (void)originalPhotoButtonClick {
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected; //是否选中原图通过原图button的选中状态来判断
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}


- (void)previewButtonClick {
    MMPhotoPreviewController *vc = [MMPhotoPreviewController new];
    [self pushPhotoPreviewController:vc];
}

#pragma mark    AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (kiOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
            NSURL *privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
            if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
                [[UIApplication sharedApplication] openURL:privacyUrl];
            } else {
                NSString *message = [NSBundle mm_localizedStringForKey:@"Can not jump to the privacy settings page, please go to the settings page by self, thank you"];
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSBundle mm_localizedStringForKey:@"Sorry"] message:message delegate:nil cancelButtonTitle:[NSBundle mm_localizedStringForKey:@"OK"] otherButtonTitles: nil];
                [alert show];
            }
            
        }
    }
}



#pragma mark    Getter & Setter

- (UIImagePickerController *)imagePicker {
    if (_imagePicker == nil) {
        _imagePicker = [UIImagePickerController new];
        _imagePicker.delegate = self;
        _imagePicker.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePicker.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *mmBarItem, *BarItem;
        if (kiOS9Later) {
            mmBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[MMImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            mmBarItem = [UIBarButtonItem appearanceWhenContainedIn:[MMPhotoPickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *dic = [mmBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:dic forState:UIControlStateNormal];
    }
    return _imagePicker;
}

- (void)refreshBottomToolBarStatus {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    
    _previewButton.enabled = nav.selectedModels.count > 0;
    _doneButton.enabled = nav.selectedModels.count > 0 || nav.alwaysEnableDoneBtn;
    
    
    _numberImageView.hidden = nav.selectedModels.count <= 0;
    _numberLabel.hidden = nav.selectedModels.count <= 0;
    _numberLabel.text = [NSString stringWithFormat:@"%zd", nav.selectedModels.count];
    
    _originalPhotoButton.enabled = nav.selectedModels.count > 0;
    _originalPhotoButton.selected = (_isSelectOriginalPhoto && _originalPhotoButton.enabled);
    _originalPhotoLabel.hidden = (!_originalPhotoButton.isSelected);
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

- (void)didGetAllPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infos {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    [nav hideProgressHUD];
    
    if (nav.autoDismiss) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethodWithPhotos:photos assets:assets infoArray:infos];
        }];
    } else {
        [self callDelegateMethodWithPhotos:photos assets:assets infoArray:infos];
    }
}

- (void)callDelegateMethodWithPhotos:(NSArray *)photos assets:(NSArray *)assets infoArray:(NSArray *)infos {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    if ([nav.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:sourceAssets:isSelectOriginalPhoto:infos:)]) {
        [nav.pickerDelegate imagePickerController:nav didFinishPickingMediaWithInfo:photos sourceAssets:assets isSelectOriginalPhoto:_isSelectOriginalPhoto infos:infos];
    }
    if ([nav.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:sourceAssets:isSelectOriginalPhoto:)]) {
        [nav.pickerDelegate imagePickerController:nav didFinishPickingMediaWithInfo:photos sourceAssets:assets isSelectOriginalPhoto:_isSelectOriginalPhoto];
    }
    if (nav.didFinishPickPhotosHandle) nav.didFinishPickPhotosHandle(photos, assets, _isSelectOriginalPhoto);
    if (nav.didFinishPickPhotosWithInfosHandle) nav.didFinishPickPhotosWithInfosHandle(photos, assets, _isSelectOriginalPhoto, infos);
}


- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width < size.width) return image;
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *new = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return new;
}


#pragma mark    UICollection-Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // take a photo / 去拍照
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    if (((nav.sortAscendingByModificationDate && indexPath.row >= _models.count) || (!nav.sortAscendingByModificationDate && indexPath.row == 0)) && _showTakePhotoButton)  {
        [self takePhoto]; return;
    }
    // preview phote or video / 预览照片或视频
    NSInteger index = indexPath.row;
    if (!nav.sortAscendingByModificationDate && _showTakePhotoButton) {
        index = indexPath.row - 1;
    }
    MMAssetModel *model = _models[index];
    if (model.type == MMAssetModelMediaTypeVideo) {
        if (nav.selectedModels.count > 0) {
            MMImagePickerController *imagePickerVc = (MMImagePickerController *)self.navigationController;
            [imagePickerVc showAlertWithTitle:[NSBundle mm_localizedStringForKey:@"Can not choose both video and photo"]];
        } else {
            MMVideoPlayerController *videoPlayerVc = [[MMVideoPlayerController alloc] init];
            videoPlayerVc.model = model;
            [self.navigationController pushViewController:videoPlayerVc animated:YES];
        }
    } else if (model.type == MMAssetModelMediaTypeGIF && nav.allowPickGif) {
        if (nav.selectedModels.count > 0) {
            MMImagePickerController *imagePickerVc = (MMImagePickerController *)self.navigationController;
            [imagePickerVc showAlertWithTitle:[NSBundle mm_localizedStringForKey:@"Can not choose both photo and GIF"]];
        } else {
            MMGIFPhotoPreviewController *gifPreviewVc = [[MMGIFPhotoPreviewController alloc] init];
            gifPreviewVc.model = model;
            [self.navigationController pushViewController:gifPreviewVc animated:YES];
        }
    } else {
        MMPhotoPreviewController *photoPreviewVc = [[MMPhotoPreviewController alloc] init];
        photoPreviewVc.currentIndex = index;
        photoPreviewVc.models = _models;
        [self pushPhotoPreviewController:photoPreviewVc];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"count===%ld",_models.count);
    if (_showTakePhotoButton) {
        MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
        if (nav.allowPickImage && nav.allowTakePicture) return _models.count + 1;
    }
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
#warning  !nav.sortAscendingByModificationDate 未加感叹号
    if (((nav.sortAscendingByModificationDate && indexPath.row >= _models.count) || (!nav.sortAscendingByModificationDate && indexPath.row == 0)) && _showTakePhotoButton) {
        MMAssetCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMAssetCameraCell" forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamedFromMyBundle:nav.takePictureImageName];
        return cell;
    }
    // the cell lead to take a picture / 去拍照的cell
       static NSString *cellID = @"MMAssetCell";
    MMAssetModel *model;
    
    MMAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.defImageName = nav.photoDefImageName;
    cell.selectImageName = nav.photoSelImageName;
    cell.allowPickGIF = nav.allowPickGif;
    cell.showSeletedButton = nav.showSelectButton;
    
    if (nav.sortAscendingByModificationDate || !_showTakePhotoButton) {
        model = _models[indexPath.row];
    } else {
        model = _models[indexPath.row - 1];
    }
    cell.model = model;
    if (!nav.allowPreview) cell.selectPhotoButton.frame = cell.bounds;
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    __weak typeof(_numberImageView.layer) weakLayer = _numberImageView.layer;
    
    cell.didSeletePhotoBlock = ^(BOOL seleted) {
        MMImagePickerController *weak_nav = (MMImagePickerController *)weakSelf.navigationController;
        if (seleted) {
            weakCell.selectPhotoButton.selected = NO;
            model.selected = NO;
            NSArray *selectedModels = [NSArray arrayWithArray:nav.selectedModels];
            for (MMAssetModel *item_model in selectedModels) {
                if ([[[MMImagePickManager manager] getAssetIdentifier:model.asset] isEqualToString:[[MMImagePickManager manager] getAssetIdentifier:item_model.asset]]) {
                    [weak_nav.selectedModels removeObject:item_model];
                    break;
                }
            }
            [weakSelf refreshBottomToolBarStatus];//刷新顶部选中数量
        } else {
            if (weak_nav.selectedModels.count < nav.maxImagesCount) {
                weakCell.selectPhotoButton.selected = YES;
                model.selected = YES;
                [weak_nav.selectedModels addObject:model];
                [weakSelf refreshBottomToolBarStatus];
            } else {
                NSString *title = [NSString stringWithFormat:[NSBundle mm_localizedStringForKey:@"Select a maximum of %zd photos"], nav.maxImagesCount];
                [weak_nav showAlertWithTitle:title];
            }
        }
        [weakLayer showOscillatoryAnimationWithType:MMOscillatorAnimationTypeToSmaller];
    };
    return cell;
}


#pragma mark    UIIMagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
        [nav showProgressHUD];
        UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (photo) {
            [[MMImagePickManager manager] savePhotoWithImage:photo location:self.location completion:^(NSError *error) {
                if (error) [self reloadPhotoArray];
            }];
            self.location = nil;
        }
    }
}


#pragma mark    Private - Method

- (void)takePhoto {
    AVAuthorizationStatus state = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((state == AVAuthorizationStatusRestricted || state == AVAuthorizationStatusDenied) && kiOS7Later) {
        // 无权限 做一个友好的提示
        NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
        if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
        NSString *message = [NSString stringWithFormat:[NSBundle mm_localizedStringForKey:@"Please allow %@ to access your camera in \"Settings -> Privacy -> Camera\""],appName];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSBundle mm_localizedStringForKey:@"Can not use camera"] message:message delegate:self cancelButtonTitle:[NSBundle mm_localizedStringForKey:@"Cancel"] otherButtonTitles:[NSBundle mm_localizedStringForKey:@"Setting"], nil];
        [alert show];
    } else if (state == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        if (kiOS7Later) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self pushImagePickerController];
                    });
                }
            }];
        } else {
            [self pushImagePickerController];
        }
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    // 提前定位
    [[MMLocationManager manager] startLocationSuccess:^(CLLocation *location, CLLocation *oldLocation) {
        _location = location;
    } failure:^(NSError *error) {
        _location = nil;
    }];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = sourceType;
        if(kiOS8Later) {
            _imagePicker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:_imagePicker animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)reloadPhotoArray {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    //获取相册所有图片
    [[MMImagePickManager manager] getCameraRollAlbum:nav.allowPickImage allowPickVideo:nav.allowPickImage completion:^(MMAlbumModel *model) {
        _model = model;
        [[MMImagePickManager manager] getAssetsFromFetchResult:model.result allowPickImage:nav.allowPickImage allowPickVideo:nav.allowPickVideo completion:^(NSArray<MMAssetModel *> *models) {
            [nav hideProgressHUD];
            
            MMAssetModel *assetModel;
            if (nav.sortAscendingByModificationDate) {
                assetModel = [models lastObject];
                [_models addObject:assetModel];
            } else {
                assetModel = models.firstObject;
                [_models insertObject:assetModel atIndex:0];
            }
            
            if (nav.maxImagesCount <= 1) {
                if (nav.allowCrop) {
                    MMPhotoPreviewController *previewVC = [MMPhotoPreviewController new];
                    if (nav.sortAscendingByModificationDate) {
                        previewVC.currentIndex = _models.count - 1;
                    } else {
                        previewVC.currentIndex = 0;
                    }
                    previewVC.models = _models;
                    [self pushPhotoPreviewController:previewVC];
                } else {
                    [nav.selectedModels addObject:assetModel];
                    [self doneButtonClick];
                }
                return ;
            }
            
            if (nav.selectedModels.count < nav.maxImagesCount) {
                assetModel.selected = YES;
                [nav.selectedModels addObject:assetModel];
                [self refreshBottomToolBarStatus];
            }
            [_collectionView reloadData];
            
            _shouldScrollToBottom = YES;
            [self scrollCollectionViewToBottom];
        }];
    }];
}
- (void)resetCachedAssets {
    [[MMImagePickManager manager].cachingImageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = _collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(_collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [[MMImagePickManager manager].cachingImageManager startCachingImagesForAssets:assetsToStartCaching
                                                                       targetSize:AssetGridThumbnailSize
                                                                      contentMode:PHImageContentModeAspectFill
                                                                          options:nil];
        [[MMImagePickManager manager].cachingImageManager stopCachingImagesForAssets:assetsToStopCaching
                                                                      targetSize:AssetGridThumbnailSize
                                                                     contentMode:PHImageContentModeAspectFill
                                                                         options:nil];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) return nil;
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *index in indexPaths) {
        if (index.item < _models.count) {
            MMAssetModel *model = _models[index.item];
            [assets addObject:model.asset];
        }
    }
    return assets;
}

- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *all = [_collectionView.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (all.count == 0) return nil;
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:all.count];
    for (UICollectionViewLayoutAttributes *attribute in all) {
        NSIndexPath *indexPath = attribute.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

@implementation MMCollectionView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:[UIControl class]]) return YES;
    return [super touchesShouldCancelInContentView:view];
}

@end
#pragma clang diagnostic pop

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
            [selectedAssets addObject:model.asset];
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
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = margin;// 每个cell间的间隔
    layout.minimumLineSpacing = margin;
    
    if (self.navigationController.navigationBar.isTranslucent) {//iOS6After  YES
        top = 44;
        if (kiOS7Later) top += 20;
        collectionHeight = self.view.height - top;
    } else {
        CGFloat navHeight = 44;
        if (kiOS7Later) navHeight += 20;
        collectionHeight = self.view.height - navHeight;
    }

    _collectionView = [[MMCollectionView alloc] initWithFrame:CGRectMake(0, top, self.view.width, self.view.height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    
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

- (void)previewButtonClick {
    MMPhotoPreviewController *vc = [MMPhotoPreviewController new];
    [self pushPhotoPreviewController:vc];
}


- (void)scrollCollectionViewToBottom {
    
}


- (void)getSelectedPhotoBytes {
        MMImagePickerController *imagePickerVc = (MMImagePickerController *)self.navigationController;
        [[MMImagePickManager manager] getPhotoBytesWithArray:imagePickerVc.selectedModels completion:^(NSString *totalBytes) {
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
    
}

- (void)originalPhotoButtonClick {
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
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
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
#pragma clang diagnostic pop

//
//  MMImagePickerController.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMImagePickerController.h"
#import "MMAssetCell.h"
#import "MMAssetModel.h"
#import "MMImagePickManager.h"
#import "MMImagePickerMacro.h"
#import "MMPhotoPreviewController.h"
#import "MMPhotoPickerController.h"

@interface MMImagePickerController () {
    NSTimer *_timer;
    UILabel *_tipLabel;
    UIButton *_settingButton;
    
    BOOL _pushPhotoPickerVC;
    BOOL _didPushPhotoPickerVC;
    
    UIView *_hudContainer;
    UIButton *_hudProgress;
    UILabel *_hudLabel;
    UIActivityIndicatorView *_hudIndicatorView;
    
    UIStatusBarStyle _originalStatuBayStyle;
}

@property (nonatomic, assign) NSInteger columnNumber;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


@implementation MMImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    
    [MMImagePickManager manager].shouldFixOrientation = NO;//默认不修正图片
    self.okButtonTitleColorNormal = Color(83, 179, 17, 1.0);
    self.okButtonTitleColorDisable = Color(83, 179, 17, 0.5);
    
    if (kiOS7Later) {
        self.navigationBar.barTintColor = Color(34, 34, 34, 1.0);
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)setNaviBgColor:(UIColor *)naviBgColor {
    _naviBgColor = naviBgColor;
    self.navigationBar.barTintColor = naviBgColor;
}

- (void)setNaviTitleColor:(UIColor *)naviTitleColor {
    _naviTitleColor = naviTitleColor;
    [self configNaviTitleAppearance];
}

- (void)setNaviTitlFont:(UIFont *)naviTitlFont {
    _naviTitlFont = naviTitlFont;
    [self configNaviTitleAppearance];
}

- (void)configNaviTitleAppearance {
    NSMutableDictionary *attrs = @{}.mutableCopy;
    attrs[NSForegroundColorAttributeName] = self.naviTitleColor;
    attrs[NSFontAttributeName] = self.naviTitlFont;
    self.navigationBar.titleTextAttributes = attrs;
}

- (void)setBarItemTextFont:(UIFont *)barItemTextFont {
    _barItemTextFont = barItemTextFont;
    [self configBarButtonitemAppearance];
}

- (void)setBarItemTextColor:(UIColor *)barItemTextColor {
    _barItemTextColor = barItemTextColor;
    [self configBarButtonitemAppearance];
}

- (void)configBarButtonitemAppearance {
    UIBarButtonItem *item;
    if (kiOS9Later) {
        item = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[MMImagePickerController class]]];
    } else {
        item = [UIBarButtonItem appearanceWhenContainedIn:[MMImagePickerController class], nil];
    }
    
    NSMutableDictionary *attrs = @{}.mutableCopy;
    attrs[NSForegroundColorAttributeName] = self.barItemTextColor;
    attrs[NSFontAttributeName] = self.barItemTextFont;
    [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originalStatuBayStyle = [UIApplication sharedApplication].statusBarStyle;
    if (self.isStatusBarDefault) {
        [UIApplication sharedApplication].statusBarStyle = kiOS7Later ? UIStatusBarStyleDefault : UIStatusBarStyleBlackOpaque;
    } else {
        [UIApplication sharedApplication].statusBarStyle = kiOS7Later ? UIStatusBarStyleLightContent : UIStatusBarStyleBlackOpaque;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originalStatuBayStyle;
    [self hideProgressHUD];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<MMImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:delegate pushPhotoPickerVC:YES];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<MMImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:columnNumber delegate:delegate pushPhotoPickerVC:YES];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<MMImagePickerControllerDelegate>)delegate pushPhotoPickerVC:(BOOL)pushPhotoPickerVC  {
    _pushPhotoPickerVC = pushPhotoPickerVC;
    MMAlbumPickerController *albumPickerVC = [[MMAlbumPickerController alloc] init];
    albumPickerVC.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVC];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        self.selectedModels = [NSMutableArray array];
        
        // Allow user picking original photo and video, you also can set No after this method
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        self.allowPickOriginalPhoto = YES;
        self.allowPickVideo = YES;
        self.allowPickImage = YES;
        self.allowTakePicture = YES;
        self.sortAscendingByModificationDate = YES;
        self.autoDismiss = YES;
        self.columnNumber = columnNumber;
        [self configDefaultSetting];
        
        if (![[MMImagePickManager manager] authorizationStatusAuthorized]) {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.frame = CGRectMake(8, 120, self.view.width - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = [UIColor blackColor];
            NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
            if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
            NSString *tipText = [NSString stringWithFormat:[NSBundle mm_localizedStringForKey:@"Allow %@ to access your album in \"Settings -> Privacy -> Photos\""],appName];
            _tipLabel.text = tipText;
            [self.view addSubview:_tipLabel];
            
            _settingButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingButton setTitle:self.settingButtonTitle forState:UIControlStateNormal];
            _settingButton.frame = CGRectMake(0, 180, self.view.width, 44);
            _settingButton.titleLabel.font = [UIFont systemFontOfSize:18];
            [_settingButton addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_settingButton];
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:YES];
        } else {
            [self pushPhotoPickerVC];
        }
    }
    return self;
}

- (void)observeAuthrizationStatusChange {
    
}

- (void)settingBtnClick {
    if (kiOS8Later) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else {
        NSURL *url = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) [[UIApplication sharedApplication] openURL:url];
        else {
            NSString *message = [NSBundle mm_localizedStringForKey:@"Can not jump to the privacysettings page, please go to the settings page by self, thank you"];
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSBundle mm_localizedStringForKey:@"Sorry"] message:message delegate:nil cancelButtonTitle:[NSBundle mm_localizedStringForKey:@"OK"] otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index {
    MMPhotoPreviewController *previewVC = [MMPhotoPreviewController new];
    self = [super initWithRootViewController:previewVC];
    if (self) {
        self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
        self.allowPickOriginalPhoto = self.allowPickOriginalPhoto;
        [self configDefaultSetting];
        
        previewVC.photos = [NSMutableArray arrayWithArray:selectedPhotos];
        previewVC.currentIndex = index;
        __weak typeof(self) weakSelf = self;
        previewVC.doneButtonClickWithPreviewType = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
          [weakSelf dismissViewControllerAnimated:YES completion:^{
              if (weakSelf.didFinishPickPhotosHandle) {
                  weakSelf.didFinishPickPhotosHandle(photos, assets, isSelectOriginalPhoto);
              }
          }];
        };
        
    }
    return self;
}

- (instancetype)initCropTypeWithAsset:(id)asset photo:(UIImage *)photo completion:(void (^)(UIImage *, id))completion {
    MMPhotoPreviewController *previewVC = [MMPhotoPreviewController new];
    self = [super initWithRootViewController:previewVC];//这里直接将rootvc 设为预览图
    if (self) {
        self.maxImagesCount = 1;
        self.allowCrop = YES;
        self.selectedAssets = @[asset].mutableCopy;
        [self configDefaultSetting];
        
        previewVC.photos = @[photo].mutableCopy;
        previewVC.isCropImage = YES;
        previewVC.currentIndex = 0;
        __weak typeof(self) weakSelf = self;
        previewVC.doneButtonClickBlockCropMode = ^(UIImage *cropedImage, id asset) {
          [weakSelf dismissViewControllerAnimated:YES completion:^{
              if (completion) completion(cropedImage, asset);
          }];
        };
    }
    return self;
}

- (void)configDefaultSetting {
    _timeout = 15;
    _photoWidth = 828.f;
    _photoPreviewMaxWidth = 600.f;
    _naviTitleColor = [UIColor whiteColor];
    _naviTitlFont = [UIFont systemFontOfSize:17];
    _barItemTextFont = [UIFont systemFontOfSize:15];
    _barItemTextColor = [UIColor whiteColor];
    _allowPreview = YES;
    
    [self configDefaultImageName];
    [self configDefaultButtonTitle];
}

- (void)configDefaultImageName {
    self.takePictureImageName = @"takePicture.png";
    self.photoSelImageName = @"photo_sel_photoPickerVc.png";
    self.photoDefImageName = @"photo_def_photoPickerVc.png";
    self.photoNumberIconImageName = @"photo_number_icon.png";
    self.photoPreviewOriginDefImageName = @"preview_original_def.png";
    self.photoOriginDefImageName = @"photo_original_def.png";
    self.photoOriginSelImageName = @"photo_original_sel.png";
}

- (void)configDefaultButtonTitle {
    self.doneButtonTitle = [NSBundle mm_localizedStringForKey:@"Done"];
    self.cancelButtonTitle = [NSBundle mm_localizedStringForKey:@"Cancel"];
    self.previewButtonTitle = [NSBundle mm_localizedStringForKey:@"Preview"];
    self.fullImageButtonTitle = [NSBundle mm_localizedStringForKey:@"Full image"];
    self.settingButtonTitle = [NSBundle mm_localizedStringForKey:@"Setting"];
    self.processHintTitle = [NSBundle mm_localizedStringForKey:@"Processing..."];
}

- (void)observeAuthorizationStatuChange {
    if ([[MMImagePickManager manager] authorizationStatusAuthorized]) { //清理授权文字提示
        [_tipLabel removeFromSuperview];
        [_settingButton removeFromSuperview];
        [_timer invalidate];
        _timer = nil;
        [self pushPhotoPickerVC];
    }
}

- (void)pushPhotoPickerVC {
    _didPushPhotoPickerVC = NO;
    if (!_didPushPhotoPickerVC && _pushPhotoPickerVC) { //_pushPhotoPickerVC 这个变量在构造函数初始化的时候传入
        MMPhotoPickerController *vc = [MMPhotoPickerController new];
        vc.isFirstAppear = YES;
        vc.columnNumber = _columnNumber;
        [[MMImagePickManager manager] getCameraRollAlbum:_allowPickImage allowPickVideo:_allowPickVideo completion:^(MMAlbumModel *model) {
            vc.model = model;
            [self pushViewController:vc animated:YES];
            _didPushPhotoPickerVC = YES;
        }];
    }
    
    //相册列表页面
    MMAlbumPickerController *album = (MMAlbumPickerController *)self.visibleViewController;
    if ([album isKindOfClass:[MMAlbumPickerController class]]) [album configTableView];
}

#pragma mark    HUD && Tip
- (id)showAlertWithTitle:(NSString *)title {
    if (kiOS8Later) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle mm_localizedStringForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return alertController;
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:[NSBundle mm_localizedStringForKey:@"OK"] otherButtonTitles:nil, nil];
        [alertView show];
        return alertView;
    }
}

- (void)hideAlertView:(id)alertView {
    if ([alertView isKindOfClass:[UIAlertController class]]) {
        UIAlertController *alertC = alertView;
        [alertC dismissViewControllerAnimated:YES completion:nil];
    } else if ([alertView isKindOfClass:[UIAlertView class]]) {
        UIAlertView *alertV = alertView;
        [alertV dismissWithClickedButtonIndex:0 animated:YES];
    }
    alertView = nil;
}

- (void)showProgressHUD {
    //显示加载菊花
    if (!_hudProgress) {
        _hudProgress = [UIButton buttonWithType:UIButtonTypeCustom];
        _hudProgress = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hudProgress setBackgroundColor:[UIColor clearColor]];
        
        _hudContainer = [[UIView alloc] init];
        _hudContainer.frame = CGRectMake((self.view.width - 120) / 2, (self.view.height - 90) / 2, 120, 90);
        _hudContainer.layer.cornerRadius = 8;
        _hudContainer.clipsToBounds = YES;
        _hudContainer.backgroundColor = [UIColor darkGrayColor];
        _hudContainer.alpha = 0.7;
        
        _hudIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _hudIndicatorView.frame = CGRectMake(45, 15, 30, 30);
        
        _hudLabel = [[UILabel alloc] init];
        _hudLabel.frame = CGRectMake(0,40, 120, 50);
        _hudLabel.textAlignment = NSTextAlignmentCenter;
        _hudLabel.text = self.processHintTitle;
        _hudLabel.font = [UIFont systemFontOfSize:15];
        _hudLabel.textColor = [UIColor whiteColor];
        
        [_hudContainer addSubview:_hudLabel];
        [_hudContainer addSubview:_hudIndicatorView];
        [_hudProgress addSubview:_hudContainer];
    }
    [_hudIndicatorView startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:_hudProgress];
    
    // if over time, dismiss HUD automatic
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf hideProgressHUD];
    });
}

- (void)hideProgressHUD {
    if (_hudProgress) {
        [_hudIndicatorView stopAnimating];
        [_hudProgress removeFromSuperview];
    }
}

#pragma mark    Custom Setter && Getter
- (void)setMaxImagesCount:(NSInteger)maxImagesCount {
    _maxImagesCount = maxImagesCount;
    if (maxImagesCount > 1) {
        _showSelectButton = YES;
        _allowCrop = NO;
    }
}

- (void)setShowSelectButton:(BOOL)showSelectButton {
    _showSelectButton = showSelectButton;
    // 多选模式下，不允许让showSelectButton为NO
    if (!showSelectButton && _maxImagesCount > 1) {
        _showSelectButton = YES;
    }
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = _maxImagesCount > 1 ? NO : allowCrop;
    if (allowCrop) { // 允许裁剪的时候，不能选原图和GIF
        self.allowPickOriginalPhoto = NO;
        self.allowPickGif = NO;
    }
}

- (void)setCircleCropRadius:(NSInteger)circleCropRadius {
    _circleCropRadius = circleCropRadius;
    _cropRect = CGRectMake(self.view.width / 2 - circleCropRadius, self.view.height / 2 - _circleCropRadius, _circleCropRadius * 2, _circleCropRadius * 2);
}

- (CGRect)cropRect {
    if (_cropRect.size.width > 0) {
        return _cropRect;
    }
    CGFloat cropViewWH = self.view.width;
    return CGRectMake(0, (self.view.height - self.view.width) / 2, cropViewWH, cropViewWH);
}

- (void)settimeout:(NSInteger)timeout {
    _timeout = timeout;
    if (timeout < 5) {
        _timeout = 5;
    } else if (_timeout > 60) {
        _timeout = 60;
    }
}

- (void)setPickerDelegate:(id<MMImagePickerControllerDelegate>)pickerDelegate {
    _pickerDelegate = pickerDelegate;
    [MMImagePickManager manager].pickerDelegate = pickerDelegate;
}

- (void)setColumnNumber:(NSInteger)columnNumber {
    
    _columnNumber = columnNumber;
    if (columnNumber <= 2) {
        _columnNumber = 2;
    } else if (columnNumber >= 6) {
        _columnNumber = 6;
    }
    
    MMAlbumPickerController *albumPickerVc = [self.childViewControllers firstObject];
    albumPickerVc.columnNumber = _columnNumber;
    [MMImagePickManager manager].columnNumber = _columnNumber;
}

- (void)setMinPhotoWidthSelectable:(NSInteger)minPhotoWidthSelectable {
    _minPhotoWidthSelectable = minPhotoWidthSelectable;
    [MMImagePickManager manager].minPhotoWidthSelectable = minPhotoWidthSelectable;
}

- (void)setMinPhotoHeightSelectable:(NSInteger)minPhotoHeightSelectable {
    _minPhotoHeightSelectable = minPhotoHeightSelectable;
    [MMImagePickManager manager].minPhotoHeightSelectable = minPhotoHeightSelectable;
}

- (void)setHideWhenUnSelectable:(BOOL)hideWhenUnSelectable {
    _hideWhenUnSelectable = hideWhenUnSelectable;
    [MMImagePickManager manager].hideWhenUnselectable = hideWhenUnSelectable;
}

- (void)setPhotoPreviewMaxWidth:(CGFloat)photoPreviewMaxWidth {
    _photoPreviewMaxWidth = photoPreviewMaxWidth;
    if (photoPreviewMaxWidth > 800) {
        _photoPreviewMaxWidth = 800;
    } else if (photoPreviewMaxWidth < 500) {
        _photoPreviewMaxWidth = 500;
    }
    [MMImagePickManager manager].photoPreviewMaxWidth = _photoPreviewMaxWidth;
}

- (void)setSelectedAssets:(NSMutableArray *)selectedAssets {
    _selectedAssets = selectedAssets;
    _selectedModels = [NSMutableArray array];
    for (id asset in selectedAssets) {
        MMAssetModel *model = [MMAssetModel modelWithAsset:asset type:MMAssetModelMediaTypePhoto];
        model.selected = YES;
        [_selectedModels addObject:model];
    }
}

- (void)setAllowPickImage:(BOOL)allowPickImage {
    _allowPickImage = allowPickImage;
    NSString *allowPickImageStr = _allowPickImage ? @"1" : @"0";
    [[NSUserDefaults standardUserDefaults] setObject:allowPickImageStr forKey:@"mm_allowPickImage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAllowPickVideo:(BOOL)allowPickVideo {
    _allowPickVideo = allowPickVideo;
    NSString *allowPickVideoStr = _allowPickVideo ? @"1" : @"0";
    [[NSUserDefaults standardUserDefaults] setObject:allowPickVideoStr forKey:@"mm_allowPickVideo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate {
    _sortAscendingByModificationDate = sortAscendingByModificationDate;
    [MMImagePickManager manager].sortAscendingByModificationDate = sortAscendingByModificationDate;
}

#pragma mark    Override

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (kiOS7Later) viewController.automaticallyAdjustsScrollViewInsets = NO;
    if (_timer) {[_timer invalidate]; _timer = nil;}
    [super pushViewController:viewController animated:animated];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark    Click

- (void)cancelButtonClick {
    if (self.autoDismiss) { //这个默认是YES 暂时没有根据版本做不同的区分
        [self dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    } else {
        [self callDelegateMethod];
    }
}

- (void)callDelegateMethod {
    if ([self.pickerDelegate respondsToSelector:@selector(mm_imagePickerControllerDidCancel:)]) {
        [self.pickerDelegate mm_imagePickerControllerDidCancel:self];
    }
    
    if (self.imagePickerControllerDidCancelHandle) self.imagePickerControllerDidCancelHandle();
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

@interface MMAlbumPickerController()<UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
}

@property (nonatomic, strong) NSMutableArray *albumArray;

@end

@implementation MMAlbumPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nav.cancelButtonTitle style:UIBarButtonItemStylePlain target:nav action:@selector(cancelButtonClick)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    [nav hideProgressHUD];
    if (nav.allowTakePicture) {
        self.navigationItem.title = [NSBundle mm_localizedStringForKey:@"Photos"];
    } else if (nav.allowPickVideo) {
        self.navigationItem.title = [NSBundle mm_localizedStringForKey:@"Videos"];
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle mm_localizedStringForKey:@"Back"] style:UIBarButtonItemStylePlain target:nil action:nil];
    [self configTableView];
}

- (void)configTableView {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
        [[MMImagePickManager manager] getAllAlbum:nav.allowPickImage allowPickVideo:nav.allowPickVideo completion:^(NSArray<MMAlbumModel *> *models) {
            
            _albumArray = [NSMutableArray arrayWithArray:models];
            for (MMAlbumModel *albumModel in _albumArray) {
                albumModel.selectedModels = nav.selectedModels;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!_tableView) {
                    CGFloat top = 0;
                    CGFloat tabHeight = 0;
                    if (self.navigationController.navigationBar.isTranslucent) {//iOS6After  YES
                        top = 44;
                        if (kiOS7Later) top += 20;
                        tabHeight = self.view.height - top;
                    } else {
                        CGFloat navHeight = 44;
                        if (kiOS7Later) 
                    }
                }
            });
            
        }];
        
        
    });
}


- (void)didReceiveMemoryWarning {
    
}


@end
#pragma clang diagnostic pop

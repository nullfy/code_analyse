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

@property (nonatomic, assign) NSInteger culumnNumber;

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
        self.culumnNumber = columnNumber;
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

- (instancetype)initCropTypeWithAsset:(id)asset photo:(UIImage *)photo completion:(void (^)(UIImage *, id))completion {
    MMPhotoPreviewController *previewVC = [MMPhotoPreviewController new];
    self = [super initWithRootViewController:previewVC];
    if (self) {
        
        
    }
    return self;
}

- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index {
    MMPhotoPreviewController *previewVC = [MMPhotoPreviewController new];
    self = [super initWithRootViewController:previewVC];
    if (self) {
        self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
        
    }
    return self;
}



- (void)configDefaultSetting {
    
}

- (void)pushPhotoPickerVC {
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
#pragma clang diagnostic pop

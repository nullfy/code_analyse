//
//  MMImagePickerController.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMAssetModel.h"
#import "NSBundle+ImagePicker.h"

@protocol MMImagePickerControllerDelegate;
@interface MMImagePickerController : UINavigationController

@property (nonatomic, assign) NSInteger maxImagesCount;
@property (nonatomic, assign) NSInteger minImagesCount;
@property (nonatomic, assign) BOOL alwaysEnableDoneBtn;
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;
@property (nonatomic, assign) CGFloat photoWidth;
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;
@property (nonatomic, assign) NSInteger timeOut;
@property (nonatomic, assign) BOOL allowPickOriginalPhoto;
@property (nonatomic, assign) BOOL allowPickVideo;
@property (nonatomic, assign) BOOL allowPickGif;
@property (nonatomic, assign) BOOL allowPickImage;
@property (nonatomic, assign) BOOL allowTakePicture;
@property (nonatomic, assign) BOOL allowPreview;
@property (nonatomic, assign) BOOL autoDismiss;

@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray<MMAssetModel *> *selectedModels;

@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;
@property (nonatomic, assign) BOOL hideWhenUnSelectable;
@property (nonatomic, assign) BOOL isStatusBarDefault;
@property (nonatomic, assign) BOOL showSelectButton;
@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) BOOL needCircleCrop;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) NSInteger circleCropRadius;
@property (nonatomic, copy) void(^cropViewSettingBlock)(UIView *cropView);

@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (nonatomic, copy) NSString *takePictureImageName;
@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;
@property (nonatomic, copy) NSString *photoOriginSelImageName;
@property (nonatomic, copy) NSString *photoOriginDefImageName;
@property (nonatomic, copy) NSString *photoPreviewOriginDefImageName;
@property (nonatomic, copy) NSString *photoNumberIconImageName;

@property (nonatomic, strong) UIColor *okButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *okButtonTitleColorDisable;
@property (nonatomic, strong) UIColor *naviBgColor;
@property (nonatomic, strong) UIColor *naviTitleColor;
@property (nonatomic, strong) UIColor *barItemTextColor;
@property (nonatomic, strong) UIFont *naviTitlFont;
@property (nonatomic, strong) UIFont *barItemTextFont;

@property (nonatomic, copy) NSString *doneButtonTitle;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSString *previewButtonTitle;
@property (nonatomic, copy) NSString *fullImageButtonTitle;
@property (nonatomic, copy) NSString *settingButtonTitle;
@property (nonatomic, copy) NSString *processHint;

@property (nonatomic, copy) void(^didFinishPickPhotosHandle)(NSArray<UIImage *> *photos, NSArray *assets, BOOL isOriginal);
@property (nonatomic, copy) void(^didFinishPickPhotosWithInfosHandle)(NSArray<UIImage *> *photos, NSArray *assets, BOOL isOriginal, NSArray<NSDictionary *> *infos);
@property (nonatomic, copy) void(^imagePickerControllerDidCancelHandle)();
@property (nonatomic, copy) void(^didFinishPickVideoHandle)(UIImage *coverImage, id asset);

@property (nonatomic, weak) id<MMImagePickerControllerDelegate> pickerDelegate;


- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets
                        selectedPhotos:(NSMutableArray *)selectedPhotos
                                 index:(NSInteger)index;

- (instancetype)initCropTypeWithAsset:(id)asset
                                photo:(UIImage *)photo
                           completion:(void (^)(UIImage *cropImage,id asset))completion;

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount
                              delegate:(id<MMImagePickerControllerDelegate>)delegate;

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount
                          columnNumber:(NSInteger)columnNumber
                              delegate:(id<MMImagePickerControllerDelegate>)delegate;

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount
                          columnNumber:(NSInteger)columnNumber
                              delegate:(id<MMImagePickerControllerDelegate>)delegate
                     pushPhotoPickerVC:(BOOL)pushPhotoPickerVC;



- (void)cancelButtonClick;

- (id)showAlertWithTitle:(NSString *)title;
- (void)hideAlertView:(id)alertView;
- (void)showProgressHUD;
- (void)hideProgressHUD;

@end

@protocol MMImagePickerControllerDelegate <NSObject>

@optional
- (void)imagePickerController:(MMImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSArray<UIImage *> *)photos
                 sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isOriginal;

- (void)imagePickerController:(MMImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSArray<UIImage *> *)photos
                 sourceAssets:(NSArray *)assets
        isSelectOriginalPhoto:(BOOL)isOriginal
                        infos:(NSArray<NSDictionary *> *)infos;

- (void)mm_imagePickerControllerDidCancel:(MMImagePickerController *)picker;
- (void)imagePickerController:(MMImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)assets;
- (void)imagePickerController:(MMImagePickerController *)picker didFinishPickingGIF:(UIImage *)gif sourceAssets:(id)assets;

- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result;
- (BOOL)isAssetCanSelect:(id)asset;

@end

@interface MMAlbumPickerController : UIViewController

@property (nonatomic, assign) NSInteger columnNumber;

- (void)configTableView;

@end

@interface UIImage(imagePicker)

+ (UIImage *)imageNamedFromBundle:(NSString *)name;

@end

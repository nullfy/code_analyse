//
//  MMGIFPhotoPreviewController.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/30.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMGIFPhotoPreviewController.h"
#import "MMImagePickerController.h"
#import "MMPhotoPreviewCell.h"
#import "MMImagePickManager.h"
#import "MMAssetModel.h"
#import "MMImagePickerMacro.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@interface MMGIFPhotoPreviewController () {
    UIView *_toolBar;
    UIButton *_doneButton;
    UIProgressView *_progress;
    
    MMPhotoPreviewView *_preview;
    UIStatusBarStyle _originalStatuBarStyle;
}

@end

@implementation MMGIFPhotoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    if (nav) self.navigationItem.title = [NSString stringWithFormat:@"GIF %@",nav.previewButtonTitle];
    
    [self configPreviewView];
    [self configBottomToolBar];
}

#pragma makr    Life-Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originalStatuBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = kiOS7Later ? UIStatusBarStyleLightContent : UIStatusBarStyleBlackOpaque;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originalStatuBarStyle;
}


- (void)configPreviewView {
    _preview = [[MMPhotoPreviewView alloc] initWithFrame:self.view.bounds];
    _preview.scrollView.frame = self.view.bounds;
    _preview.model = self.model;
    __weak typeof(self) weakSelf = self;
    _preview.singleTapGestureBlock = ^{
        [weakSelf singleTapAction];
    };
    [self.view addSubview:_preview];
}

- (void)configBottomToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
    CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(self.view.width - 44 - 12, 0, 44, 44);
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    if (nav) {
        [_doneButton setTitle:nav.doneButtonTitle forState:UIControlStateNormal];
        [_doneButton setTitleColor:nav.okButtonTitleColorNormal forState:UIControlStateNormal];
    } else {
        [_doneButton setTitle:[NSBundle mm_localizedStringForKey:@"Done"] forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0] forState:UIControlStateNormal];
    }
    [_toolBar addSubview:_doneButton];
    
    UILabel *byteLabel = [[UILabel alloc] init];
    byteLabel.textColor = [UIColor whiteColor];
    byteLabel.font = [UIFont systemFontOfSize:13];
    byteLabel.frame = CGRectMake(10, 0, 100, 44);
    [[MMImagePickManager manager] getPhotoBytesWithArray:@[_model] completion:^(NSString *totalBytes) {
        byteLabel.text = totalBytes;
    }];
    [_toolBar addSubview:byteLabel];
    
    [self.view addSubview:_toolBar];
}

#pragma mark    Click-Event

- (void)doneButtonClick {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    if (nav) {
        if (nav.autoDismiss) [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];

    }
}

- (void)singleTapAction {
    _toolBar.hidden = !_toolBar.isHidden;
    self.navigationController.navigationBarHidden = _toolBar.isHidden;
    if (kiOS7Later) [UIApplication sharedApplication].statusBarHidden = _toolBar.isHidden;
}

- (void)callDelegateMethod {
    MMImagePickerController *nav = (MMImagePickerController *)self.navigationController;
    UIImage *image = _preview.imageView.image;
    if ([nav.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingGIF:sourceAssets:)]) {
        [nav.pickerDelegate imagePickerController:nav didFinishPickingGIF:image sourceAssets:_model.asset];
    }
    if (nav.didFinishPickGIFHandle) nav.didFinishPickGIFHandle(image, _model.asset);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
#pragma clang diagnostic pop

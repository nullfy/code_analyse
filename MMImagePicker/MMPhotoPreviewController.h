//
//  MMPhotoPreviewController.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/22.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMPhotoPreviewController : UIViewController
@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, strong) NSMutableArray *photos;//这个photo是用来装选中图片的
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL isSelectedOriginalPhoto;//默认是NO
@property (nonatomic, assign) BOOL isCropImage;

@property (nonatomic, copy) void (^backButtonClickBlock) (BOOL isSelectOriginalPhoto);//返回button 这个参数 为啥不用已选的原图数组
@property (nonatomic, copy) void (^doneButtonClickBlock) (BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^doneButtonClickBlockCropMode) (UIImage *cropedImage, id asset);
@property (nonatomic, copy) void (^doneButtonClickWithPreviewType) (NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto);
@end

//
//  MMPhotoPickerController.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/22.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMAlbumModel;
@interface MMPhotoPickerController : UIViewController

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) MMAlbumModel *model;

@end

@interface MMCollectionView : UICollectionView

@end

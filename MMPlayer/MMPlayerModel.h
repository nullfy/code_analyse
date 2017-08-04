//
//  MMPlayerModel.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MMPlayerModel : NSObject

//视频标题
@property (nonatomic, copy) NSString *title;

//视频封面图URL，如果和本地图片同时设置，则忽略本地图片，显示网络图片
@property (nonatomic, copy) NSString *placeholderImageURLString;

//视频分辨率字典，分辨率标题与该分辨率对应的视频URL
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *resolutionDic;

//视频URL
@property (nonatomic, strong) NSURL *videoURL;

//视频封面本地图片
@property (nonatomic, strong) UIImage *placeholderImage;

//cell播放视频
@property (nonatomic, strong) UIScrollView *scrollView;

//播放器View的父视图（非Cell 播放使用这个）
@property (nonatomic, weak) UIView *fatherView;

//播放器Cell 所在的indexPath
@property (nonatomic, strong) NSIndexPath *indexPath;

//从上次播放时间开始播放视频，默认是0
@property (nonatomic, assign) NSUInteger seekTime;

//Cell 上播放必须指定
@property (nonatomic, assign) NSUInteger fatherViewTag;

@end

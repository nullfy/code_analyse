//
//  UIImageView+MMPlayer.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/27.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MMPlayerDownloadDataBlock)(NSData *data, NSError *error);
typedef void(^MMPlayerDownloadProgressBlock)(unsigned long long total, unsigned long long current);

@interface MMPlayerImageDownloader : NSObject<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

@property (nonatomic, assign) unsigned long long totalLength;
@property (nonatomic, assign) unsigned long long currentLength;

@property (nonatomic, copy) MMPlayerDownloadDataBlock finishBlock;
@property (nonatomic, copy) MMPlayerDownloadProgressBlock progressBlock;

- (void)startDownloadImageWithURL:(NSString *)urlString
                         progress:(MMPlayerDownloadProgressBlock)progress
                         finished:(MMPlayerDownloadDataBlock)finished;

@end


typedef void(^MMPlayerImageBlock)(UIImage *image);

@interface UIImageView (MMPlayer)

@property (nonatomic, copy) MMPlayerImageBlock completion;

@property (nonatomic, strong) MMPlayerImageDownloader *imageDownloader;

@property (nonatomic, assign) NSUInteger maxFailReloadTimes;

@property (nonatomic, assign) BOOL shouldAutoClipImageToViewSize;

- (void)setImageWithURLString:(NSString *)url placeholderImageName:(NSString *)imageName;

- (void)setImageWithURLString:(NSString *)url placeholderImage:(UIImage *)image;

- (void)setImageWithURLString:(NSString *)url
         placeholderImageName:(NSString *)imageName
                   completion:(void(^)(UIImage *image))completion;

- (void)setImageWithURLString:(NSString *)url
             placeholderImage:(UIImage *)image
                   completion:(void(^)(UIImage *image))completion;
@end

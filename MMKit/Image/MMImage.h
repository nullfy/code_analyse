//
//  MMImage.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/5/13.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_include(<MMKit/MMKit.h>)
#import <MMkit/MMAnimatedImageView.h>
#import <MMKit/MMImageCoder.h>
#else
#import "MMImageCoder.h"
#import "MMAnimatedImageView.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface MMImage : UIImage

+ (nullable MMImage *)imageNamed:(NSString *)name;
+ (nullable MMImage *)imageWithContentOfFile:(NSString *)path;
+ (nullable MMImage *)imageWithData:(NSData *)data;
+ (nullable MMImage *)imageWithData:(NSData *) scale:(CGFloat)s;


@property (nonatomic, readonly) MMImageType animatedImageType;
@property (nullable, nonatomic, readonly) NSData *animatedImageData;
@property (nonatomic, readonly) NSUInteger animatedImagememorySize;
@property (nonatomic) BOOL *preloadAllAnimatedImageFrames;

@end
NS_ASSUME_NONNULL_END

//
//  UIImageView+MMPlayer.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/27.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "UIImageView+MMPlayer.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
#import "UIApplication+MMPlayer.h"

@interface MMPlayerImageDownloader ()<NSURLSessionDelegate>

@end

@implementation MMPlayerImageDownloader

- (void)startDownloadImageWithURL:(NSString *)urlString progress:(MMPlayerDownloadProgressBlock)progress finished:(MMPlayerDownloadDataBlock)finished {
    self.progressBlock = progress;
    self.finishBlock = finished;
    if (!urlString) {
        if (finished) finished(nil, nil);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *queue = [NSOperationQueue new];
    self.session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:queue];
    
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];
    [task resume];
    self.task = task;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    self.currentLength = totalBytesWritten;
    self.totalLength = totalBytesExpectedToWrite;
    
    if (self.progressBlock) self.progressBlock(self.totalLength, self.currentLength);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error.code != NSURLErrorCancelled) {
        if (self.finishBlock) self.finishBlock(nil, error);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
}

@end


@implementation UIImageView (MMPlayer)

#pragma mark    Getter && Setter

- (MMPlayerImageBlock)completion {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCompletion:(MMPlayerImageBlock)completion {
    objc_setAssociatedObject(self, @selector(completion), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (MMPlayerImageDownloader *)imageDownloader {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setImageDownloader:(MMPlayerImageDownloader *)imageDownloader {
    objc_setAssociatedObject(self, @selector(imageDownloader), imageDownloader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)maxFailReloadTimes {
    NSUInteger count = [objc_getAssociatedObject(self, _cmd) integerValue];
    if (count == 0) count = 2;
    return count;
}

- (void)setMaxFailReloadTimes:(NSUInteger)maxFailReloadTimes {
    objc_setAssociatedObject(self, @selector(maxFailReloadTimes), @(maxFailReloadTimes), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)shouldAutoClipImageToViewSize {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setShouldAutoClipImageToViewSize:(BOOL)shouldAutoClipImageToViewSize {
    objc_setAssociatedObject(self, @selector(shouldAutoClipImageToViewSize), @(shouldAutoClipImageToViewSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark    Public Method

- (void)setImageWithURLString:(NSString *)url placeholderImageName:(NSString *)imageName {
    [self setImageWithURLString:url placeholderImageName:imageName completion:nil];
}

- (void)setImageWithURLString:(NSString *)url placeholderImage:(UIImage *)image {
    [self setImageWithURLString:url placeholderImage:image completion:nil];
}

- (void)setImageWithURLString:(NSString *)url placeholderImageName:(NSString *)imageName completion:(void (^)(UIImage *))completion {
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (image == nil) image = [UIImage imageNamed:imageName];
    [self setImageWithURLString:url placeholderImage:image completion:nil];
}

- (void)setImageWithURLString:(NSString *)url placeholderImage:(UIImage *)image completion:(void (^)(UIImage *))completion {
    [self.layer removeAllAnimations];
    self.completion = completion;
    
    if (url == nil ||
        [url isKindOfClass:[NSNull class]] ||
        (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"])) {
        [self setImage:image isFromCache:YES];
        if (completion) completion(self.image);
        return;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self downloadWithRequest:request holdImage:image];
}

#pragma mark    Private Method

- (void)setImage:(UIImage *)image isFromCache:(BOOL)isCache {
    self.image = image;
    if (!isCache) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.6];
        [animation setType:kCATransitionFade];
        animation.removedOnCompletion = YES;
        [self.layer addAnimation:animation forKey:@"transition"];
    }
}

- (void)downloadWithRequest:(NSMutableURLRequest *)requst holdImage:(UIImage *)holdimage {
    UIImage *cacheImage = [[UIApplication sharedApplication] mm_cacheImageForRequest:requst];
    if (cacheImage) {
        [self setImage:cacheImage isFromCache:YES];
        if (self.completion) self.completion(cacheImage);
        return;
    }
    [self setImage:holdimage isFromCache:YES];
    
    if ([[UIApplication sharedApplication] mm_failTimesForRequest:requst] >= self.maxFailReloadTimes) return;
    
    [self cancleRequest];
    self.imageDownloader = nil;
    
    __weak typeof(self) weakSelf = self;
    self.imageDownloader = [[MMPlayerImageDownloader alloc] init];
    [self.imageDownloader startDownloadImageWithURL:requst.URL.absoluteString progress:nil finished:^(NSData *data, NSError *error) {
        if (data != nil && error == nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage imageWithData:data];
                UIImage *finalImage = image;
                
                if (image) {
                    if (weakSelf.shouldAutoClipImageToViewSize) {
                        if (fabs(weakSelf.frame.size.width - image.size.width) != 0 &&
                            fabs(weakSelf.frame.size.height - image.size.height) != 0 ) {
                            finalImage = [self clipImage:image toSize:weakSelf.frame.size isScaleToMax:YES];
                        }
                    }
                    
                    [[UIApplication sharedApplication] mm_cacheImage:finalImage forRequest:requst];
                } else {
                    [[UIApplication sharedApplication] mm_cacheFailRequest:requst];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (finalImage) {
                        [weakSelf setImage:finalImage isFromCache:NO];
                        if (weakSelf.completion) weakSelf.completion(weakSelf.image);
                    } else {
                        if (weakSelf.completion) weakSelf.completion(weakSelf.image);
                    }
                });
            });
        } else {
            [[UIApplication sharedApplication] mm_cacheFailRequest:requst];
            if (weakSelf.completion) weakSelf.completion(weakSelf.image);
        }
    }];
}

- (void)cancleRequest {
    [self.imageDownloader.task cancel];
}

- (UIImage *)clipImage:(UIImage *)image toSize:(CGSize)size isScaleToMax:(BOOL)isMax {
    CGFloat scale = [UIScreen mainScreen].scale;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGSize aspectFitSize = CGSizeZero;
    if (image.size.width != 0 && image.size.height != 0) {
        CGFloat rateWidth = size.width / image.size.width;
        CGFloat rateHeight = size.height / image.size.height;
        
        CGFloat rate = isMax ? MAX(rateHeight, rateWidth) : MIN(rateHeight, rateWidth);
        
        aspectFitSize = CGSizeMake(image.size.width * rate, image.size.height * rate);
    }
    [image drawInRect:CGRectMake(0, 0, aspectFitSize.width, aspectFitSize.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end

//
//  MMPlayerModel.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/26.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMPlayerModel.h"
#import "MMPlayer.h"

@implementation MMPlayerModel

- (UIImage *)placeholderImage {
    if (!_placeholderImage) {
        _placeholderImage = MMPlayerImage(@"MMPlayer_loading_bgView");
    }
    return _placeholderImage;
}

@end

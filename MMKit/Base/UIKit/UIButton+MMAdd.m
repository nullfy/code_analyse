//
//  UIButton+MMAdd.m
//  PracticeKit
//
//  Created by 晓东 on 2017/2/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "UIButton+MMAdd.h"

@implementation UIButton (MMAdd)

+ (UIButton *)buttonWithFrame:(CGRect)frame CenterTitle:(NSString *)title centerImage:(UIImage *)image {
    if (!title && !image) return nil;
    
    UIButton *button = [UIButton new];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    //[button sizeToFit];
    button.frame = frame;
    
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    
    CGSize buttonSize = button.size;
    
    if (title && image) {
        CGFloat imageW = button.imageView.frame.size.width;
        CGFloat imageH = button.imageView.frame.size.height;
        
        CGFloat labelW = button.titleLabel.frame.size.width;
        CGFloat labelH = button.titleLabel.frame.size.height;
        
        CGFloat imageLeft = (buttonSize.width - imageW) / 2;
        CGFloat imageTop = (buttonSize.height - imageH - labelH) / 2;
        button.imageEdgeInsets = UIEdgeInsetsMake(imageTop, imageLeft, 0, 0);
        
        CGFloat labelLeft = (buttonSize.width - labelW) / 2 - imageW;
        CGFloat labelTop = imageTop + imageH;
        button.titleEdgeInsets = UIEdgeInsetsMake(labelTop, labelLeft, 0, 0);
    } else {
        button.contentHorizontalAlignment = UIControlContentVerticalAlignmentCenter;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
    
    return button;
}

@end

//
//  UIView+MMToast.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/5/27.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "UIView+MMToast.h"

static CGFloat const kToastDuration = 1.5;
static CGFloat const kToastAnimationTime = 0.1;
static CGFloat const kToastFontSize = 14.f;
#define kToastFont(font) [UIFont systemFontOfSize:font]
@implementation UIView (MMToast)

- (void)toast:(NSString *)msg {
    [self toast:msg duration:kToastDuration];
}

- (void)toast:(NSString *)msg position:(MMToastPosition)position {
    [self toast:msg position:position style:MMToastStyleBlack];
}

- (void)toast:(NSString *)msg style:(MMToastStyle)style {
    [self toast:msg position:MMToastPositionMiddle style:style];
}

- (void)toast:(NSString *)msg position:(MMToastPosition)position style:(MMToastStyle)style {
    [self toast:msg duration:kToastDuration position:position style:style];
}

- (void)toast:(NSString *)msg duration:(NSTimeInterval)duration {
    [self toast:msg duration:duration position:MMToastPositionBottom];
}

- (void)toast:(NSString *)msg duration:(NSTimeInterval)duration position:(MMToastPosition)position {
    [self toast:msg duration:duration position:position style:MMToastStyleWhite];
}

- (void)toast:(NSString *)msg duration:(NSTimeInterval)duration position:(MMToastPosition)position style:(MMToastStyle)style {
    [self createContentLabelWithMsg:msg duration:duration position:position style:style];
}

- (UILabel *)createContentLabelWithMsg:(NSString *)msg duration:(NSTimeInterval)duration position:(MMToastPosition)position style:(MMToastStyle)style {
    self.userInteractionEnabled = NO;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat contentLabelY = 0.0;
    UIColor *fontColor = nil;
    UIColor *backColor = nil;
    
    switch (position) {
        case MMToastPositionTop:
            contentLabelY = 100.0;
            break;
            case MMToastPositionMiddle:
            contentLabelY = screenSize.height / 2.0;
            break;
            case MMToastPositionBottom:
            contentLabelY = screenSize.height - 100.0;
        default:
            break;
    }
    switch (style) {
        case MMToastStyleWhite:
            fontColor = [UIColor whiteColor];
            backColor = [UIColor blackColor];
            break;
            case MMToastStyleBlur:
            fontColor = [UIColor colorWithWhite:0.95 alpha:0.9];
            backColor = [UIColor colorWithWhite:0.3 alpha:0.9];
            break;
            case MMToastStyleBlack:
            fontColor = [UIColor blackColor];
            backColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
            break;
        default:
            break;
    }
    
    CGFloat padding = 10.0;
    /*
     [self boundingRectWithSize:size
     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
     attributes:attr
     context:nil];
     
     NSMutableDictionary *attr = [NSMutableDictionary new];
     attr[NSFontAttributeName] = font;
     if (lineBreakMode != NSLineBreakByWordWrapping) {
     NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
     paragraphStyle.lineBreakMode = lineBreakMode;
     attr[NSParagraphStyleAttributeName] = paragraphStyle;
     }
     */
    
    NSMutableDictionary *attr = [NSMutableDictionary new];
    attr[NSFontAttributeName] = kToastFont(kToastFontSize);
    //attr[NSParagraphStyleAttributeName] = ;
    
    CGSize msgSize = [msg boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                       options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attr
                                       context:nil].size;
    CGFloat contentLabelWidth = msgSize.width + padding * 2;
    NSInteger multiple = (NSInteger)(msgSize.width / (screenSize.width - padding * 2)) + 1;
    if (multiple > 1) contentLabelWidth = screenSize.width - padding * 2;
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake((screenSize.width - contentLabelWidth) / 2.0, contentLabelY, contentLabelWidth, multiple * msgSize.height + padding)];
    contentLabel.numberOfLines = 0;
    contentLabel.backgroundColor = backColor;
    contentLabel.textColor = fontColor;
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.center = CGPointMake(screenSize.width/2, contentLabelY);
    contentLabel.text = msg;
    contentLabel.layer.cornerRadius = 8.0;
    contentLabel.transform = CGAffineTransformMakeScale(0.5, 0.6);
    [self addSubview:contentLabel];
    
    [UIView animateWithDuration:kToastAnimationTime
                     animations:^{
                         contentLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1 animations:^{
                             contentLabel.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             [self performSelector:@selector(clearContentLabel:) withObject:contentLabel afterDelay:duration];
                         }];
                     }];
    return contentLabel;
}

- (CATransform3D)loadTransform3D:(CGFloat)z {
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0/1000.0;
    CATransform3D transform = CATransform3DMakeTranslation(0.0, 0.0, z);
    return CATransform3DConcat(transform, scale);
}

- (void)clearContentLabel:(UILabel *)label {
    [UIView animateWithDuration:kToastAnimationTime
                     animations:^{
                         label.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished) {
                         [label removeFromSuperview];
                         self.userInteractionEnabled = YES;
                     }];
}




@end

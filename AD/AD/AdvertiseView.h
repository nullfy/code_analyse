//
//  AdvertiseView.h
//  zhibo
//
//  Created by mumuno on 16/5/17.
//  Copyright © 2016年 mumuno. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifndef kScreenWidth
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#endif

#ifndef kScreenHeight
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#endif

#ifndef kUserDefaults
#define kUserDefaults [NSUserDefaults standardUserDefaults]
#endif
static NSString *const adImageName = @"adImageName";
static NSString *const adUrl = @"adUrl";
@interface AdvertiseView : UIView

/** 图片路径*/
@property (nonatomic, copy) NSString *filePath;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;



+ (instancetype)shareAdvertise;
/** 显示广告页面方法*/
- (void)show;

- (void)dismiss;

@end

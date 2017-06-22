//
//  MMImagePickerMacro.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#ifndef MMImagePickerMacro_h
#define MMImagePickerMacro_h

#import "CALayer+ImageLayout.h"
#import "UIImage+imagePicker.h"
#import "NSBundle+ImagePicker.h"

#ifndef kiOS6Later
#define kiOS6Later ([UIDevice currentDevice].systemVersion.floatValue >= 6.0f)
#endif

#ifndef kiOS7Later
#define kiOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#endif

#ifndef kiOS8Later
#define kiOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#endif

#ifndef kiOS9Later
#define kiOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#endif

//屏幕的宽
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
//屏幕的高
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#ifndef Color//(r,g,b,a)
#define Color(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#endif


//#if __has_include(<YYKit/YYKit.h>)
//#import <YYKit/YYKit.h>
//#else 
//#impor "YYKit.h"
//#endif

#endif /* MMImagePickerMacro_h */

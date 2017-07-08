//
//  NSKeyedUnarchiver+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/11/29.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSKeyedUnarchiver (MMAdd)

+ (nullable id)unarchiveObjectWithData:(NSData *)data exception:(NSException *_Nullable  *_Nullable)exception;

+ (nullable id)unarchiveObjectWithFile:(NSString *)path exception:(NSException *_Nullable *_Nullable)exception;

@end
NS_ASSUME_NONNULL_END

//
//  MMRouteResponse.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/10/28.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface MMRouteResponse : NSObject

@property (nonatomic, assign, readonly, getter=isMatch) BOOL match;
@property (nonatomic, strong, readonly, nullable) NSDictionary *parameters;

+ (instancetype)invalidMatchResponse;

+ (instancetype)validMatchResponseWithParameters:(NSDictionary *)parameters;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

@end
NS_ASSUME_NONNULL_END

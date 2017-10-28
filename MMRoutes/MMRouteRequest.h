//
//  MMRouteRequest.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/10/27.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMRouteRequest : NSObject

@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, strong, readonly) NSArray *pathComponnents;
@property (nonatomic, strong, readonly) NSDictionary *queryParams;


- (instancetype)initWithURL:(NSURL *)URL alwaysTreatsHostAsPathComponent:(BOOL)alwaysTreatsHostAsPathComponent NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@end

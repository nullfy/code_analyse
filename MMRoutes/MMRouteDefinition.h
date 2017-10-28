//
//  MMRouteDefinition.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/10/28.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMRouteRequest.h"
#import "MMRouteResponse.h"


@interface MMRouteDefinition : NSObject

@property (nonatomic, copy, readonly) NSString *scheme;
@property (nonatomic, copy, readonly) NSString *pattern;
@property (nonatomic, assign, readonly) NSUInteger priority;
@property (nonatomic, copy, readonly) BOOL (^handlerBlock)(NSDictionary *parameters);

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithScheme:(NSString *)scheme pattern:(NSString *)pattern priority:(NSUInteger)priority handleBlock:(BOOL(^)(NSDictionary *parameters))handler NS_DESIGNATED_INITIALIZER;

- (BOOL)callHandlerBlockWithParameters:(NSDictionary *)parameters;
- (MMRouteResponse *)routeResponseForRequest:(MMRouteRequest *)request decodePlusSymbols:(BOOL)decodedSymbols;
@end

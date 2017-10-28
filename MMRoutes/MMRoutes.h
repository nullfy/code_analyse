//
//  MMRoutes.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/10/28.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class MMParsingUtilities;

extern NSString * const MMRoutePatternKey;
extern NSString * const MMRouteURLKey;
extern NSString * const MMRouteSchemeKey;
extern NSString * const MMRouteWildCardComponentsKey;
extern NSString * const MMRouteGlobalRoutesScheme;

@interface MMRoutes : NSObject

@property (nonatomic, assign) BOOL shouldFallBackToGlobalRoutes;
@property (nonatomic, copy, nullable) void(^unmathcedURLHandle)(MMRoutes *routes, NSURL *__nullable URL, NSDictionary<NSString *, id> * params);

+ (instancetype)globalRoutes;
+ (instancetype)routesForScheme:(NSString *)scheme;

+ (void)unregisterRouteScheme:(NSString *)scheme;
+ (void)unregisterAllRouteSchemes;


- (void)addRoute:();

@end
NS_ASSUME_NONNULL_END

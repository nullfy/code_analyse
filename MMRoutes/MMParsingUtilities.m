//
//  MMParsingUtilities.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/10/27.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMParsingUtilities.h"

@interface NSArray (combinations)

- (NSArray<NSArray *> *)MMRoutes_allOrderedCombinations;

@end

@implementation NSArray (combinations)

- (NSArray<NSArray *> *)MMRoutes_allOrderedCombinations {
    NSInteger length = self.count;
    if (length == 0) return [NSArray arrayWithObject:@[]];
    
    id lastObject = [self lastObject];
    NSArray *subArray = [self subarrayWithRange:NSMakeRange(0, length - 1)];
    NSArray *subArrayCombinations = [subArray MMRoutes_allOrderedCombinations];
    NSMutableArray *combinations = [NSMutableArray arrayWithArray:subArrayCombinations];
    
    for (NSArray *subarrayCombos in subArrayCombinations) {
        [combinations addObject:[subarrayCombos arrayByAddingObject:lastObject]];
    }
    return [NSArray arrayWithArray:combinations];
}


@end


@implementation MMParsingUtilities

+ (NSString *)variableValueFrom:(NSString *)value decodePlusSymbols:(BOOL)decodePlusSymbols {
    if (!decodePlusSymbols) return value;
    return [value stringByReplacingOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, value.length)];
}

+ (NSDictionary *)queryParams:(NSDictionary *)queryParams decodePlussSymbols:(BOOL)decodePlusSymbols {
    if (!decodePlusSymbols) return queryParams;
    
    NSMutableDictionary *updateQueryParams = @{}.mutableCopy;
    for (NSString *name in queryParams) {
        id value = queryParams[name];
        if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *variables = @[].mutableCopy;
            for (NSString *arrayValue in (NSArray *)value) {
                [variables addObject:[self variableValueFrom:arrayValue decodePlusSymbols:YES]];
            }
            updateQueryParams[name] = [variables copy];
        } else if ([value isKindOfClass:[NSString class]]) {
            NSString *variable = [self variableValueFrom:value decodePlusSymbols:YES];
            updateQueryParams[name] = variable;
        } else {
            NSAssert(NO, @"Unexpected query parameter type: %@", NSStringFromClass([value class]));
        }
    }
    return [updateQueryParams copy];;
}

+ (NSArray<NSString *> *)expandOptionalRoutePatternsForPattern:(NSString *)routePattern {
    if ([routePattern rangeOfString:@"("].location == NSNotFound) return @[];
    
    NSString *baseRoute = nil;
    NSArray *componetes = [self _optionalComponentsForPattern:routePattern baseRoute:&baseRoute];
    NSArray *routes = [self _routesForOptionalComponents:componetes baseRoute:baseRoute];
    return routes;
}

+ (NSArray<NSString *> *)_optionalComponentsForPattern:(NSString *)routePattern baseRoute:(NSString **)outBaseRoute {
    if (routePattern.length == 0) return @[];
    
    NSMutableArray *optionalComponents = @[].mutableCopy;
    NSScanner *scanner = [NSScanner scannerWithString:routePattern];
    NSString *nonOptionalRouteSubpath = nil;
    
    BOOL parsedBaseRoute = NO;
    BOOL parseError = NO;
    while ([scanner scanUpToString:@"(" intoString:&nonOptionalRouteSubpath]) {
        if ([scanner isAtEnd]) break;
        
        if (nonOptionalRouteSubpath.length > 0 &&
            outBaseRoute != NULL &&
            !parsedBaseRoute) {
            *outBaseRoute = nonOptionalRouteSubpath;
            parsedBaseRoute = YES;
        }
        
        scanner.scanLocation += 1;
        
        NSString *component = nil;
        if (![scanner scanUpToString:@")" intoString:&component]) {
            parseError = YES;
            break;
        }
        
        [optionalComponents addObject:component];
    }
    
    if (parseError) {
        NSLog(@"[MMRoutes] : Parse Error, unsupported route: %@", routePattern);
        return @[];
    }
    return [optionalComponents copy];
}

+ (NSArray<NSString *> *)_routesForOptionalComponents:(NSArray<NSString *> *)optionalComponets baseRoute:(NSString *)baseRoute {
    if (optionalComponets.count == 0 || baseRoute.length == 0) return @[];
    NSMutableArray *routes = @[].mutableCopy;
    NSArray *combinations = [optionalComponets MMRoutes_allOrderedCombinations];
    for (NSArray *components in combinations) {
        NSString *path = [components componentsJoinedByString:@""];
        [routes addObject:[baseRoute stringByAppendingString:path]];
    }
    [routes sortUsingSelector:@selector(length)];
    return [routes copy];
}


@end

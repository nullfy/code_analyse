//
//  MMRouteDefinition.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/10/28.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMRouteDefinition.h"
#import "MMParsingUtilities.h"
#import "MMRoutes.h"

@interface MMRouteDefinition ()
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *pattern;
@property (nonatomic, assign) NSUInteger priority;
@property (nonatomic, copy) BOOL (^handlerBlock)(NSDictionary *parameters);
@property (nonatomic, strong) NSArray *patternComponents;

@end

@implementation MMRouteDefinition
- (instancetype)initWithScheme:(NSString *)scheme pattern:(NSString *)pattern priority:(NSUInteger)priority handleBlock:(BOOL (^)(NSDictionary *))handler {
    self = [super init];
    if (self) {
        self.scheme = scheme;
        self.pattern = pattern;
        self.priority = priority;
        self.handlerBlock = handler;
        if ([pattern characterAtIndex:0] == '/') pattern = [pattern substringFromIndex:1];
        self.patternComponents = [pattern componentsSeparatedByString:@"/"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> - %@ (priority: %@)", NSStringFromClass(self.class), self, self.pattern, @(self.priority)];
}

- (MMRouteResponse *)routeResponseForRequest:(MMRouteRequest *)request decodePlusSymbols:(BOOL)decodedSymbols {
    BOOL patternContainsWildCard = [self.patternComponents containsObject:@"*"];
    if (request.pathComponnents.count != self.patternComponents.count && !patternContainsWildCard) {
        return [MMRouteResponse invalidMatchResponse];
    }
    
    MMRouteResponse *response = [MMRouteResponse invalidMatchResponse];
    NSMutableDictionary *dic = @{}.mutableCopy;
    BOOL isMatch = YES;
    NSUInteger index = 0;
    
    for (NSString *patternComponent in self.patternComponents) {
        NSString *URLComponent = nil;
        if (index < request.pathComponnents.count) {
            URLComponent = request.pathComponnents[index];
        } else if ([patternComponent isEqualToString:@"*"]) {
            URLComponent = [request.pathComponnents lastObject];
        }
        
        if ([patternComponent hasPrefix:@":"]) {
            NSString *varName = [self varNameForValue:patternComponent];
        }
    }
}

- (NSDictionary *)objectInPatternComponentsAtIndex:(NSUInteger)index {
    return @{};
}


- (BOOL)callHandlerBlockWithParameters:(NSDictionary *)parameters {
    if (self.handlerBlock == nil) return YES;
    return self.handlerBlock(parameters);
}


#pragma mark    Private-Method
- (NSString *)varNameForValue:(NSString *)patternComponent {
    NSString *name = [patternComponent substringFromIndex:1];
    if (name.length > 1 && [name characterAtIndex:0] == ':') {
        name = [name substringFromIndex:1];
    }
    if (name.length > 1 && [name characterAtIndex:name.length - 1] == '#') {
        name = [name substringToIndex:name.length - 1];
    }
    return name;
}

- (NSString *)varNameForValue:(NSString *)value decodedPlusSymbols:(BOOL)decodedPlusSymbol {
    NSString *var = [value stringByRemovingPercentEncoding];
    
    if (var.length > 1 && [var characterAtIndex:var.length - 1] == '#') {
        var = [var substringToIndex:var.length - 1];
    }
    var = [MMParsingUtilities variableValueFrom:var decodePlusSymbols:decodedPlusSymbol];
    return var;
}


@end

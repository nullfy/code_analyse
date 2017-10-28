//
//  MMRouteRequest.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/10/27.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMRouteRequest.h"

@interface MMRouteRequest ()

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSArray *pathComponents;
@property (nonatomic, strong) NSDictionary *queryParams;

@end

@implementation MMRouteRequest

- (instancetype)initWithURL:(NSURL *)URL alwaysTreatsHostAsPathComponent:(BOOL)alwaysTreatsHostAsPathComponent {
    self = [super init];
    if (self) {
        NSURLComponents *components = [NSURLComponents componentsWithString:self.URL.absoluteString];
        if (components.host.length > 0 &&
            (alwaysTreatsHostAsPathComponent || (![components.host isEqualToString:@"localhost"] &&
                                                 [components.host rangeOfString:@"."].location == NSNotFound))) {
            NSString *host = [components.percentEncodedHost copy];
            components.host = @"/";
            components.percentEncodedPath = [host stringByAppendingPathComponent:(components.percentEncodedPath ?: @"")];
        }
        NSLog(@"request component----%@",components);
        NSString *path = [components percentEncodedPath];
        NSLog(@"request path----%@",path);
        if (components.fragment != nil) {
            BOOL fragmentContainsQueryParams = NO;
            NSURLComponents *fragmentComponents = [NSURLComponents componentsWithString:components.percentEncodedFragment];
            
            if (fragmentComponents.query == nil && fragmentComponents.path != nil) {
                fragmentComponents.query = fragmentComponents.path;
            }
            
            if (fragmentComponents.queryItems.count > 0) {
                fragmentContainsQueryParams = fragmentComponents.queryItems.firstObject.value.length > 0;
            }
            
            if (fragmentContainsQueryParams) {
                components.queryItems = [(components.queryItems ?: @[])  arrayByAddingObjectsFromArray:fragmentComponents.queryItems];
            }
            
            if (fragmentComponents.path != nil && (!fragmentContainsQueryParams || ![fragmentComponents.path isEqualToString:fragmentComponents.query])) {
                path = [path stringByAppendingString:[NSString stringWithFormat:@"#%@",fragmentComponents.percentEncodedPath]];
            }
        }
        
        if (path.length > 0 && [path characterAtIndex:0] == '/') {
            path = [path substringFromIndex:1];
        }
        
        if (path.length > 0 && [path characterAtIndex:path.length - 1] == '/') {
            path = [path substringToIndex:path.length - 1];
        }
        
        self.pathComponents = [path componentsSeparatedByString:@"/"];
        
        NSArray<NSURLQueryItem *> *queryItems = [components queryItems] ?: @[];
        NSMutableDictionary *queryParams = @{}.mutableCopy;
        NSLog(@"requst queryItems----%@",queryItems);
        for (NSURLQueryItem *item in queryItems) {
            if (item.value == nil) continue;
            
            if (queryParams[item.name] == nil) {
                queryParams[item.name] = item.value;
            } else if ([queryParams[item.name] isKindOfClass:[NSArray class]]) {
                NSArray *values = (NSArray *)(queryParams[item.name]);
                queryParams[item.name] = [values arrayByAddingObject:item.value];
            } else {
                id existingValue = queryParams[item.name];
                queryParams[item.name] = @[existingValue, item.value];
            }
        }
        self.queryParams = [queryParams copy];
        NSLog(@"requst init pathComponent: %@ params: %@",self.pathComponents, self.queryParams);
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> - URL: %@", NSStringFromClass(self.class), self, self.URL.absoluteString];
}

@end

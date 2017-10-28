//
//  MMRouteResponse.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/10/28.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMRouteResponse.h"

@interface MMRouteResponse ()

@property (nonatomic, assign, getter=isMatch) BOOL match;
@property (nonatomic, strong) NSDictionary *parameters;

@end

@implementation MMRouteResponse

+ (instancetype)invalidMatchResponse {
    MMRouteResponse *response = [[self alloc] init];
    response.match = NO;
    return response;
}

+ (instancetype)validMatchResponseWithParameters:(NSDictionary *)parameters {
    MMRouteResponse *response = [[self class] init];
    response.match = NO;
    response.parameters = parameters;
    return response;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> - match: %@, params: %@", NSStringFromClass(self.class), self, self.match ? @"YES" : @"NO", self.parameters];
}

@end

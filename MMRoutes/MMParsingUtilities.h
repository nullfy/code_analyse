//
//  MMParsingUtilities.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/10/27.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMParsingUtilities : NSObject

+ (NSString *)variableValueFrom:(NSString *)value decodePlusSymbols:(BOOL)decodePlusSymbols;

+ (NSDictionary *)queryParams:(NSDictionary *)queryParams decodePlussSymbols:(BOOL)decodePlusSymbols;

+ (NSArray <NSString *> *)expandOptionalRoutePatternsForPattern:(NSString *)routePattern;

@end

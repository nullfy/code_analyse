//
//  MMLocationManager.h
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMLocationManager : NSObject

+ (instancetype)manager;
- (void)startLocation;
- (void)startLocationSuccess:(void(^)(CLLocation *location, CLLocation *oldLocation))success failure:(void(^)(NSError *error))fail;
- (void)startLocationWithGeocoder:(void(^)(NSArray *geocoderArray))geocoders;
- (void)startLocationSuccess:(void (^)(CLLocation *, CLLocation *))success failure:(void (^)(NSError *))fail geocoder:(void(^)(NSArray *geocoders))geocoders;

@end

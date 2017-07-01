//
//  MMLocationManager.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/20.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMLocationManager.h"
#import "MMImagePickerMacro.h"
#import <CoreText/CoreText.h>

@interface MMLocationManager ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void(^successBlock)(CLLocation *location, CLLocation *oldLocation);
@property (nonatomic, copy) void(^failureBlock)(NSError *error);
@property (nonatomic, copy) void(^geocodersBlock)(NSArray *geocoderArray);

@end
@implementation MMLocationManager

+ (instancetype)manager {
    static MMLocationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.locationManager = [[CLLocationManager alloc] init];
        manager.locationManager.delegate = manager;
        if (kiOS8Later) [manager.locationManager requestWhenInUseAuthorization];
    });
    return manager;
}


- (void)startLocation {
    [self startLocationSuccess:nil failure:nil geocoder:nil];
}

- (void)startLocationSuccess:(void (^)(CLLocation *, CLLocation *))success failure:(void (^)(NSError *))fail {
    [self startLocationSuccess:success failure:fail geocoder:nil];
}

- (void)startLocationWithGeocoder:(void (^)(NSArray *))geocoders {
    [self startLocationSuccess:nil failure:nil geocoder:geocoders];
}

- (void)startLocationSuccess:(void (^)(CLLocation *, CLLocation *))success failure:(void (^)(NSError *))fail geocoder:(void (^)(NSArray *))geocoders {
    [self.locationManager startUpdatingLocation];
    _successBlock = success;
    _geocodersBlock = geocoders;
    _failureBlock = fail;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(nonnull CLLocation *)newLocation fromLocation:(nonnull CLLocation *)oldLocation{
    [manager stopUpdatingLocation];
    if (_successBlock) _successBlock(newLocation, oldLocation);
    if (_geocodersBlock) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            _geocodersBlock(placemarks);
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    switch ([error code]) {
        case kSTClassDeletedGlyph:{
            NSLog(@"禁止定位");
        } break;
        default:
            break;
    }
    if (_failureBlock) _failureBlock(error);
}


@end

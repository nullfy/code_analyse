//
//  NSDate+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/11/29.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
@interface NSDate (MMAdd)
#pragma mark    Property
@property (nonatomic, readonly) NSInteger year;
@property (nonatomic, readonly) NSInteger month;
@property (nonatomic, readonly) NSInteger day;
@property (nonatomic, readonly) NSInteger hour;
@property (nonatomic, readonly) NSInteger minute;
@property (nonatomic, readonly) NSInteger second;
@property (nonatomic, readonly) NSInteger nanosecond;
@property (nonatomic, readonly) NSInteger weekDay;
@property (nonatomic, readonly) NSInteger weekDayOrdinal;
@property (nonatomic, readonly) NSInteger weekOfMonth;
@property (nonatomic, readonly) NSInteger weekOfYear;
@property (nonatomic, readonly) NSInteger quarter;
@property (nonatomic, readonly) BOOL    isLeapMonth;
@property (nonatomic, readonly) BOOL    isLeapYear;
@property (nonatomic, readonly) BOOL    isToday;
@property (nonatomic, readonly) BOOL    isYesterDay;

#pragma mark    Date-modify

- (nullable NSDate *)dateByAddingYears:(NSInteger)years;

- (nullable NSDate *)dateByAddingMonths:(NSInteger)months;

- (nullable NSDate *)dateByAddingWeeks:(NSInteger)weeks;

- (nullable NSDate *)dateByAddingDays:(NSInteger)days;

- (nullable NSDate *)dateByAddingHours:(NSInteger)hours;

- (nullable NSDate *)dateByAddingMinutes:(NSInteger)minutes;

- (nullable NSDate *)dateByAddingSeconds:(NSInteger)seconds;


#pragma mark     Date_Format
- (nullable NSString *)stringWithFormat:(NSString *)format;

- (nullable NSString *)stringWithFormat:(NSString *)format
                               timeZone:(NSTimeZone *)timeZone
                                 locale:(NSLocale *)locale;

- (nullable NSString *)stringWithISOFormat;

+ (nullable NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format;

+ (nullable NSDate *)dateWithString:(NSString *)dateString
                             format:(NSString *)format
                           timeZone:(NSTimeZone *)timeZone
                             locale:(NSLocale *)locale;

+ (nullable NSDate *)dateWithISOFormatString:(NSString *)dateString;
@end
NS_ASSUME_NONNULL_END


//
//  NSObject+MMModel.m
//  PracticeKit
//
//  Created by 晓东 on 16/12/5.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "NSObject+MMModel.h"
#import "MMClassInfo.h"
#import <objc/message.h>

#define force_inline __inline__ __attribute__((always_inline))

typedef NS_ENUM(NSUInteger, MMEncodingNSType) {
    MMEncodingTypeNSUnknow,
    MMEncodingTypeNSString,
    MMEncodingTypeNSMutableString,
    MMEncodingTypeNSValue,
    MMEncodingTypeNSNumber,
    MMEncodingTypeNSDecimalNumber,
    MMEncodingTypeNSData,
    MMEncodingTypeNSMutableData,
    MMEncodingTypeNSDate,
    MMEncodingTypeNSURL,
    MMEncodingTypeNSArray,
    MMEncodingTypeNSMutableArray,
    MMEncodingTypeNSDictionary,
    MMEncodingTypeNSMutableDictionary,
    MMEncodingTYpeNSSet,
    MMEncodingTypeNSMutableSet,
};

static force_inline MMEncodingNSType MMClassGetNSType(Class cls) {
    if (!cls) return MMEncodingTypeNSUnknow;
    if ([cls isSubclassOfClass:[NSMutableString class]])        return MMEncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]])               return MMEncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]])        return MMEncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]])               return MMEncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]])                return MMEncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSData class]])                 return MMEncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSMutableData class]])          return MMEncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSDate class]])                 return MMEncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]])                  return MMEncodingTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]])         return MMEncodingTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]])                return MMEncodingTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]])    return MMEncodingTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]])           return MMEncodingTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]])           return MMEncodingTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]])                  return MMEncodingTYpeNSSet;
    return MMEncodingTypeNSUnknow;
}

static force_inline BOOL MMEncodingTypeIsCNumber(MMEncodingType type) {
    switch (type & MMEncodingTypeMask) {
        case MMEncodingTypeBool:
        case MMEncodingTypeInt8:
        case MMEncodingTypeUInt8:
        case MMEncodingTypeInt16:
        case MMEncodingTypeUInt16:
        case MMEncodingTypeInt32:
        case MMEncodingTypeUInt32:
        case MMEncodingTypeInt64:
        case MMEncodingTypeUInt64:
        case MMEncodingTypeFloat:
        case MMEncodingTypeDouble:
        case MMEncodingTypeLongDouble: return YES;
        default: return NO;
    }
}

static force_inline NSNumber *MMNSNumberCreateFromID(__unsafe_unretained id value) {
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE"     : @(YES),
                @"True"     : @(YES),
                @"true"     : @(YES),
                @"FALSE"    : @(NO),
                @"False"    : @(NO),
                @"YES"      : @(YES),
                @"Yes"      : @(YES),
                @"yes"      : @(YES),
                @"NO"       : @(NO),
                @"No"       : @(NO),
                @"no"       : @(NO),
                @"NIL"      : (id)kCFNull,
                @"Nil"      : (id)kCFNull,
                @"nil"      : (id)kCFNull,
                @"NULL"     : (id)kCFNull,
                @"Null"     : (id)kCFNull,
                @"(NULL)"   : (id)kCFNull,
                @"(Null)"   : (id)kCFNull,
                @"(null)"   : (id)kCFNull,
                @"<NULL>"   : (id)kCFNull,
                @"<Null>"   : (id)kCFNull,
                @"<null>"   : (id)kCFNull,
                };
    });
    
    if (!value || value == (id)kCFNull) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *num = dic[value];
        if (num) {
            if (num == (id)kCFNull) return nil;
            return num;
        }
        
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } else {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }
    return nil;
}

static force_inline NSDate *MMNSDateFromString(__unsafe_unretained NSString *string) {
    typedef NSDate* (^MMNSDateParseBlock)(NSString *string);
#define kParserNum 34
    static MMNSDateParseBlock blocks[kParserNum + 1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter.dateFormat = @"yyyy-MM-dd";
            blocks[10] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
        
        {
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = formatter1.locale;
            formatter2.timeZone = formatter1.timeZone;
            formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
            formatter3.locale = formatter1.locale;
            formatter3.timeZone = formatter1.timeZone;
            formatter3.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss:SSS";
            
            NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
            formatter4.locale = formatter1.locale;
            formatter4.timeZone = formatter1.timeZone;
            formatter4.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSS";
            
            
            blocks[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                } else {
                    return [formatter2 dateFromString:string];
                }
            };
            
            blocks[23] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter3 dateFromString:string];
                } else {
                    return [formatter4 dateFromString:string];
                }
            };
        }
        
        {
            NSDateFormatter *formatter1 = [NSDateFormatter new];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = formatter2.locale;
            formatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            
            blocks[20] = ^(NSString *string) { return [formatter1 dateFromString:string]; };
            blocks[24] = ^(NSString *string) { return [formatter1 dateFromString:string] ?: [formatter2 dateFromString:string]; };
            blocks[25] = ^(NSString *string) { return [formatter1 dateFromString:string]; };
            blocks[28] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
            blocks[29] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
        
        {
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = formatter.locale;
            formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z yyyy";
            
            blocks[30] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[34] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
    });
    
    if (!string) return nil;
    if (string.length > kParserNum) return nil;
    MMNSDateParseBlock parser = blocks[string.length];
    if (!parser) return nil;
    return parser(string);
#undef kParserNum
    
}

static force_inline Class MMNSBlockClass() {
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^block)(void) = ^() {};
        cls = ((NSObject *)block).class;
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    return cls; //获取Block的类型 目前是NSBlock
}

static force_inline NSDateFormatter *MMISODateFormatter() {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return formatter;
}

static force_inline id MMValueForKeyPath(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *keyPaths) {
    id value = nil;
    for (NSUInteger i = 0, max = keyPaths.count; i < max; i++) {
        value = dic[keyPaths[i]];
        if (i + 1 < max) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                dic = value;
            } else {
                return nil;
            }
        }
    }
    return value;
}

static force_inline id MMValueForMultiKeys(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *multiKeys) {
    id value = nil;
    for (NSString *key in multiKeys) {
        if ([key isKindOfClass:[NSString class]]) {
            value = dic[key];
            if (value) break;
        } else {
            value = MMValueForKeyPath(dic, (NSArray *)key);
            if (value) break;
        }
    }
    return value;
}

@interface _MMModelProperMeta : NSObject {
    @package
    NSString *_name;
    MMEncodingType _type;
    MMEncodingNSType _nsType;
    BOOL _isCNumberl;
    Class _cls;
    Class _genericCls;
    SEL _getter;
    SEL _setter;
    BOOL _isKVCCompatible;
    BOOL _isStructAvailableForKeyedArchiver;
    BOOL _hasCustomClassFromDictionary;
    
    NSString *_mappedToKey;
    NSArray *_mappedToKeyPaths;
    NSArray *_mappedToKeyArray;
    MMClassPropertyInfo *_info;
    _MMModelProperMeta *_next;
}

@end

@implementation _MMModelProperMeta

+ (instancetype)metaWithClassInfo:(MMClassInfo *)classInfo propertyInfo:(MMClassPropertyInfo *)propertyInfo generic:(Class)generic {
    if (!generic && propertyInfo.protocols) {
        for (NSString *protocol in propertyInfo.protocols) {
            Class cls = objc_getClass(protocol.UTF8String);
            if (cls) {
                generic = cls;
                break;
            }
        }
    }
    
    _MMModelProperMeta *meta = [self new];
    meta->_name = propertyInfo.name;
    meta->_type = propertyInfo.type;
    meta->_info = propertyInfo;
    meta->_genericCls = generic;
    
    if ((meta->_type & MMEncodingTypeMask) == MMEncodingTypeObject) {
        meta->_nsType = MMClassGetNSType(propertyInfo.cls);
    } else {
        meta->_isCNumberl = MMEncodingTypeIsCNumber(meta->_type);
    }
    if ((meta->_type & MMEncodingTypeMask) == MMEncodingTypeStruct) {
        static NSSet *types = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet *set = [NSMutableSet new];
            
            // 32 bit
            [set addObject:@"{CGSize=ff}"];
            [set addObject:@"{CGPoint=ff}"];
            [set addObject:@"{CGRect={CGPoint=ff}{CGSize=ff}}"];
            [set addObject:@"{CGAffineTransform=ffffff}"];
            [set addObject:@"{UIEdgeInsets=ffff}"];
            [set addObject:@"{UIOffset=ff}"];
            
            // 64 bit
            [set addObject:@"{CGSize=dd"];
            [set addObject:@"{CGPoint=dd}"];
            [set addObject:@"{CGRect={CGPoint=dd}{CGSize=ddd}}"];
            [set addObject:@"{CGAffineTransform=dddddd}"];
            [set addObject:@"{UIEdgeInsets=dddd}"];
            [set addObject:@"{UIOffset=dd}"];
            types = set;
        });
        if ([types containsObject:propertyInfo.typeEncoding]) {
            meta->_isStructAvailableForKeyedArchiver = YES;
        }
    }
    meta->_cls = propertyInfo.cls;
    
    if (generic) {
        meta->_hasCustomClassFromDictionary = [generic respondsToSelector:@selector(modelCustomClassForDictionary:)];
    } else if (meta->_cls && meta->_nsType == MMEncodingTypeNSUnknow) {
        meta->_hasCustomClassFromDictionary = [meta->_cls respondsToSelector:@selector(modelCustomClassForDictionary:)];
    }
    
    if (propertyInfo.getter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.getter]) {
            meta->_getter = propertyInfo.getter;
        }
    }
    
    if (propertyInfo.setter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.setter]) {
            meta->_setter = propertyInfo.setter;
        }
    }
    
    if (meta->_getter && meta->_setter) {
        switch (meta->_type & MMEncodingTypeMask) {
            case MMEncodingTypeBool:
            case MMEncodingTypeInt8:
            case MMEncodingTypeUInt8:
            case MMEncodingTypeInt16:
            case MMEncodingTypeUInt16:
            case MMEncodingTypeInt32:
            case MMEncodingTypeUInt32:
            case MMEncodingTypeInt64:
            case MMEncodingTypeUInt64:
            case MMEncodingTypeFloat:
            case MMEncodingTypeDouble:
            case MMEncodingTypeObject:
            case MMEncodingTypeClass:
            case MMEncodingTypeBlock:
            case MMEncodingTypeStruct:
            case MMEncodingTypeUnion: {
                meta->_isKVCCompatible = YES;
            } break;
            default: break;
        }
    }
    return meta;
}

@end

@interface _MMModelMeta : NSObject {
    /*
     @protected  该类和所有子类中的方法可以直接访问这个变量
     @private   该类中的方法可以访问，子类不可以访问
     @public    可以被所有的类访问
     @package   本包内可以使用，跨包不可以使用
     */
    
    @package
    MMClassInfo *_classInfo;
    NSDictionary *_mapper;
    NSArray *_allPropertyMetas;
    NSArray *_keyPathpropertyMetas;
    NSArray *_multiKeysPropertyMetas;
    NSUInteger _keyMappedCount;
    MMEncodingNSType _nsType;
    
    BOOL _hasCustomWillTransformFromDictionary;
    BOOL _hasCustomTransformFromDictionary;
    BOOL _hasCustomTransformToDictionary;
    BOOL _hasCustomClassFromDictionary;
}

@end

@implementation _MMModelMeta

- (instancetype)initWitClass:(Class)cls {
    MMClassInfo *classInfo = [MMClassInfo classInfoWithClass:cls];
    if (!classInfo) return nil;
    self = [super init];
    
    NSSet *blacklist = nil;
    if ([cls respondsToSelector:@selector(modelPropertyBlacklist)]) {
        NSArray *properties = [(id<MMModel>)cls modelPropertyBlacklist];
        if (properties) {
            blacklist = [NSSet setWithArray:properties];
        }
    }
    
    NSSet *whitelist = nil;
    if ([cls respondsToSelector:@selector(modelPropertyWhitelist)]) {
        NSArray *properties = [(id<MMModel>)cls modelPropertyWhitelist];
        if (properties) {
            whitelist = [NSSet setWithArray:properties];
        }
    }
    
    NSDictionary *genericMapper = nil;
    if ([cls respondsToSelector:@selector(modelContainerPropertyGenericClass)]) {
        genericMapper = [(id<MMModel>)cls modelContainerPropertyGenericClass];
        if (genericMapper) {
            NSMutableDictionary *tmp = [NSMutableDictionary new];
            [genericMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (![key isKindOfClass:[NSString class]]) return ;
                Class meta = object_getClass(obj);
                if (!meta) return;
                if (class_isMetaClass(meta)) {
                    tmp[key] = obj;
                } else if ([obj isKindOfClass:[NSString class]]) {
                    Class cls = NSClassFromString(obj);
                    if (cls) tmp[key] = cls;
                }
            }];
            genericMapper = tmp;
        }
    }
    
    NSMutableDictionary *allPropertyMetas = [NSMutableDictionary new];
    MMClassInfo *curClassInfo = classInfo;
    while (curClassInfo && curClassInfo.superCls != nil) {
        for (MMClassPropertyInfo *propertyInfo in curClassInfo.propertyInfos.allValues) {
            if (!propertyInfo.name) continue;
            if (blacklist && [blacklist containsObject:propertyInfo.name]) continue;
            if (whitelist && [whitelist containsObject:propertyInfo.name]) continue;
            _MMModelProperMeta *meta = [_MMModelProperMeta metaWithClassInfo:classInfo
                                                                propertyInfo:propertyInfo
                                                                     generic:genericMapper[propertyInfo.name]];
            if (!meta || !meta->_name) continue;
            if (!meta->_getter || !meta->_setter) continue;
            if (allPropertyMetas[meta->_name]) continue;
            allPropertyMetas[meta->_name] = meta;
        }
        curClassInfo = curClassInfo.superClassInfo;
    }
    if (allPropertyMetas.count) _allPropertyMetas = allPropertyMetas.allValues.copy;
    
    NSMutableDictionary *mapper = [NSMutableDictionary new];
    NSMutableArray *keyPathPropertyMetas = [NSMutableArray new];
    NSMutableArray *multiKeysPropertyMetas = [NSMutableArray new];
    
    if ([cls respondsToSelector:@selector(modelCustomPropertyMapper)]) {
        NSDictionary *customMapper = [(id<YYModel>)cls modelCustomPropertyMapper];
        [customMapper enumerateKeysAndObjectsUsingBlock:^(NSString  *propertyName, NSString  *mappedTokey, BOOL * _Nonnull stop) {
            _MMModelProperMeta *propertyMeta = allPropertyMetas[propertyName];
            if (!propertyMeta) return ;
            [allPropertyMetas removeObjectForKey:propertyName];
            
            if ([mappedTokey isKindOfClass:[NSString class]]) {
                if (mappedTokey.length == 0) return;
                
                propertyMeta->_mappedToKey = mappedTokey;
                NSArray *keyPaths = [mappedTokey componentsSeparatedByString:@"."];
                for (NSString *onePath in keyPaths) {
                    if (onePath.length == 0) {
                        NSMutableArray *tmp = keyPaths.mutableCopy;
                        [tmp removeObject:@""];
                        keyPaths = tmp;
                        break;
                    }
                }
                if (keyPaths.count > 1) {
                    propertyMeta->_mappedToKeyPaths = keyPaths;
                    [keyPathPropertyMetas addObject:propertyMeta];
                }
                
                propertyMeta->_next = mapper[mappedTokey] ?: nil;
                mapper[mappedTokey] = propertyMeta;
            } else if ([mappedTokey isKindOfClass:[NSArray class]]) {
                NSMutableArray *mappedToKeyArray = [NSMutableArray new];
                for (NSString *oneKey in ((NSArray *)mappedTokey)) {
                    if (![oneKey isKindOfClass:[NSString class]]) continue;
                    if (oneKey.length == 0) continue;
                    
                    NSArray *keyPath = [oneKey componentsSeparatedByString:@"."];
                    if (keyPath.count > 1) {
                        [mappedToKeyArray addObject:keyPath];
                    } else {
                        [mappedToKeyArray addObject:oneKey];
                    }
                    if (!propertyMeta->_mappedToKey) {
                        propertyMeta->_mappedToKey = oneKey;
                        propertyMeta->_mappedToKeyPaths = keyPath.count > 1 ? keyPath : nil;
                    }
                }
                if (!propertyMeta->_mappedToKey) return;
                
                propertyMeta->_mappedToKeyArray = mappedToKeyArray;
                [multiKeysPropertyMetas addObject:propertyMeta];
                
                propertyMeta->_next = mapper[mappedTokey] ?: nil;
                mapper[mappedTokey] = propertyMeta;
            }
        }];
    }
    
    [allPropertyMetas enumerateKeysAndObjectsUsingBlock:^(NSString  * name, _MMModelProperMeta  * propertyMeta, BOOL * _Nonnull stop) {
        propertyMeta->_mappedToKey = name;
        propertyMeta->_next = mapper[name] ?: nil;
        mapper[name] = propertyMeta;
    }];
    
    if (mapper.count) _mapper = mapper;
    if (keyPathPropertyMetas) _keyPathpropertyMetas = keyPathPropertyMetas;
    if (multiKeysPropertyMetas) _multiKeysPropertyMetas = multiKeysPropertyMetas;
    
    _classInfo = classInfo;
    _keyMappedCount = _allPropertyMetas.count;
    _nsType = MMClassGetNSType(cls);
    _hasCustomWillTransformFromDictionary = ([cls instancesRespondToSelector:@selector(modelCustomWillTransformFromDictionary:)]);
    _hasCustomTransformFromDictionary = ([cls instancesRespondToSelector:@selector(modelCustomTransformFromDictionary:)]);
    _hasCustomTransformToDictionary = ([cls instancesRespondToSelector:@selector(modelCustomTransformToDictionary:)]);
    _hasCustomClassFromDictionary = ([cls respondsToSelector:@selector(modelCustomClassForDictionary:)]);
    
    return self;
}

+ (instancetype)metaWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef cache;
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    _MMModelMeta *meta = CFDictionaryGetValue(cache, (__bridge const void *)cls);
    dispatch_semaphore_signal(lock);
    if (!meta || meta->_classInfo.needUpdate) {
        meta = [[_MMModelMeta alloc] initWitClass:cls];
        if (meta) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(cache, (__bridge const void *)cls, (__bridge const void *)meta);
            dispatch_semaphore_signal(lock);
        }
    }
    return meta;
}

@end


static force_inline NSNumber *MMModelCreateNumberFromProperty(__unsafe_unretained id model,__unsafe_unretained _MMModelProperMeta *meta) {
    switch (meta->_type & MMEncodingTypeMask) {
        case MMEncodingTypeBool:
            return @(((bool (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        case MMEncodingTypeInt8:{
            return @(((int8_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case MMEncodingTypeUInt8: {
            return @(((uint8_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case MMEncodingTypeInt16: {
            return @(((int16_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case MMEncodingTypeUInt16: {
            return @(((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case MMEncodingTypeInt32: {
            return @(((int32_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case MMEncodingTypeUInt32: {
            return @(((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case MMEncodingTypeInt64: {
            return @(((int64_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case MMEncodingTypeUInt64: {
            return @(((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case MMEncodingTypeFloat:{
            float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case MMEncodingTypeDouble: {
            double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num || isinf(num))) return nil;
            return @(num);
        }
        case MMEncodingTypeLongDouble: {
            double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        default:    return nil;
    }
}

static force_inline void MMModelSetNumberToProperty(__unsafe_unretained id model,
                                                    __unsafe_unretained NSNumber *num,
                                                    __unsafe_unretained _MMModelProperMeta *meta) {
    switch (meta->_type & MMEncodingTypeMask) {
        case MMEncodingTypeBool: {
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)model, meta->_setter, num.boolValue);
        } break;
        case MMEncodingTypeInt8: {
            ((void (*)(id, SEL, int8_t))(void *) objc_msgSend)((id)model, meta->_setter, (int8_t)num.charValue);
        } break;
        case MMEncodingTypeUInt8: {
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint8_t)num.unsignedCharValue);
        } break;
        case MMEncodingTypeInt16: {
            ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)model, meta->_setter, (int16_t)num.shortValue);
        } break;
        case MMEncodingTypeUInt16: {
            ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint16_t)num.unsignedShortValue);
        } break;
        case MMEncodingTypeInt32: {
            ( (void (*)(id, SEL, int32_t)) (void *) objc_msgSend)( (id)model, meta->_setter, (int32_t)num.intValue );
        } break;
        case MMEncodingTypeUInt32: {
            ( (void (*)(id, SEL, uint32_t)) (void *) objc_msgSend)( (id)model, meta->_setter, (uint32_t)num.intValue);
        } break;
        case MMEncodingTypeInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ( (void (*)(id, SEL, int64_t)) (void *) objc_msgSend)( (id)model, meta->_setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ( (void (*)(id, SEL, uint64_t)) (void *)objc_msgSend)( (id)model, meta->_setter, (uint64_t)num.longLongValue);
            }
        } break;
        case MMEncodingTypeUInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ( (void (*)(id, SEL, int64_t))(void *) objc_msgSend)( (id)model, meta->_setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ( (void (*)(id, SEL, uint64_t))(void *) objc_msgSend)( (id)model, meta->_setter, (uint64_t)num.unsignedLongLongValue);
            }
        } break;
        case MMEncodingTypeFloat: {
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            ( (void (*)(id, SEL, float))(void *) objc_msgSend)( (id)model, meta->_setter, f);
        } break;
        case MMEncodingTypeDouble: {
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ( (void (*)(id, SEL, double))(void *) objc_msgSend)( (id)model, meta->_setter, d);
        } break;
        case MMEncodingTypeLongDouble: {
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ( (void (*)(id, SEL, long double))(void *) objc_msgSend)( (id)model, meta->_setter, (long double)d);
        } break;
        default: break;
    }
}

static void MMModeSetValueForProperty(__unsafe_unretained id model,
                                      __unsafe_unretained id value,
                                      __unsafe_unretained _MMModelProperMeta *meta) {
    if (meta->_isCNumberl) {
        NSNumber *num = MMNSNumberCreateFromID(value);
        MMModelSetNumberToProperty(model, num, meta);
        if (num) [num class];
    } else if (meta->_nsType) {
        if (value == (id)kCFNull) {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)nil);
        } else {
            switch (meta->_nsType) {
                case MMEncodingTypeNSString:
                case MMEncodingTypeNSMutableString: {
                    if ([value isKindOfClass:[NSString class]]) {
                        if (meta->_nsType == MMEncodingTypeNSString) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        } else {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, ((NSString *)value).mutableCopy);
                        }
                    } else if ([value isKindOfClass:[NSNumber class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter,
                                                                       (meta->_nsType == MMEncodingTypeNSString) ? ((NSNumber *)value).stringValue : ((NSNumber *)value).stringValue.mutableCopy);
                    } else if ([value isKindOfClass:[NSData class]]) {
                        NSMutableString *string = [[NSMutableString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                        /*
                         objc_msgSend(model, meta->_setter, string)
                         (void *)objc_msgSend(model, meta->_setter, string)
                         ((void (*)(id, SEL, id))(void *) objc_msgSend(model, metal->_setter, string)
                         */
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id) model, meta->_setter, string);
                    } else if ([value isKindOfClass:[NSURL class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       (meta->_nsType == MMEncodingTypeNSString) ?
                                                                       ((NSURL *)value).absoluteString :
                                                                       ((NSURL *)value).absoluteString.mutableCopy);
                    } else if ([value isKindOfClass:[NSAttributedString class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       (meta->_nsType == MMEncodingTypeNSString) ?
                                                                       ((NSAttributedString *)value).string :
                                                                       ((NSAttributedString *)value).string.mutableCopy);
                    }
                } break;
                    
                case MMEncodingTypeNSValue:
                case MMEncodingTypeNSNumber:
                case MMEncodingTypeNSDecimalNumber: {
                    if (meta->_nsType == MMEncodingTypeNSNumber) {
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, MMNSNumberCreateFromID(value));
                    } else if ([value isKindOfClass:[NSDecimalNumber class]]) {
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, value);
                    } else if ([value isKindOfClass:[NSNumber class]]) {
                        NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[((NSNumber *)value) decimalValue]];
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, decNum);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithString:value];
                        NSDecimal dec = decNum.decimalValue;
                        if (dec._length == 0 && dec._isNegative) {
                            decNum = nil;   //NaN
                        }
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, decNum);
                    } else {
                        if ([value isKindOfClass:[NSValue class]]) {
                            ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter,value);
                        }
                    }
                } break;
                    
                case MMEncodingTypeNSDate: {
                    if ([value isKindOfClass:[NSDate class]]) {
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter,value);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter,MMNSDateFromString(value));
                    }
                } break;
                    
                case MMEncodingTypeNSURL: {
                    if ([value isKindOfClass:[NSURL class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                        NSString *str = [value stringByTrimmingCharactersInSet:set];
                        if (str.length == 0) {
                            ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, nil);
                        } else {
                            ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter,[[NSURL alloc]initWithString:str]);
                        }
                    }
                } break;
                    
                    case MMEncodingTypeNSArray:
                case MMEncodingTypeNSMutableArray: {
                    if (meta->_genericCls) {
                        NSArray *valueArr = nil;
                        if ([value isKindOfClass:[NSArray class]]) valueArr = value;
                        else if ([value isKindOfClass:[NSSet class]]) valueArr = ((NSSet *)value).allObjects;
                        if (valueArr) {
                            NSMutableArray *objectArr = [NSMutableArray new];
                            for (id one in valueArr) {
                                if ([one isKindOfClass:meta->_genericCls]) {
                                    [objectArr addObject:one];
                                } else if ([one isKindOfClass:[NSDictionary class]]) {
                                    Class cls = meta->_genericCls;
                                    if (meta->_hasCustomClassFromDictionary) {
                                        cls = [cls modelCustomClassForDictionary:one];
                                        if (!cls) cls = meta->_genericCls;
                                    }
                                    NSObject *newOne = [cls new];
                                    [newOne modelSetWithDictionary:one];
                                    if (newOne) [objectArr addObject:newOne];
                                }
                            }
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, objectArr);
                        }
                        
                    } else {
                        if ([value isKindOfClass:[NSArray class]]) {
                            if (meta->_nsType == MMEncodingTypeNSArray) {
                                ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, value);
                            } else {
                                ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, ((NSArray *)value).mutableCopy);
                            }
                        } else if ([value isKindOfClass:[NSSet class]]) {
                            if (meta->_nsType == MMEncodingTypeNSArray) {
                                ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter,((NSSet *)value).allObjects);
                            } else {
                                ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, ((NSSet *)value).mutableCopy);
                            }
                        }
                    }
                } break;
                    
                    case MMEncodingTypeNSDictionary:
                case MMEncodingTypeNSMutableDictionary: {
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        if (meta->_genericCls) {
                            NSMutableDictionary *dic = [NSMutableDictionary new];
                            [((NSDictionary *)value) enumerateKeysAndObjectsUsingBlock:^(NSString *oneKey, id oneValue, BOOL * _Nonnull stop) {
                                if ([oneValue isKindOfClass:[NSDictionary class]]) {
                                    Class cls = meta->_genericCls;
                                    if (meta->_hasCustomClassFromDictionary) {
                                        cls = [cls modelCustomClassForDictionary:oneValue];
                                        if (!cls) cls = meta->_genericCls;
                                    }
                                    NSObject *newOne = [cls new];
                                    [newOne modelSetWithDictionary:(id)oneValue];
                                    if (newOne) dic[oneKey] = newOne;
                                }
                            }];
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter,dic);
                        } else {
                            if (meta->_nsType == MMEncodingTypeNSDictionary) {
                                ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, value);
                            } else {
                                ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, ((NSDictionary *)value).mutableCopy);
                            }
                        }
                    }
                } break;
                    
                    case MMEncodingTYpeNSSet:
                case MMEncodingTypeNSMutableSet: {
                    NSSet *valueSet = nil;
                    if ([value isKindOfClass:[NSArray class]]) {
                        valueSet = [[NSMutableSet setWithArray:value] copy];
                    } else if ([value isKindOfClass:[NSSet class]]) {
                        valueSet = (NSSet *)value;
                    }
                    if (meta->_genericCls) {
                        NSMutableSet *set = [NSMutableSet new];
                        for (id one in valueSet) {
                            if ([one isKindOfClass:meta->_genericCls]) {
                                [set addObject:one];
                            } else if ([one isKindOfClass:[NSDictionary class]]) {
                                Class cls = meta->_genericCls;
                                if (meta->_hasCustomClassFromDictionary) {
                                    cls = [cls modelCustomClassForDictionary:one];
                                    if (!cls) cls = meta->_genericCls;
                                }
                                NSObject *newOne = [cls new];
                                [newOne modelSetWithDictionary:one];
                                if (newOne) [set addObject:newOne];
                            }
                        }
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, set);
                    } else {
                        if (meta->_nsType == MMEncodingTYpeNSSet) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, valueSet);
                        } else {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter,((NSSet *)valueSet).mutableCopy);
                        }
                    }
                }
                default:  break;
            }
        }
    } else {
        BOOL isNull = (value == (id)kCFNull);
        switch (meta->_type & MMEncodingTypeMask) {
            case MMEncodingTypeObject:{
                if (isNull) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)nil);
                } else if ([value isKindOfClass:meta->_cls] || !meta->_cls) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter,(id)value);
                } else if ([value isKindOfClass:[NSDictionary class]]) {
                    NSObject *one = nil;
                    if (meta->_getter) {
                        one = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
                    }
                    if (one) {
                        [one modelSetWithDictionary:value];
                    } else {
                        Class cls = meta->_cls;
                        if (meta->_hasCustomClassFromDictionary) {
                            cls = [cls modelCustomClassForDictionary:value];
                            if (!cls) cls = meta->_genericCls;
                        }
                        one = [cls new];
                        [one modelSetWithDictionary:value];
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, (id)one);
                    }
                }
            }   break;
             
            case MMEncodingTypeClass: {
                if (isNull) {
                    ((void (*)(id, SEL, Class))(void *)objc_msgSend)((id)model, meta->_setter,(Class)NULL);
                } else {
                    Class cls = nil;
                    if ([value isKindOfClass:[NSString class]]) {
                        cls = NSClassFromString(value);
                        if (cls) {
                            ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter,(Class)cls);
                        }
                    } else {
                        cls = object_getClass(value);
                        if (cls) {
                            if (class_isMetaClass(cls)) {
                                ((void (*)(id, SEL, Class))(void *)objc_msgSend)((id)model, meta->_setter, (Class)value);
                            }
                        }
                    }
                }
            } break;
            case MMEncodingTypeSEL: {
                if (isNull) {
                    ((void (*)(id, SEL, SEL))(void *)objc_msgSend)((id)model, meta->_setter, (SEL)NULL);
                } else {
                    SEL sel = NSSelectorFromString(value);
                    if (sel) ((void (*)(id, SEL, SEL))(void *)objc_msgSend)((id)model, meta->_setter,(SEL)sel);
                }
            } break;
                
            case MMEncodingTypeBlock: {
                if (isNull) {
                    ((void (*)(id, SEL, void(^)()))(void *) objc_msgSend)((id)model, meta->_setter, (void (^)())NULL);
                } else if ([value isKindOfClass:MMNSBlockClass()]) {
                    ((void (*)(id, SEL, void (^)()))(void *) objc_msgSend)((id)model, meta->_setter, (void (^)())value);
                }
            } break;
                
                case MMEncodingTypeStruct:
                case MMEncodingTypeUnion:
            case MMEncodingTypeCArray: {
                if ([value isKindOfClass:[NSValue class]]) {
                    const char *valueType = ((NSValue *)value).objCType;
                    const char *metaType = meta->_info.typeEncoding.UTF8String;
                    if (value && metaType && strcmp(valueType, metaType) == 0) {
                        [model setValue:value forKey:meta->_name];
                    }
                }
            } break;
                
                case MMEncodingTypePointer:
            case MMEncodingTypeCString: {
                if (isNull) {
                    ((void (*)(id, SEL, void *))(void *) objc_msgSend)((id)model, meta->_setter, (void *)NULL);
                } else if ([value isKindOfClass:[NSValue class]]) {
                    NSValue *nsValue = value;
                    if (nsValue.objCType && strcmp(nsValue.objCType, "^v") == 0) {
                        ((void (*)(id, SEL, void *))(void *)objc_msgSend)((id)model, meta->_setter, nsValue.pointerValue);
                    }
                }
            } //break : commented for code coverage in next time    与下一行运行合并
            default: break;
        }
    }
}

typedef struct {
    void *modelMeta;    //MMModel meta
    void *model;        //id self
    void *dicitonary;   // NSDictionary(json)
}ModelSetContext;

static void ModelSetWithDictionaryFunction(const void *_key, const void *_value, void *_context) {
    ModelSetContext *context = _context;
    __unsafe_unretained _MMModelMeta *meta = (__bridge _MMModelMeta *)(context->modelMeta);
    __unsafe_unretained _MMModelProperMeta *propertyMeta = [meta->_mapper objectForKey:(__bridge id)(_key)];
    __unsafe_unretained id model = (__bridge id)(context->model);
    while (propertyMeta) {
        if (propertyMeta -> _setter) {
            MMModeSetValueForProperty(model, (__bridge  __unsafe_unretained id)_value, propertyMeta);
        }
        propertyMeta = propertyMeta->_next;
    }
}

static void ModelSetWithPropertyMetaArrayFunction(const void *_propertyMeta, void *_context) {
    ModelSetContext *context = _context;
    __unsafe_unretained NSDictionary *dictionary = (__bridge NSDictionary *)(context->dicitonary);
    __unsafe_unretained _MMModelProperMeta *propertyMeta = (__bridge _MMModelProperMeta *)(_propertyMeta);
    if (!propertyMeta->_setter) return;
    id value = nil;
    
    if (propertyMeta->_mappedToKeyArray) {
        value = MMValueForMultiKeys(dictionary, propertyMeta->_mappedToKeyArray);
    } else if (propertyMeta->_mappedToKeyPaths) {
        value = MMValueForKeyPath(dictionary, propertyMeta->_mappedToKeyPaths);
    } else {
        value = [dictionary objectForKey:propertyMeta->_mappedToKey];
    }
    
    if (value) {
        __unsafe_unretained id model = (__bridge id)(context->model);
        MMModeSetValueForProperty(model, value, propertyMeta);
    }
}

static id ModelToJSONObjectRecursive(NSObject *model) { //预先将json转model
    if (!model || model == (id)kCFNull) return model;
    if ([model isKindOfClass:[NSString class]]) return model;
    if ([model isKindOfClass:[NSNumber class]]) return model;
    if ([model isKindOfClass:[NSDictionary class]]) {
        if ([NSJSONSerialization isValidJSONObject:model]) return model;
        NSMutableDictionary *newDic = [NSMutableDictionary new];
        [((NSDictionary *)model) enumerateKeysAndObjectsUsingBlock:^(NSString  *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *stringKey = [key isKindOfClass:[NSString class]] ? key : key.description;
            if (!stringKey) return ;
            id jsonObj = ModelToJSONObjectRecursive(obj);
            if (!jsonObj) jsonObj = (id)kCFNull;
            newDic[stringKey] = jsonObj;
        }];
        return newDic;
    }
    
    if ([model isKindOfClass:[NSSet class]]) {
        NSArray *array = ((NSSet *)model).allObjects;
        if ([NSJSONSerialization isValidJSONObject:array]) return array;
        NSMutableArray *newArray = [NSMutableArray new];
        for (id obj in array) {
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [newArray addObject:obj];
            } else {
                id jsonObj = ModelToJSONObjectRecursive(obj);
                if (jsonObj && jsonObj != (id)kCFNull) [newArray addObject:jsonObj];
            }
        }
        return newArray;
    }
    
    if ([model isKindOfClass:[NSArray class]]) {
        if ([NSJSONSerialization isValidJSONObject:model]) return model;
        NSMutableArray *newArray = [NSMutableArray new];
        for (id obj in (NSArray *)model) {
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [newArray addObject:obj];
            } else {
                id jsonObj = ModelToJSONObjectRecursive(obj);
                if (jsonObj && jsonObj != (id)kCFNull) [newArray addObject:jsonObj];
            }
        }
        return newArray;
    }
    
    if ([model isKindOfClass:[NSURL class]]) return ((NSURL *)model).absoluteString;
    if ([model isKindOfClass:[NSAttributedString class]]) return ((NSAttributedString *)model).string;
    if ([model isKindOfClass:[NSDate class]]) return [MMISODateFormatter() stringFromDate:(id)model];
    if ([model isKindOfClass:[NSData class]]) return nil;
    
    _MMModelMeta *modelMeta = [_MMModelMeta metaWithClass:[model class]];
    if (!modelMeta || modelMeta->_keyMappedCount == 0) return nil;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:64];
    __unsafe_unretained NSMutableDictionary *dic = result;
    [modelMeta->_mapper enumerateKeysAndObjectsUsingBlock:^(NSString *propertyMappedKey, _MMModelProperMeta *propertyMeta, BOOL * _Nonnull stop) {
        if (!propertyMeta->_getter) return ;
        id value = nil;
        if (propertyMeta->_isCNumberl) {
            value = MMModelCreateNumberFromProperty(model, propertyMeta);
        } else if (propertyMeta->_nsType) {
            id v = ((id (*)(id, SEL))(void *)objc_msgSend)((id)model, propertyMeta->_getter);
            value = ModelToJSONObjectRecursive(v);
        } else {
            switch (propertyMeta->_type & MMEncodingTypeMask) {
                case MMEncodingTypeObject:{
                    id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
                    value = ModelToJSONObjectRecursive(v);
                    if (value == (id)kCFNull) value = nil;
                }   break;
                case MMEncodingTypeClass: {
                    Class v = ((Class (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
                    value = v ? NSStringFromClass(v) : nil;
                } break;
                case MMEncodingTypeSEL: {
                    SEL v = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
                    value = v ? NSStringFromSelector(v) : nil;
                } break;
                default:
                    break;
            }
        }
        
        if (!value) return;
        
        if (propertyMeta->_mappedToKeyPaths) {
            NSMutableDictionary *superDic = dic;
            NSMutableDictionary *subDic = nil;
            for (NSUInteger i = 0 , max = propertyMeta->_mappedToKeyPaths.count; i < max; i++) {
                NSString *key = propertyMeta->_mappedToKeyPaths[i];
                if (i + 1 == max) {
                    if (!superDic[key]) superDic[key] = value;
                    break;
                }
                
                subDic = superDic[key];
                if (subDic) {
                    if ([subDic isKindOfClass:[NSDictionary class]]) {
                        subDic = subDic.mutableCopy;
                        superDic[key] = subDic;
                    } else {
                        break;
                    }
                } else {
                    subDic = [NSMutableDictionary new];
                    superDic[key] = subDic;
                }
                superDic = subDic;
                subDic = nil;
            }
        } else {
            if (!dic[propertyMeta->_mappedToKey]) {
                dic[propertyMeta->_mappedToKey] = value;
            }
        }
    }];
    
    if (modelMeta->_hasCustomTransformToDictionary) {
        BOOL suc = [((id<YYModel>) model) modelCustomTransformToDictionary:dic];
        if (!suc) return nil;
    }
    return result;
}

static NSMutableString *ModelDescriptionAddIndent(NSMutableString *desc, NSUInteger indent) {
    for (NSUInteger i = 0, max = desc.length; i < max; i++) {
        unichar c = [desc characterAtIndex:i];//字符串 变字符
        if (c == '\n') {
            for (NSInteger j = 0; j < indent; j++) {
                [desc insertString:@"    " atIndex:i + 1];
            }
            i += indent * 4;
            max += indent * 4;
        }
    }
    return desc;
}

static NSString *ModelDescription(NSObject *model) {
    static const int kDescMaxLength = 100;
    if (!model) return @"<nil>";
    if (model == (id)kCFNull) return @"<null>";
    if (![model isKindOfClass:[NSObject class]]) return [NSString stringWithFormat:@"%@",model];
    
    _MMModelMeta *modelMeta = [_MMModelMeta metaWithClass:model.class];
    switch (modelMeta->_nsType) {
        case MMEncodingTypeNSString:
        case MMEncodingTypeNSMutableString: {
            return [NSString stringWithFormat:@"\"%@\"",model];
        }
            case MMEncodingTypeNSValue:
            case MMEncodingTypeNSData:
        case MMEncodingTypeNSMutableData:{
            NSString *tmp = model.description;
            if (tmp.length > kDescMaxLength) {
                tmp = [tmp substringFromIndex:kDescMaxLength];
                tmp = [tmp stringByAppendingString:@"..."];
            }
            return tmp;
        }
            case MMEncodingTypeNSNumber:
            case MMEncodingTypeNSDecimalNumber:
            case MMEncodingTypeNSDate:
        case MMEncodingTypeNSURL: {
            return [NSString stringWithFormat:@"%@",model];
        }
            case MMEncodingTYpeNSSet:
        case MMEncodingTypeNSMutableSet: {
            model = ((NSSet *)model).allObjects;
        }
        case MMEncodingTypeNSArray:
        case MMEncodingTypeNSMutableArray: {
            NSArray *array = (id)model;
            NSMutableString *des = [NSMutableString new];
            if (array.count == 0) {
                return [des stringByAppendingString:@"[]"];
            } else {
                [des appendFormat:@"[\n"];
                for (NSUInteger i = 0, max = array.count; i < max; i++) {
                    NSObject *obj = array[i];
                    [des appendString:@"    "];
                    [des appendString:ModelDescriptionAddIndent(ModelDescription(obj).mutableCopy, 1)];
                    [des appendString:(i + 1 == max) ? @"\n" : @";\n"];
                }
                [des appendString:@"]"];
                return des;
            }
        }
            case MMEncodingTypeNSDictionary:
        case MMEncodingTypeNSMutableDictionary: {
            NSDictionary *dic = (id)model;
            NSMutableString *des = [NSMutableString new];
            if (dic.count == 0) {
                return [des stringByAppendingString:@"{}"];
            } else {
                NSArray *keys = dic.allKeys;
                
                [des appendFormat:@"{\n"];
                for (NSUInteger i = 0, max = keys.count; i < max; i++) {
                    NSString *key = keys[i];
                    NSObject *value = dic[key];
                    [des appendString:@"    "];
                    [des appendFormat:@"%@ = %@", key,ModelDescriptionAddIndent(ModelDescription(value).mutableCopy, 1)];
                    [des appendString:(i + 1 == max) ? @"\n" : @";\n"];
                }
                [des appendString:@"}"];
            }
            return des;
        }
            
        default: {
            NSMutableString *des = [NSMutableString new];
            [des appendFormat:@"<%@: %p>",model.class, model];
            if (modelMeta->_allPropertyMetas.count == 0) return des;
            
            NSArray *properties = [modelMeta->_allPropertyMetas sortedArrayUsingComparator:^NSComparisonResult(_MMModelProperMeta *p1, _MMModelProperMeta *p2) {
                return [p1->_name compare:p2->_name];
            }];
            [des appendFormat:@" {\n"];
            for (NSUInteger i = 0, max = properties.count; i < max; i++) {
                _MMModelProperMeta *property = properties[i];
                NSString *propertyDesc;
                if (property->_isCNumberl) {
                    NSNumber *num = MMModelCreateNumberFromProperty(model, property);
                    propertyDesc = num.stringValue;
                } else {
                    switch (property->_type & MMEncodingTypeMask) {
                        case MMEncodingTypeObject: {
                            id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = ModelDescription(v);
                            if (!propertyDesc) propertyDesc = @"<nil>";
                        }   break;
                        case MMEncodingTypeClass: {
                            id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = ((NSObject *)v).description;
                            if (!propertyDesc) propertyDesc = @"<nil>";
                        } break;
                        case MMEncodingTypeSEL: {
                            SEL sel = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            if (sel) propertyDesc = NSStringFromSelector(sel);
                            else propertyDesc = @"<NULL>";
                        } break;
                        case MMEncodingTypeBlock: {
                            id block = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = block ? ((NSObject *)block).description : @"<nil>";
                        } break;
                        case MMEncodingTypeCArray: {
                            void *pointer = ((void* (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = [NSString stringWithFormat:@"%p",pointer];
                        } break;
                        case MMEncodingTypeStruct: {
                            NSValue *value = [model valueForKey:property->_name];
                            propertyDesc = value ? value.description : @"{unknown}";
                        } break;
                        default:
                            propertyDesc = @"<unknown>";
                    }
                }
                propertyDesc = ModelDescriptionAddIndent(propertyDesc.mutableCopy, 1);
                [des appendFormat:@"    %@ = %@",property->_name, propertyDesc];
                [des appendString:(1 + 1 == max) ? @"\n" : @";\n"];
            }
            
            [des appendFormat:@"}"];
            return des;
        }
    }
}

@implementation NSObject (MMModel)

+ (NSDictionary *)_mm_dictionaryWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}

+ (instancetype)modelWithJSON:(id)json {
    NSDictionary *dic = [self _mm_dictionaryWithJSON:json];
    return [self modelWithDictionary:dic];
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    
    Class cls = [self class];
    _MMModelMeta *modelMeta = [_MMModelMeta metaWithClass:cls];
    if (modelMeta->_hasCustomClassFromDictionary) {
        cls = [cls modelCustomClassForDictionary:dictionary] ?: cls;
    }
    NSObject *one = [cls new];
    if ([one modelSetWithDictionary:dictionary]) return one;
    return nil;
}

- (BOOL)modelSetWithJSON:(id)json {
    NSDictionary *dic = [NSObject _mm_dictionaryWithJSON:json];
    return [self modelSetWithDictionary:dic];
}

- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    if (!dic || dic == (id)kCFNull) return NO;
    if (![dic isKindOfClass:[NSDictionary class]]) return NO;
    
    _MMModelMeta *modelMeta = [_MMModelMeta metaWithClass:object_getClass(self)];
    if (modelMeta->_keyMappedCount == 0) return NO;
    
    if (modelMeta->_hasCustomWillTransformFromDictionary) {
        dic = [((id<MMModel>)self) modelCustomWillTransformFromDictionary:dic];
        if (![dic isKindOfClass:[NSDictionary class]]) return NO;
    }
    
    ModelSetContext context = {0};
    context.modelMeta = (__bridge void *)(modelMeta);
    context.model = (__bridge void *)(self);
    context.dicitonary = (__bridge void *)(dic);
    
    if (modelMeta->_keyMappedCount >= CFDictionaryGetCount((CFDictionaryRef)dic)) {
        CFDictionaryApplyFunction((CFDictionaryRef)dic, ModelSetWithDictionaryFunction,&context);
        if (modelMeta->_keyPathpropertyMetas) {
            CFArrayApplyFunction((CFArrayRef)modelMeta->_keyPathpropertyMetas,
                                 CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_keyPathpropertyMetas)),
                                 ModelSetWithPropertyMetaArrayFunction,
                                 &context);
        }
        if (modelMeta->_multiKeysPropertyMetas) {
            CFArrayApplyFunction((CFArrayRef)modelMeta->_multiKeysPropertyMetas,
                                 CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_multiKeysPropertyMetas)),
                                 ModelSetWithPropertyMetaArrayFunction,
                                 &context);
        }
    } else {
        CFArrayApplyFunction((CFArrayRef)modelMeta->_allPropertyMetas,
                             CFRangeMake(0, modelMeta->_keyMappedCount),
                             ModelSetWithPropertyMetaArrayFunction,
                             &context);
    }
    
    if (modelMeta->_hasCustomWillTransformFromDictionary) {
        return [((id<YYModel>)self) modelCustomTransformFromDictionary:dic];
    }
    return YES;
}

- (id)modelToJSONObject {
    id jsonObject = ModelToJSONObjectRecursive(self);
    if ([jsonObject isKindOfClass:[NSArray class]]) return jsonObject;
    if ([jsonObject isKindOfClass:[NSDictionary class]]) return jsonObject;
    return nil;
}

- (NSData *)modelToJSONData {
    id jsonObject = [self modelToJSONObject];
    if (!jsonObject) return nil;
    return [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
}

- (NSString *)modelToJSONString {
    NSData *jsonData = [self modelToJSONData];
    if (jsonData.length == 0) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (id)modelCopy {
    if (self == (id)kCFNull) return self;
    _MMModelMeta *modelMeta = [_MMModelMeta metaWithClass:[self class]];
    if (modelMeta->_nsType) return [self copy];
    
    NSObject *one = [[self class] new];
    for (_MMModelProperMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_getter || !propertyMeta->_setter) continue;
        
        if (propertyMeta->_isCNumberl) {
            switch (propertyMeta->_type & MMEncodingTypeMask) {
                case MMEncodingTypeBool: {
                    bool num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, bool))(void *)objc_msgSend)((id)one, propertyMeta->_setter,num);
                } break;
                  case MMEncodingTypeInt8:
                case MMEncodingTypeUInt8: {
                    uint8_t num = ((bool (*)(id, SEL))(void *)objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                    
                } break;
                    case MMEncodingTypeInt16:
                case MMEncodingTypeUInt16: {
                    uint16_t num = ((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case MMEncodingTypeInt32:
                case MMEncodingTypeUInt32: {
                    uint32_t num = ((uint32_t (*)(id, SEL))(void *)objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                    case MMEncodingTypeInt64:
                case MMEncodingTypeUInt64: {
                    uint64_t num = ((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case MMEncodingTypeFloat: {
                    float num = ((float (*)(id, SEL))(void *)objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case MMEncodingTypeDouble: {
                    double num = ((double (*)(id, SEL))(void *)objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case MMEncodingTypeLongDouble: {
                    long double num = ((long double (*)(id, SEL))(void *)objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                }
                default: break;
            }
        } else {
            switch (propertyMeta->_type & MMEncodingTypeMask) {
                case MMEncodingTypeObject:
                case MMEncodingTypeClass:
                case MMEncodingTypeBlock: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                case MMEncodingTypeSEL:
                case MMEncodingTypePointer:
                case MMEncodingTypeCString: {
                    size_t value = ((size_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, size_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                case MMEncodingTypeStruct:
                case MMEncodingTypeUnion: {
                    @try {
                        NSValue *value = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
                        if (value) {
                            [one setValue:value forKey:propertyMeta->_name];
                        }
                    } @catch (NSException *exception) {}
                } // break; commented for code coverage in next line
                default: break;
            }
        }
    }
    return one;
}

- (void)modelEncodeWithCoder:(NSCoder *)aCoder {
    if (!aCoder) return;
    if (self == (id)kCFNull) {
        [((id<NSCoding>)self) encodeWithCoder:aCoder];
        return;
    }
    
    _MMModelMeta *modelMeta = [_MMModelMeta metaWithClass:[self class]];
    if (modelMeta->_nsType) {
        [((id<NSCoding>)self) encodeWithCoder:aCoder];
        return;
    }
    
    for (_MMModelProperMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_getter) return;
        
        if (propertyMeta->_isCNumberl) {
            NSNumber *value = MMModelCreateNumberFromProperty(self, propertyMeta);
            if (value) [aCoder encodeObject:value forKey:propertyMeta->_name];
        } else {
            switch (propertyMeta->_type & MMEncodingTypeMask) {
                case MMEncodingTypeObject: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    if (value && (propertyMeta->_nsType || [value respondsToSelector:@selector(encodeWithCoder:)])) {
                        if ([value isKindOfClass:[NSValue class]]) {
                            if ([value isKindOfClass:[NSNumber class]]) {
                                [aCoder encodeObject:value forKey:propertyMeta->_name];
                            }
                        } else {
                            [aCoder encodeObject:value forKey:propertyMeta->_name];
                        }
                    }
                }  break;
                    
                case MMEncodingTypeSEL: {
                    SEL value = ((SEL (*)(id, SEL))(void *)objc_msgSend)((id)self, propertyMeta->_getter);
                    if (value) {
                        NSString *str = NSStringFromSelector(value);
                        [aCoder encodeObject:str forKey:propertyMeta->_name];
                    }
                } break;
                case MMEncodingTypeStruct:
                case MMEncodingTypeUnion: {
                    if (propertyMeta->_isKVCCompatible && propertyMeta->_isStructAvailableForKeyedArchiver) {
                        @try {
                            NSValue *value = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
                            [aCoder encodeObject:value forKey:propertyMeta->_name];
                        } @catch (NSException *exception) {}
                    }
                } break;

                default:
                    break;
            }
        }
    }
}

- (id)modelInitWithCoder:(NSCoder *)aDecoder {
    if (!aDecoder) return self;
    if (self == (id)kCFNull) return self;
    _MMModelMeta *modelMeta = [_MMModelMeta metaWithClass:[self class]];
    if (modelMeta->_nsType) return self;
    
    for (_MMModelProperMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_setter) continue;
        if (propertyMeta->_isCNumberl) {
            NSNumber *value = [aDecoder decodeObjectForKey:propertyMeta->_name];
            if ([value isKindOfClass:[NSNumber class]]) {
                MMModelSetNumberToProperty(self, value, propertyMeta);
                [value class];//proxy
            }
        } else {
            MMEncodingType type = propertyMeta->_type & MMEncodingTypeMask;
            switch (type) {
                case MMEncodingTypeObject: {
                    id value = [aDecoder decodeObjectForKey:propertyMeta->_name];
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)self, propertyMeta->_setter, value);
                } break;
                case MMEncodingTypeSEL: {
                    NSString *str = [aDecoder decodeObjectForKey:propertyMeta->_name];
                    if ([str isKindOfClass:[NSString class]]) {
                        SEL sel = NSSelectorFromString(str);
                        ((void (*)(id, SEL, SEL))(void *)objc_msgSend)((id)self, propertyMeta->_setter, sel);
                    }
                } break;
                    case MMEncodingTypeStruct:
                case MMEncodingTypeUnion: {
                    if (propertyMeta->_isKVCCompatible) {
                        @try {
                            NSValue *value = [aDecoder decodeObjectForKey:propertyMeta->_name];
                            if (value) [self setValue:value forKey:propertyMeta->_name];
                        } @catch (NSException *exception) {
                        } @finally {
                        }
                    }
                } break;
                default:
                    break;
            }
        }
    }
    return self;
}

- (NSUInteger)modelHash {
    if (self == (id)kCFNull) return [self hash];
    _MMModelMeta *modelMeta = [_MMModelMeta metaWithClass:[self class]];
    if (modelMeta->_nsType) return [self hash];
    
    NSUInteger value = 0;
    NSUInteger count = 0;
    for (_MMModelProperMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_isKVCCompatible) continue;
        value ^= [[self valueForKey:NSStringFromSelector(propertyMeta->_getter)] hash];
        count++;
    }
    
    if (count == 0) value = (long)((__bridge void *)self);
    return value;
}

- (BOOL)modelIsEqual:(id)model {
    if (self == model) return YES;
    if (![model isMemberOfClass:[self class]]) return NO;
    _MMModelMeta *modelMeta = [_MMModelMeta metaWithClass:[self class]];
    if (modelMeta->_nsType) return [self isEqual:model];
    if ([self hash] != [model hash]) return NO;
    
    for (_MMModelProperMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_isKVCCompatible) continue;
        id this = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        id that = [model valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        if (this == that) continue;
        if (this == nil || that == nil) return NO;
        if (![this isEqual:that]) return NO;
    }
    return YES;
}

- (NSString *)modelDescription {
    return ModelDescription(self);
}

@end


@implementation NSArray(MMModel)

+ (NSArray *)modelArrayWithClass:(Class)cls json:(id)json {
    if (!json) return nil;
    NSArray *arr = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSArray class]]) {
        arr = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    
    if (jsonData) {
        arr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![arr isKindOfClass:[NSArray class]]) arr = nil;
    }
    return [self modelArrayWithClass:cls array:arr];
}

+ (NSArray *)modelArrayWithClass:(Class)cls array:(NSArray *)arr {
    if (!cls || !arr) return nil;
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *dic in arr) {
        if (![dic isKindOfClass:[NSDictionary class]]) continue;
        NSObject *obj = [cls modelWithDictionary:dic];
        if (obj) [result addObject:obj];
    }
    return result;
}

@end

@implementation NSDictionary(MMModel)

+ (NSDictionary *)modelDictionaryWithClass:(Class)cls json:(id)json {
    if (!json) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) return nil;
    }
    return [self modelDictionaryWithClass:cls dictionary:dic];
}

+ (NSDictionary *)modelDictionaryWithClass:(Class)cls dictionary:(NSDictionary *)dic {
    if (!cls || !cls) return nil;
    NSMutableDictionary *result = [NSMutableDictionary new];
    for (NSString *key in dic.allKeys) {
        if (![key isKindOfClass:[NSString class]]) continue;
        NSObject *obj = [cls modelWithDictionary:dic[key]];
        if (obj) result[key] = obj;
    }
    return result;
}

@end

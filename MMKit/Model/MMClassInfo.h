//
//  MMClassInfo.h
//  PracticeKit
//
//  Created by 晓东 on 16/12/5.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, MMEncodingType) {
    MMEncodingTypeMask              = 0xFF, //255
    MMEncodingTypeUnknown           = 0,
    MMEncodingTypeVoid              = 1,
    MMEncodingTypeBool              = 2,
    MMEncodingTypeInt8              = 3,
    MMEncodingTypeUInt8             = 4,
    MMEncodingTypeInt16             = 5,
    MMEncodingTypeUInt16            = 6,
    MMEncodingTypeInt32             = 7,
    MMEncodingTypeUInt32            = 8,
    MMEncodingTypeInt64             = 9,
    MMEncodingTypeUInt64            = 10,
    MMEncodingTypeFloat             = 11,
    MMEncodingTypeDouble            = 12,
    MMEncodingTypeLongDouble        = 13,
    MMEncodingTypeObject            = 14,
    MMEncodingTypeClass             = 15,
    MMEncodingTypeSEL               = 16,
    MMEncodingTypeBlock             = 17,
    MMEncodingTypePointer           = 18,
    MMEncodingTypeStruct            = 19,
    MMEncodingTypeUnion             = 20,
    MMEncodingTypeCString           = 21,
    MMEncodingTypeCArray            = 22,
    
    MMEncodingTypeQualifierMask             = 0xFF00,   //65280
    MMEncodingTypeQualifierConst            = 1 << 8,   //100000000              256
    MMEncodingTypeQualifierIn               = 1 << 9,   //1000000000             512
    MMEncodingTypeQualifierInout            = 1 << 10,  //10000000000            1024
    MMEncodingTypeQualifierOut              = 1 << 11,  //100000000000           2048
    MMEncodingTypeQualifierBycopy           = 1 << 12,  //1000000000000          4096
    MMEncodingTypeQualifierByref            = 1 << 13,  //10000000000000         8192
    MMEncodingTypeQualifierOneway           = 1 << 14,  //100000000000000
    
    MMEncodingTypePropertyMask              = 0xFF0000,// 16711680
    MMEncodingTypePropertyReadonly          = 1 << 16,  //1000000000000000          32768
    MMEncodingTypePropertyCopy              = 1 << 17,  //10000000000000000         65536
    MMEncodingTypePropertyRetain            = 1 << 18,  //100000000000000000        131072
    MMEncodingTypePropertyNonatomic         = 1 << 19,  //1000000000000000000
    MMEncodingTypePropertyWeak              = 1 << 20,
    MMEncodingTypePropertyCustomGetter      = 1 << 21,
    MMEncodingTypePropertyCustomSetter      = 1 << 22,
    MMEncodingTypePropertyDynamic           = 1 << 23,
};

MMEncodingType MMEncodingGetType(const char *typeEncoding);

/**
 1.IvarInfo         获取变量信息
 2.MethodInfo       获取方法信息
 3.PropertyInfo     获取属性信息
 4.ClassInfo        以上三个封装到classinfo中，同时获取 superclassInfo、metaInfo
 */


@interface MMClassIvarInfo : NSObject
@property (nonatomic, assign, readonly) Ivar ivar;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) ptrdiff_t offset;
@property (nonatomic, strong, readonly) NSString *typeEncoding;
@property (nonatomic, assign, readonly) MMEncodingType type;


- (instancetype)initWithIvar:(Ivar)ivar;

@end

@interface MMClassMethodInfo : NSObject

@property (nonatomic, assign, readonly) Method method;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) SEL sel;
@property (nonatomic, assign, readonly) IMP imp;
@property (nonatomic, strong, readonly) NSString *typeEncoding;
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;
@property (nullable ,nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncoding;

- (instancetype)initWithMethod:(Method)method;

@end

@interface MMClassPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) MMEncodingType type;
@property (nonatomic, strong, readonly) NSString *typeEncoding;
@property (nonatomic, strong, readonly) NSString *ivarName;
@property (nullable, nonatomic, assign, readonly) Class cls;
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols;
@property (nonatomic, assign, readonly) SEL getter;
@property (nonatomic, assign, readonly) SEL setter;

- (instancetype)initWithProperty:(objc_property_t)property;

@end

@interface MMClassInfo : NSObject

@property (nonatomic, assign, readonly) Class cls;
@property (nullable, nonatomic, assign, readonly) Class superCls;
@property (nullable, nonatomic, assign, readonly) Class metaCls;
@property (nonatomic, readonly) BOOL isMeta;
@property (nonatomic, strong, readonly) NSString *name;
@property (nullable, nonatomic, strong, readonly) MMClassInfo *superClassInfo;
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, MMClassInfo *> *ivarInfos;
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, MMClassMethodInfo *> *methodInfos;
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, MMClassPropertyInfo *> *propertyInfos;

- (void)setNeddUpdate;

- (BOOL)needUpdate;

+ (nullable instancetype)classInfoWithClass:(Class)cls;

+ (nullable instancetype)classInfoWitClassName:(NSString *)className;

@end




NS_ASSUME_NONNULL_END

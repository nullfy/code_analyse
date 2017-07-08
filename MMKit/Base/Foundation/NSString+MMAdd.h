//
//  NSString+MMAdd.h
//  PracticeKit
//
//  Created by 晓东 on 16/11/17.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MMAdd)

#pragma mark    -Hash
- (nullable NSString *)md2String;

- (nullable NSString *)md4String;

- (nullable NSString *)md5String;

- (nullable NSString *)sha1String;

- (nullable NSString *)sha224String;

- (nullable NSString *)sha256String;

- (nullable NSString *)sha384String;

- (nullable NSString *)sha512String;

- (nullable NSString *)hmacMD5StringWithKey:(NSString *)key;

- (nullable NSString *)hmacSHA1StringWithKey:(NSString *)key;

- (nullable NSString *)hmacSHA224StringWithKey:(NSString *)key;

- (nullable NSString *)hmacSHA384StringWithKey:(NSString *)key;

- (nullable NSString *)hmacSHA512StringWithKey:(NSString *)key;

- (nullable NSString *)crc32String;



#pragma mark    -Encode and Decode 编码和解码

- (nullable NSString *)base64EncodedString;

+ (nullable NSString *)stringWithBase64EncodedString:(NSString *)base64EncodedString;

- (NSString *)stringByURLEncode;

- (NSString *)stringByURLDecode;

- (NSString *)stringByEscapingHTML;


#pragma mark    -Drawing 文字绘制

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

- (CGFloat)widthForFont:(UIFont *)font;

- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width;


#pragma mark    -Regular Expression 正则表达式

- (BOOL)matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options;

- (void)enumerateRegexMatches:(NSString *)regex
                     options:(NSRegularExpressionOptions)options
                  usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL stop))block;

- (NSString *)stringByReplaceingRegex:(NSString *)regex
                              options:(NSRegularExpressionOptions)options
                           withString:(NSString *)replacement;


#pragma mark    -NSNumber compatible 和NSNumber 兼容

@property (readonly)char charValue;
@property (readonly)unsigned char unsignedCharValue;
@property (readonly)short shortValue;
@property (readonly)unsigned short unsignedShortValue;
@property (readonly)unsigned int unsignedIntValue;
@property (readonly)long longValue;
@property (readonly)unsigned long unsignedLongValue;
@property (readonly)unsigned long long  unsignedLongLongValue;
@property (readonly)NSUInteger unsignedIntegerValue;


#pragma mark    -Utilities  自定义

+ (NSString *)stringWithUUID;

+ (nullable NSString *)stringWithUTF32Char:(UTF32Char)char32;

+ (nullable NSString *)stringWithUTF32Chars:(const UTF32Char *)char32 length:(NSUInteger)length;

- (void)enumerateUTF32CharInRange:(NSRange)range usingBlock:(void (^)(UTF32Char char32, NSRange range, BOOL *stop))block;

- (NSString *)stringByTrim;     //修剪 处理头和尾的空格 和 newline

/*
 <tr><td>"icon"     </td><td>"icon@2x"     </td></tr>
 <tr><td>"icon "    </td><td>"icon @2x"    </td></tr>
 <tr><td>"icon.top" </td><td>"icon.top@2x" </td></tr>
 <tr><td>"/p/name"  </td><td>"/p/name@2x"  </td></tr>
 <tr><td>"/path/"   </td><td>"/path/"      </td></tr>
 */
- (NSString *)stringByAppendingNameScale:(CGFloat)scale; //在文本末尾加上几倍图 如上例子

/*
 <tr><th>Before     </th><th>After(scale:2)</th></tr>
 <tr><td>"icon.png" </td><td>"icon@2x.png" </td></tr>
 <tr><td>"icon..png"</td><td>"icon.@2x.png"</td></tr>
 <tr><td>"icon"     </td><td>"icon@2x"     </td></tr>
 <tr><td>"icon "    </td><td>"icon @2x"    </td></tr>
 <tr><td>"icon."    </td><td>"icon.@2x"    </td></tr>
 <tr><td>"/p/name"  </td><td>"/p/name@2x"  </td></tr>
 <tr><td>"/path/"   </td><td>"/path/"      </td></tr>
 */
- (NSString *)stringByAppendingPathScale:(CGFloat)scale;

/*
 <table>
 <tr><th>Path            </th><th>Scale </th></tr>
 <tr><td>"icon.png"      </td><td>1     </td></tr>
 <tr><td>"icon@2x.png"   </td><td>2     </td></tr>
 <tr><td>"icon@2.5x.png" </td><td>2.5   </td></tr>
 <tr><td>"icon@2x"       </td><td>1     </td></tr>
 <tr><td>"icon@2x..png"  </td><td>1     </td></tr>
 <tr><td>"icon@2x.png/"  </td><td>1     </td></tr>
 */
- (CGFloat)pathScale;//返回几倍图的倍数

- (BOOL)isNotBlank;

- (BOOL)containsString:(NSString *)string;

- (BOOL)containsCharacterSet:(NSCharacterSet *)set;

- (nullable NSNumber *)numberValue;

- (nullable NSData *)dataValue;     //返回UTF－8格式的编码

- (NSRange)rangeOfAll;

- (nullable id)jsonValueDecoded;

+ (nullable NSString *)stringNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END









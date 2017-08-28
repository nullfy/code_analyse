//
//  UIFont+MMAdd.m
//  PracticeKit
//
//  Created by 晓东 on 16/12/3.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "UIFont+MMAdd.h"
#import "MMKitMacro.h"

MMSYNTH_DUMMY_CLASS(UIFont_MMAdd)

#pragma clang   diagnostic push
#pragma clang   diagnostic ignored "-Wprotocol"
@implementation UIFont (MMAdd)

- (BOOL)isBold {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitItalic) > 0;
}

- (BOOL)isItalic {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitItalic) > 0;
}

- (BOOL)isMonoSpace {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitMonoSpace) > 0;
}

- (BOOL)isColorGlyphs {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
    return (CTFontGetSymbolicTraits((__bridge CTFontRef)self) & kCTFontTraitColorGlyphs) != 0;
}

- (CGFloat)fontWeight {
    NSDictionary *traits = [self.fontDescriptor objectForKey:UIFontDescriptorTraitsAttribute];
    return [traits[UIFontWidthTrait] floatValue];
}

- (UIFont *)fontWithBold {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:self.pointSize];
}

- (UIFont *)fontWithBoldItalic {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic] size:self.pointSize];
}

- (UIFont *)fontWithItalic {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic] size:self.pointSize];
}

- (UIFont *)fontWithNormal {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:0] size:self.pointSize];
}

+ (UIFont *)fontWithCTFont:(CTFontRef)CTFont {
    if (!CTFont) return nil;
    CFStringRef name = CTFontCopyPostScriptName(CTFont);
    if (!name) return nil;
    CGFloat size = CTFontGetSize(CTFont);
    UIFont *font = [self fontWithName:(__bridge NSString *)(name) size:size];
    CFRelease(name);
    return font;
}

+ (UIFont *)fontWithCGFont:(CGFontRef)CGFont size:(CGFloat)size {
    if (!CGFont) return nil;
    CFStringRef name = CGFontCopyPostScriptName(CGFont);
    if (!name) return nil;
    UIFont *font = [self fontWithName:(__bridge NSString *)(name) size:size];
    CFRelease(name);
    return font;
}

- (CTFontRef)CTFontRef CF_RETURNS_RETAINED {
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.fontName, self.pointSize, NULL);
    return font;
}

- (CGFontRef)CGFontRef CF_RETURNS_RETAINED {
    CGFontRef font = CGFontCreateWithFontName((__bridge CFStringRef)self.fontName);
    return font;
}

+ (BOOL)loadFontFromPath:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    CFErrorRef error;
    BOOL sucess = CTFontManagerRegisterFontsForURL((__bridge CFTypeRef)url, kCTFontManagerScopeNone, &error);
    if (!sucess) NSLog(@"Failed to load font:%@",error);
    return sucess;
}

+ (void)unloadFontFromPath:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    CTFontManagerUnregisterFontsForURL((__bridge CFTypeRef)url, kCTFontManagerScopeNone, NULL);
}


+ (UIFont *)loadFontFromData:(NSData *)data {
    CGDataProviderRef provide = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    if (!provide) return nil;
    CGFontRef fontRef = CGFontCreateWithDataProvider(provide);
    CGDataProviderRelease(provide);
    if (!fontRef) return nil;
    
    CFErrorRef errorRef;
    BOOL sucess = CTFontManagerUnregisterGraphicsFont(fontRef, &errorRef);
    if (!sucess) {
        CFRelease(fontRef);
        return nil;
    } else {
        CFStringRef fontName = CGFontCopyPostScriptName(fontRef);
        UIFont *font = [UIFont fontWithName:(__bridge NSString *)(fontName) size:[UIFont systemFontSize]];
        if (fontName) CFRelease(fontName);
        CGFontRelease(fontRef);
        return font;
    }
}

+ (BOOL)unloadFontFromData:(UIFont *)font {
    CGFontRef fontRef = CGFontCreateWithFontName((__bridge CFStringRef)font.fontName);
    if (!fontRef) return NO;
    CFErrorRef errorRef;
    BOOL sucess = CTFontManagerUnregisterGraphicsFont(fontRef, &errorRef);
    CFRelease(fontRef);
    if (!sucess) NSLog(@"%@",errorRef);
    return sucess;
}

+ (NSData *)dataFromFont:(UIFont *)font {
    CGFontRef cgFont = font.CGFontRef;
    NSData *data = [self dataFromCGFont:cgFont];
    CGFontRelease(cgFont);
    return data;
}

typedef struct FontHeader {
    int32_t fVersion;
    uint16_t fNumTables;
    uint16_t fSearchRange;
    uint16_t fEntrySelector;
    uint16_t fRangeShift;
} FontHeader;

typedef struct TableEntry {
    uint32_t fTag;
    uint32_t fCheckSum;
    uint32_t fOffset;
    uint32_t fLength;
} TableEntry;

static uint32_t CalcTableCheckSum(const uint32_t *table, uint32_t numberOfBytesInTable) {
    uint32_t sum = 0;
    uint32_t nLongs = (numberOfBytesInTable + 3) / 4;
    while (nLongs-- > 0) {
        sum += CFSwapInt32HostToBig(*table++);
    }
    return sum;
}

+ (NSData *)dataFromCGFont:(CGFontRef)cgFont {
    if (!cgFont) return nil;
    CFRetain(cgFont);
    
    CFArrayRef tags = CGFontCopyTableTags(cgFont);
    if (!tags) return nil;
    CFIndex tableCount = CFArrayGetCount(tags);
    
    size_t *tableSizes = malloc(sizeof(size_t) * tableCount);
    memset(tableSizes, 0, sizeof(size_t) * tableCount);
    
    BOOL containsCFFTable = NO;
    
    size_t totalSize = sizeof(FontHeader) + sizeof(TableEntry) * tableCount;
    
    for (CFIndex index = 0; index < tableCount; index++) {
        size_t tableSize = 0;
        uint32_t aTag = (uint32_t)CFArrayGetValueAtIndex(tags, index);
        if (aTag == kCTFontTableCFF && !containsCFFTable) containsCFFTable = YES;
        
        CFDataRef tableDataRef = CGFontCopyTableForTag(cgFont, aTag);
        if (tableDataRef) {
            tableSize = CFDataGetLength(tableDataRef);
            CFRelease(tableDataRef);
        }
        totalSize += (tableSize + 3) & ~3;
        tableSizes[index] = tableSize;
    }
    unsigned char *stream = malloc(totalSize);
    memset(stream, 0, totalSize);
    char *dataStart = (char *)stream;
    char *dataPtr = dataStart;
    
    uint16_t entrySelector = 0;
    uint16_t searchRange = 1;
    while (searchRange < tableCount >> 1) {
        entrySelector++;
        searchRange <<= 1;
    }
    searchRange <<= 4;
    
    uint16_t rangeShift = (tableCount << 4) - searchRange;
    
    FontHeader *offsetTable = (FontHeader *)dataPtr;
    
    offsetTable->fVersion = containsCFFTable ? 'OTTO' : CFSwapInt16HostToBig(1);
    offsetTable->fNumTables = CFSwapInt16HostToBig((uint16_t)tableCount);
    offsetTable->fSearchRange = CFSwapInt16HostToBig((uint16_t)searchRange);
    offsetTable->fEntrySelector = CFSwapInt16HostToBig((uint16_t)entrySelector);
    offsetTable->fRangeShift = CFSwapInt16HostToBig((uint16_t)rangeShift);
    
    dataPtr += sizeof(FontHeader);
    
    TableEntry *entry = (TableEntry *)dataPtr;
    dataPtr += sizeof(TableEntry) * tableCount;
    
    for (int index = 0; index < tableCount; ++index) {
        uint32_t aTag = (uint32_t)CFArrayGetValueAtIndex(tags, index);
        CFDataRef tableDataRef = CGFontCopyTableForTag(cgFont, aTag);
        size_t tableSize = CFDataGetLength(tableDataRef);
        
        memcpy(dataPtr, CFDataGetBytePtr(tableDataRef), tableSize);
        
        entry->fTag = CFSwapInt32HostToBig((uint32_t)aTag);
        entry->fCheckSum = CFSwapInt32HostToBig(CalcTableCheckSum((uint32_t *)dataPtr, (uint32_t)tableSize));
        
        uint32_t offset = (uint32_t)dataPtr - (uint32_t)dataStart;
        entry->fOffset = CFSwapInt32HostToBig((uint32_t)offset);
        entry->fLength = CFSwapInt32HostToBig((uint32_t)tableSize);
        dataPtr += (tableSize + 3) & ~3;
        ++entry;
        CFRelease(tableDataRef);
    }
    
    CFRelease(cgFont);
    CFRelease(tags);
    free(tableSizes);
    NSData *fontData = [NSData dataWithBytesNoCopy:stream length:totalSize freeWhenDone:YES];
    
    return fontData;
}

@end
#pragma clang   diagnostic pop

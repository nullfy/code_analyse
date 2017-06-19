//
//  MMImageCoder.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/5/12.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMImageCoder.h"
#import <CoreFoundation/CoreFoundation.h>
#import <ImageIO/ImageIO.h>
#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h> //saveToAlbumWithCompletionBlock

#import <zlib.h> //crc32()
#import "MMImage.h"
#import "MMKitMacro.h"

/**
 if(MMIMAGE_WEBP_ENABLED 为空) {
 if(<webp>) {
 MMIMAGE_WEBP_ENABLED 1
 import <webp/decode.h>
 } else if ("webp") {
 MMIMAGE_WEBP_ENABLED 1
 import  “webp/decode.h”
 } else {
 MMIMAGE_WEBP_ENABLED 0
 }
 }
 */


#ifndef MMIMAGE_WEBP_ENABLED

#if __has_include(<webp/decode.h>) && __has_include(<webp/encode.h>) && \
__has_include(<webp/demux.h>) && __has_include(<webp/mux.h>)

#define MMIMAGE_WEBP_ENABLED 1

#import <WebP/decode.h>
#import <WebP/encode.h>
#import <WebP/mux.h>
#import <WebP/demux.h>

#elif __has_include("webp/decode.h") && __has_include("webp/encode.h") && \
__has_include("webp/demux.h") && __has_include("webp/mux.h")

#define MMIMAGE_WEBP_ENABLED 1

#import "webp/decode.h"
#import "webp/encode.h"
#import "webp/demux.h"
#import "webp/mux.h"

#else
#define MMIMAGE_WEBP_ENABLED 0

#endif

#endif


#pragma mark   - Utility
#define MM_FOUR_CC(c1,c2,c3,c4) ( (uint32_t)( ((c4) << 24 ) | ((c3) << 16) | ((c2) << 8) | (c1)) )
#define MM_TWO_CC(c1, c2) ( (uint16_t) ( ((c2) << 8) | (c1) ) )

static inline uint16_t mm_swap_endian_uint16(uint16_t value) {
    return
    (uint16_t) ((value & 0x00FF) << 8) |
    (uint16_t) ((value & 0xFF00) >> 8);
}

static inline uint32_t mm_swap_endian_uint32(uint32_t value) {
    return
    (uint32_t) ((value & 0x000000FFU) << 24) |
    (uint32_t) ((value & 0x0000FF00U) << 8) |
    (uint32_t) ((value & 0x00FF0000U) >> 8) |
    (uint32_t) ((value & 0xFF000000U) >> 24);
}

typedef enum {
    MM_PNG_ALPHA_TYPE_PALEETE = 1 << 0,
    MM_PNG_ALPHA_TYPE_COLOR = 1 << 1,
    MM_PNG_ALPHA_TYPE_ALPHA = 1 << 2,
} mm_png_alpha_type;

typedef enum {
    MM_PNG_DISPOSE_OP_NONE = 0,
    MM_PNG_DISPOSE_OP_BACKGROUND = 1,
    MM_PNG_DISPOSE_OP_PREVIOUS = 2,
}mm_png_dispose_op;

typedef enum {
    MM_PNG_BLEND_OP_SOURCE = 0,
    MM_PNG_BLEND_OP_OVER = 1,
} mm_png_blend_op;

typedef struct {
    uint32_t width;
    uint32_t height;
    uint8_t bit_depth;
    uint8_t color_type;
    uint8_t compression_method;
    uint8_t filter_method;
    uint8_t interlace_method;
} mm_png_chunk_IHDR;

typedef struct {
    uint32_t sequence_number;
    uint32_t width;
    uint32_t height;
    uint32_t x_offset;
    uint32_t y_offset;
    uint16_t delay_num;
    uint16_t delay_den;
    uint8_t dispose_op;
    uint8_t blend_op;
} mm_png_chunk_fcTL;

typedef struct {
    uint32_t offset;
    uint32_t fourcc;
    uint32_t length;
    uint32_t crc32;
} mm_png_chunk_info;

typedef struct {
    uint32_t chunk_index;
    uint32_t chunk_num;
    uint32_t chunk_size;
    mm_png_chunk_fcTL frame_control;
} mm_png_frame_info;

typedef struct {
    mm_png_chunk_IHDR header;
    mm_png_chunk_info *chunks;
    uint32_t chunk_num;
    
    mm_png_frame_info *apng_frames;
    uint32_t apng_frame_num;
    uint32_t apng_loop_num;
    
    uint32_t *apng_shared_chunk_indexs;
    uint32_t apng_shared_chunk_num;
    uint32_t apng_shared_chunk_size;
    uint32_t apng_shared_insert_index;
    bool apng_first_frame_is_cover;
} mm_png_info;

static void mm_png_chunk_IHDR_read(mm_png_chunk_IHDR *IHDR, const uint8_t *data) {
    IHDR->width = mm_swap_endian_uint32(*((uint32_t *)(data)));
    IHDR->height = mm_swap_endian_uint32(*((uint32_t *)(data + 4)));
    IHDR->bit_depth = data[8];
    IHDR->color_type = data[9];
    IHDR->compression_method = data[10];
    IHDR->filter_method = data[11];
    IHDR->interlace_method = data[12];
}

static void mm_png_chunk_IHDR_write(mm_png_chunk_IHDR *IHDR, uint8_t *data) {
    *((uint32_t *)(data)) = IHDR->width ;
    *((uint32_t *)(data + 4)) = IHDR->height;
    data[8] = IHDR->bit_depth;
    data[9] = IHDR->color_type;
    data[10] = IHDR->compression_method ;
    data[11] = IHDR->filter_method;
    data[12] = IHDR->interlace_method;
}

static void mm_png_chunk_fcTL_read(mm_png_chunk_fcTL *fcTL, const uint8_t *data) {
    fcTL->sequence_number = mm_swap_endian_uint32(*((uint32_t *)(data)));
    fcTL->width = mm_swap_endian_uint32(*((uint32_t *)(data + 4)));
    fcTL->height = mm_swap_endian_uint32(*((uint32_t *)(data + 8)));
    fcTL->x_offset = mm_swap_endian_uint32(*((uint32_t *)(data + 12)));
    fcTL->y_offset = mm_swap_endian_uint32(*((uint32_t *)(data + 16)));
    fcTL->delay_num = mm_swap_endian_uint16(*((uint16_t *)(data + 20)));
    fcTL->delay_den = mm_swap_endian_uint16(*((uint16_t *)(data + 22)));
    fcTL->dispose_op = data[24];
    fcTL->blend_op = data[25];
}

static void mm_png_chunk_fcTL_write(mm_png_chunk_fcTL *fcTL, uint8_t *data) {
    *((uint32_t *)(data)) = fcTL->sequence_number;
    *((uint32_t *)(data + 4)) = fcTL->width;
    *((uint32_t *)(data + 8)) = fcTL->height;
    *((uint32_t *)(data + 12)) = fcTL->x_offset;
    *((uint32_t *)(data + 16)) = fcTL->y_offset;
    *((uint16_t *)(data + 20)) = fcTL->delay_num;
    *((uint16_t *)(data + 22)) = fcTL->delay_den;
    data[24] = fcTL->dispose_op;
    data[25] = fcTL->blend_op;
}

// convert double value to fraction
static void mm_png_delay_to_fraction(double duration, uint16_t *num, uint16_t *den) {
    if (duration >= 0xFF) {
        *num = 0xFF;
        *den = 1;
    } else if (duration <= 1.0 / (double)0xFF) {
        *num = 1;
        *den = 0xFF;
    } else {
        // Use continued fraction to calculate the num and den.
        long MAX = 10;
        double eps = (0.5 / (double)0xFF);
        long p[MAX], q[MAX], a[MAX], i, numl = 0, denl = 0;
        // The first two convergents are 0/1 and 1/0
        p[0] = 0; q[0] = 1;
        p[1] = 1; q[1] = 0;
        // The rest of the convergents (and continued fraction)
        for (i = 2; i < MAX; i++) {
            a[i] = lrint(floor(duration));
            p[i] = a[i] * p[i - 1] + p[i - 2];
            q[i] = a[i] * q[i - 1] + q[i - 2];
            if (p[i] <= 0xFF && q[i] <= 0xFF) { // uint16_t
                numl = p[i];
                denl = q[i];
            } else break;
            if (fabs(duration - a[i]) < eps) break;
            duration = 1.0 / (duration - a[i]);
        }
        
        if (numl != 0 && denl != 0) {
            *num = numl;
            *den = denl;
        } else {
            *num = 1;
            *den = 100;
        }
    }
}

// convert fraction to double value
static double mm_png_delay_to_seconds(uint16_t num, uint16_t den) {
    if (den == 0) {
        return num / 100.0;
    } else {
        return (double)num / (double)den;
    }
}

static bool mm_png_validate_animation_chunk_order(mm_png_chunk_info *chunks,  /* input */
                                                  uint32_t chunk_num,         /* input */
                                                  uint32_t *first_idat_index, /* output */
                                                  bool *first_frame_is_cover  /* output */) {
    /*
     PNG at least contains 3 chunks: IHDR, IDAT, IEND.
     `IHDR` must appear first.
     `IDAT` must appear consecutively.
     `IEND` must appear end.
     
     APNG must contains one `acTL` and at least one 'fcTL' and `fdAT`.
     `fdAT` must appear consecutively.
     `fcTL` must appear before `IDAT` or `fdAT`.
     */
    if (chunk_num <= 2) return false;
    if (chunks->fourcc != MM_FOUR_CC('I', 'H', 'D', 'R')) return false;
    if ((chunks + chunk_num - 1)->fourcc != MM_FOUR_CC('I', 'E', 'N', 'D')) return false;
    
    uint32_t prev_fourcc = 0;
    uint32_t IHDR_num = 0;
    uint32_t IDAT_num = 0;
    uint32_t acTL_num = 0;
    uint32_t fcTL_num = 0;
    uint32_t first_IDAT = 0;
    bool first_frame_cover = false;
    for (uint32_t i = 0; i < chunk_num; i++) {
        mm_png_chunk_info *chunk = chunks + i;
        switch (chunk->fourcc) {
            case MM_FOUR_CC('I', 'H', 'D', 'R'): {  // png header
                if (i != 0) return false;
                if (IHDR_num > 0) return false;
                IHDR_num++;
            } break;
            case MM_FOUR_CC('I', 'D', 'A', 'T'): {  // png data
                if (prev_fourcc != MM_FOUR_CC('I', 'D', 'A', 'T')) {
                    if (IDAT_num == 0)
                        first_IDAT = i;
                    else
                        return false;
                }
                IDAT_num++;
            } break;
            case MM_FOUR_CC('a', 'c', 'T', 'L'): {  // apng control
                if (acTL_num > 0) return false;
                acTL_num++;
            } break;
            case MM_FOUR_CC('f', 'c', 'T', 'L'): {  // apng frame control
                if (i + 1 == chunk_num) return false;
                if ((chunk + 1)->fourcc != MM_FOUR_CC('f', 'd', 'A', 'T') &&
                    (chunk + 1)->fourcc != MM_FOUR_CC('I', 'D', 'A', 'T')) {
                    return false;
                }
                if (fcTL_num == 0) {
                    if ((chunk + 1)->fourcc == MM_FOUR_CC('I', 'D', 'A', 'T')) {
                        first_frame_cover = true;
                    }
                }
                fcTL_num++;
            } break;
            case MM_FOUR_CC('f', 'd', 'A', 'T'): {  // apng data
                if (prev_fourcc != MM_FOUR_CC('f', 'd', 'A', 'T') && prev_fourcc != MM_FOUR_CC('f', 'c', 'T', 'L')) {
                    return false;
                }
            } break;
        }
        prev_fourcc = chunk->fourcc;
    }
    if (IHDR_num != 1) return false;
    if (IDAT_num == 0) return false;
    if (acTL_num != 1) return false;
    if (fcTL_num < acTL_num) return false;
    *first_idat_index = first_IDAT;
    *first_frame_is_cover = first_frame_cover;
    return true;
}

static void mm_png_info_release(mm_png_info *info) {
    if (info) {
        if (info->chunks) free(info->chunks);
        if (info->apng_frames) free(info->apng_frames);
        if (info->apng_shared_chunk_indexs) free(info->apng_shared_chunk_indexs);
        free(info);
    }
}

/**
 Create a png info from a png file. See struct png_info for more information.
 
 @param data   png/apng file data.
 @param length the data's length in bytes.
 @return A png info object, you may call mm_png_info_release() to release it.
 Returns NULL if an error occurs.
 */
static mm_png_info *mm_png_info_create(const uint8_t *data, uint32_t length) {
    if (length < 32) return NULL;
    if (*((uint32_t *)data) != MM_FOUR_CC(0x89, 0x50, 0x4E, 0x47)) return NULL;
    if (*((uint32_t *)(data + 4)) != MM_FOUR_CC(0x0D, 0x0A, 0x1A, 0x0A)) return NULL;
    
    uint32_t chunk_realloc_num = 16;
    mm_png_chunk_info *chunks = malloc(sizeof(mm_png_chunk_info) * chunk_realloc_num);
    if (!chunks) return NULL;
    
    // parse png chunks
    uint32_t offset = 8;
    uint32_t chunk_num = 0;
    uint32_t chunk_capacity = chunk_realloc_num;
    uint32_t apng_loop_num = 0;
    int32_t apng_sequence_index = -1;
    int32_t apng_frame_index = 0;
    int32_t apng_frame_number = -1;
    bool apng_chunk_error = false;
    do {
        if (chunk_num >= chunk_capacity) {
            mm_png_chunk_info *new_chunks = realloc(chunks, sizeof(mm_png_chunk_info) * (chunk_capacity + chunk_realloc_num));
            if (!new_chunks) {
                free(chunks);
                return NULL;
            }
            chunks = new_chunks;
            chunk_capacity += chunk_realloc_num;
        }
        mm_png_chunk_info *chunk = chunks + chunk_num;
        const uint8_t *chunk_data = data + offset;
        chunk->offset = offset;
        chunk->length = mm_swap_endian_uint32(*((uint32_t *)chunk_data));
        if ((uint64_t)chunk->offset + (uint64_t)chunk->length + 12 > length) {
            free(chunks);
            return NULL;
        }
        
        chunk->fourcc = *((uint32_t *)(chunk_data + 4));
        if ((uint64_t)chunk->offset + 4 + chunk->length + 4 > (uint64_t)length) break;
        chunk->crc32 = mm_swap_endian_uint32(*((uint32_t *)(chunk_data + 8 + chunk->length)));
        chunk_num++;
        offset += 12 + chunk->length;
        
        switch (chunk->fourcc) {
            case MM_FOUR_CC('a', 'c', 'T', 'L') : {
                if (chunk->length == 8) {
                    apng_frame_number = mm_swap_endian_uint32(*((uint32_t *)(chunk_data + 8)));
                    apng_loop_num = mm_swap_endian_uint32(*((uint32_t *)(chunk_data + 12)));
                } else {
                    apng_chunk_error = true;
                }
            } break;
            case MM_FOUR_CC('f', 'c', 'T', 'L') :
            case MM_FOUR_CC('f', 'd', 'A', 'T') : {
                if (chunk->fourcc == MM_FOUR_CC('f', 'c', 'T', 'L')) {
                    if (chunk->length != 26) {
                        apng_chunk_error = true;
                    } else {
                        apng_frame_index++;
                    }
                }
                if (chunk->length > 4) {
                    uint32_t sequence = mm_swap_endian_uint32(*((uint32_t *)(chunk_data + 8)));
                    if (apng_sequence_index + 1 == sequence) {
                        apng_sequence_index++;
                    } else {
                        apng_chunk_error = true;
                    }
                } else {
                    apng_chunk_error = true;
                }
            } break;
            case MM_FOUR_CC('I', 'E', 'N', 'D') : {
                offset = length; // end, break do-while loop
            } break;
        }
    } while (offset + 12 <= length);
    
    if (chunk_num < 3 ||
        chunks->fourcc != MM_FOUR_CC('I', 'H', 'D', 'R') ||
        chunks->length != 13) {
        free(chunks);
        return NULL;
    }
    
    // png info
    mm_png_info *info = calloc(1, sizeof(mm_png_info));
    if (!info) {
        free(chunks);
        return NULL;
    }
    info->chunks = chunks;
    info->chunk_num = chunk_num;
    mm_png_chunk_IHDR_read(&info->header, data + chunks->offset + 8);
    
    // apng info
    if (!apng_chunk_error && apng_frame_number == apng_frame_index && apng_frame_number >= 1) {
        bool first_frame_is_cover = false;
        uint32_t first_IDAT_index = 0;
        if (!mm_png_validate_animation_chunk_order(info->chunks, info->chunk_num, &first_IDAT_index, &first_frame_is_cover)) {
            return info; // ignore apng chunk
        }
        
        info->apng_loop_num = apng_loop_num;
        info->apng_frame_num = apng_frame_number;
        info->apng_first_frame_is_cover = first_frame_is_cover;
        info->apng_shared_insert_index = first_IDAT_index;
        info->apng_frames = calloc(apng_frame_number, sizeof(mm_png_frame_info));
        if (!info->apng_frames) {
            mm_png_info_release(info);
            return NULL;
        }
        info->apng_shared_chunk_indexs = calloc(info->chunk_num, sizeof(uint32_t));
        if (!info->apng_shared_chunk_indexs) {
            mm_png_info_release(info);
            return NULL;
        }
        
        int32_t frame_index = -1;
        uint32_t *shared_chunk_index = info->apng_shared_chunk_indexs;
        for (int32_t i = 0; i < info->chunk_num; i++) {
            mm_png_chunk_info *chunk = info->chunks + i;
            switch (chunk->fourcc) {
                case MM_FOUR_CC('I', 'D', 'A', 'T'): {
                    if (info->apng_shared_insert_index == 0) {
                        info->apng_shared_insert_index = i;
                    }
                    if (first_frame_is_cover) {
                        mm_png_frame_info *frame = info->apng_frames + frame_index;
                        frame->chunk_num++;
                        frame->chunk_size += chunk->length + 12;
                    }
                } break;
                case MM_FOUR_CC('a', 'c', 'T', 'L'): {
                } break;
                case MM_FOUR_CC('f', 'c', 'T', 'L'): {
                    frame_index++;
                    mm_png_frame_info *frame = info->apng_frames + frame_index;
                    frame->chunk_index = i + 1;
                    mm_png_chunk_fcTL_read(&frame->frame_control, data + chunk->offset + 8);
                } break;
                case MM_FOUR_CC('f', 'd', 'A', 'T'): {
                    mm_png_frame_info *frame = info->apng_frames + frame_index;
                    frame->chunk_num++;
                    frame->chunk_size += chunk->length + 12;
                } break;
                default: {
                    *shared_chunk_index = i;
                    shared_chunk_index++;
                    info->apng_shared_chunk_size += chunk->length + 12;
                    info->apng_shared_chunk_num++;
                } break;
            }
        }
    }
    return info;
}

/**
 Copy a png frame data from an apng file.
 
 @param data  apng file data
 @param info  png info
 @param index frame index (zero-based)
 @param size  output, the size of the frame data
 @return A frame data (single-frame png file), call free() to release the data.
 Returns NULL if an error occurs.
 */
static uint8_t *mm_png_copy_frame_data_at_index(const uint8_t *data,
                                                const mm_png_info *info,
                                                const uint32_t index,
                                                uint32_t *size) {
    if (index >= info->apng_frame_num) return NULL;
    
    mm_png_frame_info *frame_info = info->apng_frames + index;
    uint32_t frame_remux_size = 8 /* PNG Header */ + info->apng_shared_chunk_size + frame_info->chunk_size;
    if (!(info->apng_first_frame_is_cover && index == 0)) {
        frame_remux_size -= frame_info->chunk_num * 4; // remove fdAT sequence number
    }
    uint8_t *frame_data = malloc(frame_remux_size);
    if (!frame_data) return NULL;
    *size = frame_remux_size;
    
    uint32_t data_offset = 0;
    bool inserted = false;
    memcpy(frame_data, data, 8); // PNG File Header
    data_offset += 8;
    for (uint32_t i = 0; i < info->apng_shared_chunk_num; i++) {
        uint32_t shared_chunk_index = info->apng_shared_chunk_indexs[i];
        mm_png_chunk_info *shared_chunk_info = info->chunks + shared_chunk_index;
        
        if (shared_chunk_index >= info->apng_shared_insert_index && !inserted) { // replace IDAT with fdAT
            inserted = true;
            for (uint32_t c = 0; c < frame_info->chunk_num; c++) {
                mm_png_chunk_info *insert_chunk_info = info->chunks + frame_info->chunk_index + c;
                if (insert_chunk_info->fourcc == MM_FOUR_CC('f', 'd', 'A', 'T')) {
                    *((uint32_t *)(frame_data + data_offset)) = mm_swap_endian_uint32(insert_chunk_info->length - 4);
                    *((uint32_t *)(frame_data + data_offset + 4)) = MM_FOUR_CC('I', 'D', 'A', 'T');
                    memcpy(frame_data + data_offset + 8, data + insert_chunk_info->offset + 12, insert_chunk_info->length - 4);
                    uint32_t crc = (uint32_t)crc32(0, frame_data + data_offset + 4, insert_chunk_info->length);
                    *((uint32_t *)(frame_data + data_offset + insert_chunk_info->length + 4)) = mm_swap_endian_uint32(crc);
                    data_offset += insert_chunk_info->length + 8;
                } else { // IDAT
                    memcpy(frame_data + data_offset, data + insert_chunk_info->offset, insert_chunk_info->length + 12);
                    data_offset += insert_chunk_info->length + 12;
                }
            }
        }
        
        if (shared_chunk_info->fourcc == MM_FOUR_CC('I', 'H', 'D', 'R')) {
            uint8_t tmp[25] = {0};
            memcpy(tmp, data + shared_chunk_info->offset, 25);
            mm_png_chunk_IHDR IHDR = info->header;
            IHDR.width = frame_info->frame_control.width;
            IHDR.height = frame_info->frame_control.height;
            mm_png_chunk_IHDR_write(&IHDR, tmp + 8);
            *((uint32_t *)(tmp + 21)) = mm_swap_endian_uint32((uint32_t)crc32(0, tmp + 4, 17));
            memcpy(frame_data + data_offset, tmp, 25);
            data_offset += 25;
        } else {
            memcpy(frame_data + data_offset, data + shared_chunk_info->offset, shared_chunk_info->length + 12);
            data_offset += shared_chunk_info->length + 12;
        }
    }
    return frame_data;
}

#pragma mark - Helper

// 字节对齐
static inline size_t MMImageByteAlign(size_t size, size_t alignment) {
    return ((size + (alignment - 1)) / alignment) * alignment;
}

/// Convert degree to radians
static inline CGFloat MMImageDegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

CGColorSpaceRef MMCGColorSpaceGetDeviceRGB() {
    static CGColorSpaceRef space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        space = CGColorSpaceCreateDeviceRGB();
    });
    return space;
}

CGColorSpaceRef MMCGColorSpaceGetDeviceGray() {
    static CGColorSpaceRef space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        space = CGColorSpaceCreateDeviceGray();
    });
    return space;
}

BOOL MMCGColorSpaceIsDeviceRGB(CGColorSpaceRef space) {
    return space && CFEqual(space, MMCGColorSpaceGetDeviceRGB());
}

BOOL MMCGColorSpaceIsDeviceGray(CGColorSpaceRef space) {
    return space && CFEqual(space, MMCGColorSpaceGetDeviceGray());
}

/**
 A callback used in CGDataProviderCreateWithData() to release data.
 
 Example:
 
 void *data = malloc(size);
 CGDataProviderRef provider = CGDataProviderCreateWithData(data, data, size, MMCGDataProviderReleaseDataCallback);
 */
static void MMCGDataProviderReleaseDataCallback(void *info, const void *data, size_t size) {
    if (info) free(info);
}

/**
 Decode an image to bitmap buffer with the specified format.
 
 @param srcImage   Source image.
 @param dest       Destination buffer. It should be zero before call this method.
 If decode succeed, you should release the dest->data using free().
 @param destFormat Destination bitmap format.
 
 @return Whether succeed.
 
 @warning This method support iOS7.0 and later. If call it on iOS6, it just returns NO.
 CG_AVAILABLE_STARTING(__MAC_10_9, __IPHONE_7_0)
 */
static BOOL MMCGImageDecodeToBitmapBufferWithAnyFormat(CGImageRef srcImage, vImage_Buffer *dest, vImage_CGImageFormat *destFormat) {
    if (!srcImage || (((long)vImageConvert_AnyToAny) + 1 == 1) || !destFormat || !dest) return NO;
    size_t width = CGImageGetWidth(srcImage);
    size_t height = CGImageGetHeight(srcImage);
    if (width == 0 || height == 0) return NO;
    dest->data = NULL;
    
    vImage_Error error = kvImageNoError;
    CFDataRef srcData = NULL;
    vImageConverterRef convertor = NULL;
    vImage_CGImageFormat srcFormat = {0};
    srcFormat.bitsPerComponent = (uint32_t)CGImageGetBitsPerComponent(srcImage);
    srcFormat.bitsPerPixel = (uint32_t)CGImageGetBitsPerPixel(srcImage);
    srcFormat.colorSpace = CGImageGetColorSpace(srcImage);
    srcFormat.bitmapInfo = CGImageGetBitmapInfo(srcImage) | CGImageGetAlphaInfo(srcImage);
    
    convertor = vImageConverter_CreateWithCGImageFormat(&srcFormat, destFormat, NULL, kvImageNoFlags, NULL);
    if (!convertor) goto fail;
    
    CGDataProviderRef srcProvider = CGImageGetDataProvider(srcImage);
    srcData = srcProvider ? CGDataProviderCopyData(srcProvider) : NULL; // decode
    size_t srcLength = srcData ? CFDataGetLength(srcData) : 0;
    const void *srcBytes = srcData ? CFDataGetBytePtr(srcData) : NULL;
    if (srcLength == 0 || !srcBytes) goto fail;
    
    vImage_Buffer src = {0};
    src.data = (void *)srcBytes;
    src.width = width;
    src.height = height;
    src.rowBytes = CGImageGetBytesPerRow(srcImage);
    
    error = vImageBuffer_Init(dest, height, width, 32, kvImageNoFlags);
    if (error != kvImageNoError) goto fail;
    
    error = vImageConvert_AnyToAny(convertor, &src, dest, NULL, kvImageNoFlags); // convert
    if (error != kvImageNoError) goto fail;
    
    CFRelease(convertor);
    CFRelease(srcData);
    return YES;
    
fail:
    if (convertor) CFRelease(convertor);
    if (srcData) CFRelease(srcData);
    if (dest->data) free(dest->data);
    dest->data = NULL;
    return NO;
}

/**
 Decode an image to bitmap buffer with the 32bit format (such as ARGB8888).
 
 @param srcImage   Source image.
 @param dest       Destination buffer. It should be zero before call this method.
 If decode succeed, you should release the dest->data using free().
 @param bitmapInfo Destination bitmap format.
 
 @return Whether succeed.
 */
static BOOL MMCGImageDecodeToBitmapBufferWith32BitFormat(CGImageRef srcImage, vImage_Buffer *dest, CGBitmapInfo bitmapInfo) {
    if (!srcImage || !dest) return NO;
    size_t width = CGImageGetWidth(srcImage);
    size_t height = CGImageGetHeight(srcImage);
    if (width == 0 || height == 0) return NO;
    
    BOOL hasAlpha = NO;
    BOOL alphaFirst = NO;
    BOOL alphaPremultiplied = NO;
    BOOL byteOrderNormal = NO;
    
    switch (bitmapInfo & kCGBitmapAlphaInfoMask) {
        case kCGImageAlphaPremultipliedLast: {
            hasAlpha = YES;
            alphaPremultiplied = YES;
        } break;
        case kCGImageAlphaPremultipliedFirst: {
            hasAlpha = YES;
            alphaPremultiplied = YES;
            alphaFirst = YES;
        } break;
        case kCGImageAlphaLast: {
            hasAlpha = YES;
        } break;
        case kCGImageAlphaFirst: {
            hasAlpha = YES;
            alphaFirst = YES;
        } break;
        case kCGImageAlphaNoneSkipLast: {
        } break;
        case kCGImageAlphaNoneSkipFirst: {
            alphaFirst = YES;
        } break;
        default: {
            return NO;
        } break;
    }
    
    switch (bitmapInfo & kCGBitmapByteOrderMask) {
        case kCGBitmapByteOrderDefault: {
            byteOrderNormal = YES;
        } break;
        case kCGBitmapByteOrder32Little: {
        } break;
        case kCGBitmapByteOrder32Big: {
            byteOrderNormal = YES;
        } break;
        default: {
            return NO;
        } break;
    }
    
    /*
     Try convert with vImageConvert_AnyToAny() (avaliable since iOS 7.0).
     If fail, try decode with CGContextDrawImage().
     CGBitmapContext use a premultiplied alpha format, unpremultiply may lose precision.
     */
    vImage_CGImageFormat destFormat = {0};
    destFormat.bitsPerComponent = 8;
    destFormat.bitsPerPixel = 32;
    destFormat.colorSpace = MMCGColorSpaceGetDeviceRGB();
    destFormat.bitmapInfo = bitmapInfo;
    dest->data = NULL;
    if (MMCGImageDecodeToBitmapBufferWithAnyFormat(srcImage, dest, &destFormat)) return YES;
    
    CGBitmapInfo contextBitmapInfo = bitmapInfo & kCGBitmapByteOrderMask;
    if (!hasAlpha || alphaPremultiplied) {
        contextBitmapInfo |= (bitmapInfo & kCGBitmapAlphaInfoMask);
    } else {
        contextBitmapInfo |= alphaFirst ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaPremultipliedLast;
    }
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, MMCGColorSpaceGetDeviceRGB(), contextBitmapInfo);
    if (!context) goto fail;
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), srcImage); // decode and convert
    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
    size_t length = height * bytesPerRow;
    void *data = CGBitmapContextGetData(context);
    if (length == 0 || !data) goto fail;
    
    dest->data = malloc(length);
    dest->width = width;
    dest->height = height;
    dest->rowBytes = bytesPerRow;
    if (!dest->data) goto fail;
    
    if (hasAlpha && !alphaPremultiplied) {
        vImage_Buffer tmpSrc = {0};
        tmpSrc.data = data;
        tmpSrc.width = width;
        tmpSrc.height = height;
        tmpSrc.rowBytes = bytesPerRow;
        vImage_Error error;
        if (alphaFirst && byteOrderNormal) {
            error = vImageUnpremultiplyData_ARGB8888(&tmpSrc, dest, kvImageNoFlags);
        } else {
            error = vImageUnpremultiplyData_RGBA8888(&tmpSrc, dest, kvImageNoFlags);
        }
        if (error != kvImageNoError) goto fail;
    } else {
        memcpy(dest->data, data, length);
    }
    
    CFRelease(context);
    return YES;
    
fail:
    if (context) CFRelease(context);
    if (dest->data) free(dest->data);
    dest->data = NULL;
    return NO;
    return NO;
}

CGImageRef MMCGImageCreateDecodedCopy(CGImageRef imageRef, BOOL decodeForDisplay) {
    if (!imageRef) return NULL;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || height == 0) return NULL;
    
    if (decodeForDisplay) { //decode with redraw (may lose some precision)
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        // BGRA8888 (premultiplied) or BGRX8888
        // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, MMCGColorSpaceGetDeviceRGB(), bitmapInfo);
        if (!context) return NULL;
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
        CGImageRef newImage = CGBitmapContextCreateImage(context);
        CFRelease(context);
        return newImage;
        
    } else {
        CGColorSpaceRef space = CGImageGetColorSpace(imageRef);
        size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
        size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
        size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
        CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
        if (bytesPerRow == 0 || width == 0 || height == 0) return NULL;
        
        CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
        if (!dataProvider) return NULL;
        CFDataRef data = CGDataProviderCopyData(dataProvider); // decode
        if (!data) return NULL;
        
        CGDataProviderRef newProvider = CGDataProviderCreateWithCFData(data);
        CFRelease(data);
        if (!newProvider) return NULL;
        
        CGImageRef newImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, space, bitmapInfo, newProvider, NULL, false, kCGRenderingIntentDefault);
        CFRelease(newProvider);
        return newImage;
    }
}

CGImageRef MMCGImageCreateAffineTransformCopy(CGImageRef imageRef, CGAffineTransform transform, CGSize destSize, CGBitmapInfo destBitmapInfo) {
    if (!imageRef) return NULL;
    size_t srcWidth = CGImageGetWidth(imageRef);
    size_t srcHeight = CGImageGetHeight(imageRef);
    size_t destWidth = round(destSize.width);
    size_t destHeight = round(destSize.height);
    if (srcWidth == 0 || srcHeight == 0 || destWidth == 0 || destHeight == 0) return NULL;
    
    CGDataProviderRef tmpProvider = NULL, destProvider = NULL;
    CGImageRef tmpImage = NULL, destImage = NULL;
    vImage_Buffer src = {0}, tmp = {0}, dest = {0};
    if(!MMCGImageDecodeToBitmapBufferWith32BitFormat(imageRef, &src, kCGImageAlphaFirst | kCGBitmapByteOrderDefault)) return NULL;
    
    size_t destBytesPerRow = MMImageByteAlign(destWidth * 4, 32);
    tmp.data = malloc(destHeight * destBytesPerRow);
    if (!tmp.data) goto fail;
    
    tmp.width = destWidth;
    tmp.height = destHeight;
    tmp.rowBytes = destBytesPerRow;
    vImage_CGAffineTransform vTransform = *((vImage_CGAffineTransform *)&transform);
    uint8_t backColor[4] = {0};
    vImage_Error error = vImageAffineWarpCG_ARGB8888(&src, &tmp, NULL, &vTransform, backColor, kvImageBackgroundColorFill);
    if (error != kvImageNoError) goto fail;
    free(src.data);
    src.data = NULL;
    
    tmpProvider = CGDataProviderCreateWithData(tmp.data, tmp.data, destHeight * destBytesPerRow, MMCGDataProviderReleaseDataCallback);
    if (!tmpProvider) goto fail;
    tmp.data = NULL; // hold by provider
    tmpImage = CGImageCreate(destWidth, destHeight, 8, 32, destBytesPerRow, MMCGColorSpaceGetDeviceRGB(), kCGImageAlphaFirst | kCGBitmapByteOrderDefault, tmpProvider, NULL, false, kCGRenderingIntentDefault);
    if (!tmpImage) goto fail;
    CFRelease(tmpProvider);
    tmpProvider = NULL;
    
    if ((destBitmapInfo & kCGBitmapAlphaInfoMask) == kCGImageAlphaFirst &&
        (destBitmapInfo & kCGBitmapByteOrderMask) != kCGBitmapByteOrder32Little) {
        return tmpImage;
    }
    
    if (!MMCGImageDecodeToBitmapBufferWith32BitFormat(tmpImage, &dest, destBitmapInfo)) goto fail;
    CFRelease(tmpImage);
    tmpImage = NULL;
    
    destProvider = CGDataProviderCreateWithData(dest.data, dest.data, destHeight * destBytesPerRow, MMCGDataProviderReleaseDataCallback);
    if (!destProvider) goto fail;
    dest.data = NULL; // hold by provider
    destImage = CGImageCreate(destWidth, destHeight, 8, 32, destBytesPerRow, MMCGColorSpaceGetDeviceRGB(), destBitmapInfo, destProvider, NULL, false, kCGRenderingIntentDefault);
    if (!destImage) goto fail;
    CFRelease(destProvider);
    destProvider = NULL;
    
    return destImage;
    
fail:
    if (src.data) free(src.data);
    if (tmp.data) free(tmp.data);
    if (dest.data) free(dest.data);
    if (tmpProvider) CFRelease(tmpProvider);
    if (tmpImage) CFRelease(tmpImage);
    if (destProvider) CFRelease(destProvider);
    return NULL;
}

UIImageOrientation YYUIImageOrientationFromEXIFValue(NSInteger value) {
    switch (value) {
        case kCGImagePropertyOrientationUp: return UIImageOrientationUp;
        case kCGImagePropertyOrientationDown: return UIImageOrientationDown;
        case kCGImagePropertyOrientationLeft: return UIImageOrientationLeft;
        case kCGImagePropertyOrientationRight: return UIImageOrientationRight;
        case kCGImagePropertyOrientationUpMirrored: return UIImageOrientationUpMirrored;
        case kCGImagePropertyOrientationDownMirrored: return UIImageOrientationDownMirrored;
        case kCGImagePropertyOrientationLeftMirrored: return UIImageOrientationLeftMirrored;
        case kCGImagePropertyOrientationRightMirrored: return UIImageOrientationRightMirrored;
        default: return UIImageOrientationUp;
    }
}

NSInteger YYUIImageOrientationToEXIFValue(UIImageOrientation orientation) {
    switch (orientation) {
        case UIImageOrientationUp: return kCGImagePropertyOrientationUp;
        case UIImageOrientationDown: return kCGImagePropertyOrientationDown;
        case UIImageOrientationLeft: return kCGImagePropertyOrientationLeft;
        case UIImageOrientationRight: return kCGImagePropertyOrientationRight;
        case UIImageOrientationUpMirrored: return kCGImagePropertyOrientationUpMirrored;
        case UIImageOrientationDownMirrored: return kCGImagePropertyOrientationDownMirrored;
        case UIImageOrientationLeftMirrored: return kCGImagePropertyOrientationLeftMirrored;
        case UIImageOrientationRightMirrored: return kCGImagePropertyOrientationRightMirrored;
        default: return kCGImagePropertyOrientationUp;
    }
}

//用于保证图片是保持朝上而不受设备旋转影响的
CGImageRef MMCGImageCreateCopyWithOrientation(CGImageRef imageRef, UIImageOrientation orientation, CGBitmapInfo destBitmapInfo) {
    if (!imageRef) return NULL;
    if (orientation == UIImageOrientationUp) return (CGImageRef)CFRetain(imageRef);
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    BOOL swapWidthAndHeight = NO;
    switch (orientation) {
        case UIImageOrientationDown: {
            transform = CGAffineTransformMakeRotation(MMImageDegreesToRadians(180));
            transform = CGAffineTransformTranslate(transform, -(CGFloat)width, -(CGFloat)height);
        } break;
        case UIImageOrientationLeft: {
            transform = CGAffineTransformMakeRotation(MMImageDegreesToRadians(90));
            transform = CGAffineTransformTranslate(transform, -(CGFloat)0, -(CGFloat)height);
            swapWidthAndHeight = YES;
        } break;
        case UIImageOrientationRight: {
            transform = CGAffineTransformMakeRotation(MMImageDegreesToRadians(-90));
            transform = CGAffineTransformTranslate(transform, -(CGFloat)width, (CGFloat)0);
            swapWidthAndHeight = YES;
        } break;
        case UIImageOrientationUpMirrored: {
            transform = CGAffineTransformTranslate(transform, (CGFloat)width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        } break;
        case UIImageOrientationDownMirrored: {
            transform = CGAffineTransformTranslate(transform, 0, (CGFloat)height);
            transform = CGAffineTransformScale(transform, 1, -1);
        } break;
        case UIImageOrientationLeftMirrored: {
            transform = CGAffineTransformMakeRotation(MMImageDegreesToRadians(-90));
            transform = CGAffineTransformScale(transform, 1, -1);
            transform = CGAffineTransformTranslate(transform, -(CGFloat)width, -(CGFloat)height);
            swapWidthAndHeight = YES;
        } break;
        case UIImageOrientationRightMirrored: {
            transform = CGAffineTransformMakeRotation(MMImageDegreesToRadians(90));
            transform = CGAffineTransformScale(transform, 1, -1);
            swapWidthAndHeight = YES;
        } break;
        default: break;
    }
    if (CGAffineTransformIsIdentity(transform)) return (CGImageRef)CFRetain(imageRef);
    
    CGSize destSize = {width, height};
    if (swapWidthAndHeight) {
        destSize.width = height;
        destSize.height = width;
    }
    
    return MMCGImageCreateAffineTransformCopy(imageRef, transform, destSize, destBitmapInfo);
}

MMImageType MMImageDetectType(CFDataRef data) {
    if (!data) return MMImageTypeUnknown;
    uint64_t length = CFDataGetLength(data);
    if (length < 16) return MMImageTypeUnknown;
    
    const char *bytes = (char *)CFDataGetBytePtr(data);
    
    uint32_t magic4 = *((uint32_t *)bytes);
    switch (magic4) {
        case MM_FOUR_CC(0x4D, 0x4D, 0x00, 0x2A): { // big endian TIFF
            return MMImageTypeTIFF;
        } break;
            
        case MM_FOUR_CC(0x49, 0x49, 0x2A, 0x00): { // little endian TIFF
            return MMImageTypeTIFF;
        } break;
            
        case MM_FOUR_CC(0x00, 0x00, 0x01, 0x00): { // ICO
            return MMImageTypeICO;
        } break;
            
        case MM_FOUR_CC(0x00, 0x00, 0x02, 0x00): { // CUR
            return MMImageTypeICO;
        } break;
            
        case MM_FOUR_CC('i', 'c', 'n', 's'): { // ICNS
            return MMImageTypeICNS;
        } break;
            
        case MM_FOUR_CC('G', 'I', 'F', '8'): { // GIF
            return MMImageTypeGIF;
        } break;
            
        case MM_FOUR_CC(0x89, 'P', 'N', 'G'): {  // PNG
            uint32_t tmp = *((uint32_t *)(bytes + 4));
            if (tmp == MM_FOUR_CC('\r', '\n', 0x1A, '\n')) {
                return MMImageTypePNG;
            }
        } break;
            
        case MM_FOUR_CC('R', 'I', 'F', 'F'): { // WebP
            uint32_t tmp = *((uint32_t *)(bytes + 8));
            if (tmp == MM_FOUR_CC('W', 'E', 'B', 'P')) {
                return MMImageTypeWebP;
            }
        } break;
            /*
             case MM_FOUR_CC('B', 'P', 'G', 0xFB): { // BPG
             return MMImageTypeBPG;
             } break;
             */
    }
    
    uint16_t magic2 = *((uint16_t *)bytes);
    switch (magic2) {
        case MM_TWO_CC('B', 'A'):
        case MM_TWO_CC('B', 'M'):
        case MM_TWO_CC('I', 'C'):
        case MM_TWO_CC('P', 'I'):
        case MM_TWO_CC('C', 'I'):
        case MM_TWO_CC('C', 'P'): { // BMP
            return MMImageTypeBMP;
        }
        case MM_TWO_CC(0xFF, 0x4F): { // JPEG2000
            return MMImageTypeJPEG2000;
        }
    }
    
    // JPG             FF D8 FF
    if (memcmp(bytes,"\377\330\377",3) == 0) return MMImageTypeJPEG;
    
    // JP2
    if (memcmp(bytes + 4, "\152\120\040\040\015", 5) == 0) return MMImageTypeJPEG2000;
    
    return MMImageTypeUnknown;
}

/**
 <mobileCoreServeice/mobile>
 图片类型由NS_ENUM 转UTCoreType
 */

CFStringRef MMImageTypeToUTType(MMImageType type) {
    switch (type) {
        case MMImageTypeJPEG: return kUTTypeJPEG;
        case MMImageTypeJPEG2000: return kUTTypeJPEG2000;
        case MMImageTypeTIFF: return kUTTypeTIFF;
        case MMImageTypeBMP: return kUTTypeBMP;
        case MMImageTypeICO: return kUTTypeICO;
        case MMImageTypeICNS: return kUTTypeAppleICNS;
        case MMImageTypeGIF: return kUTTypeGIF;
        case MMImageTypePNG: return kUTTypePNG;
        default: return NULL;
    }
}

MMImageType MMImageTypeFromUTType(CFStringRef uti) {
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{(id)kUTTypeJPEG : @(MMImageTypeJPEG),
                (id)kUTTypeJPEG2000 : @(MMImageTypeJPEG2000),
                (id)kUTTypeTIFF : @(MMImageTypeTIFF),
                (id)kUTTypeBMP : @(MMImageTypeBMP),
                (id)kUTTypeICO : @(MMImageTypeICO),
                (id)kUTTypeAppleICNS : @(MMImageTypeICNS),
                (id)kUTTypeGIF : @(MMImageTypeGIF),
                (id)kUTTypePNG : @(MMImageTypePNG)};
    });
    if (!uti) return MMImageTypeUnknown;
    NSNumber *num = dic[(__bridge __strong id)(uti)];
    return num.unsignedIntegerValue;
}

NSString *MMImageTypeGetExtension(MMImageType type) {
    switch (type) {
        case MMImageTypeJPEG: return @"jpg";
        case MMImageTypeJPEG2000: return @"jp2";
        case MMImageTypeTIFF: return @"tiff";
        case MMImageTypeBMP: return @"bmp";
        case MMImageTypeICO: return @"ico";
        case MMImageTypeICNS: return @"icns";
        case MMImageTypeGIF: return @"gif";
        case MMImageTypePNG: return @"png";
        case MMImageTypeWebP: return @"webp";
        default: return nil;
    }
}

CFDataRef MMCGImageCreateEncodedData(CGImageRef imageRef, MMImageType type, CGFloat quality) {
    if (!imageRef) return nil;
    quality = quality < 0 ? 0 : quality > 1 ? 1 : quality;
    
    if (type == MMImageTypeWebP) {
#if MMImage_WEBP_ENABLED
        if (quality == 1) {
            return MMCGImageCreateEncodedWebPData(imageRef, YES, quality, 4, MMImagePresetDefault);
        } else {
            return MMCGImageCreateEncodedWebPData(imageRef, NO, quality, 4, MMImagePresetDefault);
        }
#else
        return NULL;
#endif
    }
    
    CFStringRef uti = MMImageTypeToUTType(type);
    if (!uti) return nil;
    
    CFMutableDataRef data = CFDataCreateMutable(CFAllocatorGetDefault(), 0);
    if (!data) return NULL;
    CGImageDestinationRef dest = CGImageDestinationCreateWithData(data, uti, 1, NULL);
    if (!dest) {
        CFRelease(data);
        return NULL;
    }
    NSDictionary *options = @{(id)kCGImageDestinationLossyCompressionQuality : @(quality) };
    CGImageDestinationAddImage(dest, imageRef, (CFDictionaryRef)options);
    if (!CGImageDestinationFinalize(dest)) {
        CFRelease(data);
        CFRelease(dest);
        return nil;
    }
    CFRelease(dest);
    
    if (CFDataGetLength(data) == 0) {
        CFRelease(data);
        return NULL;
    }
    return data;
}

#if MMImage_WEBP_ENABLED

BOOL MMImageWebPAvailable() {
    return YES;
}

CFDataRef MMCGImageCreateEncodedWebPData(CGImageRef imageRef, BOOL lossless, CGFloat quality, int compressLevel, MMImagePreset preset) {
    if (!imageRef) return nil;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || width > WEBP_MAX_DIMENSION) return nil;
    if (height == 0 || height > WEBP_MAX_DIMENSION) return nil;
    
    vImage_Buffer buffer = {0};
    if(!MMCGImageDecodeToBitmapBufferWith32BitFormat(imageRef, &buffer, kCGImageAlphaLast | kCGBitmapByteOrderDefault)) return nil;
    
    WebPConfig config = {0};
    WebPPicture picture = {0};
    WebPMemoryWriter writer = {0};
    CFDataRef webpData = NULL;
    BOOL pictureNeedFree = NO;
    
    quality = quality < 0 ? 0 : quality > 1 ? 1 : quality;
    preset = preset > MMImagePresetText ? MMImagePresetDefault : preset;
    compressLevel = compressLevel < 0 ? 0 : compressLevel > 6 ? 6 : compressLevel;
    if (!WebPConfigPreset(&config, (WebPPreset)preset, quality)) goto fail;
    
    config.quality = round(quality * 100.0);
    config.lossless = lossless;
    config.method = compressLevel;
    switch ((WebPPreset)preset) {
        case WEBP_PRESET_DEFAULT: {
            config.image_hint = WEBP_HINT_DEFAULT;
        } break;
        case WEBP_PRESET_PICTURE: {
            config.image_hint = WEBP_HINT_PICTURE;
        } break;
        case WEBP_PRESET_PHOTO: {
            config.image_hint = WEBP_HINT_PHOTO;
        } break;
        case WEBP_PRESET_DRAWING:
        case WEBP_PRESET_ICON:
        case WEBP_PRESET_TEXT: {
            config.image_hint = WEBP_HINT_GRAPH;
        } break;
    }
    if (!WebPValidateConfig(&config)) goto fail;
    
    if (!WebPPictureInit(&picture)) goto fail;
    pictureNeedFree = YES;
    picture.width = (int)buffer.width;
    picture.height = (int)buffer.height;
    picture.use_argb = lossless;
    if(!WebPPictureImportRGBA(&picture, buffer.data, (int)buffer.rowBytes)) goto fail;
    
    WebPMemoryWriterInit(&writer);
    picture.writer = WebPMemoryWrite;
    picture.custom_ptr = &writer;
    if(!WebPEncode(&config, &picture)) goto fail;
    
    webpData = CFDataCreate(CFAllocatorGetDefault(), writer.mem, writer.size);
    free(writer.mem);
    WebPPictureFree(&picture);
    free(buffer.data);
    return webpData;
    
fail:
    if (buffer.data) free(buffer.data);
    if (pictureNeedFree) WebPPictureFree(&picture);
    return nil;
}

NSUInteger MMImageGetWebPFrameCount(CFDataRef webpData) {
    if (!webpData || CFDataGetLength(webpData) == 0) return 0;
    
    WebPData data = {CFDataGetBytePtr(webpData), CFDataGetLength(webpData)};
    WebPDemuxer *demuxer = WebPDemux(&data);
    if (!demuxer) return 0;
    NSUInteger webpFrameCount = WebPDemuxGetI(demuxer, WEBP_FF_FRAME_COUNT);
    WebPDemuxDelete(demuxer);
    return webpFrameCount;
}

CGImageRef MMCGImageCreateWithWebPData(CFDataRef webpData,
                                       BOOL decodeForDisplay,
                                       BOOL useThreads,
                                       BOOL bypassFiltering,
                                       BOOL noFancyUpsampling) {
    /*
     Call WebPDecode() on a multi-frame webp data will get an error (VP8_STATUS_UNSUPPORTED_FEATURE).
     Use WebPDemuxer to unpack it first.
     */
    WebPData data = {0};
    WebPDemuxer *demuxer = NULL;
    
    int frameCount = 0, canvasWidth = 0, canvasHeight = 0;
    WebPIterator iter = {0};
    BOOL iterInited = NO;
    const uint8_t *payload = NULL;
    size_t payloadSize = 0;
    WebPDecoderConfig config = {0};
    
    BOOL hasAlpha = NO;
    size_t bitsPerComponent = 0, bitsPerPixel = 0, bytesPerRow = 0, destLength = 0;
    CGBitmapInfo bitmapInfo = 0;
    WEBP_CSP_MODE colorspace = 0;
    void *destBytes = NULL;
    CGDataProviderRef provider = NULL;
    CGImageRef imageRef = NULL;
    
    if (!webpData || CFDataGetLength(webpData) == 0) return NULL;
    data.bytes = CFDataGetBytePtr(webpData);
    data.size = CFDataGetLength(webpData);
    demuxer = WebPDemux(&data);
    if (!demuxer) goto fail;
    
    frameCount = WebPDemuxGetI(demuxer, WEBP_FF_FRAME_COUNT);
    if (frameCount == 0) {
        goto fail;
        
    } else if (frameCount == 1) { // single-frame
        payload = data.bytes;
        payloadSize = data.size;
        if (!WebPInitDecoderConfig(&config)) goto fail;
        if (WebPGetFeatures(payload , payloadSize, &config.input) != VP8_STATUS_OK) goto fail;
        canvasWidth = config.input.width;
        canvasHeight = config.input.height;
        
    } else { // multi-frame
        canvasWidth = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH);
        canvasHeight = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT);
        if (canvasWidth < 1 || canvasHeight < 1) goto fail;
        
        if (!WebPDemuxGetFrame(demuxer, 1, &iter)) goto fail;
        iterInited = YES;
        
        if (iter.width > canvasWidth || iter.height > canvasHeight) goto fail;
        payload = iter.fragment.bytes;
        payloadSize = iter.fragment.size;
        
        if (!WebPInitDecoderConfig(&config)) goto fail;
        if (WebPGetFeatures(payload , payloadSize, &config.input) != VP8_STATUS_OK) goto fail;
    }
    if (payload == NULL || payloadSize == 0) goto fail;
    
    hasAlpha = config.input.has_alpha;
    bitsPerComponent = 8;
    bitsPerPixel = 32;
    bytesPerRow = MMImageByteAlign(bitsPerPixel / 8 * canvasWidth, 32);
    destLength = bytesPerRow * canvasHeight;
    if (decodeForDisplay) {
        bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        colorspace = MODE_bgrA; // small endian
    } else {
        bitmapInfo = kCGBitmapByteOrderDefault;
        bitmapInfo |= hasAlpha ? kCGImageAlphaLast : kCGImageAlphaNoneSkipLast;
        colorspace = MODE_RGBA;
    }
    destBytes = calloc(1, destLength);
    if (!destBytes) goto fail;
    
    config.options.use_threads = useThreads; //speed up 23%
    config.options.bypass_filtering = bypassFiltering; //speed up 11%, cause some banding
    config.options.no_fancy_upsampling = noFancyUpsampling; //speed down 16%, lose some details
    config.output.colorspace = colorspace;
    config.output.is_external_memory = 1;
    config.output.u.RGBA.rgba = destBytes;
    config.output.u.RGBA.stride = (int)bytesPerRow;
    config.output.u.RGBA.size = destLength;
    
    VP8StatusCode result = WebPDecode(payload, payloadSize, &config);
    if ((result != VP8_STATUS_OK) && (result != VP8_STATUS_NOT_ENOUGH_DATA)) goto fail;
    
    if (iter.x_offset != 0 || iter.y_offset != 0) {
        void *tmp = calloc(1, destLength);
        if (tmp) {
            vImage_Buffer src = {destBytes, canvasHeight, canvasWidth, bytesPerRow};
            vImage_Buffer dest = {tmp, canvasHeight, canvasWidth, bytesPerRow};
            vImage_CGAffineTransform transform = {1, 0, 0, 1, iter.x_offset, -iter.y_offset};
            uint8_t backColor[4] = {0};
            vImageAffineWarpCG_ARGB8888(&src, &dest, NULL, &transform, backColor, kvImageBackgroundColorFill);
            memcpy(destBytes, tmp, destLength);
            free(tmp);
        }
    }
    
    provider = CGDataProviderCreateWithData(destBytes, destBytes, destLength, MMCGDataProviderReleaseDataCallback);
    if (!provider) goto fail;
    destBytes = NULL; // hold by provider
    
    imageRef = CGImageCreate(canvasWidth, canvasHeight, bitsPerComponent, bitsPerPixel, bytesPerRow, MMCGColorSpaceGetDeviceRGB(), bitmapInfo, provider, NULL, false, kCGRenderingIntentDefault);
    
    CFRelease(provider);
    if (iterInited) WebPDemuxReleaseIterator(&iter);
    WebPDemuxDelete(demuxer);
    
    return imageRef;
    
fail:
    if (destBytes) free(destBytes);
    if (provider) CFRelease(provider);
    if (iterInited) WebPDemuxReleaseIterator(&iter);
    if (demuxer) WebPDemuxDelete(demuxer);
    return NULL;
}

#else

BOOL MMImageWebPAvailable() {
    return NO;
}

CFDataRef MMCGImageCreateEncodedWebPData(CGImageRef imageRef, BOOL lossless, CGFloat quality, int compressLevel, MMImagePreset preset) {
    NSLog(@"WebP decoder is disabled");
    return NULL;
}

NSUInteger MMImageGetWebPFrameCount(CFDataRef webpData) {
    NSLog(@"WebP decoder is disabled");
    return 0;
}

CGImageRef MMCGImageCreateWithWebPData(CFDataRef webpData,
                                       BOOL decodeForDisplay,
                                       BOOL useThreads,
                                       BOOL bypassFiltering,
                                       BOOL noFancyUpsampling) {
    NSLog(@"WebP decoder is disabled");
    return NULL;
}

#endif


/**
 MMImageFrame 主要作用就是实现了NSCopying协议用于封装图片的尺寸信息
 */

@implementation MMImageFrame

+ (instancetype)frameWithImage:(UIImage *)image {
    MMImageFrame *frame = [self new];
    frame.image = image;
    return frame;
}

- (id)copyWithZone:(NSZone *)zone {
    MMImageFrame *frame = [self.class new];
    frame.index = _index;
    frame.width = _width;
    frame.height = _height;
    frame.offsetX = _offsetX;
    frame.offsetY = _offsetY;
    frame.duration = _duration;
    frame.dispose = _dispose;
    frame.blend = _blend;
    frame.image = _image.copy;
    return frame;
}

@end

@interface _MMImageDecoderFrame : MMImageFrame

@property (nonatomic, assign) BOOL hasAlpha;
@property (nonatomic, assign) BOOL isFullSize;
@property (nonatomic, assign) NSUInteger blendFromIndex;

@end

@implementation _MMImageDecoderFrame

- (id)copyWithZone:(NSZone *)zone {
    _MMImageDecoderFrame *frame = [super copyWithZone:zone];
    frame.hasAlpha = _hasAlpha;
    frame.isFullSize = _isFullSize;
    frame.blendFromIndex = _blendFromIndex;
    return frame;
}

@end

@implementation MMImageDecoder {
    pthread_mutex_t _lock;  //互斥锁 recursive lock
    
    BOOL _sourceTypeDetected;
    CGImageSourceRef _source;
    mm_png_info *_apngSource;
#if MMIMAGE_WEBP_ENABLED
    WebPDemuxer *_webpSource;
#endif
    
    UIImageOrientation _orientation;
    dispatch_semaphore_t _framesLock;
    NSArray *_frames;
    BOOL _needBlend;
    NSUInteger _blendFrameIndex;
    CGContextRef _blendCanvas; //用于Blend的画布也作为画布
}

- (void)dealloc {
    if (_source)     CFRelease(_source);
    if (_apngSource) mm_png_info_release(_apngSource);
#if MMIMAGE_WEBP_ENABLED
    if (_webpSource) WebPDemuxDelete(_webpSource);
#endif
    
    if (_blendCanvas) CFRelease(_blendCanvas);
    pthread_mutex_destroy(&_lock);
}

+ (instancetype)decoderWithData:(NSData *)data scale:(CGFloat)scale {
    if (!data) return nil;
    MMImageDecoder *decoder = [[MMImageDecoder alloc] initWithScale:scale];
    [decoder updateData:data final:YES];
    if (decoder.frameCount == 0) return nil;
    return decoder;
}

- (instancetype)init {
    return [self initWithScale:[UIScreen mainScreen].scale];
}

- (instancetype)initWithScale:(CGFloat)scale {
    self = [super init];
    if (scale <= 0) scale = 1;
    _scale = scale;
    _framesLock = dispatch_semaphore_create(1);
    pthread_mutex_init_recursive(&_lock, true);
    return self;
}

- (BOOL)updateData:(NSData *)data final:(BOOL)finally {
    BOOL result = NO;
    pthread_mutex_lock(&_lock);
    result = [self _updateData:data final:finally];
    pthread_mutex_unlock(&_lock);
    return result;
}

- (MMImageFrame *)frameAtIndex:(NSUInteger)index decodeForDisplay:(BOOL)decodeForDisplay {
    MMImageFrame *result = nil;
    pthread_mutex_lock(&_lock);
    result = [self _frameAtIndex:index decodeForDisplay:decodeForDisplay];
    pthread_mutex_unlock(&_lock);
    return result;
}

- (NSTimeInterval)frameDurationAtIndex:(NSUInteger)index {
    NSTimeInterval result = 0;
    dispatch_semaphore_wait(_framesLock, DISPATCH_TIME_FOREVER);
    if (index < _frames.count) {
        result = ((_MMImageDecoderFrame *)_frames[index]).duration;
    }
    dispatch_semaphore_signal(_framesLock);
    return result;
}

- (NSDictionary *)framePropertiesAtIndex:(NSUInteger)index {
    NSDictionary *result = nil;
    pthread_mutex_lock(&_lock);
    result = [self _framePropertiesAtIndex:index];
    NSLog(@"%s--%@\n",__FUNCTION__,result);
    pthread_mutex_unlock(&_lock);
    return result;
}

- (NSDictionary *)imageProperties {
    NSDictionary *result = nil;
    pthread_mutex_lock(&_lock);
    result = [self _imageProperties];
    NSLog(@"%s--%@\n",__FUNCTION__,result);
    pthread_mutex_unlock(&_lock);
    return result;
}

#pragma mark    Private-Method(wrap)
- (BOOL)_updateData:(NSData *)data final:(BOOL)final {
    if (_finalized) return NO;
    if (data.length < _data.length) return NO;
    _finalized = final;
    _data = data;
    
    MMImageType type = MMImageDetectType((__bridge CFDataRef)data);
    if (_sourceTypeDetected) {
        if (_type != type) {
            return NO;
        } else {
            [self _updateSource];
        }
    } else {
        if (_data.length > 16) {
            _type = type;
            _sourceTypeDetected = YES;
            [self _updateSource];
        }
    }
    return YES;
}

- (void)_updateSource {
    switch (_type) {
        case MMImageTypeWebP: {
            [self _updateSourceWebP];
        }    break;
        case MMImageTypePNG: {
            [self _updateSourceAPNG];
        } break;
        default: {
            [self _updateSourceImageIO];
        } break;
    }
}

- (void)_updateSourceWebP {
    
}

- (void)_updateSourceAPNG {
    
}

- (void)_updateSourceImageIO{
    
}



- (MMImageFrame *)_frameAtIndex:(NSUInteger)index decodeForDisplay:(BOOL)decodeForDisplay {
    /**
     -[YYImageDecoder _frameAtIndex:decodeForDisplay:] at /Users/lixiaodong/Desktop/Github/YYKit/YYKit/Image/YYImageCoder.m:1628
     -[YYImageDecoder frameAtIndex:decodeForDisplay:] at /Users/lixiaodong/Desktop/Github/YYKit/YYKit/Image/YYImageCoder.m:1567
     -[YYImage initWithData:scale:] at /Users/lixiaodong/Desktop/Github/YYKit/YYKit/Image/YYImage.m:79
     -[YYImageCache imageFromData:] at /Users/lixiaodong/Desktop/Github/YYKit/YYKit/Image/YYImageCache.m:68
     -[YYImageCache getImageForKey:withType:] at /Users/lixiaodong/Desktop/Github/YYKit/YYKit/Image/YYImageCache.m:202
     -[YYWebImageOperation _startOperation]_block_invoke at /Users/lixiaodong/Desktop/Github/YYKit/YYKit/Image/YYWebImageOperation.m:266
     
     对于图片过大导致内存暴涨的问题这里是调用栈，在SDWebImage中是通过【SDWebImageCache sharedCache】.shouldDecompressImages 来控制是否解压图片
     但是在YY中的YYImageCache中的 decodeForDisplay，我猜想作者是想通过这个属性来控制，可是在具体的实现中具体的解压代码
     `MMCGImageCreateDecodedCopy()` 参数都是直接使用的YES
     */
    
    
    if (index >= _frames.count) return 0;
    MMImageFrame *result = [(_MMImageDecoderFrame *)_frames[index] copy];
    BOOL decoded = NO;
    BOOL extendToCanvas = NO;
    
    if (_type != MMImageTypeICO && decodeForDisplay) extendToCanvas = YES;
    
    if (!_needBlend) {
        CGImageRef imageRef = [self _newUnblendedImageAtIndex:index extendedToCanvas:extendToCanvas decoded:&decodeForDisplay];
        if (!imageRef) return nil;
        if (decodeForDisplay && !decoded) {
            CGImageRef imageRefDecoded = MMCGImageCreateDecodedCopy(imageRef, decodeForDisplay);
            if (imageRefDecoded) {
                CFRelease(imageRef);
                imageRef = imageRefDecoded;
                decoded = YES;
            }
        }
        UIImage *image = [UIImage imageWithCGImage:imageRef scale:_scale orientation:_orientation];
        CFRelease(imageRef);
        if (!image) return nil;
        image.isDecodedForDisplay = decoded;
        result.image = image;
        return result;
    }
    
    if (![self _createBlendContextIfNeeded]) return nil;
    
    return result;
}

- (NSDictionary *)_framePropertiesAtIndex:(NSUInteger)index {
    if (index >= _frames.count) return nil;
    if (!_source) return nil;
    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(_source, index, NULL);
    if (!properties) return nil;
    return CFBridgingRelease(properties);
}

- (NSDictionary *)_imageProperties {
    if (!_source) return nil;
    CFDictionaryRef properties = CGImageSourceCopyProperties(_source, NULL);
    if (!properties) return nil;
    return CFBridgingRelease(properties);
}

- (CGImageRef)_newUnblendedImageAtIndex:(NSUInteger)index extendedToCanvas:(BOOL)extendToCanvas decoded:(BOOL *)decoded CF_RETURNS_RETAINED {
    if (!_finalized && index > 0) return NULL;
    if (_frames.count <= index) return NULL;
    _MMImageDecoderFrame *frame = _frames[index];
    
    if (_source) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_source, index, (CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
        if (imageRef && extendToCanvas) {
            size_t width = CGImageGetWidth(imageRef);
            size_t height = CGImageGetHeight(imageRef);
            if (width == _width && height == _height) {
                CGImageRef imageRefExtended = MMCGImageCreateDecodedCopy(imageRef, YES);
                if (imageRefExtended) {
                    CFRelease(imageRef);
                    imageRef = imageRefExtended;
                    if (decoded) *decoded = YES;
                }
            } else {
                CGContextRef context = CGBitmapContextCreate(NULL, _width, _height, 8, 0, MMCGColorSpaceGetDeviceRGB(), kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
                if (context) {
                    CGContextDrawImage(context, CGRectMake(0, _height - height, width, height), imageRef);
                    CGImageRef imageRefExtended = CGBitmapContextCreateImage(context);
                    CFRelease(context);
                    if (imageRefExtended) {
                        CFRelease(imageRefExtended);
                        imageRef = imageRefExtended;
                        if (decoded) *decoded = YES;
                    }
                }
            }
        }
        return imageRef;
    }
    /**
     ImageIO 对外开放的对象有 CGImageResourceRef、CGImageDestinationRef、不对外开放的有CGImageMetadataRef
     
     CoreGraphics 中经常与ImageIO打交道的对象有 CGImageRef、CGDataProvider
     
     UIImage的三种初始化类方法
     + (nullable UIImage *)imageNamed:(NSString *)name;
     + (nullable UIImage *)imageWithContentsOfFile:(NSString *)path;
     + (nullable UIImage *)imageWithData:(NSData *)data;
     
     NSString *resourceImage = [[NSBundle mainBundle] pathForResource:@"xx.png" ofType:@""];
     NSData *imageData = [NSData dataWithContentsOfFile:resourceImage];
     CFDataRef dataRef = (__bridge CFDataRef)imageData;
     
     CGImageSourceRef sourceRef = CGImageSourceCreateWithData(dataRef, NULL);
     CGImageRef cgImage = CGImageSourceCreateImageAtIndex(sourceRef, 0, NULL);
     
     CGDataProviderRef providerRef = CGDataProviderCreateWithCFData(dataRef);
     CGImageSourceRef providerSourceRef = CGImageSourceCreateWithDataProvider(providerRef, NULL);
     
     */
    
    
    
    
    if (_apngSource) {
        uint32_t size = 0;
        uint8_t *bytes = mm_png_copy_frame_data_at_index(_data.bytes, _apngSource, (uint32_t)index, &size);
        if (!bytes) return NULL;
        CGDataProviderRef provider = CGDataProviderCreateWithData(bytes, bytes, size, MMCGDataProviderReleaseDataCallback);
        if (!provider) {
            free(bytes);
            return NULL;
        }
        bytes = NULL;
        
        CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
        if (!source) {
            CFRelease(provider);
            return NULL;
        }
        CFRelease(provider);
        
        if (CGImageSourceGetCount(source) < 1) {
            CFRelease(source);
            return NULL;
        }
        
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, (CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
        CFRelease(source);
        if (!imageRef) return NULL;
        if (extendToCanvas) {
            CGContextRef context = CGBitmapContextCreate(NULL, _width, _height, 8, 0, MMCGColorSpaceGetDeviceRGB(), kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
            if (context) {
                CGContextDrawImage(context, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), imageRef);
                CFRelease(imageRef);
                imageRef = CGBitmapContextCreateImage(context);
                CFRelease(context);
                if (decoded) *decoded = YES;
            }
        }
        return imageRef;
    }
    
#if MMIMAGE_WEBP_ENABLED
    if (_webpSource) {
        WebPIterator iter;
        if (!WebPDemuxGetFrame(_webpSource, (int)(index + 1), &iter)) return NULL;
        
        int frameWidth = iter.width;
        int frameHeight = iter.height;
        if (frameWidth < 1 || frameHeight < 1) return NULL;
        
        int width = extendToCanvas ? (int)_width : frameWidth;
        int height = extendToCanvas ? (int)_height : frameHeight;
        if (width > _width || height > _height) return NULL;
        
        const uint8_t *payload = iter.fragment.bytes;
        size_t payloadSize = iter.fragment.size;
        
        WebPDecoderConfig config;
        if (!WebPInitDecoderConfig(&config)) {
            WebPDemuxReleaseIterator(&iter);
            return NULL;
        }
        
        if (WebPGetFeatures(payload, payloadSize, &config.input) != VP8_STATUS_OK) {
            WebPDemuxReleaseIterator(&iter);
            return NULL;
        }
        
        size_t bitsPerComponent = 8;
        size_t bitsPerPixel = 32;
        size_t bytePerRow = MMImageByteAlign(bitsPerPixel / 8 * width, 32); //每行的的字节数
        size_t length = bytePerRow * height;
        CGBitmapInfo bitMapInfo = kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst;//bgrA
        
        void *pixels = calloc(1, length);
        if (!pixels) {
            WebPDemuxReleaseIterator(&iter);
            return NULL;
        }
        
        config.output.colorspace = MODE_bgrA;
        config.output.is_external_memory = 1;
        config.output.u.RGBA.rgba = pixels;
        config.output.u.RGBA.stride = (int)bytePerRow;
        config.output.u.RGBA.size = length;
        VP8StatusCode result = WebPDecode(payload, payloadSize, &config); //decode
        if ((result != VP8_STATUS_OK) && (result != VP8_STATUS_NOT_ENOUGH_DATA)) {
            WebPDemuxReleaseIterator(&iter);
            return NULL;
        }
        WebPDemuxReleaseIterator(&iter);
        
        //<Accelerate/vImage.h>
        if (extendToCanvas && (iter.x_offset != 0 || iter.y_offset != 0)) {
            void *tmp = calloc(1, length);
            if (tmp) {
                vImage_Buffer src = {pixels, height, width, bytePerRow};
                vImage_Buffer dest = {tmp, height, width, bytePerRow};
                vImage_CGAffineTransform tranform = {1, 0, 0, 1, iter.x_offset, -iter.y_offset};
                uint8_t backColor[4] = {0};
                vImage_Error error = vImageAffineWarpCG_ARGB8888(&src, &dest, NULL, &tranform, backColor, kvImageBackgroundColorFill);
                if (error == kvImageNoError) {
                    memcpy(pixels, tmp, length); //usr/include/secure
                }
                free(tmp);
            }
        }
        CGDataProviderRef provider = CGDataProviderCreateWithData(pixels, pixels, length, MMCGDataProviderReleaseDataCallback);
        if (!provider) {
            free(pixels);
            return NULL;
        }
        pixels = NULL;
        
        CGImageRef image = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytePerRow, MMCGColorSpaceGetDeviceRGB(), bitMapInfo, provider, NULL, false, kCGRenderingIntentDefault);
        CFRelease(provider);
        if (decoded) *decoded = YES;
        return image;
    }
#endif
    return NULL;
    
}

- (BOOL)_createBlendContextIfNeeded {
    if (!_blendCanvas) {
        _blendFrameIndex = NSNotFound;
        _blendCanvas = CGBitmapContextCreate(NULL, _width, _height, 8, 0, MMCGColorSpaceGetDeviceRGB(), kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
    }
    BOOL suc = _blendCanvas != NULL;
    return suc;
}

- (void)_blendImaegWithFrame:(_MMImageDecoderFrame *)frame {    //根据frame合成图片
    if (frame.dispose == MMImageDisposePrevious) {
        
    } else if (frame.dispose == MMImageDisposeBackground) {
        CGContextClearRect(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height));
    } else {
        /**
         CGContextClearRect()
         获取CGImageRef
         调用CGContextDrawImage()
         再CFRelease()
         */
        
        if (frame.blend == MMImageBlendOver) {
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendedToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
        } else {
            CGContextClearRect(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height));
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendedToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
        }
    }
}

- (CGImageRef)_newBlendedImageWithFrame:(_MMImageDecoderFrame *)frame CF_RETURNS_RETAINED {
    CGImageRef imageRef = NULL;
    /*
     dispose 的不同取决了 CGContextClearRect() 是否调用
     blend 的不同取决了 CGBitmapContextCreateImage() 是否调用
     */
    if (frame.dispose == MMImageDisposePrevious) { //如果frame有提前部署加载
        if (frame.blend == MMImageBlendOver) {
            CGImageRef previousImage = CGBitmapContextCreateImage(_blendCanvas);
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendedToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
            imageRef = CGBitmapContextCreateImage(_blendCanvas);
            CGContextClearRect(_blendCanvas, CGRectMake(0, 0, _width, _height));//清除以前合成的
            if (previousImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(0, 0, _width, _height), previousImage);
                CFRelease(previousImage);
            }
        } else {
            CGImageRef previousImage = CGBitmapContextCreateImage(_blendCanvas);
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendedToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
            imageRef = CGBitmapContextCreateImage(_blendCanvas);
            CGContextClearRect(_blendCanvas, CGRectMake(0, 0, _width, _height));//清除以前合成的
            if (previousImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(0, 0, _width, _height), previousImage);
                CFRelease(previousImage);
            }
        }
    } else if (frame.dispose == MMImageDisposeBackground) {
        if (frame.blend == MMImageBlendOver) {
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendedToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
            imageRef = CGBitmapContextCreateImage(_blendCanvas);
            CGContextClearRect(_blendCanvas, CGRectMake(0, 0, _width, _height));//清除以前合成的
        } else {
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendedToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
            imageRef = CGBitmapContextCreateImage(_blendCanvas);
            CGContextClearRect(_blendCanvas, CGRectMake(0, 0, _width, _height));//清除以前合成的
        }
    } else {
        if (frame.blend == MMImageBlendOver) {
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendedToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
            imageRef = CGBitmapContextCreateImage(_blendCanvas);
        } else {
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendedToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
            imageRef = CGBitmapContextCreateImage(_blendCanvas);
        }
    }
    return imageRef;
}


@end


@implementation MMImageEncoder {
    NSMutableArray *_images;
    NSMutableArray *_durations;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"MMImagEncoder init error" reason:@"MMImageEncoder must be initialized with a Type , Use 'initWithType:' instead" userInfo:nil];
    return [self initWithType:MMImageTypeUnknown];
}

- (instancetype)initWithType:(MMImageType)type {
    if (type == MMImageTypeUnknown || type >= MMImageTypeOther) {
        NSLog(@"[%s : %d] Unsupport image type:%d",__FUNCTION__,__LINE__,(int)type);
        return nil;
    }
#if !MMIMAGE_WEBP_ENABLED
    if (type == MMImageTypeWebP) {
        NSLog(@"[%s: %d] WebP is not available, check the documention to see how to install WebP component: ",__FUNCTION__,__LINE__);
        return nil;
    }
#endif
    
    self = [super init];
    if (!self) return nil;
    _type = type;
    _images = [NSMutableArray array];
    _durations = @[].mutableCopy;
    
    switch (type) {
        case MMImageTypeJPEG:
        case MMImageTypeJPEG2000: {
            _quality = 0.9;
        }break;
        case MMImageTypeTIFF:
        case MMImageTypeBMP:
        case MMImageTypeGIF:
        case MMImageTypeICO:
        case MMImageTypeICNS:
        case MMImageTypePNG: {
            _quality = 1;
            _lossless = YES;
        } break;
        case MMImageTypeWebP: {
            _quality = 0.8;
        } break;
        default: break;
    }
    return self;
}

- (void)setQuality:(CGFloat)quality {
    _quality = quality < 0 ? 0 : quality > 1 ? 1 : quality;
}

- (void)addImage:(UIImage *)image duration:(NSTimeInterval)duration {
    if (!image.CGImage) return;
    duration = duration < 0 ? 0 : duration;
    [_images addObject:image];
    [_durations addObject:@(duration)];
}

- (void)addImageWithData:(NSData *)data duration:(NSTimeInterval)duration {
    if (data.length == 0) return;
    duration = duration < 0 ? 0 : duration;
    //[_images addObject:image];
    [_durations addObject:@(duration)];
}

- (void)addImageWithFile:(NSString *)path duration:(NSTimeInterval)duration {
    if (path.length == 0) return;
    duration = duration < 0 ? 0 : duration;
    NSURL *url = [NSURL URLWithString:path];
    [_images addObject:url];
    [_durations addObject:@(duration)];
}

- (BOOL)_imageIOAvaliable {
    switch (_type) {
        case MMImageTypeJPEG:
        case MMImageTypeJPEG2000:
        case MMImageTypeTIFF:
        case MMImageTypeBMP:
        case MMImageTypeICO:
        case MMImageTypeICNS:
        case MMImageTypeGIF: {
            return _images.count > 0;
        } break;
        case MMImageTypePNG: {
            return _images.count == 1;
        } break;
        case MMImageTypeWebP: {
            return NO;
        } break;
        default: return NO;
    }
}

- (CGImageDestinationRef)_newImageDestination:(id)dest imageCount:(NSUInteger)count CF_RETURNS_RETAINED {
    if (!dest) return nil;
    CGImageDestinationRef destination = NULL;
    if ([dest isKindOfClass:[NSString  class]]) {
        NSURL *url = [NSURL URLWithString:dest];
        if (url) destination = CGImageDestinationCreateWithURL((CFURLRef)url, MMImageTypeToUTType(_type), count, NULL);
    } else if ([dest isKindOfClass:[NSMutableData class]]) {
        destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest, MMImageTypeToUTType(_type), count, NULL);
    }
    return destination;
}

- (void)_encodeImageWithDestination:(CGImageDestinationRef)destination imageCount:(NSUInteger)count {
    if (_type == MMImageTypeGIF) {
        NSDictionary *gifProperty = @{(__bridge id)kCGImagePropertyGIFDictionary : @{(__bridge id)kCGImagePropertyGIFLoopCount : @(_loopCount)}};
        CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifProperty);
    }
    
    for (int i = 0; i < count; i++) {
        @autoreleasepool {
            id imageSrc = _images[i];
            NSDictionary *frameProperty = NULL;
            if (_type == MMImageTypeGIF && count > 1) {
                frameProperty = @{(NSString *)kCGImagePropertyGIFDictionary : @{(NSString *)kCGImagePropertyGIFDelayTime : _durations[i]}};
            } else {
                frameProperty = @{(id)kCGImageDestinationLossyCompressionQuality : @(_quality)};
            }
            
            if ([imageSrc isKindOfClass:[UIImage class]]) {
                UIImage *image = imageSrc;
                if (image.imageOrientation != UIImageOrientationUp && image.CGImage) {
                    CGBitmapInfo info = CGImageGetBitmapInfo(image.CGImage) | CGImageGetAlphaInfo(image.CGImage);
                    CGImageRef rotated = MMCGImageCreateCopyWithOrientation(image.CGImage, image.imageOrientation, info);
                    if (rotated) {
                        image = [UIImage imageWithCGImage:rotated];
                        CFRelease(rotated);
                    }
                }
                if (image.CGImage) CGImageDestinationAddImage(destination, ((UIImage *)imageSrc).CGImage, (CFDictionaryRef)frameProperty);
            } else if ([imageSrc isKindOfClass:[NSURL class]]) {
                CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)imageSrc, NULL);
                if (source) {
                    CGImageDestinationAddImageFromSource(destination, source, 0, (CFDictionaryRef)frameProperty);
                    CFRelease(source);
                }
            } else if ([imageSrc isKindOfClass:[NSData class]]) {
                CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)imageSrc, NULL);
                if (source) {
                    CGImageDestinationAddImageFromSource(destination, source, 0, (CFDictionaryRef)frameProperty);
                    CFRelease(source);
                }
            }
        }
    }
}

- (CGImageRef)_newCGImageFromIndex:(NSUInteger)index decoded:(BOOL)decoded CF_RETURNS_RETAINED {
    UIImage *image = nil;
    id imageSrc = _images[index];
    if ([imageSrc isKindOfClass:[UIImage class]]) {
        image = imageSrc;
    } else if ([imageSrc isKindOfClass:[NSURL class]]) {
        image = [UIImage imageWithContentsOfFile:((NSURL *)imageSrc).absoluteString];
    } else if ([imageSrc isKindOfClass:[NSData class]]) {
        image = [UIImage imageWithData:imageSrc];
    }
    
    if (!image) return NULL;
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) return NULL;
    if (image.imageOrientation != UIImageOrientationUp) {
        return MMCGImageCreateCopyWithOrientation(imageRef, image.imageOrientation, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst); //CGBitmapInfo 是NS_OPTION
    }
    if (decoded) return MMCGImageCreateDecodedCopy(imageRef, YES);
    return (CGImageRef)CFRetain(imageRef);
}

- (NSData *)_encodeWithImageIO {
    NSMutableData *data = [NSMutableData new];
    NSUInteger count = _type == MMImageTypeGIF ? _images.count : 1; //主要用于判断是不是GIF 否则只有一张
    CGImageDestinationRef destination = [self _newImageDestination:destination imageCount:count];
    BOOL suc = NO;
    if (destination) {
        [self _encodeImageWithDestination:destination imageCount:count];
        suc = CGImageDestinationFinalize(destination);
        CFRelease(destination);
    }
    if (suc && data.length > 0) {
        return data;
    } else {
        return nil;
    }
}

- (BOOL)_encodeWithImageIO:(NSString *)path {
    NSUInteger count = _type == MMImageTypeGIF ? _images.count : 1;
    CGImageDestinationRef destination = [self _newImageDestination:path imageCount:count];
    BOOL suc = NO;
    if (destination) {
        [self _encodeImageWithDestination:destination imageCount:count];
        suc = CGImageDestinationFinalize(destination);
        CFRelease(destination);
    }
    return suc;
}

- (NSData *)_encodeAPNG {
    NSMutableArray *pngDatas = @[].mutableCopy;
    NSMutableArray *pngSize = @[].mutableCopy;
    NSUInteger canvasWidth = 0, canvasHeight =0;
    for (int i = 0; i < _images.count; i++) {
        CGImageRef decoded = [self _newCGImageFromIndex:i decoded:YES];
        if (!decoded) return nil;
        CGSize size = CGSizeMake(CGImageGetWidth(decoded), CGImageGetHeight(decoded));
        [pngSize addObject:[NSValue valueWithCGSize:size]];
        if (canvasWidth < size.width) canvasWidth = size.width;
        if (canvasHeight < size.height) canvasHeight = size.height;
        CFDataRef frameData = MMCGImageCreateEncodedData(decoded, MMImageTypePNG, 1);
        CFRelease(decoded);
        if (!frameData) return nil;
        [pngDatas addObject:(__bridge id)(frameData))];
        CFRelease(frameData);
        if (size.width < 1 || size.height < 1) return nil;
    }
    CGSize firstFrameSize = [(NSValue *)[pngSize firstObject] CGSizeValue];
    if (firstFrameSize.width < canvasWidth ||firstFrameSize.height < canvasHeight) {
        CGImageRef decoded = [self _newCGImageFromIndex:0 decoded:YES];
        if (!decoded) return nil;
        CGContextRef context = CGBitmapContextCreate(NULL, canvasWidth, canvasHeight, 8, 0, MMCGColorSpaceGetDeviceRGB(), kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
        if (!context) {
            CFRelease(decoded);
            return nil;
        }
        CGContextDrawImage(context, CGRectMake(0, canvasHeight - firstFrameSize.height, firstFrameSize.width, firstFrameSize.height), decoded);
        CFRelease(decoded);
        CGImageRef extendedImage = CGBitmapContextCreateImage(context);
        CFRelease(context);
        if (!extendedImage) return nil;
        CFDateRef frameData = MMCGImageCreateEncodedData(extendedImage, MMImageTypePNG, 1);
        if (!frameData) {
            CFRelease(extendedImage);
            return nil;
        }
        pngDatas[0] = (__bridge id)(frameData);
        CFRelease(frameData);
    }
    
    NSData *firstFrameData = pngDatas[0];
    mm_png_info *info = mm_png_info_create(firstFrameData.bytes, (uint32_t)firstFrameData.length);
    if (!info) return nil;
    NSMutableData *result = [NSMutableData new];
    BOOL insertBefore = NO, inserAfter = NO;
    uint32_t apngSequenceIndex = 0;
    
    uint32_t png_header[2];
    png_header[0] = MM_FOUR_CC(0x89, 0x50, 0x4E, 0x47);
    png_header[1] = MM_FOUR_CC(0x0D, 0x0A, 0x1A, 0x0A);
    
    [result appendBytes:png_header length:8];
    
    for (int i = 0; i < info->chunks; i++) {
        mm_png_chunk_info *chunk = info->chunks + i;
        
        if (!insertBefore && chunk->fourcc == MM_FOUR_CC('I', 'D', 'A', 'T')) {
            insertBefore = YES;
            /*uint8_t uint16_t uint32_t 都是typedef 给类型起的别名，typedef对于代码的维护会有很好的作用，比如C 中没有bool，于是在一个软件中，有的程序员用int 有的程序员用short，就会比较混乱，最好的就是用一个typedef 来定义，
             
             uint8_t        1字节
             uint16_t       2字节
             uint32_t       4字节
             uint64_t       8字节
             */
            uint32_t acTL[5] = {0};
            uint32_t acTL[5] = {0};
            acTL[0] = mm_swap_endian_uint32(8); //length
            acTL[1] = MM_FOUR_CC('a', 'c', 'T', 'L'); // fourcc
            acTL[2] = mm_swap_endian_uint32((uint32_t)pngDatas.count); // num frames
            acTL[3] = mm_swap_endian_uint32((uint32_t)_loopCount); // num plays
            acTL[4] = mm_swap_endian_uint32((uint32_t)crc32(0, (const Bytef *)(acTL + 1), 12)); //crc32
            [result appendBytes:acTL length:20];
            
            // insert fcTL (first frame control)
            yy_png_chunk_fcTL chunk_fcTL = {0};
            chunk_fcTL.sequence_number = apngSequenceIndex;
            chunk_fcTL.width = (uint32_t)firstFrameSize.width;
            chunk_fcTL.height = (uint32_t)firstFrameSize.height;
            yy_png_delay_to_fraction([(NSNumber *)_durations[0] doubleValue], &chunk_fcTL.delay_num, &chunk_fcTL.delay_den);
            chunk_fcTL.delay_num = chunk_fcTL.delay_num;
            chunk_fcTL.delay_den = chunk_fcTL.delay_den;
            chunk_fcTL.dispose_op = YY_PNG_DISPOSE_OP_BACKGROUND;
            chunk_fcTL.blend_op = YY_PNG_BLEND_OP_SOURCE;
            
            uint8_t fcTL[38] = {0};
            *((uint32_t *)fcTL) = mm_swap_endian_uint32(26); //length
            *((uint32_t *)(fcTL + 4)) = MM_FOUR_CC('f', 'c', 'T', 'L'); // fourcc
            yy_png_chunk_fcTL_write(&chunk_fcTL, fcTL + 8);
            *((uint32_t *)(fcTL + 34)) = mm_swap_endian_uint32((uint32_t)crc32(0, (const Bytef *)(fcTL + 4), 30));
            [result appendBytes:fcTL length:38];
            
            apngSequenceIndex++;
        }
        
        if (!insertAfter && insertBefore && chunk->fourcc != MM_FOUR_CC('I', 'D', 'A', 'T')) {
            insertAfter = YES;
            // insert fcTL and fdAT (APNG frame control and data)
            
            for (int i = 1; i < pngDatas.count; i++) {
                NSData *frameData = pngDatas[i];
                yy_png_info *frame = yy_png_info_create(frameData.bytes, (uint32_t)frameData.length);
                if (!frame) {
                    mm_png_info_release(info);
                    return nil;
                }
                
                // insert fcTL (first frame control)
                yy_png_chunk_fcTL chunk_fcTL = {0};
                chunk_fcTL.sequence_number = apngSequenceIndex;
                chunk_fcTL.width = frame->header.width;
                chunk_fcTL.height = frame->header.height;
                yy_png_delay_to_fraction([(NSNumber *)_durations[i] doubleValue], &chunk_fcTL.delay_num, &chunk_fcTL.delay_den);
                chunk_fcTL.delay_num = chunk_fcTL.delay_num;
                chunk_fcTL.delay_den = chunk_fcTL.delay_den;
                chunk_fcTL.dispose_op = YY_PNG_DISPOSE_OP_BACKGROUND;
                chunk_fcTL.blend_op = YY_PNG_BLEND_OP_SOURCE;
                
                uint8_t fcTL[38] = {0};
                *((uint32_t *)fcTL) = mm_swap_endian_uint32(26); //length
                *((uint32_t *)(fcTL + 4)) = MM_FOUR_CC('f', 'c', 'T', 'L'); // fourcc
                yy_png_chunk_fcTL_write(&chunk_fcTL, fcTL + 8);
                *((uint32_t *)(fcTL + 34)) = mm_swap_endian_uint32((uint32_t)crc32(0, (const Bytef *)(fcTL + 4), 30));
                [result appendBytes:fcTL length:38];
                
                apngSequenceIndex++;
                
                // insert fdAT (frame data)
                for (int d = 0; d < frame->chunk_num; d++) {
                    yy_png_chunk_info *dchunk = frame->chunks + d;
                    if (dchunk->fourcc == MM_FOUR_CC('I', 'D', 'A', 'T')) {
                        uint32_t length = mm_swap_endian_uint32(dchunk->length + 4);
                        [result appendBytes:&length length:4]; //length
                        uint32_t fourcc = MM_FOUR_CC('f', 'd', 'A', 'T');
                        [result appendBytes:&fourcc length:4]; //fourcc
                        uint32_t sq = mm_swap_endian_uint32(apngSequenceIndex);
                        [result appendBytes:&sq length:4]; //data (sq)
                        [result appendBytes:(((uint8_t *)frameData.bytes) + dchunk->offset + 8) length:dchunk->length]; //data
                        uint8_t *bytes = ((uint8_t *)result.bytes) + result.length - dchunk->length - 8;
                        uint32_t crc = mm_swap_endian_uint32((uint32_t)crc32(0, bytes, dchunk->length + 8));
                        [result appendBytes:&crc length:4]; //crc
                        
                        apngSequenceIndex++;
                    }
                }
                mm_png_info_release(frame);
            }
        }
        
        [result appendBytes:((uint8_t *)firstFrameData.bytes) + chunk->offset length:chunk->length + 12];
    }
    mm_png_info_release(info);
    return result;
}

- (NSData *)_encodeWebP {
#if YYIMAGE_WEBP_ENABLED
    // encode webp
    NSMutableArray *webpDatas = [NSMutableArray new];
    for (NSUInteger i = 0; i < _images.count; i++) {
        CGImageRef image = [self _newCGImageFromIndex:i decoded:NO];
        if (!image) return nil;
        CFDataRef frameData = YYCGImageCreateEncodedWebPData(image, _lossless, _quality, 4, YYImagePresetDefault);
        CFRelease(image);
        if (!frameData) return nil;
        [webpDatas addObject:(__bridge id)frameData];
        CFRelease(frameData);
    }
    if (webpDatas.count == 1) {
        return webpDatas.firstObject;
    } else {
        // multi-frame webp
        WebPMux *mux = WebPMuxNew();
        if (!mux) return nil;
        for (NSUInteger i = 0; i < _images.count; i++) {
            NSData *data = webpDatas[i];
            NSNumber *duration = _durations[i];
            WebPMuxFrameInfo frame = {0};
            frame.bitstream.bytes = data.bytes;
            frame.bitstream.size = data.length;
            frame.duration = (int)(duration.floatValue * 1000.0);
            frame.id = WEBP_CHUNK_ANMF;
            frame.dispose_method = WEBP_MUX_DISPOSE_BACKGROUND;
            frame.blend_method = WEBP_MUX_NO_BLEND;
            if (WebPMuxPushFrame(mux, &frame, 0) != WEBP_MUX_OK) {
                WebPMuxDelete(mux);
                return nil;
            }
        }
        
        WebPMuxAnimParams params = {(uint32_t)0, (int)_loopCount};
        if (WebPMuxSetAnimationParams(mux, &params) != WEBP_MUX_OK) {
            WebPMuxDelete(mux);
            return nil;
        }
        
        WebPData output_data;
        WebPMuxError error = WebPMuxAssemble(mux, &output_data);
        WebPMuxDelete(mux);
        if (error != WEBP_MUX_OK) {
            return nil;
        }
        NSData *result = [NSData dataWithBytes:output_data.bytes length:output_data.size];
        WebPDataClear(&output_data);
        return result.length ? result : nil;
    }
#else
    return nil;
#endif
}

- (NSData *)encode {
    if (_images.count == 0) return nil;
    if ([self _imageIOAvaliable]) return [self _encodeWithImageIO];
    if (_type == MMImageTypePNG) return [self _encodeAPNG];
    if (_type == MMImageTypeWebP) return [self _encodeWebP];
    return nil;
}

- (BOOL)encodeToFile:(NSString *)path {
    if (_images.count == 0 || path.length == 0) return NO;
    
    if ([self _imageIOAvaliable]) return [self _encodeWithImageIO:path];
    NSData *data = [self encode];
    if (!data) return NO;
    return [data writeToFile:path atomically:YES];
}

+ (NSData *)encodeImage:(UIImage *)image type:(MMImageType)type quality:(CGFloat)quality {
    MMImageEncoder *encoder = [[MMImageEncoder alloc] initWithType:type];
    encoder.quality = quality;
    [encoder addImage:image duration:0];
    return [encoder encode];
}

+ (NSData *)encodeImageWithDecoder:(MMImageDecoder *)decoder type:(MMImageType)type quality:(CGFloat)quality {
    if (!decoder || decoder.frameCount == 0) return nil;
    MMImageEncoder *encoder = [[MMImageEncoder alloc] initWithType:type];
    encoder.quality = quality;
    for (int i = 0; i < decoder.frameCount; i++) {
#warning decodeForDisplay
        UIImage *frame = [decoder frameAtIndex:i decodeForDisplay:YES].image;
        [encoder addImageWithData:UIImagePNGRepresentation(frame) duration:[decoder frameDurationAtIndex:i]];
    }
    return encoder.encode;
}

@end

@implementation UIImage (MMImageCoder)

- (instancetype)imageByDecoded {
    if (self.isDecodedForDisplay) return self;
    CGImageRef imageRef = self.CGImage;
    CGImageRef newImageRef = MMCGImageCreateDecodedCopy(imageRef, YES);
    if (!newImageRef) return self;
    UIImage *newImage = [[self.class alloc] initWithCGImage:newImageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(newImageRef);
    if (!newImage) newImage = self;
    newImage.isDecodedForDisplay = YES;
    return newImage;
}


- (BOOL)isDecodedForDisplay {
    if (self.images.count > 1) return YES;
    NSNumber *num = objc_getAssociatedObject(self, @selector(isDecodedForDisplay));
    return [num boolValue];
}

- (void)setIsDecodedForDisplay:(BOOL)isDecodedForDisplay {
    objc_setAssociatedObject(self, @selector(isDecodedForDisplay), @(isDecodedForDisplay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)saveToAlbumWithCompletionBlock:(void (^)(NSURL * _Nullable, NSError * _Nullable))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [self _imageDataRepresentationForSystem:YES];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            if (!completionBlock) return ;
            if (pthread_main_np()) {
                completionBlock(assetURL, error);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(assetURL, error);
                })
            }
        }]
    })
}


- (NSData *)imageDataRepresentation {
    return [self _imageDataRepresentationForSystem:NO];
}

- (void)_imageDataRepresentationForSystem:(BOOL)forSystem {
    NSData *data = nil;
    if ([self isKindOfClass:[MMImage class]]) {
        MMImage *image = (id)self;
        if (image.animatedImageData) {
            if (forSystem) {
                if (image.animatedImageType == MMImageTypeGIF ||
                    image.animatedImageType == MMImageTypePNG) {
                    data = image.animatedImageData;
                }
            } else {
                data = image.animatedImageData;
            }
        }
    }
    if (!data) {
        CGImageRef imageRef = self.CGImage ? (CGImageRef)CFRetain(self.CGImage) : nil;
        if (imageRef) {
            CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
            CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
            BOOL hasAlpha = NO;
            if (alphaInfo == kCGImageAlphaPremultipliedFirst ||
                alphaInfo == kCGImageAlphaPremultipliedLast ||
                alphaInfo == kCGImageAlphaLast ||
                alphaInfo == kCGImageAlphaFirst) {
                hasAlpha = YES;
            }
            if (self.imageOrientation != UIImageOrientationUp) {
                CGImageRef rotated = MMCGImageCreateCopyWithOrientation(imageRef, self.imageOrientation, bitmapInfo | alphaInfo);
                if (rotated) {
                    CFRelease(imageRef);
                    imageRef = rotated;
                }
            }
            
            @autoreleasepool {
                UIImage *newImage = [UIImage imageWithCGImage:imageRef];
                if (newImage) {
                    if (hasAlpha) {
                        data = UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef]);
                    } else {
                        data = UIImageJPEGRepresentation([UIImage imageWithCGImage:imageRef], 0.9);
                    }
                }
            }
            CFRelease(imageRef);
        }
    }
    if (!data) {
        data = UIImagePNGRepresentation(self);
    }
    return data;
}



@end

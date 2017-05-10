////
////  MMKvStorage.m
////  PracticeKit
////
////  Created by 晓东 on 17/1/12.
////  Copyright © 2017年 Xiaodong. All rights reserved.
////
//
//#import "MMKVStorage.h"
//#import "UIApplication+MMAdd.h"
//#import <UIKit/UIKit.h>
//#import <time.h>
//
//#if __has_include(<sqlite3.h>)
//#import <sqlite3.h>
//#else
//#import "sqlite3.h"
//#endif
//
//static const NSUInteger kMaxErroRetryCount = 8;
//static const NSTimeInterval kMinRetryTimeInterval = 2.0;
//static const int kPathLengthMax = PATH_MAX -64;
//static NSString *const kDBFileName = @"mainfest.sqlite";
//static NSString *const kDBShmFileName = @"mainfest.sqlite-shm";
//static NSString *const kDBWalFileName = @"mainfest.sqlite-wal";
//static NSString *const kDataDirectioryName = @"data";
//static NSString *const kTrashDirectoryName = @"trash";
//
//@implementation MMKVStorageItem
//
//@end
//
//@implementation MMKVStorage {
//    dispatch_queue_t _trashQueue;
//
//    NSString *_path;
//    NSString *_dbPath;
//    NSString *_dataPath;
//    NSString *_trashPath;
//
//    sqlite3 *_db;
//    CFMutableDictionaryRef _dbStmtCache;
//    NSTimeInterval _dbLastOpenErrorTime;
//    NSUInteger _dbOpenErrorCount;
//}
//
//- (BOOL)_dbOpen {
//    if (_db ) return YES;
//    int result = sqlite3_open(_dbPath.UTF8String, &_db);
//    if (result == SQLITE_OK) {
//        CFDictionaryKeyCallBacks keyCallbacks = kCFCopyStringDictionaryKeyCallBacks;
//        CFDictionaryValueCallBacks valueCallbacks = {0};
//        _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallbacks, &valueCallbacks);
//        _dbLastOpenErrorTime = 0;
//        _dbOpenErrorCount = 0;
//        return YES;
//    } else {
//        _db = NULL;
//        if (_dbStmtCache) CFRelease(_dbStmtCache);
//        _dbStmtCache = NULL;
//        _dbLastOpenErrorTime = CACurrentMediaTime();
//        _dbOpenErrorCount++;
//        if (_errorLogsEnabled) {
//            NSLog(@"%s line:%d sqlite open failed (%d).",__FUNCTION__, __LINE__, result);
//        }
//        return NO;
//    }
//}
//
//- (BOOL)_dbClose {
//    if (!_db) return YES;
//
//    int result = 0;
//    BOOL retry = NO;
//    BOOL stmtFinalized = NO;
//
//    if (_dbStmtCache) CFRelease(_dbStmtCache);
//    _dbStmtCache = NULL;
//
//    do {
//        retry = NO;
//        result = sqlite3_close(_db);
//        if (result == SQLITE_BUSY || result == SQLITE_LOCKED) {
//            if (!stmtFinalized) {
//                stmtFinalized = YES;
//                /*
//                 因为你可以把 sqlite3_stmt * 所表示的内容看成是 sql语句，但是实际上它不是我们所熟知的sql语句。它是一个已经把sql语句解析了的、用sqlite自己标记记录的内部数据结构。
//                 */
//                sqlite3_stmt *stmt;
//                while ((stmt = sqlite3_next_stmt(_db, nil)) != 0) {
//                    sqlite3_finalize(stmt);
//                    retry = YES;
//                }
//
//            }
//        } else if (result != SQLITE_OK) {
//            if (_errorLogsEnabled) {
//                /*
//                 人如其名 __FUNCTION__  就是函数名    数据类型char const*
//                 __LINE__      就是行号     数据类型是 int
//                 */
//                NSLog(@"%s line:%d sqlite close failed (%d).",__FUNCTION__, __LINE__, result);
//            }
//        }
//    } while (retry);
//    _db = NULL;
//    return YES;
//}
//
//- (BOOL)_dbCheck {
//    if (!_db) {
//        if (_dbOpenErrorCount < kMaxErroRetryCount && CACurrentMediaTime() - _dbLastOpenErrorTime > kMinRetryTimeInterval) {
//            return [self _dbOpen] && [self _dbInitialize];
//        } else {
//            return NO;
//        }
//    }
//    return YES;
//}
//
//- (BOOL)_dbInitialize {
//    NSString *sql = @"pragma journal_mode = wal; pragma synchronous = normal; create table if not exists mainfest (key text, filename text, size integer, inline_data blob, modification_time integer, last_access_time integer, extended_data blob, primary key(key)); create index if not exists last_access_time_idx on mainfest(last_access_time);";
//    return [self _dbExcute:sql];
//}
//
//- (void)_dbCheckPoint {
//    if (![self _dbCheck]) return;
//    sqlite3_wal_checkpoint(_db, NULL);
//}
//
//- (BOOL)_dbExcute:(NSString *)sql {
//    if (sql.length == 0) return NO;
//    if (![self _dbCheck]) return NO;
//
//    char *error = NULL;
//    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
//    if (error) {
//        if (_errorLogsEnabled) NSLog(@"%s line: %d sqlite exec error (%d) : %s",__FUNCTION__, __LINE__, result, error);
//        sqlite3_free(error);
//    }
//    return result == SQLITE_OK;
//}
//
//- (sqlite3_stmt *)_dbPrepareStmt:(NSString *)sql {
//    if (![self _dbCheck] || sql.length == 0 || !_dbStmtCache) return NULL;
//    sqlite3_stmt *stmt = (sqlite3_stmt *)CFDictionaryGetValue(_dbStmtCache, (__bridge const void *)(sql));
//    if (!stmt) {
//        int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
//        if (result != SQLITE_OK) {
//            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error:(%d) : %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
//            return NULL;
//        }
//        CFDictionarySetValue(_dbStmtCache, (__bridge const void *)(sql), stmt);
//    } else {
//        sqlite3_reset(stmt);
//    }
//    return stmt;
//}
//
//- (NSString *)_dbJoinedKeys:(NSArray *)keys {
//    NSMutableString *string = [NSMutableString new];
//    for (NSUInteger i = 0, max = keys.count; i < max; i++) {
//        [string appendString:@"?"];
//        if (i + 1 != max) {
//            [string appendString:@","];
//        }
//    }
//    return string;
//}
//
//- (void)_dbBindJoinedKeys:(NSArray *)keys stmt:(sqlite3_stmt *)stmt fromIndex:(int)index {
//
//}
//
//@end
//
//

#import "MMKVStorage.h"
#import "UIApplication+MMAdd.h" //在dealloc中用到
#import <time.h>

#if __has_include(<sqlite3.h>)
#import <sqlite3.h>
#else
#import "sqlite3.h"
#endif

@implementation MMKVStorageItem

@end


@interface MMKVStorage () {
    dispatch_queue_t _trashQueue;
    
    NSString *_path;
    NSString *_dbPath;
    NSString *_dataPath;
    NSString *_trashPath;
    
    sqlite3 *_db;
    CFMutableDictionaryRef _dbStmtCache;
    NSTimeInterval _dbLastOpenErrorTime;
    NSUInteger  _dbOpenErrorCount;
}

@end
@implementation MMKVStorage

#pragma mark    打开 db
- (BOOL)_dbOpen {
    if (_db) return YES;
    
    //打开sqlite 传入两个参数 char *  sqlite **
    /*
     SQLITE
     sqlite3 为一个结构，它指代了一个数据库连接，之后调用的大部分API函数都需要使用它作为其中一个参数，sqlite3_open的第一个参数为文件名字符串，以下两个函数都是成功返回SQLITE_OK，失败返回错误码，可以使用sqlite3_errmsg函数获得错误描述const char *sqlite3_erromsg(sqlite3 *)
     int sqlite3_open(const char *, sqlite3 **);
     int sqlite3_close(sqlite3 *);
     
     
     数据库操作-执行SQL语句
     int sqlite3_prepare(sqlite3 *, const char *, int, sqlite3_stmt **, const char **);
     int sqlite3_finalize(sqlite3_stmt *);
     int sqlite3_reset(sqlite3_stmt *);
     
     sqlite3_stmt   结构代指一条SQL语句，上述三个函数的功能就是创建，销毁和重置sqlite3_stmt结构，
     sqlite3_prepare函数的第二个参数为SQL语句字符串，第三个参数为字符串长度，如果传入的SQL语句字符串超出了一条SQL语句，则第五个参数返回SQL语句字符串中指向下一条SQL语句的char 指针
     SQL语句字符串可以带？号，它是SQL语句中的不确定部分，需要对它另外赋值
     
     
     int sqlite3_bind_text(sqlite3_stmt *, int, const char *, int, void(*)(void *))
     sqlite3_bind_* 系列函数有好多，这里我只对sqlite3_bind_text进行一下说明，其他的我暂时还没用到，
     sqlite3_bind_text的第二个参数为序号（从1开始），第三个参数为字符串值，第四个参数为字符串长度，第五个参数为一个函数指针，SQLITE3执行完操作后回调此函数，通常用于释放字符串占用的内存，
     statement准备好了，就是操作的执行了
     
     
     int sqlite3_step(sqlite3_stmt *);
     它的返回值有些特殊，返回SQLITE_BUSY表示暂时无法执行操作，SQLITE_DONE表示操作执行完毕，SQLITE_ROW表示执行完毕并且有返回，（执行select语句时）当返回值为SQLITE_ROW时，我们需要对查询结果进行处理，SQLITE3提供了sqlite3_column *系列函数
     
     
     const unsigned char * sqlite3_column_text(sqlite3_stmt *, int iCol);
     其中参数iCol为列的序号，从0开始，如果返回值有多行，则可以再次调用sqlite3_step函数，然后由sqlite3_column *函数取得返回值
     
     参考博客：blog.csdn.net/jun2ran/article/detail/6474543
     */
    
    int result = sqlite3_open(_dbPath.UTF8String, &_db);
    if (result == SQLITE_OK) {
        CFDictionaryKeyCallBacks keyCallBacks = kCFCopyStringDictionaryKeyCallBacks;
        CFDictionaryValueCallBacks valueCallBacks = {0};
        _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallBacks, &valueCallBacks);
        _dbLastOpenErrorTime = 0;
        _dbOpenErrorCount = 0;
        return YES;
    } else {
        _db = NULL;
        if (_dbStmtCache) CFRelease(_dbStmtCache);
        _dbStmtCache = NULL;
        _dbLastOpenErrorTime = CACurrentMediaTime();
        _dbOpenErrorCount++;
        if (_errorLogsEnabled) {
            NSLog(@"%s line：%d sqlite open failed (%d).",__FUNCTION__, __LINE__,result);
        }
        return NO;
    }
}

#pragma mark    关闭 db
- (BOOL)_dbClose {
    if (!_db) return YES;
    
    int result = 0;
    BOOL retry = NO;
    BOOL stmtFinalized = NO;
    
    if (_dbStmtCache) CFRelease(_dbStmtCache);
    _dbStmtCache = NULL;
    
    do {
        retry = NO;
        result = sqlite3_close(_db);
#warning stmt 需要了解
        /*
         sqlite3_stmt  sqlite3操作二进制数据需要用一个辅助的数据类型，sqlite3_stmt *，这个数据类型
         这个数据类型 记录了一个sql语句，为什么我把”sql语句“ 用双引号引起来呢，你可以把sqlite3_stmt * 所表示的内容看成是 sql语句，但是实际上它不是我们所熟知的sql 语句，它是一个已经把sql 语句解析了点，用sqlite自己标记记录的内部数据结构
         因为这个结构已经被解析了，所以你可以往这个语句里面插入二进制数据，
         
         SQLITE3 基础使用 常用的函数
         
         sqlite3_open()     打开数据库
         sqlite3_close()    关闭数据
         sqlite3_errmsg()   错误信息
         sqlite3_exec()     操作SQl语句
            int sqlite3_exec(sqlite3 *, const char *sql, sqlite3_callback, void *, char **errmsg)
            1.第一个参数为sqlite3 *类型，可以通过sqlite3_open()获得
            2.第二个参数是一个指向一个字符串的指针，该字符串的内容为一条完整的SQL语句(不需要再语句结束加 ";")，
            3.第三个参数为一个回调函数，当这条语句执行之后，sqlite3 会去调用这个函数，其原型为 type int (*sqlite_callback) (void *, int, char **colvalue, char **colname)
            4.第四个参数为提供回调函数的参数，如果不需要传递参数，则可以写为NULL
            5.第五个参数为错误信息，这是指针的指针，通过打印printf(%s)，可以知道错误在什么地方
         
         sqlite3_get_table()    非回调方法查询数据库
         
         sqlite3_exec()的替代，sqlite3_prepare(), sqlite3_step(), sqlite3_finalize()
            1.共同涉及到的类型sqlite3_stmt  
            2.这三个函数实现将sql语句编译成字节码，然后执行释放，这三个函数都有V2版本，应该尽量使用新版，V2版本和原版本都是基于UTF-8编码，在返回值上V2版本更丰富
         
         */
        if (result == SQLITE_BUSY || result == SQLITE_LOCKED) {
            if (!stmtFinalized) {
                stmtFinalized = YES;
                sqlite3_stmt *stmt = NULL;
                while ((stmt == sqlite3_next_stmt(_db, nil)) != 0) {
                    sqlite3_finalize(stmt);
                    retry = YES;
                }
            }
        } else if (result != SQLITE_OK) {
            if (_errorLogsEnabled) {
                NSLog(@"%s line:%d sqlite close failed (%d)", __FUNCTION__, __LINE__, result);
            }
        }
    } while (retry);
    _db = NULL;
    return YES;
}

static const NSUInteger kMaxErrorRetryCount = 8;
static const NSTimeInterval kMinRetryTimeInterval = 2.0;
static const int kPathLengthMax = PATH_MAX - 64;

static NSString *const kDBFileName = @"maifest.sqlite";
static NSString *const kDBShmFileName = @"mainfest.sqlite-shm";
static NSString *const kDBWalFileName = @"mainfest.sqlite-wal";
static NSString *const kDataDirectoryName = @"data";
static NSString *const kTrashDirectoryName = @"trash";

#pragma mark 检查SQLite
- (BOOL)_dbCheck {
    if (!_db) {
        if (_dbOpenErrorCount < kMaxErrorRetryCount && CACurrentMediaTime() - _dbLastOpenErrorTime > kMinRetryTimeInterval) {
            return [self _dbOpen] && [self _dbInitialize];
        } else {
            return NO;
        }
    }
    return YES;
}

#pragma mark    本地 db初始化
- (BOOL)_dbInitialize {
    NSString *sql = @"pragma journal_mode = wal; pragma synchronous = normal; create table if not exists mainfest (key text, filename text, size integer, inline_data blob, modification_time integer, last_access_time integer, extended_data blob, primary key(key)); create index if not exists last_access_time_idx on mainfest(last_access_time);";
    return [self _dbExcute:sql];
}

#pragma mark 再加上 sqlite3_wal_checkpoint
- (void)_dbCheckPoint {
    if (![self _dbCheck]) return;
    sqlite3_wal_checkpoint(_db, NULL);
}

#pragma mark    执行sql语句
- (BOOL)_dbExcute:(NSString *)sql {
    if (sql.length == 0) return NO;
    if (![self _dbCheck]) return NO;
    
    char *error = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    if (error) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite exec error (%d):%s",__FUNCTION__, __LINE__, result, error);
        sqlite3_free(error);
    }
    return result = SQLITE_OK;
}

- (sqlite3_stmt *)_dbPrepareStmt:(NSString *)sql {
    //这个方法其实是通过CFMutableDictionaryRef   来对sqlite3_stmt进行缓存设置
    if (![self _dbCheck] || sql.length == 0 || !_dbStmtCache) return NULL;
    sqlite3_stmt *stmt = (sqlite3_stmt *)CFDictionaryGetValue(_dbStmtCache, (__bridge const void *)(sql));
    if (!stmt) {
        int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
        if (result != SQLITE_OK) {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d):%s",__FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            return NULL;
        }
        CFDictionarySetValue(_dbStmtCache, (__bridge const void *)(sql), stmt);
    } else {
        sqlite3_reset(stmt);
    }
    return stmt;
}

- (NSString *)_dbJoinedKeys:(NSArray *)keys {
    NSMutableString *string = [NSMutableString new];
    for (NSUInteger i = 0, max = keys.count; i < max; i++) {
        [string appendFormat:@"?"];
        if (i + 1 != max) {
            [string appendFormat:@","];
        }
    }
    return string.copy;
}

- (void)_dbBindJoinedKeys:(NSArray *)keys stmt:(sqlite3_stmt *)stmt fromIndex:(int)index {
    for (int i = 0, max = (int)keys.count; i < max; i++) {
        NSString *key = keys[i];
        /**
         sqlite3_bind_int
         sqlite3_bind_text
         这两个函数给"准备语句"绑定参数，其中函数的第二个参数是绑定参数的编号
         编号从1开始，而不是0
         */
        sqlite3_bind_text(stmt, index + i, key.UTF8String, -1, NULL);
    }
}

- (BOOL)_dbSaveWithKey:(NSString *)key value:(NSData *)value fileName:(NSString *)fileName extendedData:(NSData *)extendedData {
    NSString *sql = @"insert or replace into mainfest (key, filename, size, inline_data, modification_time, last_access_time, extended_data) values (?1, ?2, ?3, ?4, ?5, ?6, ?7);";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return NO;
    
    int timeStamp = (int)time(NULL);
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 2, fileName.UTF8String, -1, NULL);
    sqlite3_bind_int(stmt, 3, (int)value.length);
    
    if (fileName.length == 0) {
        sqlite3_bind_blob(stmt, 4, value.bytes, (int)value.length, 0);
    } else {
        sqlite3_bind_blob(stmt, 4, NULL, 0, 0);
    }
    sqlite3_bind_int(stmt, 5, timeStamp);
    sqlite3_bind_int(stmt, 6, timeStamp);
    sqlite3_bind_blob(stmt, 7, extendedData.bytes, (int)extendedData.length, 0);
    
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite insert error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (BOOL)_dbUpdateAccessTimeWithKey:(NSString *)key {
    NSString *sql = @"update mainfest set last_access_time = ?1 where key = ?2;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return NO;
    
    sqlite3_bind_int(stmt, 1, (int)time(NULL));
    sqlite3_bind_text(stmt, 2, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        if (_errorLogsEnabled) NSLog(@"%s line: %d sqlite update error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (BOOL)_dbUpdateAccessTimeWithKeys:(NSArray *)keys {
    if (![self _dbCheck ]) return NO;
    int t = (int)time(NULL);
    NSString *sql = [NSString stringWithFormat:@"update mainfest set last_access_time = %d where key in (%@);", t, [self _dbJoinedKeys:keys]];
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (BOOL)_dbDeleteItemWithKey:(NSString *)key {
    NSString *sql = @"delete from mainfest where key = ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return NO;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d db delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (BOOL)_dbDeleteItemWithKeys:(NSArray *)keys {
    if (![self _dbCheck]) return NO;
    NSString *sql = [NSString stringWithFormat:@"delete from mainfest where key in (%@);", [self _dbJoinedKeys:keys]];
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    
    [self _dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    result = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (result == SQLITE_ERROR) {
        if (_errorLogsEnabled) NSLog(@"%s line: %d sqlite error (%d): %s;", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (BOOL)_dbDeleteItemsWithSizeLargerThan:(int)size {
    NSString *sql = @"delete from mainfest where size > ?1;";
    //上面delete为什么不用preparestmt
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return NO;
    sqlite3_bind_int(stmt, 1, size);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (BOOL)_dbDeleteItemsWithTimeEarlierThan:(int)time {
    NSString *sql = @"delete from mainfest where last_access_time < ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return NO;
    sqlite3_bind_int(stmt, -1, time);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (MMKVStorageItem *)_dbGetItemFromStmt:(sqlite3_stmt *)stmt excludeInlineData:(BOOL)excludeInlineData {
    int i = 0;
    char *key = (char *)sqlite3_column_text(stmt, i++);
    char *filename = (char *)sqlite3_column_text(stmt, i++);
    int size = sqlite3_column_int(stmt, i++);
    const void *inline_data = excludeInlineData ? NULL : sqlite3_column_blob(stmt, i);
    int inline_data_bytes = excludeInlineData ? 0 : sqlite3_column_bytes(stmt, i++);
    int modification_time = sqlite3_column_int(stmt, i++);
    int last_access_time = sqlite3_column_int(stmt, i++);
    const void *extended_data = sqlite3_column_blob(stmt, i);//这么怎么没有i++
    int extended_data_bytes = sqlite3_column_bytes(stmt, i++);
    
    MMKVStorageItem *item = [MMKVStorageItem new];//擦 头文件不是声明new unavailable；
    if (key) item.key = [NSString stringWithUTF8String:key];
    if (filename && *filename != 0) item.fileName = [NSString stringWithUTF8String:filename];
    item.size = size;
    if (inline_data_bytes > 0 && inline_data) item.value = [NSData dataWithBytes:inline_data length:inline_data_bytes];
    item.modTime = modification_time;
    item.accessTime = last_access_time;
    if (extended_data_bytes > 0 && extended_data) item.extendedData = [NSData dataWithBytes:extended_data length:extended_data_bytes];
    return item;
}

- (MMKVStorageItem *)_dbGetItemWithKey:(NSString *)key excludeInlineData:(BOOL)excludeInlineData {
    NSString *sql = excludeInlineData ? @"select key, filename, size, modifiation_time, last_access_time, extended_data from mainfest where key = ?1;" : @"select key, filename, size, inline_data, modification_time, last_access_time, extended_data from mainfest where key = ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    MMKVStorageItem *item = nil;
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        item = [self _dbGetItemFromStmt:stmt excludeInlineData:excludeInlineData];
    } else {
        if (result != SQLITE_DONE) {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query erroR (%d):%s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
    }
    return item;
}

- (NSMutableArray *)_dbGetItemWithKeys:(NSArray *)keys excludeInlineData:(BOOL)excludeInlineData {
    if (![self _dbCheck]) return nil;
    NSString *sql;
    if (excludeInlineData) {
        sql = [NSString stringWithFormat:@"select key, filename, size, modification_time, last_access_time, excludedData from mainfest where key in (%@);",[self _dbJoinedKeys:keys]];
    } else {
        sql = [NSString stringWithFormat:@"select key, filename, size, modification_time, last_access_time from mainfest where key in (%@);", [self _dbJoinedKeys:keys]];
    }
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
    }
    NSMutableArray *items = [NSMutableArray new];
    do {
        result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            MMKVStorageItem *item = [self _dbGetItemFromStmt:stmt excludeInlineData:excludeInlineData];
            if (item) [items addObject:item];
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s",__FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            items = nil;
            break;
        }
    } while (1);
    sqlite3_finalize(stmt);
    return items;
}

- (NSData *)_dbGetValueWithKey:(NSString *)key {
    NSString *sql = @"select inline_data from mainfest where key = ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String - 1, -1, NULL);
    
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        const void *inline_data = sqlite3_column_blob(stmt, 0);
        int inline_data_bytes = sqlite3_column_bytes(stmt, 0);
        if (!inline_data || inline_data_bytes <= 0) return nil;
        return [NSData dataWithBytes:inline_data length:inline_data_bytes];
    } else {
        if (result != SQLITE_DONE) {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
        return nil;
    }
}

- (NSString *)_dbGetFilenameWithKey:(NSString *)key {
    NSString *sql = @"select filename from mainfest where key = ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String - 1, -1, NULL); //第二个参数是序列号， 从1开始
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        //SQLITE_ROW 表示查询完成且有返回，需要用 sqlite3_colum * 函数处理
        /*
         系列操作是 sqlite3_prepare * ----> sqlite3_bind_text 表示statment 准备好------>sqlite3_step *表示执行，------> 如果有返回 则SQLITE_ROW  利用sqlite3_column_blob／int 进行处理
         sqlite3_column * 的第二个参数从0开始 表示序号
         */
        char *filename = (char *)sqlite3_column_text(stmt, 0);
        if (filename && *filename != 0) {
            return [NSString stringWithUTF8String:filename];
        }
    } else {
        if (result != SQLITE_DONE) {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            
        }
    }
    return nil;
}

- (NSMutableArray *)_dbGetFilenameWithKeys:(NSArray *)keys {
    if (![self _dbCheck]) return nil;
    NSString *sql = [NSString stringWithFormat:@"select filename from mainfest where key in (%@);", [self _dbJoinedKeys:keys]];
    sqlite3_stmt *stmt = NULL;
    
    //通过key 对sqlite 进行增 删 查的时候没有直接用_dbPrepareStmt: 对于单条的key就直接用了PrepareStmt，而多条keys就需要先_dbJoinedKes: 然后手动sqlite3_prepare_v2来准备
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    /**
     常见返回SQLITE_OK的函数有
     sqlite3_open
     sqlite3_close
     sqlite3_prepare_v2
     */
    
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return nil;
    }
    
    [self _dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    NSMutableArray *filenames = [NSMutableArray new];
    do {
        result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *filename = (char *)sqlite3_column_text(stmt, 0);
            if (filename && *filename != 0) {
                NSString *name = [NSString stringWithUTF8String:filename];
                if (name)  [filenames addObject:name];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            filenames = nil;
            break;
        }
    } while (1);
    sqlite3_finalize(stmt);
    return filenames;
}

- (NSMutableArray *)_dbGetFilenamesWithSizeLargerThan:(int)size {
    NSString *sql = @"select filename from mainfest where size > ?1 and filename is not null;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 1, size);//sqlite3_bind *系列的参数 stmt，
    
    NSMutableArray *filenames = [NSMutableArray new];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *filename = (char *)sqlite3_column_text(stmt, 0);
            if (filename && *filename != 0) {
                NSString *name = [NSString stringWithUTF8String:filename];
                if (name) [filenames addObject:name];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            filenames = nil;
            break;
        }
    } while (1);
    return filenames;
}

- (NSMutableArray *)_dbGetFilenamesWithTimeEarlierThan:(int)time {
    NSString *sql = @"select filename from mainfest where last_access_time < ?1 and filename is not null;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 1, time);
    
    NSMutableArray *filenames = [NSMutableArray new];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *filename = (char *)sqlite3_column_text(stmt, 0);
            if (filename && *filename != 0) {
                NSString *name = [NSString stringWithUTF8String:filename];
                if (name)  [filenames addObject:name];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            filenames = nil;
            break;
        }
    } while (1);
    return filenames;
}

- (NSMutableArray *)_dbGetItemSizeInfoOrderByTimeAscWithLimit:(int)count {
    NSString *sql = @"select key, filename, size from mainfest order by last_access_time asc limit ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 1, count);
    
    NSMutableArray *items = [NSMutableArray new];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *key = (char *)sqlite3_column_text(stmt, 0); //sqlite_colum * 系列函数第二个参数序号从0开始
            char *filename = (char *)sqlite3_column_text(stmt, 1);
            int size = sqlite3_column_int(stmt, 3);
            NSString *keyStr = key ? [NSString stringWithUTF8String:key] : nil;
            if (keyStr) {
                YYKVStorageItem *item = [YYKVStorageItem new];
                item.key = keyStr;
                item.filename = filename ? [NSString stringWithUTF8String:filename] : nil;
                item.size = size;
                [items addObject:item];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s ",__FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            items = nil;
            break;
        }
    } while (1);
    return items;
}

- (int)_dbGetItemCountWithKey:(NSString *)key {
    NSString *sql = @"select count(key) from mainfest where key = ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return -1;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s",__FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return -1;
    }
    return sqlite3_column_int(stmt, 0);
}

- (int)_dbGetTotalItemSize {
    NSString *sql = @"select sum(size) from mainfest;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return -1;
    
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return -1;
    }
    return sqlite3_column_int(stmt, 0);
}

- (int)_dbGetTotalItemCount {
    NSString *sql = @"select sum(*) from mainfest;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return -1;
    
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return  -1;
    }
    return sqlite3_column_int(stmt, 0);
}


#pragma mark    -File

- (BOOL)_fileWriteWithName:(NSString *)filename data:(NSData *)data {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [data writeToFile:path atomically:NO];
}

- (NSData *)_fileReadWithName:(NSString *)filename {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [NSData dataWithContentsOfFile:path];
}

- (BOOL)_fileDeleteWithName:(NSString *)filename {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (BOOL)_fileMoveAllToTrash {
    /**
     文件cache 移除方法是先将_dataPath里面的缓存移动到一个临时的文件中
     */

    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuid = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    
    NSString *tempPath = [_trashPath stringByAppendingPathComponent:(__bridge NSString *)(uuid)];
    BOOL suc = [[NSFileManager defaultManager] moveItemAtPath:_dataPath toPath:tempPath error:NULL];
    if (suc) {
        suc = [[NSFileManager defaultManager] createDirectoryAtPath:_dataPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    CFRelease(uuid);
    return suc;
}

- (void)_fileEmptyTrashInBachground {
    /**
     另外开一个线程去清理_trashPath 内的文件内容
     */

    NSString *trashPath = _trashPath;
    dispatch_queue_t queue = _trashQueue;
    dispatch_async(queue, ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        NSArray *directoryContents = [manager contentsOfDirectoryAtPath:trashPath error:NULL];
        for (NSString *path in directoryContents) {
            NSString *fullPath = [trashPath stringByAppendingPathComponent:path];
            [manager removeItemAtPath:fullPath error:NULL];
        }
    });
}

- (void)_reset {
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBFileName] error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBShmFileName] error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBWalFileName] error:NULL];
    [self _fileMoveAllToTrash];
    [self _fileEmptyTrashInBachground];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"MMKVStorage init error" reason:@"please use the designed initializer and pass the 'path' and 'type'." userInfo:nil];
    return [self initWithPath:@"" type:MMKVStorageTypeFile];
}

- (instancetype)initWithPath:(NSString *)path type:(MMKVStorageType)type {
    if (path.length == 0 || path.length > kPathLengthMax ) {
        NSLog(@"MMKVStorage init error : invalid path:[%@].", path);
        return nil;
    }
    if (type > MMKVStorageTypeMixed) {
        NSLog(@"MMKVStorage init error: invalid type: %lu.",(unsigned long)type);
        return nil;
    }
    
    self = [super init];
    _path = path.copy;
    _type = type;
    _dataPath = [path stringByAppendingPathComponent:kDataDirectoryName];
    _trashPath = [path stringByAppendingPathComponent:kTrashDirectoryName];
    _trashQueue = dispatch_queue_create("com.mumuno.cache.disk.trash", DISPATCH_QUEUE_SERIAL); //处理过期缓存的线程为串行
    _dbPath = [path stringByAppendingPathComponent:kDBFileName];
    _errorLogsEnabled = YES;
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error] ||
        ![[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingPathComponent:kDataDirectoryName]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error] ||
        ![[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingPathComponent:kTrashDirectoryName]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
            NSLog(@"MMKVStorage init error: %@", error);
            return nil;
        }
    
    if (![self _dbOpen] || ![self _dbInitialize]) {
        [self _dbClose];
        [self _reset];
        if (![self _dbOpen] || ![self _dbInitialize]) {
            [self _dbClose];
            NSLog(@"MMKVStorage init error: fail to open sqlite db.");
        }
        return nil;
    }
    [self _fileEmptyTrashInBachground];
    return self;
}


- (void)dealloc {
    UIBackgroundTaskIdentifier taskID = [[UIApplication sharedExtensionApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    [self _dbClose];
    if (taskID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedExtensionApplication] endBackgroundTask:taskID];
    }
}

- (BOOL)saveItem:(YYKVStorageItem *)item {
    return [self saveItemWithKey:item.key value:item.value fileName:item.filename extendedData:item.extendedData];
}

- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value {
    return [self saveItemWithKey:key value:value fileName:nil extendedData:nil];
}

- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value fileName:(NSString *)filename extendedData:(NSData *)extendedData {
    if (key.length == 0 || value.length == 0) return NO;
    if (_type == MMKVStorageTypeFile && filename.length == 0) return NO;
    /**
     1.先判断key 和 value
     2.再判断type 是不是只是file类型但是 filename又没有
     3.如果filename 有值则文件写入，同时也用sqlite 保存一份
     4.如果没有filename 就只用sqlite保存
     */
    
    if (filename.length) {
        if (![self _fileWriteWithName:filename data:value]) return NO;
        if (![self _dbSaveWithKey:key value:value fileName:filename extendedData:extendedData]) {
            [self _fileDeleteWithName:filename];
            return NO;
        }
        return YES;
    } else {
        if (_type != MMKVStorageTypeSQLite) {
            NSString *filename = [self _dbGetFilenameWithKey:key];
            if (filename) [self _fileDeleteWithName:filename];
        }
        return [self _dbSaveWithKey:key value:value fileName:nil extendedData:extendedData];
    }
    
}

- (BOOL)removeItemForKey:(NSString *)key {
    if (key.length == 0) return NO;
    switch (_type) {
        case MMKVStorageTypeSQLite:{
            return [self _dbDeleteItemWithKey:key];
        } break;
        case MMKVStorageTypeFile:
        case MMKVStorageTypeMixed:{
            NSString *filename = [self _dbGetFilenameWithKey:key];
            if (filename) [self _fileDeleteWithName:filename];
            return [self _dbDeleteItemWithKey:key];
        } break;
        default: return NO;
    }
}

- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys {
    if (keys.count == 0) return NO;
    switch (_type) {
        case MMKVStorageTypeSQLite: {
            return [self _dbDeleteItemWithKeys:keys];
        } break;
        case MMKVStorageTypeFile:
        case MMKVStorageTypeMixed: {
            NSArray *filenames = [self _dbGetFilenameWithKeys:keys];
            for (NSString *filename in filenames) {
                [self _fileDeleteWithName:filename];
            }
            return [self _dbDeleteItemWithKeys:keys];
        } break;
        default: return NO;
            
    }
}

- (BOOL)removeItemsLargerThanSize:(int)size {
    if (size == INT_MAX) return YES;
    if (size <= 0) return [self removeAllItems];
    
    switch (_type) {
        case MMKVStorageTypeSQLite: {
            if ([self _dbDeleteItemsWithSizeLargerThan:size]) {
                [self _dbCheckPoint];// check point 无返回 内部调用了 _dbCheck ,同时调用sqlite3_wal_checkpoint 函数
                return YES;
            }
        }break;
            case MMKVStorageTypeFile:
        case MMKVStorageTypeMixed: {
            NSArray *filenames = [self _dbGetFilenamesWithSizeLargerThan:size];
            for (NSString *name in filenames) {
                [self _fileDeleteWithName:name];
            }
            if ([self _dbDeleteItemsWithSizeLargerThan:size]) {
                [self _dbCheckPoint];
                return YES;
            }
        } break;
    }
    return NO;
}

- (BOOL)removeItemEarlierThanTime:(int)time {
    if (time <= 0) return YES;
    if (time == INT_MAX) return [self removeAllItems];
    
    switch (_type) {
        case MMKVStorageTypeSQLite: {
            if ([self _dbDeleteItemsWithTimeEarlierThan:time]) {
                [self _dbCheckPoint];
                return YES;
            }
        } break;
            case MMKVStorageTypeFile:
        case MMKVStorageTypeMixed: {
            NSArray *filenames = [self _dbGetFilenamesWithTimeEarlierThan:time];
            for (NSString *filename in filenames) {
                [self _fileDeleteWithName:filename];
            }
            if ([self _dbDeleteItemsWithTimeEarlierThan:time]) {
                [self _dbCheckPoint];
                return YES;
            }
        } break;
    }
    return NO;
}

- (BOOL)removeItemsToFitSize:(int)maxSize {
    if (maxSize == INT_MAX) return YES;
    if (maxSize <= 0) return [self removeAllItems];
    
    int total = [self _dbGetTotalItemSize];//清理之后再检查当前的占用内存
    if (total < 0) return NO;
    if (total <= maxSize) return YES;
#warning    ASC
    //如果还不够需要再清理 ASC 是啥
    NSArray *items = nil;
    BOOL suc = NO;
    do {
        int perCount = 16;
        items = [self _dbGetItemSizeInfoOrderByTimeAscWithLimit:perCount];
        for (MMKVStorageItem *item in items) {
            if (total > maxSize) {
                if (item.fileName) {
                    [self _fileDeleteWithName:item.fileName];
                }
                suc = [self _dbDeleteItemWithKey:item.key];
                total -= item.size;
            } else {
                break;
            }
            if (!suc) break;
        }
    } while ( total > maxSize && items.count > 0 && suc);
    if (suc) [self _dbCheckPoint];
    return suc;
}

- (BOOL)removeItemsToFitCount:(int)maxCount {
    if (maxCount == INT_MAX) return YES;
    if (maxCount <= 0) return [self removeAllItems];
    
    int total = [self _dbGetTotalItemCount];
    if (total < 0) return NO;
    if (total < maxCount) return YES;
    
    NSArray *items = nil;
    BOOL suc = NO;
    do {
        int perCount = 16;
        items = [self _dbGetItemSizeInfoOrderByTimeAscWithLimit:perCount];
        for (MMKVStorageItem *item in items) {
            if (total > maxCount) {
                if (item.fileName) {
                    [self _fileDeleteWithName:item.fileName];
                }
                suc = [self _dbDeleteItemWithKey:item.key];
                total--;
            } else {
                break;
            }
            if (!suc) break;
        }
    } while (total > maxCount && items.count > 0 && suc);
    if (suc) [self _dbCheckPoint];
    return suc;
}

- (BOOL)removeAllItems {
    if (![self _dbClose]) return NO;
    [self _reset];
    if (![self _dbOpen]) return NO;
    if (![self _dbInitialize]) return NO;
    return YES;
}

- (void)removeAllItemsWithProgressBlock:(void(^)(int removedCount, int totalCount))progress endBlock:(void (^)(BOOL))end {
    int total = [self _dbGetTotalItemCount];
    if (total <= 0) {
        if (end) end(total < 0);
    } else {
        int left = total;
        int perCount = 32;
        BOOL suc = NO;
        NSArray *items = nil;
        do {
            items = [self _dbGetItemSizeInfoOrderByTimeAscWithLimit:perCount];
            for (MMKVStorageItem *item in items) {
                if (left > 0) {
                    if (item.fileName) {
                        [self _fileDeleteWithName:item.fileName];
                        suc = [self _dbDeleteItemWithKey:item.key];
                        left--;
                    } else {
                        break;
                    }
                    if (!suc) break;
                }
            }
            if (progress) progress(total - left, total);
        } while (left > 0 && items.count > 0 && suc);
        if (suc) [self _dbCheckPoint];
        if (end) end(!suc);
    }
}

- (MMKVStorageItem *)getItemForKey:(NSString *)key {
    if (key.length == 0) return nil;
    MMKVStorageItem *item = [self _dbGetItemWithKey:key excludeInlineData:NO];
    if (item) {
        [self _dbUpdateAccessTimeWithKey:key];
        if (item.fileName) {
            item.value = [self _fileReadWithName:item.fileName];
            if (!item.value) {
                [self _dbDeleteItemWithKey:key];
                item = nil;
            }
        }
    }
    return item;
}

- (MMKVStorageItem *)getItemInfoForKey:(NSString *)key {
    if (key.length == 0) return nil;
    MMKVStorageItem *item = [self _dbGetItemWithKey:key excludeInlineData:YES];
    return item;
}


- (NSData *)getItemValueForKey:(NSString *)key {
    if (key.length == 0) return nil;
    NSData *value = nil;
    switch (_type) {
        case MMKVStorageTypeFile: {
            NSString *filename = [self _dbGetFilenameWithKey:key];
            if (filename) {
                value = [self _fileReadWithName:filename];
                if (!value) {
                    [self _dbDeleteItemWithKey:key];
                    value = nil;
                }
            }
        }break;
        case MMKVStorageTypeSQLite: {
            value = [self _dbGetValueWithKey:key];
        } break;
        case MMKVStorageTypeMixed: {
            NSString *filename = [self _dbGetFilenameWithKey:key];
            if (filename) {
                value = [self _fileReadWithName:filename];
                if (!value) {
                    [self _dbDeleteItemWithKey:key];
                    value = nil;
                }
            } else {
                value = [self _dbGetValueWithKey:key];
            }
        }
            
    }if (value) {
        [self _dbUpdateAccessTimeWithKey:key];
    }
    return value;
}

- (NSArray *)getItemForKeys:(NSArray *)keys {
    if (keys.count == 0) return nil;
    NSMutableArray *items = [self _dbGetItemWithKeys:keys excludeInlineData:NO];
    if (_type != MMKVStorageTypeSQLite) {
        for (NSInteger i = 0, max = items.count; i < max; i++) {
            MMKVStorageItem *item  = items[i];
            if (item.fileName) {
                item.value = [self _fileReadWithName:item.fileName];
                if (!item.value) {
                    if (item.key) [self _dbDeleteItemWithKey:item.key];
                    [items removeObjectAtIndex:i];
                    i--;
                    max--;
                }
            }
        }
    }
    if (items.count > 0) {
        [self _dbUpdateAccessTimeWithKeys:keys];
    }
    return items.count ? items : nil;
}

- (NSArray *)getItemInfoForKeys:(NSArray *)keys {
    if (keys.count == 0) return nil;
    return [self _dbGetItemWithKeys:keys excludeInlineData:YES];
}

- (NSDictionary *)getItemValueForKeys:(NSArray *)keys {
    NSMutableArray *items = (NSMutableArray *)[self getItemForKeys:keys];
}















@end

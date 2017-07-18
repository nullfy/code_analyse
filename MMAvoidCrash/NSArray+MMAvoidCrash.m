//
//  NSArray+MMAvoidCrash.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/7/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "NSArray+MMAvoidCrash.h"
#import "MMAvoidCrash.h"

@implementation NSArray (MMAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MMAvoidCrash exchangeInstanceMethod:self
                                   methodSel:@selector(arrayWithObjects:count:)
                              otherMethodSel:@selector(avoidCrashArrayWithObjects:count:)];
        
        Class __NSArray = NSClassFromString(@"NSArray");
        Class __NSArrayI = NSClassFromString(@"__NSArrayI");
        Class __NSSingleObjectArrayI = NSClassFromString(@"__NSSingleObjectArrayI");
        Class __NSArray0 = NSClassFromString(@"__NSArray0");
        
        //objectAtIndexs
        [MMAvoidCrash exchangeInstanceMethod:__NSArray
                                   methodSel:@selector(objectsAtIndexes:)
                              otherMethodSel:@selector(avoidCrashObjectAtIndexes:)];
        
        //objectAtIndex
        [MMAvoidCrash exchangeInstanceMethod:__NSArrayI
                                   methodSel:@selector(objectAtIndex:)
                              otherMethodSel:@selector(__NSArrayIAvoidCrashObjectAtIndex:)];
        
        [MMAvoidCrash exchangeInstanceMethod:__NSSingleObjectArrayI
                                   methodSel:@selector(objectAtIndex:)
                              otherMethodSel:@selector(__NSSingleObjectAvoidCrashObjectAtIndex:)];
        
        [MMAvoidCrash exchangeInstanceMethod:__NSArray0
                                   methodSel:@selector(objectAtIndex:)
                              otherMethodSel:@selector(__NSArray0AvoidCrashObjectAtIndex:)];
        
        //getObject: range:
        [MMAvoidCrash exchangeInstanceMethod:__NSArray
                                   methodSel:@selector(getObjects:range:)
                              otherMethodSel:@selector(NSArrayAvoidCrashGetObjects:range:)];
        
        [MMAvoidCrash exchangeInstanceMethod:__NSArrayI
                                   methodSel:@selector(getObjects:range:)
                              otherMethodSel:@selector(__NSArrayIAvoidCrashGetObjects:range:)];
        
        [MMAvoidCrash exchangeInstanceMethod:__NSSingleObjectArrayI
                                   methodSel:@selector(getObjects:range:)
                              otherMethodSel:@selector(__NSSingleObjectArrayIAvoidCrashGetObjects:range:)]; 
    });
}

# pragma mark private-method

+ (instancetype)avoidCrashArrayWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt {
    id obj = nil;
    @try {
        obj = [self avoidCrashArrayWithObjects:objects count:cnt];
    } @catch (NSException *exception) {
        NSString *defaultToDo = @"This framework default is to remove nil object and instance a array";
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
        NSInteger index = 0;
        id  newObjects[cnt];
        for (NSInteger i = 0 ; i < cnt; i++) {
            if (objects[i] != nil) {
                newObjects[index] = objects[i];
                index++;
            }
        }
        obj = [self avoidCrashArrayWithObjects:newObjects count:index];
    } @finally {
        return obj;
    }
}

- (id)avoidCrashObjectAtIndexedSubscript:(NSUInteger)idx {
    id obj = nil;
    @try {
        obj = [self avoidCrashObjectAtIndexedSubscript:idx];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return obj;
    }
}

- (NSArray *)avoidCrashObjectAtIndexes:(NSIndexSet *)indexes {
    NSArray *result = nil;
    @try {
        result = [self avoidCrashObjectAtIndexes:indexes];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return result;
    }
}

- (id)__NSArrayIAvoidCrashObjectAtIndex:(NSUInteger)index {
    id obj = nil;
    @try {
        obj = [self __NSArrayIAvoidCrashObjectAtIndex:index];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return obj;
    }
}

- (id)__NSSingleObjectAvoidCrashObjectAtIndex:(NSUInteger)index {
    id obj = nil;
    @try {
        obj = [self __NSSingleObjectAvoidCrashObjectAtIndex:index];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return obj;
    }
}

- (id)__NSArray0AvoidCrashObjectAtIndex:(NSUInteger)index {
    id obj = nil;
    @try {
        obj = [self __NSArray0AvoidCrashObjectAtIndex:index];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        return obj;
    }
}

- (void)NSArrayAvoidCrashGetObjects:(__unsafe_unretained id  _Nonnull *)objects range:(NSRange)range {
    @try {
        [self NSArrayAvoidCrashGetObjects:objects range:range];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        
    }
}

- (void)__NSSingleObjectArrayIAvoidCrashGetObjects:(__unsafe_unretained id  _Nonnull *)objects range:(NSRange)range {
    @try {
        [self __NSSingleObjectArrayIAvoidCrashGetObjects:objects range:range];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        
    }
}

- (void)__NSArrayIAvoidCrashGetObjects:(__unsafe_unretained id  _Nonnull *)objects range:(NSRange)range {
    @try {
        [self __NSArrayIAvoidCrashGetObjects:objects range:range];
    } @catch (NSException *exception) {
        [MMAvoidCrash noteErrorWithException:exception defaultToDo:MMAvoidCrashDefaultReturnNil];
    } @finally {
        
    }
}

@end

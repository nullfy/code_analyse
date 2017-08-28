//
//  UIBarButtonItem+MMAdd.m
//  PracticeKit
//
//  Created by 晓东 on 16/12/2.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "UIBarButtonItem+MMAdd.h"
#import "MMKitMacro.h"
#import <objc/runtime.h>

MMSYNTH_DUMMY_CLASS(UIBarButtonItem_MMAdd)

@interface _MMUIBarButtonItemBlockTarget : NSObject

@property (nonatomic, copy) void(^block)(id sender);

- (id)initWithBlock:(void (^)(id sender))block;
- (void)invoke:(id)sender;

@end

@implementation _MMUIBarButtonItemBlockTarget

- (id)initWithBlock:(void (^)(id))block {
    self = [super init];
    if (self) {
        _block = block;
    }
    return self;
}

- (void)invoke:(id)sender {
    if (self.block) self.block(sender);
}
@end

@implementation UIBarButtonItem (MMAdd)

- (void)setActionBlock:(void (^)(id sender))actionBlock {
    _MMUIBarButtonItemBlockTarget *targe = [[_MMUIBarButtonItemBlockTarget alloc] initWithBlock:actionBlock];
    objc_setAssociatedObject(self, _cmd, targe, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setTarget:targe];
    [self setAction:@selector(invoke:)];
}

- (void(^)(id sender)) actionBlock {
    _MMUIBarButtonItemBlockTarget *target = objc_getAssociatedObject(self, _cmd);
    return target.block;
}


@end

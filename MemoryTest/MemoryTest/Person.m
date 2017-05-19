//
//  Person.m
//  MemoryTest
//
//  Created by 李晓东 on 2017/5/19.
//  Copyright © 2017年 XD. All rights reserved.
//

#import "Person.h"
#import <objc/objc-runtime.h>
NSString *height = @"dede";
static NSString *width = @"3";
static NSString const *base = @"haha";
NSInteger hh = 10;
NSInteger gg;

@interface Person () {
    NSString *_name;
}

@property (nonatomic, copy) NSString *date;

@end

@implementation Person

- (void)test {
    _date = @"1";
    _name = @"2";
    _age = @"3";        //字面量声明的会指向同一快内存
    printf("\n\
          对外属性age----%p\n\
          匿名变量name---%p\n\
          匿名属性date---%p\n\
          全局变量height--%p\n\
          全局静态width--%p\n\
          静态常量base---%p\n\
          全局初始化a-----%p\n\
          全局未初始化b---%p\n",_age,_name,_date,height,width,base,&hh,&gg);
    
}


@end

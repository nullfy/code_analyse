//
//  main.m
//  MemoryTest
//
//  Created by 李晓东 on 2017/5/18.
//  Copyright © 2017年 XD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "view.h"
#import "Person.h"


int a = 10;         //全局初始化区
char *p;            //全局未初始化区

void memoryTest () {
    //int b;                                //栈区
    //char s[] = "abc";                     //栈
    char *p1;                               //栈
    char *p2 = "124";                       //栈
    static int c = 0;                       //全局区 的数据初始化区
    char *w1 = (char *)malloc(100*1024*1024);      //堆区
    char *w2 = (char *)malloc(10);                 //堆区
    printf("\n\
           全局初始化a    :%p 数据区\n\
           全局未初始化*p  :%p\n\
           局部static c  :%p\n\
           局部初始化*p2  :%p\n\
           局部未初始化*p  :%p\n\
           局部malloc大w1 :%p\n\
           局部malloc小w2 :%p\n",&a,&p,&c,&p2,&p1,&w1,&w2);
}

void varibleTest() {
    [[Person new] test];
}

void viewTest() {
    view *v = [[view alloc] initWithFrame:NSMakeRect(0, 0, 12, 12)];
    [v description];
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        memoryTest();
        viewTest();
        varibleTest();
    }
    return 0;
}

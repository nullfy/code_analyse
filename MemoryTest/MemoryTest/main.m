//
//  main.m
//  MemoryTest
//
//  Created by 李晓东 on 2017/5/18.
//  Copyright © 2017年 XD. All rights reserved.
//

#import <Foundation/Foundation.h>

int a = 10;         //全局初始化区
char *p;            //全局未初始化区

void memoryTest () {
    //int b;                              //栈区
    //char s[] = "abc";                   //栈
    char *p1;                           //栈
    char *p2 = "124";                   //栈
    static int c = 0;                   //全局静态初始化
    char *w1 = (char *)malloc(100*1024*1024);      //
    char *w2 = (char *)malloc(100*1024*1024);
    printf(" a----%p \n p----%p\n c----%p\n p2---%p\n p1---%p\n w1---%p\n w2---%p\n",&a,&p,&c,&p2,&p1,&w1,&w2);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        memoryTest();
    }
    return 0;
}

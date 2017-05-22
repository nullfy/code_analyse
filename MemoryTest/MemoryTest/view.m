//
//  view.m
//  MemoryTest
//
//  Created by 李晓东 on 2017/5/19.
//  Copyright © 2017年 XD. All rights reserved.
//

#import "view.h"


//全局区
int a1 = 1;     //全局区 0x100002520
static int a2=2;//全局区 0x100002528   全局区自低向高
const int a3=3; //常量区 0x100001fa0

int add(int a,int b) {
    return a+b;
}
/*
 add: 0x1000014f0 --->
 main:0x100001510 代码区 自低向高
 
 地址从下至上
 add -> main -> a1 -> b2 -> a2 -> a3 -> b3 -> b1
 add -> main -> a1 -> a2 -> a3 -> b1 -> b2 -> b3
 */

void main1() {
    int b1=4;           //栈区
    static int b2=5;    //常量区 0x100002524
     int const b3 =6;    //栈区   0x7fff5fbff568     为什么不是常量区呢
    
    int *p1=malloc(40); //堆区   0x100500cd0
    
    printf("全局变量a1:%p\n",&a1);
    printf("全局静态a2:%p\n",&a2);
    printf("全局常量a3:%p\n",&a3);
    printf("局部变量b1:%p\n",&b1);
    printf("局部静态b2:%p\n",&b2);
    printf("局部常量b3:%p\n",&b3);
    printf("局部创建p1:%p\n",p1);
    printf("无返回main:%p\n",&main1);
    printf("有返回add:%p\n",&add);
}

NSView  * view1;

@implementation view {
    NSView *_view2;
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _view2 = [NSView new];
        view1 = [NSView new];
        NSView *v3 = [[NSView alloc] init];
        printf("\n\
                全局View v1:%p\n\
                匿名全局 v2:%p\n\
                局部View v3:%p\n\n",view1, _view2, v3);
        main1();
    }
    return self;
}



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

@end

//
//  view.m
//  MemoryTest
//
//  Created by 李晓东 on 2017/5/19.
//  Copyright © 2017年 XD. All rights reserved.
//

#import "view.h"


//全局区
int a1 = 1;     //全局变量
static int a2=2;//全局静态变量
const int a3=3; //全局常量

int add(int a,int b) {
    return a+b;
}

void main1() {
    int b1=4;
    static int b2=5;
    const int b3 =6;
    
    int *p1=malloc(40);
    
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

//
//  intrisicViewController.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/8/7.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "intrisicViewController.h"

static BOOL closeIntrinsic = NO;

@interface customIntrinsicView : UIView

@property (nonatomic, assign) CGSize extendSize;
@end

@implementation customIntrinsicView

- (instancetype)init
{
    self = [super init];
    if (self) {
        /*
         不兼容旧版AutoresizingMask 只使用autolayout
         默认为YES，如果为YES，在autolayout中 系统会自动将frame和bounds 属性转换为约束
         如果为NO，就可以只设置约束而不必写frame
         
         下面的值如果为NO，会因为条件不足而无法正常添加intricsicView到VC中，self.view中会什么都没有
         */
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)setExtendSize:(CGSize)extendSize {
    _extendSize = extendSize;
    //如果不加这句话，在view显示之后，再设置extendSize不会有效果
    [self invalidateIntrinsicContentSize];
}

/*
    通过覆盖intrinsicContentSize 函数修改Intrinsic的大小
 */
- (CGSize)intrinsicContentSize {
    if (closeIntrinsic) {
        return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
    } else {
        return CGSizeMake(_extendSize.width, _extendSize.height);
    }
}


@end

@interface intrisicViewController ()

@end

@implementation intrisicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    customIntrinsicView *v1 = [[customIntrinsicView alloc] init];
    v1.extendSize = CGSizeMake(100, 100);
    v1.backgroundColor = [UIColor greenColor];
    [self.view addSubview:v1];
    
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:100],
                               [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:10]]];
    
    customIntrinsicView *v2 = [[customIntrinsicView alloc] init];
    v2.extendSize = CGSizeMake(100, 30);
    v2.backgroundColor = [UIColor redColor];
    [self.view addSubview:v2];
    
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:v2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:220],
                                [NSLayoutConstraint constraintWithItem:v2 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:10]]];
    [self performSelector:@selector(testIntrinsicView:) withObject:v2 afterDelay:4];
    
    /*
     比如说，两个水平的label，左边距10，间隔10，右边距为10
     当label上的文字很少的时候，那么就需要一个label被拉伸才能满足条件
     当label上的文字很多，超过了屏幕宽度，那么就需要其中的一个压缩一下宽度来适应屏幕
     
     Content Hugging Priority
     默认的优先级是251，越大那么当视图需要拉伸时，优先级高的就不会被拉伸
     
     Content CompressionResistance
     默认的优先级是750，越小那么当intrinsicSize的大小确定，需要某一个视图缩小时，那么优先级高的那个不会缩小
     
     下面对应的是代码修改，直接xib的话修改水平／垂直的优先级
     */
    
    //[v1 setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    //[v1 setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
}

- (void)testIntrinsicView:(customIntrinsicView *)view {
    view.extendSize = CGSizeMake(100, 80);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

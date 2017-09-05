//
//  CrossDissolveSecondViewController.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/9/5.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "CrossDissolveSecondViewController.h"

@interface CrossDissolveSecondViewController ()

@end

@implementation CrossDissolveSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 24, 45, 40)];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)backView {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

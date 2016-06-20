//
//  AdvertiseViewController.m
//  zhibo
//
//  Created by mumuno on 16/5/17.
//  Copyright © 2016年 mumuno. All rights reserved.
//

#import "AdvertiseViewController.h"

@interface AdvertiseViewController ()

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation AdvertiseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"点击进入广告链接";
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.backgroundColor = [UIColor whiteColor];
    if (!self.adUrl) {
        self.adUrl = @"http://www.jianshu.com";
    }
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.adUrl]];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
}

- (void)viewDidLayoutSubviews {
    
}


- (void)setAdUrl:(NSString *)adUrl
{
    _adUrl = adUrl;
}



@end

//
//  OtherChexunController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-27.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "OtherChexunController.h"


@interface OtherChexunController ()<UIGestureRecognizerDelegate>

@end

@implementation OtherChexunController
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (self.navigationController.viewControllers.count == 1){
        
        //关闭主界面的右滑返回
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}



- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer

{
    
    return YES;
    
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    /*
    self.navigationItem.title = @"车讯";
    
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       
                                       target:nil action:nil];
    
    negativeSpacer.width = -20;
    
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    
    
    
    [backBtn setImage:[UIImage imageNamed:@"chexun_home_backarrow"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    
    
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, backItem];
    */
    //导航视图
    
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    
    navView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:navView];
    
    
    
    //返回按钮
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 44, 44)];
    
    backBtn.backgroundColor = [UIColor clearColor];
    
    [backBtn setImage:[UIImage imageNamed:@"chexun_backarrow_black"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    [navView addSubview:backBtn];
    
    
    
    //标题视图
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 80) * 0.5, 20, 80, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"车讯";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    //加载webView
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    
    NSURL *url = [NSURL URLWithString:@"http://3g.chexun.com"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}
@end
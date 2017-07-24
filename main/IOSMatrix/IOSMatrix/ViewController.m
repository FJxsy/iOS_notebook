//
//  ViewController.m
//  IOSMatrix
//
//  Created by zhoupan on 2017/7/24.
//  Copyright © 2017年 zhoupan. All rights reserved.
//

#import "ViewController.h"
#import "IMatrixWebViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    IMatrixWebViewController *ctrl = [[IMatrixWebViewController alloc] init];
    ctrl.urlString = @"https://www.baidu.com";
    [self.navigationController pushViewController:ctrl animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

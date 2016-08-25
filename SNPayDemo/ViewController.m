//
//  ViewController.m
//  SNPayDemo
//
//  Created by wangsen on 16/8/22.
//  Copyright © 2016年 wangsen. All rights reserved.
//

#import "ViewController.h"
#import "SNPayManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //调起支付
    [[SNPayManager sharePayManager] sn_openTheAlipayPay:^(NSError *error) {
        if (!error) {
            //成功
        } else {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
    [[SNPayManager sharePayManager] sn_openTheWechatPay:^(NSError *error) {
        if (!error) {
            //成功
        } else {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

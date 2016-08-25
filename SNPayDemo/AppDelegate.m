//
//  AppDelegate.m
//  SNPayDemo
//
//  Created by wangsen on 16/8/22.
//  Copyright © 2016年 wangsen. All rights reserved.
//

#import "AppDelegate.h"
#import "SNPayManager.h"

//微信
#define WeChatAppID @""
#define WeChatAppSecret @""
#define WeChatPrivateKey @""
#define WeChatShopID @""

//支付宝
#define Alipay_PID @""
#define Alipay_seller @""
#define Alipay_appScheme @""
#define Alipay_privateKey @""

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //注册微信 支付宝
    [self registerPay];
    return YES;
}

- (void)registerPay {
    [[SNPayManager sharePayManager] registerAlipayPatenerID:Alipay_PID seller:Alipay_seller appScheme:Alipay_appScheme privateKey:Alipay_privateKey];
    [[SNPayManager sharePayManager]registerWechatAppID:WeChatAppID partnerID:WeChatPrivateKey shopID:WeChatShopID];
}

#pragma 设置回调
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[SNPayManager sharePayManager]sn_alipayHandleOpenURL:url];
    [[SNPayManager sharePayManager] sn_wechatHandleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    [[SNPayManager sharePayManager]sn_alipayHandleOpenURL:url];
    [[SNPayManager sharePayManager] sn_wechatHandleOpenURL:url];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

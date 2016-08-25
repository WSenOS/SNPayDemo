# 微信，支付宝支付 
## SNPayDemo
### 使用方法如下
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //注册微信 支付宝
    [self registerPay];
    return YES;
}

- (void)registerPay {
  //详情可见 SNPayManager.h
    [[SNPayManager sharePayManager] registerAlipayPatenerID:Alipay_PID seller:Alipay_seller appScheme:Alipay_appScheme privateKey:Alipay_privateKey];
    [[SNPayManager sharePayManager]registerWechatAppID:WeChatAppID partnerID:WeChatPrivateKey shopID:WeChatShopID];
}

#pragma 注册回调
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

//设置使用block回调提示 还是通知提示
[SNPayManager sharePayManager].useNotication  默认NO（使用block提示）
//支付参数
/*
[SNPayManager sharePayManager].order_name = @"";
[SNPayManager sharePayManager].notify_url = @"";
支付参数 订单标题 回调url  订单号 等信息 详情见 详情可见 SNPayManager.h
*/
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
/* 
 * 目前版本微信支付 统一下单接口本地调用 生成签名 后续会增加只本地调起支付方法(建议服务器签名)
 */

```
## 欢迎访问Blog
Blog: https://wsenos.github.io/
## License
[MIT License](https://opensource.org/licenses/MIT)

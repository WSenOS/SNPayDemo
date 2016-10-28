//
//  SNPayManager.m
//  SNPay
//
//  Created by wangsen on 16/8/20.
//  Copyright © 2016年 wangsen. All rights reserved.
//

#import "SNPayManager.h"

#include <arpa/inet.h>
#include <ifaddrs.h>


#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#define Domain @"com.sn.payResults"

NSString * const SNPaySuccess = @"SN_paysuccess";
NSString * const SNPayFailure = @"SN_payfailure";

static SNPayManager * _manager = nil;

@interface SNPayManager ()
{
    //支付宝
    NSString * _alipay_partnerID;
    NSString * _alipay_seller;
    NSString * _alipay_appScheme;
    NSString * _alipay_privateKey;
    //微信
    NSString * _wechat_appID;
    NSString * _wechat_partnerID;
    NSString * _wechat_shopID;
}
@property (nonatomic, copy) SNAlipayResultsBlock alipayResultsBlock;
@property (nonatomic, copy) SNWechatResultsBlock wechatResultsBlock;

@end
@implementation SNPayManager
+ (instancetype)sharePayManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

- (void)registerAlipayPatenerID:(NSString *)partner
                         seller:(NSString *)seller
                      appScheme:(NSString *)appScheme
                     privateKey:(NSString *)private_key {
    _alipay_partnerID = partner;
    _alipay_seller    = seller;
    _alipay_appScheme = appScheme;
    _alipay_privateKey= private_key;

}

- (void)registerWechatAppID:(NSString *)AppID
                  partnerID:(NSString *)partnerID
                     shopID:(NSString *)shopID {
    [WXApi registerApp:AppID];
    _wechat_appID    = AppID;
    _wechat_partnerID= partnerID;
    _wechat_shopID   = shopID;
}


#pragma mark - ip
////获取ip地址
//- (NSString *)getIPAddress:(BOOL)preferIPv4 {
//    
//    NSArray *searchArray = preferIPv4 ?
//    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
//    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
//    
//    NSDictionary *addresses = [self getIPAddresses];
//    NSLog(@"addresses: %@", addresses);
//    
//    __block NSString *address;
//    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
//     {
//         address = addresses[key];
//         if(address) *stop = YES;
//     } ];
//    return address ? address : @"0.0.0.0";
//}
//
//- (NSDictionary *)getIPAddresses {
//    
//    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
//    
//    // retrieve the current interfaces - returns 0 on success
//    struct ifaddrs *interfaces;
//    if(!getifaddrs(&interfaces)) {
//        // Loop through linked list of interfaces
//        struct ifaddrs *interface;
//        for(interface=interfaces; interface; interface=interface->ifa_next) {
//            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
//                continue; // deeply nested code harder to read
//            }
//            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
//            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
//            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
//                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
//                NSString *type;
//                if(addr->sin_family == AF_INET) {
//                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
//                        type = IP_ADDR_IPv4;
//                    }
//                } else {
//                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
//                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
//                        type = IP_ADDR_IPv6;
//                    }
//                }
//                if(type) {
//                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
//                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
//                }
//            }
//        }
//        // Free memory
//        freeifaddrs(interfaces);
//    }
//    return [addresses count] ? addresses : nil;
//}
//
//- (NSString *)spbill_create_ip {
//    NSString * string;
//    string =  [self getIPAddress:YES];
//    return string;
//}

- (NSString *)fetchIPAddress {
    NSString *address = @"0.0.0.0";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (NSString *)spbill_create_ip {
    NSString * string;
    string =  [self fetchIPAddress];
    return string;
}

@end

#pragma mark - 支付宝
@implementation SNPayManager(sn_alipayPay)

- (void)sn_openTheAlipayPay:(SNAlipayResultsBlock)alipayResultsBlock {
    if (!_useNotication) {
        _alipayResultsBlock = [alipayResultsBlock copy];
    }
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = _alipay_partnerID;
    order.sellerID = _alipay_seller;
    order.outTradeNO = _order_no; //订单ID（由商家自行制定）
    order.subject = _order_name; //商品标题
    
    order.body = _order_description; //商品描述
    order.totalFee = [NSString stringWithFormat:@"%.2f",[_order_price floatValue]]; //商品价格
    order.notifyURL = _notify_url; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showURL = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = _alipay_appScheme;
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(_alipay_privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            
            NSLog(@"callback ===>> %@",resultDic);
            if ([resultDic[@"resultStatus"] integerValue] == 9000) {
                if (_useNotication) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SNPaySuccess object:self];
                } else {
                    if (_alipayResultsBlock) {
                        _alipayResultsBlock(nil);
                    }
                }
            } else {
                if (_useNotication) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SNPayFailure object:self];
                } else {
                    if (_alipayResultsBlock) {
                        _alipayResultsBlock([NSError errorWithDomain:Domain code:1 userInfo:@{NSLocalizedDescriptionKey:resultDic[@"memo"]}]);
                        
                    }
                }
            }
        }];
        
    } else {
        if (_useNotication) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SNPayFailure object:self];
        } else {
            if (_alipayResultsBlock) {
                _alipayResultsBlock([NSError errorWithDomain:Domain code:1 userInfo:@{NSLocalizedDescriptionKey:@"调起支付宝失败，请重试"}]);
            }
        }
    }
}


- (void)sn_alipayHandleOpenURL:(NSURL *)url {
    //如果极简开发包不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给开发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"openURL ===>> %@",resultDic);
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            if ([resultDic[@"resultStatus"] integerValue] == 9000) {
                if (_useNotication) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SNPaySuccess object:self];
                } else {
                    if (_alipayResultsBlock) {
                        _alipayResultsBlock(nil);
                    }
                }
            } else {
                if (_useNotication) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SNPayFailure object:self];
                } else {
                    if (_alipayResultsBlock) {
                        _alipayResultsBlock([NSError errorWithDomain:Domain code:1 userInfo:@{NSLocalizedDescriptionKey:resultDic[@"memo"]}]);
                    }
                }
            }
        }];
    }
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
        
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"openURL ===>> %@",resultDic);
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            if ([resultDic[@"resultStatus"] integerValue] == 9000) {
                if (_useNotication) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SNPaySuccess object:self];
                } else {
                    if (_alipayResultsBlock) {
                        _alipayResultsBlock(nil);
                    }
                }
            } else {
                if (_useNotication) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SNPayFailure object:self];
                } else {
                    if (_alipayResultsBlock) {
                        _alipayResultsBlock([NSError errorWithDomain:Domain code:1 userInfo:@{NSLocalizedDescriptionKey:resultDic[@"memo"]}]);
                    }
                }
            }
        }];
    }
}

@end

#pragma mark - 微信
@implementation SNPayManager(sn_wechatPay)

//测试查询订单
//- (void)sign {
//    payRequsestHandler *req = [[payRequsestHandler alloc] init];
//    //初始化支付签名对象
//    [req init:_wechat_appID mch_id:_wechat_shopID];
//    //设置密钥
//    [req setKey:_wechat_partnerID];
//    [req loadSin];
//}

- (void)sn_openTheWechatPay:(SNWechatResultsBlock)wechatResultsBlock {
    if (!_useNotication) {
        _wechatResultsBlock = [wechatResultsBlock copy];
    }
    //创建支付签名对象
    payRequsestHandler *req = [[payRequsestHandler alloc] init];
    //初始化支付签名对象
    [req init:_wechat_appID mch_id:_wechat_shopID];
    //设置密钥
    [req setKey:_wechat_partnerID];
    
    req.notify_url = _notify_url;
    req.order_name = _order_name;
    req.order_no = _order_no;
    req.order_price = [NSString stringWithFormat:@"%.f",[_order_price floatValue] * 100];
    
    req.spbill_create_ip = [self spbill_create_ip];
    
    //获取到实际调起微信支付的参数后，在app端调起支付
    
    NSMutableDictionary *dict = [req sendPay];
    
    if(dict == nil){
        //错误提示
        NSString *error = [req error];
        if (_useNotication) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SNPayFailure object:self];
        } else {
            if (_wechatResultsBlock) {
                _wechatResultsBlock([NSError errorWithDomain:Domain code:1 userInfo:@{NSLocalizedDescriptionKey:error}]);
            }
        }
//        [self alert:@"错误信息" msg:error];
        
    }else{
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        
        [WXApi sendReq:req];
    }
}


- (void)sn_wechatHandleOpenURL:(NSURL *)url {
    [WXApi handleOpenURL:url delegate:self];
}

//客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    
    [alter show];
}

- (void)onResp:(BaseResp*)resp {
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    NSString *strTitle;
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
    }
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        strTitle = [NSString stringWithFormat:@"支付结果"];
        switch (resp.errCode) {
            case WXSuccess:{
                strMsg = @"支付结果：成功！";
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                if (_useNotication) {
                    //通过通知中心发送通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:SNPaySuccess object:self];
                } else {
                    if (_wechatResultsBlock) {
                        _wechatResultsBlock(nil);
                    }
                }
            }
                break;
                
            default:
                strMsg = [NSString stringWithFormat:@"%@", @"支付不成功哦！"];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                if (_useNotication) {
                    //通过通知中心发送通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:SNPayFailure object:self];
                } else {
                    if (_wechatResultsBlock) {
                        _wechatResultsBlock([NSError errorWithDomain:Domain code:1 userInfo:@{NSLocalizedDescriptionKey:@"支付失败"}]);
                    }
                }
                break;
        }
    }
}


@end

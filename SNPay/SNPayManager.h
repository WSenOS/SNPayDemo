//
//  SNPayManager.h
//  SNPay
//
//  Created by wangsen on 16/8/20.
//  Copyright © 2016年 wangsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "payRequsestHandler.h"
#import "RSADataSigner.h"
#import "Order.h"

//使用通知回调
extern NSString * const SNPaySuccess;
extern NSString * const SNPayFailure;

//block回调
typedef void(^SNAlipayResultsBlock) (NSError * error);
typedef void(^SNWechatResultsBlock) (NSError * error);

@interface SNPayManager : NSObject <WXApiDelegate>
#pragma mark - 服务器签名 微信调起支付参数
//服务器签名 微信调起支付参数
@property (nonatomic, copy) NSString * wxPartnerId;//商户号
@property (nonatomic, copy) NSString * wxPrepayId;//预支付id
@property (nonatomic, copy) NSString * wxNonceStr;//随机字符串
@property (nonatomic, copy) NSString * wxTimeStamp;//时间戳
@property (nonatomic, copy) NSString * wxSign;//签名
#pragma mark - 支付宝参数 微信参数(本地签名)
//回调url 支付宝 微信(本地签名)
@property (nonatomic, copy) NSString * notify_url;
//订单标题，展示给用户 支付宝 微信(本地签名)
@property (nonatomic, copy) NSString * order_name;
//订单金额 支付宝 微信(本地签名)
@property (nonatomic, copy) NSString * order_price;
//订单号 订单id 支付宝 微信(本地签名)
@property (nonatomic, copy) NSString * order_no;
//商品描述 支付宝
@property (nonatomic, copy) NSString * order_description;


/**
 是否使用通知回调提示支付结果  默认不使用 NO
 */
@property (nonatomic, assign) BOOL useNotication;
/**
 获取设备ip
 */
@property (nonatomic, copy, readonly) NSString * deviceIp;

+ (instancetype)sharePayManager;

/** 注册支付宝
 * @param partner 支付宝PID
 * @param seller 支付宝账号
 * @param appScheme 应用注册scheme,在AlixPayDemo-Info.plist定义URL types
 * @param private_key 私钥 服务器签名可为空
 */
- (void)registerAlipayPatenerID:(NSString *)partner
                         seller:(NSString *)seller
                      appScheme:(NSString *)appScheme
                     privateKey:(NSString *)private_key;
/**
 注册支付宝 服务器统一下单
 @param appScheme 应用注册scheme,在AlixPayDemo-Info.plist定义URL types
 */
- (void)registerAlipayAppScheme:(NSString *)appScheme;

/** 注册微信 全部由app生成支付
 * @param appID 创建应用AppID
 * @param secretKey api密钥 登陆商户号 自己生成上传
 * @param shopID 支付能力申请返回的商户号
 */
- (void)registerWechatAppID:(NSString *)appID
                  secretKey:(NSString *)secretKey
                     shopID:(NSString *)shopID;
/**
 注册微信 服务器统一下单
 @param appID 应用appID
 */
- (void)registerWechatAppID:(NSString *)appID;

@end

#pragma mark - Alipay
@interface SNPayManager(sn_alipayPay)
//回调设置
- (void)sn_alipayHandleOpenURL:(NSURL *)url;
//调起支付
#pragma 本地签名调起支付
- (void)sn_openTheAlipayPay:(SNAlipayResultsBlock)alipayResultsBlock;
#pragma 建议服务器签名调起支付
- (void)sn_openTheAlipayOrderString:(NSString *)orderString WithServicePay:(SNAlipayResultsBlock)alipayResultsBlock;

@end

#pragma mark - Wechat
@interface SNPayManager(sn_wechatPay)
//回调设置
- (void)sn_wechatHandleOpenURL:(NSURL *)url;
//调起支付
#pragma 本地签名调起支付
- (void)sn_openTheWechatPay:(SNWechatResultsBlock)wechatResultsBlock;
#pragma 建议服务器签名调起支付
- (void)sn_openTheWechatWithServicePay:(SNWechatResultsBlock)wechatResultsBlock;

@end









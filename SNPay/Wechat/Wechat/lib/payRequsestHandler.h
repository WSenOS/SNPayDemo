

#import <Foundation/Foundation.h>
#import "WXUtil.h"
#import "ApiXml.h"

@interface payRequsestHandler : NSObject{
	//预支付网关url地址
    NSString *payUrl;

    //lash_errcode;
    long     last_errcode;
	//debug信息
    NSMutableString *debugInfo;
    NSString *appid,*mchid,*spkey;
    
    NSString * error;
}
//回调网址
@property (nonatomic, copy) NSString * notify_url;
//订单标题，展示给用户
@property (nonatomic, copy) NSString * order_name;
//订单金额,单位（分）
@property (nonatomic, copy) NSString * order_price;
//订单号
@property (nonatomic, copy) NSString * order_no;
//发起支付的设备ip
@property (nonatomic, copy) NSString * spbill_create_ip;

//初始化函数
-(BOOL) init:(NSString *)app_id mch_id:(NSString *)mch_id;
-(NSString *) getDebugifo;
-(long) getLasterrCode;
//设置商户密钥
-(void) setKey:(NSString *)key;
//创建package签名
-(NSString*) createMd5Sign:(NSMutableDictionary*)dict;
//获取package带参数的签名包
-(NSString *)genPackage:(NSMutableDictionary*)packageParams;
//提交预支付
-(NSString *)sendPrepay:(NSMutableDictionary *)prePayParams;

/**
 *  @author sen 15-06-17 17:06:13
 *
 *  @return 错误
 */
- (NSString *)error;
//签名
- ( NSMutableDictionary *)sendPay;

//- (void)loadSin;

@end

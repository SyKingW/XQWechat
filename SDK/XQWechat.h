//
//  XQWebchat.h
//  lmZigBee
//
//  Created by WXQ on 2018/1/10.
//  Copyright © 2018年 shishuzhen. All rights reserved.
//  wechat aut

#import <Foundation/Foundation.h>
#import "XQWechatHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class PayResp;

typedef void(^XQWechatSucceed)(id responseObject);
typedef void(^XQWechatFailure)(NSError *error);

typedef void(^XQWechatAuthResultCallback)(NSString *code, int errCode);

@protocol XQWebchatDelegate <NSObject>

@optional

/**
 接收到 wechat 授权消息
 
 @param code 授权 code
 @param errCode 0 成功
 */
- (void)wechatReceiveAutWithCode:(NSString *)code errCode:(int)errCode;

/**
 微信支付回调
 */
- (void)wechatReceivePayWithResp:(PayResp *)resp;

@end

@interface XQWechat : NSObject

+ (instancetype)manager;

@property (nonatomic, weak) id <XQWebchatDelegate> delegate;

/// 启动APP调用
/// @param appSecret 如果存放后台, 可不传入
///
/// @note - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 调用
///
+ (BOOL)registerWechatWithAppId:(NSString *)appId universalLink:(NSString *)universalLink appSecret:(nullable NSString *)appSecret;

/**
 处理微信通过URL启动App时传递的数据
 
 @note 需要在 appdelegate.m
 - application:app openURL:url options:options 中调用。
 */
+ (BOOL)handleOpenURLWithURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

/**
 wechat是否已下载
 
 @return NO未下载
 */
+ (BOOL)isInstalled;

#pragma mark - 基础登录功能

/**
 发送 wechat 授权信息
 
 @note 回调是 XQWebchatDelegate 的 - wechatReceiveAutWithCode:code;
 1. 跳转不到了微信问题
 要添加 scheme 白名单, wechat 和 weixin.
 
 2. 授权后, 微信回跳不了自己APP问题
 要给自己APP加上 scheme, scheme 是申请的 app id
 
 */
- (void)sendWechatAutInfo;

- (void)sendWechatAutInfoWithCallback:(XQWechatAuthResultCallback)callback;

/**
 发送 wechat 授权信息
 
 @note 回调是 XQWebchatDelegate 的 - wechatReceiveAutWithCode:code;
 
 @param viewController 控制器
 */
- (void)sendWechatAutInfoWithViewContoller:(UIViewController *)viewController;

/**
 获取wechat token
 
 unionid
 同一个微信开放平台下的相同主体的App、公众号、小程序，如果用户已经关注公众号，或者曾经登录过App或公众号，则用户打开小程序时，开发者可以直接通过wx.login获取到该用户UnionID，无须用户再次授权。
 
 openid
 同一个应用（App、公众号、小程序）的同一个用户有唯一的openid
 
 @param code 发送授权信息回的 code
 */
- (void)getWechatTokenWithCode:(NSString *)code succeed:(XQWechatSucceed)succeed failure:(XQWechatFailure)failure;

/**
 续期 token 时间

 @param refresh_token 要续期的 token
 */
- (void)refresh_tokenWithRefresh_token:(NSString *)refresh_token succeed:(XQWechatSucceed)succeed failure:(XQWechatFailure)failure;

/**
 检验 token 是否有效

 @param access_token 要检验的token
 */
- (void)checkoutTokenWithAccess_token:(NSString *)access_token openid:(NSString *)openid succeed:(XQWechatSucceed)succeed failure:(XQWechatFailure)failure;

/**
 获取用户信息
 
 @param lang 可不填(nil or @""), 国家地区语言版本，zh_CN 简体，zh_TW 繁体，en 英语，默认为zh-CN
 */
- (void)getUserinfoWithAccess_token:(NSString *)access_token openid:(NSString *)openid lang:(NSString *)lang succeed:(XQWechatSucceed)succeed failure:(XQWechatFailure)failure;


#pragma mark - 分享

/**
 分享文字

 @param content 文字内容
 */
- (void)sharedTextWithContent:(NSString *)content scene:(XQWXScene)scene;

/**
 分享图片
 
 @note 测试了..然而发什么都没用, 就填一下 imageData 和 thumbImage 就好(略缩图其实都可以不要)

 @param mediaTagName 媒体标记
 @param imageData 图片
 @param scene 发送到哪
 */
- (void)sharedImageWithImageData:(NSData *)imageData mediaTagName:(NSString *)mediaTagName scene:(XQWXScene)scene;

/**
 分享网页
 
 @param title 标题
 @param description 描述
 @param thumbImage 略缩图
 @param webpageUrl 分享网页
 */
- (void)sharedWebpageWithTitle:(NSString *)title description:(NSString *)description mediaTagName:(NSString *)mediaTagName thumbImage:(UIImage *)thumbImage webpageUrl:(NSString *)webpageUrl scene:(XQWXScene)scene;

@end


NS_ASSUME_NONNULL_END

















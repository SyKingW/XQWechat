//
//  XQWebchat.m
//  lmZigBee
//
//  Created by WXQ on 2018/1/10.
//  Copyright © 2018年 shishuzhen. All rights reserved.
//

#import "XQWechat.h"
#import <WechatOpenSDK/WXApi.h>

/**
 微信扫描登录
 可看这个类 WechatAuthSDK
 */

@interface XQWechat () <WXApiDelegate>

/// <#note#>
@property (nonatomic, copy) NSString *appId;
/// <#note#>
@property (nonatomic, copy) NSString *universalLink;
/// <#note#>
@property (nonatomic, copy) NSString *appSecret;

/// <#note#>
@property (nonatomic, copy) XQWechatAuthResultCallback authCallback;

@end

@implementation XQWechat

+ (instancetype)manager {
    static XQWechat *manager_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager_ = [XQWechat new];
    });
    return manager_;
}

// 注册wecaht sdk
+ (BOOL)registerWechatWithAppId:(NSString *)appId universalLink:(NSString *)universalLink appSecret:(nullable NSString *)appSecret {
    [XQWechat manager].appId = appId;
    [XQWechat manager].universalLink = universalLink;
    [XQWechat manager].appSecret = appSecret;
    return [WXApi registerApp:appId universalLink:universalLink];
}

// openURL 时告诉 wechat sdk
+ (BOOL)handleOpenURLWithURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [WXApi handleOpenURL:url delegate:[self manager]];
}

// 是否能够打开微信 and 微信是否支持使用wxapi
+ (BOOL)isInstalled {
    return [WXApi isWXAppInstalled];
}

+ (void)setAppID:(NSString *)appID {
    if (!appID) {
        appID = [XQWechat manager].appId;
    }
    [[NSUserDefaults standardUserDefaults] setObject:appID forKey:@"xq_wx_appid"];
}

+ (NSString *)appID {
    NSString *appId = [[NSUserDefaults standardUserDefaults] stringForKey:@"xq_wx_appid"];
    if (!appId) {
        return [XQWechat manager].appId;
    }
    return appId;
}

+ (void)setAppSecret:(NSString *)appSecret {
    if (!appSecret) {
        appSecret = self.appSecret;
    }
    [[NSUserDefaults standardUserDefaults] setObject:appSecret forKey:@"xq_wx_appSecret"];
}

+ (NSString *)appSecret {
    NSString *appSecret = [[NSUserDefaults standardUserDefaults] stringForKey:@"xq_wx_appSecret"];
    if (!appSecret) {
        return self.appSecret;
    }
    return appSecret;
}

#pragma mark - 分享

// 分享文字
- (void)sharedTextWithContent:(NSString *)content scene:(XQWXScene)scene {
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = YES;
    req.text = content;
    req.scene = (int)scene;
    [WXApi sendReq:req completion:^(BOOL success) {
        
    }];
}

// 分享图片
- (void)sharedImageWithImageData:(NSData *)imageData mediaTagName:(NSString *)mediaTagName scene:(XQWXScene)scene {
    
    WXMediaMessage *mediaMessage = [WXMediaMessage message];
    mediaMessage.messageExt = @"这个是 messageExt";
    mediaMessage.messageAction = @"这个是 messageAction";
    
    WXImageObject *imgObj = [WXImageObject object];
    imgObj.imageData = imageData;
    mediaMessage.mediaObject = imgObj;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.scene = (int)scene;
    req.message = mediaMessage;
    [WXApi sendReq:req completion:^(BOOL success) {
        
    }];
}

// 分享网页
- (void)sharedWebpageWithTitle:(NSString *)title description:(NSString *)description mediaTagName:(NSString *)mediaTagName thumbImage:(UIImage *)thumbImage webpageUrl:(NSString *)webpageUrl scene:(XQWXScene)scene {
    
    WXMediaMessage *mediaMessage = [WXMediaMessage message];
    mediaMessage.title = title;
    mediaMessage.description = description;
    mediaMessage.mediaTagName = mediaTagName;
    mediaMessage.messageExt = @"这个是 messageExt";
    mediaMessage.messageAction = @"这个是 messageAction";
    [mediaMessage setThumbImage:thumbImage];
    
    WXWebpageObject *imgObj = [WXWebpageObject object];
    imgObj.webpageUrl = webpageUrl;
    mediaMessage.mediaObject = imgObj;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.text = title;
    req.scene = (int)scene;
    req.message = mediaMessage;
    [WXApi sendReq:req completion:^(BOOL success) {
        
    }];
}

#pragma mark - 授权

// 发送wechat授权信息
- (void)sendWechatAutInfo {
    if (![XQWechat isInstalled]) {
        [self authFalire];
        return;
    }
    
    
    SendAuthReq* req = [[SendAuthReq alloc] init];
//    req.scope = @"snsapi_userinfo,snsapi_base" ;
    req.scope = @"snsapi_userinfo";
    // 用于保持请求和回调的状态，授权请求或原样带回
    req.state = @"xq_wf_wechatAut";
    [WXApi sendReq:req completion:^(BOOL success) {
        if (!success) {
            [self authFalire];
        }
    }];
}

- (void)sendWechatAutInfoWithCallback:(XQWechatAuthResultCallback)callback {
    self.authCallback = callback;
    [self sendWechatAutInfo];
}

- (void)authFalire {
    if (self.authCallback) {
        self.authCallback(@"", WXErrCodeCommon);
        self.authCallback = nil;
    }
}

// 发送wechat授权信息
- (void)sendWechatAutInfoWithViewContoller:(UIViewController *)viewController {
    if (![XQWechat isInstalled]) {
        return;
    }
    
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    //用于保持请求和回调的状态，授权请求或原样带回
    req.state = @"xq_wf_wechatAut";
    [WXApi sendAuthReq:req viewController:viewController delegate:self completion:^(BOOL success) {
        
    }];
}

#pragma mark - request

// 通过微信返回的code, 获取用户wechat信息
- (void)getWechatTokenWithCode:(NSString *)code succeed:(XQWechatSucceed)succeed failure:(XQWechatFailure)failure {
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", self.appId, self.appSecret,code];
    [self get:url success:succeed failure:failure];
}

// 刷新 token 时间
- (void)refresh_tokenWithRefresh_token:(NSString *)refresh_token succeed:(XQWechatSucceed)succeed failure:(XQWechatFailure)failure {
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", self.appId, refresh_token];
    [self get:url success:succeed failure:failure];
}

// 检验 token 是否有效
- (void)checkoutTokenWithAccess_token:(NSString *)access_token openid:(NSString *)openid succeed:(XQWechatSucceed)succeed failure:(XQWechatFailure)failure {
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/auth?access_token=%@&openid=%@", access_token, openid];
    [self get:url success:succeed failure:failure];
}

// 获取用户信息
- (void)getUserinfoWithAccess_token:(NSString *)access_token openid:(NSString *)openid lang:(NSString *)lang succeed:(XQWechatSucceed)succeed failure:(XQWechatFailure)failure {
    NSString *url = nil;
    if (lang.length != 0) {
        url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@&lang=%@", access_token, openid, lang];
    }else {
        url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", access_token, openid];
    }
    
    [self get:url success:succeed failure:failure];
}


/**
 基础 get 请求
 */
- (NSURLSessionDataTask *)get:(NSString *)urlStr success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"Get";
    
    // 设置 header
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{}
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:nil];
//    request.HTTPBody = jsonData;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        } else {
            NSError *e = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            if (e) {
                NSLog(@"解析data失败: %@", e);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                success(dict);
            });
        }
        
    }];
    
    [dataTask resume];
    return dataTask;
}

#pragma mark -- WXApiDelegate

/// 收到wechat请求
- (void)onReq:(BaseReq *)req {
    NSLog(@"%@", req);
}

/// 收到wechat回应
- (void)onResp:(BaseResp *)resp {
    NSLog(@"%s, %@", __func__, resp);
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        // 是认证回调
        // 强转获取code
        SendAuthResp *authResp = (SendAuthResp *)resp;
        NSString *code = authResp.code;
        if ([self.delegate respondsToSelector:@selector(wechatReceiveAutWithCode:errCode:)]) {
            [self.delegate wechatReceiveAutWithCode:code errCode:resp.errCode];
        }
        
        if (self.authCallback) {
            self.authCallback(code, resp.errCode);
            self.authCallback = nil;
        }
        
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        
        NSLog(@"错误码: %d, %@", resp.errCode, resp.errStr);
        
    }else if ([resp isKindOfClass:[PayResp class]]) {
        
        // 支付
        if ([self.delegate respondsToSelector:@selector(wechatReceivePayWithResp:)]) {
            [self.delegate wechatReceivePayWithResp:(PayResp *)resp];
        }
        
    }
    
}

@end
















